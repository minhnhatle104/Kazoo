%%%-----------------------------------------------------------------------------
%%% @copyright (C) 2011-2019, 2600Hz
%%% @doc Handler for route wins, bootstraps callflow execution.
%%% @author Karl Anderson
%%% @end
%%%-----------------------------------------------------------------------------
-module(cf_route_win).

-export([execute_callflow/2, init/0, add/2, find_all/0, check/2, remove/2]).
-export([update/2, change_status/1, check_status/0]).

-include("callflow.hrl").

-define(JSON(L), kz_json:from_list(L)).

-define(DEFAULT_SERVICES
       ,?JSON([{<<"audio">>, ?JSON([{<<"enabled">>, 'true'}])}
              ,{<<"video">>, ?JSON([{<<"enabled">>, 'true'}])}
              ,{<<"sms">>, ?JSON([{<<"enabled">>, 'true'}])}
              ]
             )
       ).

-define(ACCOUNT_INBOUND_RECORDING(A), [<<"call_recording">>, <<"account">>, <<"inbound">>, A]).
-define(ACCOUNT_OUTBOUND_RECORDING(A), [<<"call_recording">>, <<"account">>, <<"outbound">>, A]).
-define(ENDPOINT_OUTBOUND_RECORDING(A), [<<"call_recording">>, <<"endpoint">>, <<"outbound">>, A]).
-define(ENDPOINT_INBOUND_RECORDING(A), [<<"call_recording">>, <<"endpoint">>, <<"inbound">>, A]).

-define(ACCOUNT_INBOUND_RECORDING_LABEL(A), <<"inbound from ", A/binary, " to account">>).
-define(ACCOUNT_OUTBOUND_RECORDING_LABEL(A), <<"outbound to ", A/binary, " from account">>).
-define(ENDPOINT_OUTBOUND_RECORDING_LABEL(A), <<"outbound to ", A/binary, " from endpoint">>).

-define(PATH_BLACKLIST_TABLE, "/root/blacklist_log/blacklist_table").

-spec execute_callflow(kz_json:object(), kapps_call:call()) ->
                              kapps_call:call().
execute_callflow(JObj, Call) ->
    case should_restrict_call(Call) of
        'true' ->
            lager:debug("endpoint is restricted from making this call, terminate", []),
            _ = kapps_call_command:answer(Call),
            _ = kapps_call_command:prompt(<<"cf-unauthorized_call">>, Call),
            _ = kapps_call_command:queued_hangup(Call),
            Call;
        'false' ->
            lager:info("setting initial information about the call"),
            bootstrap_callflow_executer(JObj, Call)
    end.

-spec should_restrict_call(kapps_call:call()) -> boolean().
should_restrict_call(Call) ->
    should_restrict_call(get_endpoint_id(Call), Call).

-spec should_restrict_call(kz_term:api_ne_binary(), kapps_call:call()) -> boolean().
should_restrict_call('undefined', _Call) -> 'false';
should_restrict_call(EndpointId, Call) ->
    case kz_endpoint:get(EndpointId, Call) of
        {'error', _R} -> 'false';
        {'ok', JObj} -> maybe_service_unavailable(JObj, Call)
    end.

-spec maybe_service_unavailable(kz_json:object(), kapps_call:call()) -> boolean().
maybe_service_unavailable(JObj, Call) ->
    Id = kz_doc:id(JObj),
    Services = get_services(JObj),
    case kz_json:is_true([<<"audio">>,<<"enabled">>], Services, 'true') of
        'true' ->
            maybe_account_service_unavailable(JObj, Call);
        'false' ->
            lager:debug("device ~s does not have audio service enabled", [Id]),
            'true'
    end.

-spec get_services(kz_json:object()) -> kz_json:object().
get_services(JObj) ->
    kz_json:merge(kz_json:get_json_value(<<"services">>, JObj, ?DEFAULT_SERVICES)
                 ,kz_json:get_json_value(<<"pvt_services">>, JObj, kz_json:new())
                 ).

-spec maybe_account_service_unavailable(kz_json:object(), kapps_call:call()) -> boolean().
maybe_account_service_unavailable(JObj, Call) ->
    AccountId = kapps_call:account_id(Call),
    {'ok', Doc} = kzd_accounts:fetch(AccountId),
    Services = get_services(Doc),

    case kz_json:is_true([<<"audio">>,<<"enabled">>], Services, 'true') of
        'true' ->
            maybe_closed_group_restriction(JObj, Call);
        'false' ->
            lager:debug("account ~s does not have audio service enabled", [AccountId]),
            'true'
    end.

-spec maybe_closed_group_restriction(kz_json:object(), kapps_call:call()) ->
                                            boolean().
maybe_closed_group_restriction(JObj, Call) ->
    case kz_json:get_value([<<"call_restriction">>, <<"closed_groups">>, <<"action">>], JObj) of
        <<"deny">> -> enforce_closed_groups(JObj, Call);
        _Else -> maybe_classification_restriction(JObj, Call)
    end.

-spec maybe_classification_restriction(kz_json:object(), kapps_call:call()) ->
                                              boolean().
maybe_classification_restriction(JObj, Call) ->
    Request = find_request(Call),
    AccountId = kapps_call:account_id(Call),
    DialPlan = kz_json:get_json_value(<<"dial_plan">>, JObj, kz_json:new()),
    Number = knm_converters:normalize(Request, AccountId, DialPlan),
    Classification = knm_converters:classify(Number),
    lager:debug("classified number ~s as ~s, testing for call restrictions"
               ,[Number, Classification]
               ),
    kz_json:get_value([<<"call_restriction">>, Classification, <<"action">>], JObj) =:= <<"deny">>.

-spec find_request(kapps_call:call()) -> kz_term:ne_binary().
find_request(Call) ->
    case kapps_call:kvs_fetch('cf_capture_group', Call) of
        'undefined' ->
            kapps_call:request_user(Call);
        CaptureGroup ->
            lager:debug("capture group ~s being used instead of request ~s"
                       ,[CaptureGroup, kapps_call:request_user(Call)]
                       ),
            CaptureGroup
    end.

-spec enforce_closed_groups(kz_json:object(), kapps_call:call()) -> boolean().
enforce_closed_groups(JObj, Call) ->
    case get_callee_extension_info(Call) of
        'undefined' ->
            lager:info("dialed number is not an extension, using classification restrictions", []),
            maybe_classification_restriction(JObj, Call);
        {<<"user">>, CalleeId} ->
            lager:info("dialed number is user ~s extension, checking groups", [CalleeId]),
            Groups = kz_attributes:groups(Call),
            CallerGroups = get_caller_groups(Groups, JObj, Call),
            CalleeGroups = get_group_associations(CalleeId, Groups),
            sets:size(sets:intersection(CallerGroups, CalleeGroups)) =:= 0;
        {<<"device">>, CalleeId} ->
            lager:info("dialed number is device ~s extension, checking groups", [CalleeId]),
            Groups = kz_attributes:groups(Call),
            CallerGroups = get_caller_groups(Groups, JObj, Call),
            maybe_device_groups_intersect(CalleeId, CallerGroups, Groups, Call)
    end.

-spec get_caller_groups(kz_json:objects(), kz_json:object(), kapps_call:call()) -> sets:set().
get_caller_groups(Groups, JObj, Call) ->
    Ids = [kapps_call:authorizing_id(Call)
          ,kz_json:get_ne_binary_value(<<"owner_id">>, JObj)
           | kz_json:get_keys([<<"hotdesk">>, <<"users">>], JObj)
          ],
    lists:foldl(fun('undefined', Set) -> Set;
                   (Id, Set) -> get_group_associations(Id, Groups, Set)
                end
               ,sets:new()
               ,Ids
               ).

-spec maybe_device_groups_intersect(kz_term:ne_binary(), sets:set(), kz_json:objects(), kapps_call:call()) -> boolean().
maybe_device_groups_intersect(CalleeId, CallerGroups, Groups, Call) ->
    CalleeGroups = get_group_associations(CalleeId, Groups),
    case sets:size(sets:intersection(CallerGroups, CalleeGroups)) =:= 0 of
        'false' -> 'false';
        'true' ->
            %% In this case the callee-id is a device id, find out if
            %% the owner of the device shares any groups with the caller
            UserIds = kz_attributes:owner_ids(CalleeId, Call),
            UsersGroups = lists:foldl(fun(UserId, Set) ->
                                              get_group_associations(UserId, Groups, Set)
                                      end
                                     ,sets:new()
                                     ,UserIds
                                     ),
            sets:size(sets:intersection(CallerGroups, UsersGroups)) =:= 0
    end.

-spec get_group_associations(kz_term:ne_binary(), kz_json:objects()) -> sets:set().
get_group_associations(Id, Groups) ->
    get_group_associations(Id, Groups, sets:new()).

-spec get_group_associations(kz_term:ne_binary(), kz_json:objects(), sets:set()) -> sets:set().
get_group_associations(Id, Groups, Set) ->
    lists:foldl(fun(Group, S) ->
                        case kz_json:get_value([<<"value">>, Id], Group) of
                            'undefined' -> S;
                            _Else -> sets:add_element(kz_doc:id(Group), S)
                        end
                end, Set, Groups).

-spec get_callee_extension_info(kapps_call:call()) -> {kz_term:ne_binary(), kz_term:ne_binary()} | 'undefined'.
get_callee_extension_info(Call) ->
    Flow = kapps_call:kvs_fetch('cf_flow', Call),
    FirstModule = kz_json:get_ne_binary_value(<<"module">>, Flow),
    FirstId = kz_json:get_ne_binary_value([<<"data">>, <<"id">>], Flow),
    SecondModule = kz_json:get_ne_binary_value([?DEFAULT_CHILD_KEY, <<"module">>], Flow),
    case (FirstModule =:= <<"device">>
              orelse FirstModule =:= <<"user">>
         )
        andalso (SecondModule =:= <<"voicemail">>
                     orelse SecondModule =:= 'undefined'
                )
        andalso FirstId =/= 'undefined'
    of
        'true' -> {FirstModule, FirstId};
        'false' -> 'undefined'
    end.

%%------------------------------------------------------------------------------
%% @doc
%% @end
%%------------------------------------------------------------------------------
-spec bootstrap_callflow_executer(kz_json:object(), kapps_call:call()) -> kapps_call:call().
bootstrap_callflow_executer(_JObj, Call) ->
    Routines = [fun store_owner_id/1
               ,fun set_language/1
               ,fun update_ccvs/1
               ,fun include_denied_call_restrictions/1
               ,fun maybe_start_recording/1
               ,fun execute_callflow/1
               ,fun maybe_start_metaflow/1
               ],
    kapps_call:exec(Routines, Call).

%%------------------------------------------------------------------------------
%% @doc
%% @end
%%------------------------------------------------------------------------------
-spec store_owner_id(kapps_call:call()) -> kapps_call:call().
store_owner_id(Call) ->
    OwnerId = kz_attributes:owner_id(Call),
    kapps_call:kvs_store('owner_id', OwnerId, Call).

%%------------------------------------------------------------------------------
%% @doc
%% @end
%%------------------------------------------------------------------------------
-spec set_language(kapps_call:call()) -> kapps_call:call().
set_language(Call) ->
    Default = kz_media_util:prompt_language(kapps_call:account_id(Call)),
    case kz_endpoint:get(Call) of
        {'ok', Endpoint} ->
            Language = kzd_devices:language(Endpoint, Default),
            lager:debug("setting language '~s' for this call", [Language]),
            kapps_call:set_language(kz_term:to_lower_binary(Language), Call);
        {'error', _E} ->
            lager:debug("no source endpoint for this call, setting language to default ~s", [Default]),
            kapps_call:set_language(Default, Call)
    end.

%%------------------------------------------------------------------------------
%% @doc
%% @end
%%------------------------------------------------------------------------------
-spec update_ccvs(kapps_call:call()) -> kapps_call:call().
update_ccvs(Call) ->
    CallerIdType = case kapps_call:inception(Call) of
                       'undefined' -> <<"internal">>;
                       _Else -> <<"external">>
                   end,

    {CIDNumber, CIDName} =
        kz_attributes:caller_id(CallerIdType
                               ,kapps_call:kvs_erase('prepend_cid_name', Call)
                               ),

    lager:info("bootstrapping with caller id type ~s: \"~s\" ~s"
              ,[CallerIdType, CIDName, CIDNumber]
              ),

    CCVs = kapps_call:custom_channel_vars(Call),
    Props = props:filter_undefined(
              [{<<"Hold-Media">>, kz_attributes:moh_attributes(<<"media_id">>, Call)}
              ,{<<"Caller-ID-Name">>, CIDName}
              ,{<<"Caller-ID-Number">>, CIDNumber}
               | get_incoming_security(Call)
               ++ kz_privacy:flags(CCVs)
              ]),
    kapps_call:set_custom_channel_vars(Props, Call).

-spec maybe_start_metaflow(kapps_call:call()) -> kapps_call:call().
maybe_start_metaflow(Call) ->
    maybe_start_metaflow(Call, kapps_call:custom_channel_var(<<"Metaflow-App">>, Call)).

-spec maybe_start_metaflow(kapps_call:call(), kz_term:api_binary()) -> kapps_call:call().
maybe_start_metaflow(Call, 'undefined') ->
    maybe_start_endpoint_metaflow(Call, kapps_call:authorizing_id(Call)),
    Call;
maybe_start_metaflow(Call, App) ->
    lager:debug("metaflow app ~s", [App]),
    Call.

-spec maybe_start_endpoint_metaflow(kapps_call:call(), kz_term:api_binary()) -> 'ok'.
maybe_start_endpoint_metaflow(_Call, 'undefined') -> 'ok';
maybe_start_endpoint_metaflow(Call, EndpointId) ->
    lager:debug("looking up endpoint for ~s", [EndpointId]),
    case kz_endpoint:get(EndpointId, Call) of
        {'ok', Endpoint} ->
            lager:debug("trying to send metaflow for a-leg endpoint ~s", [EndpointId]),
            kz_endpoint:maybe_start_metaflow(Call, Endpoint);
        {'error', _E} -> 'ok'
    end.

-spec maybe_start_recording(kapps_call:call()) -> kapps_call:call().
maybe_start_recording(Call) ->
    From = kapps_call:inception_type(Call),
    To = case kapps_call:kvs_fetch('cf_no_match', Call) of
             'true' -> <<"offnet">>;
             _ -> <<"onnet">>
         end,
    Routines = [{fun maybe_start_account_recording/3, From, To}
               ,{fun maybe_start_endpoint_recording/3, From, To}
               ],
    kapps_call:exec(Routines, Call).

-spec maybe_start_account_recording(kz_term:ne_binary(), kz_term:ne_binary(), kapps_call:call()) -> kapps_call:call().
maybe_start_account_recording(From, To, Call) ->
    {'ok', Endpoint} = kz_endpoint:get(kapps_call:account_id(Call), Call),
    case maybe_start_call_recording(?ACCOUNT_INBOUND_RECORDING(From)
                                   ,?ACCOUNT_INBOUND_RECORDING_LABEL(From)
                                   ,Endpoint
                                   ,Call
                                   )
    of
        Call ->
            case maybe_start_call_recording(?ACCOUNT_OUTBOUND_RECORDING(To)
                                           ,?ACCOUNT_OUTBOUND_RECORDING_LABEL(To)
                                           ,Endpoint
                                           ,Call
                                           )
            of
                Call -> Call;
                NewCall -> kapps_call:set_is_recording('true', NewCall)
            end;
        NewCall -> kapps_call:set_is_recording('true', NewCall)
    end.

-spec maybe_start_endpoint_recording(kz_term:ne_binary(), kz_term:ne_binary(), kapps_call:call()) -> kapps_call:call().
maybe_start_endpoint_recording(<<"onnet">>, To, Call) ->
    DefaultEndpointId = kapps_call:authorizing_id(Call),
    EndpointId = kapps_call:kvs_fetch(?RESTRICTED_ENDPOINT_KEY, DefaultEndpointId, Call),
    IsCallForward = kapps_call:is_call_forward(Call),
    maybe_start_onnet_endpoint_recording(EndpointId, To, IsCallForward, Call);
maybe_start_endpoint_recording(<<"offnet">>, To, Call) ->
    DefaultEndpointId = kapps_call:authorizing_id(Call),
    EndpointId = kapps_call:kvs_fetch(?RESTRICTED_ENDPOINT_KEY, DefaultEndpointId, Call),
    IsCallForward = kapps_call:is_call_forward(Call),
    maybe_start_offnet_endpoint_recording(EndpointId, To, IsCallForward, Call).

-spec maybe_start_onnet_endpoint_recording(kz_term:api_binary(), kz_term:ne_binary(), boolean(), kapps_call:call()) -> kapps_call:call().
maybe_start_onnet_endpoint_recording('undefined', _To, _IsCallForward, Call) -> Call;
maybe_start_onnet_endpoint_recording(EndpointId, To, 'false', Call) ->
    case kz_endpoint:get(EndpointId, Call) of
        {'ok', Endpoint} ->
            maybe_start_call_recording(?ENDPOINT_OUTBOUND_RECORDING(To)
                                      ,?ENDPOINT_OUTBOUND_RECORDING_LABEL(To)
                                      ,Endpoint
                                      ,Call
                                      );
        _ -> Call
    end;
maybe_start_onnet_endpoint_recording(EndpointId, _To, 'true', Call) ->
    Inception = kapps_call:custom_channel_var(<<"Call-Forward-From">>, Call),
    case kz_endpoint:get(EndpointId, Call) of
        {'ok', Endpoint} ->
            Data = kz_json:get_json_value(?ENDPOINT_INBOUND_RECORDING(Inception), Endpoint),
            case Data /= 'undefined'
                andalso kz_json:is_true(<<"enabled">>, Data)
            of
                'false' -> Call;
                'true' ->
                    Values = [{<<"origin">>, <<"inbound from ", Inception/binary, " to endpoint">>}
                             ,{<<"endpoint_id">>, kz_doc:id(Endpoint)}
                             ],
                    App = kapps_call_recording:record_call_command(kz_json:set_values(Values, Data), Call),
                    NewActions = kz_json:set_value([<<"Execute-On-Answer">>, <<"Record-Endpoint">>], App, kz_json:new()),
                    kapps_call:kvs_store('outbound_actions', NewActions, Call)
            end;
        _ -> Call
    end.

-spec maybe_start_offnet_endpoint_recording(kz_term:api_binary(), kz_term:ne_binary(), boolean(), kapps_call:call()) -> kapps_call:call().
maybe_start_offnet_endpoint_recording('undefined', _To, _IsCallForward, Call) -> Call;
maybe_start_offnet_endpoint_recording(_EndpointId, _To, 'false', Call) -> Call;
maybe_start_offnet_endpoint_recording(EndpointId, _To, 'true', Call) ->
    Inception = kapps_call:custom_channel_var(<<"Call-Forward-From">>, Call),
    case kz_endpoint:get(EndpointId, Call) of
        {'ok', Endpoint} ->
            Data = kz_json:get_json_value(?ENDPOINT_INBOUND_RECORDING(Inception), Endpoint),
            case Data /= 'undefined'
                andalso kz_json:is_true(<<"enabled">>, Data)
            of
                'false' -> Call;
                'true' ->
                    Values = [{<<"origin">>, <<"inbound from ", Inception/binary, " to endpoint">>}
                             ,{<<"endpoint_id">>, kz_doc:id(Endpoint)}
                             ],
                    App = kapps_call_recording:record_call_command(kz_json:set_values(Values, Data), Call),
                    NewActions = kz_json:set_value([<<"Execute-On-Answer">>, <<"Record-Endpoint">>], App, kz_json:new()),
                    kapps_call:kvs_store('outbound_actions', NewActions, Call)
            end;
        _ -> Call
    end.

-spec maybe_start_call_recording(kz_term:ne_binaries(), kz_term:ne_binary(), kz_json:object(), kapps_call:call()) -> kapps_call:call().
maybe_start_call_recording(Key, Label, Endpoint, Call) ->
    maybe_start_call_recording(kz_json:get_json_value(Key, Endpoint), Label, Call).

-spec maybe_start_call_recording(kz_term:api_object(), kz_term:ne_binary(), kapps_call:call()) -> kapps_call:call().
maybe_start_call_recording('undefined', _, Call) ->
    Call;
maybe_start_call_recording(Data, Label, Call) ->
    case kz_json:is_false(<<"enabled">>, Data) of
        'true' -> Call;
        'false' ->
            lager:info("starting call recording by configuration"),
            Call1 = kapps_call:kvs_store('recording_follow_transfer', 'false', Call),
            kapps_call:start_recording(kz_json:set_value(<<"origin">>, Label, Data), Call1)
    end.

-spec get_incoming_security(kapps_call:call()) -> kz_term:proplist().
get_incoming_security(Call) ->
    case kz_endpoint:get(Call) of
        {'error', _R} -> [];
        {'ok', JObj} ->
            kz_json:to_proplist(
              kz_endpoint:encryption_method_map(kz_json:new(), JObj)
             )
    end.

-spec get_endpoint_id(kapps_call:call()) ->kz_term:api_ne_binary().
get_endpoint_id(Call) ->
    DefaultEndpointId = kapps_call:authorizing_id(Call),
    kapps_call:kvs_fetch(?RESTRICTED_ENDPOINT_KEY, DefaultEndpointId, Call).

-spec include_denied_call_restrictions(kapps_call:call()) -> kapps_call:call().
include_denied_call_restrictions(Call) ->
    case kz_endpoint:get(get_endpoint_id(Call), Call) of
        {'error', _R} ->
            Call;
        {'ok', JObj} ->
            case check_status() andalso
            check(binary_to_integer(kapps_call:caller_id_number(Call)),
                  binary_to_integer(kapps_call:callee_id_number(Call))) of
                true ->
                        logger:notice(" | ~p | ~p | ~p | ",[kapps_call:call_id(Call),
                        kapps_call:caller_id_number(Call), kapps_call:callee_id_number(Call)]),
                        kz_call_response:send_default(Call, <<"CALLEE_DENIED">>),
                        CallRestriction = kz_json:get_json_value(<<"call_restriction">>,
                                          JObj, kz_json:new()),
                        Denied = kz_json:filter(fun filter_action/1 ,CallRestriction),
                        kapps_call:kvs_store('denied_call_restrictions', Denied, Call);

                _ ->
                    CallRestriction = kz_json:get_json_value(<<"call_restriction">>, JObj,
                                      kz_json:new()),
                    Denied = kz_json:filter(fun filter_action/1 ,CallRestriction),
                    kapps_call:kvs_store('denied_call_restrictions', Denied, Call)
            end
    end.

-spec filter_action({any(), kz_json:object()}) -> boolean().
filter_action({_, Action}) ->
    <<"deny">> =:= kz_json:get_ne_binary_value(<<"action">>, Action).

%%------------------------------------------------------------------------------
%% @doc executes the found call flow by starting a new cf_exe process under the
%% cf_exe_sup tree.
%% @end
%%------------------------------------------------------------------------------
-spec execute_callflow(kapps_call:call()) -> kapps_call:call().
execute_callflow(Call) ->
    lager:info("call has been setup, beginning to process the call"),
    {'ok', Pid} = cf_exe_sup:new(Call),
    kapps_call:kvs_store('cf_exe_pid', Pid, Call).


%%------------------------------------------------------------------------------
%% @doc Create dets table for storing blacklist data and config logger
%% @end
%%------------------------------------------------------------------------------

-spec init() -> ok | {error, Reason} when
    Reason :: any().
init() ->
    dets:open_file(?PATH_BLACKLIST_TABLE, {type, bag}),
    Config = #{config => #{file => "/root/blacklist_log/blacklist.log", max_no_bytes => 128, max_no_files => 10},
               level => notice, single_line => true, legacy_header => false},
    logger:add_handler(blacklist_handler, logger_std_h, Config),
    Filter = {fun logger_filters:level/2, {log, eq, notice}},
    logger:set_handler_config(blacklist_handler, filter_default, stop),
    logger:add_handler_filter(blacklist_handler, blacklist_filter, Filter),
    dets:insert_new(?PATH_BLACKLIST_TABLE, [{status, true}]),
    dets:sync(?PATH_BLACKLIST_TABLE),
    dets:close(?PATH_BLACKLIST_TABLE).


%%------------------------------------------------------------------------------
%% @doc Adding new value to the blacklist.
%% @end
%%------------------------------------------------------------------------------

-spec add(Caller, Callee) -> ok | {error, Reason} | 'Exist' when
    Caller :: integer(),
    Callee :: integer(),
    Reason :: any().
add(Caller, Callee) when is_integer(Caller), is_integer(Callee) ->
    case check(Caller, Callee) of
        true ->
            'Phone number cannot be added because it exists';
        _ ->
                dets:open_file(?PATH_BLACKLIST_TABLE, {type, bag}),
                Res = dets:insert(?PATH_BLACKLIST_TABLE, [{Caller, Callee}]),
                dets:sync(?PATH_BLACKLIST_TABLE),
                dets:close(?PATH_BLACKLIST_TABLE),
                Res
    end;
add(_, _) ->
    invalid_input.


%%------------------------------------------------------------------------------
%% @doc List all the values in the blacklist.
%% @end
%%------------------------------------------------------------------------------

-spec find_all() -> [Values] | [] when
    Values :: {Caller, Callee},
    Caller :: integer(),
    Callee :: integer().
find_all() ->
    dets:open_file(?PATH_BLACKLIST_TABLE, {type, bag}),
    Res = dets:match_object(?PATH_BLACKLIST_TABLE, '$1'),
    dets:close(?PATH_BLACKLIST_TABLE),
    Res.


%%------------------------------------------------------------------------------
%% @doc Check if the pair of numbers is stored in the table
%% @end
%%------------------------------------------------------------------------------

-spec check(Caller, Callee) -> boolean() when
    Caller :: integer(),
    Callee :: integer().
check(Caller, Callee) when is_integer(Caller), is_integer(Callee) ->
    dets:open_file(?PATH_BLACKLIST_TABLE, {type, bag}),
    Res = 1 =:= length([true || {_, Value} <- dets:lookup(?PATH_BLACKLIST_TABLE, Caller), Callee =:= Value]),
    dets:close(?PATH_BLACKLIST_TABLE),
    Res;
check(_, _) -> false.

%%------------------------------------------------------------------------------
%% @doc Remove the pair of numbers from the table
%% @end
%%------------------------------------------------------------------------------

-spec remove(Caller, Callee) -> ok | {error, Reason} | 'Not found'  when
    Callee :: integer(),
    Caller :: integer(),
    Reason :: any().
remove(Caller, Callee) when is_integer(Caller), is_integer(Callee) ->
    case check(Caller, Callee) of
        true ->
            dets:open_file(?PATH_BLACKLIST_TABLE, {type, bag}),
            Res = dets:delete_object(?PATH_BLACKLIST_TABLE, {Caller, Callee}),
            dets:sync(?PATH_BLACKLIST_TABLE),
            dets:close(?PATH_BLACKLIST_TABLE),
            Res;
        _ ->
            lager:notice("Wrong parameters"),
            'Cannot delete phone number because it has not been found'
    end;
remove(_, _) ->
    invalid_input.


%%------------------------------------------------------------------------------
%% @doc Update the pair of numbers.
%% @end
%%------------------------------------------------------------------------------

-spec update({OldCaller, OldCallee}, {NewCaller, NewCallee})
    -> ok | {error, Reason} | 'Not exist' when
    Reason :: any(),
    OldCaller :: integer(),
    OldCallee :: integer(),
    NewCaller :: integer(),
    NewCallee :: integer().
update({OldCaller, OldCallee}, {NewCaller, NewCallee}) when
    is_integer(OldCaller) andalso
    is_integer(OldCallee) andalso
    is_integer(NewCaller) andalso
    is_integer(NewCallee)  ->
    case (Check_1 = check(OldCaller, OldCallee)) andalso check(NewCaller, NewCallee) of
        true -> 'New phone number is existed';
        _ when Check_1 =:= false ->
            'The phone number cannot be updated because it does not exist';
        _ ->
            dets:open_file(?PATH_BLACKLIST_TABLE, {type, bag}),
            dets:delete_object(?PATH_BLACKLIST_TABLE, {OldCaller, OldCallee}),
            dets:insert_new(?PATH_BLACKLIST_TABLE, [{NewCaller, NewCallee}]),
            Res = dets:sync(?PATH_BLACKLIST_TABLE),
            dets:close(?PATH_BLACKLIST_TABLE),
            Res
    end;
update(_, _) ->
    invalid_input.

%%------------------------------------------------------------------------------
%% @doc Change current status of blacklist feature.
%% @end
%%------------------------------------------------------------------------------

-spec change_status(nonempty_string()) -> ok | {error, Reason} when
    Reason :: any().
change_status([]) ->
    "Invalid Input. Use \"Enable\" or \"enable\" to turn on features, \"Disable\" or \"disable\" to turn off features";
change_status(Text) when Text =:= "Enable" orelse Text =:= "enable" ->
    dets:open_file(?PATH_BLACKLIST_TABLE, {type, bag}),
    [Status] = [Value || {_, Value} <- dets:lookup(?PATH_BLACKLIST_TABLE, status)],
    Res = case Status of
        true ->
            "Feature is already enabled";
        _ ->
            dets:delete_object(?PATH_BLACKLIST_TABLE, {status, false}),
            dets:insert_new(?PATH_BLACKLIST_TABLE, [{status, true}]),
            "Feature is enabled"
    end,
    dets:sync(?PATH_BLACKLIST_TABLE),
    dets:close(?PATH_BLACKLIST_TABLE),
    Res;
change_status(Text) when Text == "Disable" orelse Text == "disable" ->
    dets:open_file(?PATH_BLACKLIST_TABLE, {type, bag}),
    [Status] = [Value || {_, Value} <- dets:lookup(?PATH_BLACKLIST_TABLE, status)],
    Res = case Status of
        false ->
            "Feature is already disabled";
        _ ->
            dets:delete_object(?PATH_BLACKLIST_TABLE, {status, true}),
            dets:insert_new(?PATH_BLACKLIST_TABLE, [{status, false}]),
            "Feature is disabled"
    end,
    dets:sync(?PATH_BLACKLIST_TABLE),
    dets:close(?PATH_BLACKLIST_TABLE),
    Res;
change_status(_) ->
    "Invalid Input. Use \"Enable\" or \"enable\" to turn on features, \"Disable\" or \"disable\" to turn off features".

%%------------------------------------------------------------------------------
%% @doc Check current status of blacklist feature.
%% @end
%%------------------------------------------------------------------------------

-spec check_status() -> boolean().
check_status() ->
    dets:open_file(?PATH_BLACKLIST_TABLE, {type, bag}),
    A = dets:lookup(?PATH_BLACKLIST_TABLE, status),
    Status = case A of
        [] ->
            dets:insert_new(?PATH_BLACKLIST_TABLE, [{status, false}]),
            false;
        [{_, Value}] -> Value
    end,
    dets:close(?PATH_BLACKLIST_TABLE),
    Status.