% ░░░░░░░░░░░░░░░░░░░░░▄▀░░▌
% ░░░░░░░░░░░░░░░░░░░▄▀▐░░░▌
% ░░░░░░░░░░░░░░░░▄▀▀▒▐▒░░░▌
% ░░░░░▄▀▀▄░░░▄▄▀▀▒▒▒▒▌▒▒░░▌
% ░░░░▐▒░░░▀▄▀▒▒▒▒▒▒▒▒▒▒▒▒▒█
% ░░░░▌▒░░░░▒▀▄▒▒▒▒▒▒▒▒▒▒▒▒▒▀▄
% ░░░░▐▒░░░░░▒▒▒▒▒▒▒▒▒▌▒▐▒▒▒▒▒▀▄
% ░░░░▌▀▄░░▒▒▒▒▒▒▒▒▐▒▒▒▌▒▌▒▄▄▒▒▐
% ░░░▌▌▒▒▀▒▒▒▒▒▒▒▒▒▒▐▒▒▒▒▒█▄█▌▒▒▌
% ░▄▀▒▐▒▒▒▒▒▒▒▒▒▒▒▄▀█▌▒▒▒▒▒▀▀▒▒▐░░░▄
% ▀▒▒▒▒▌▒▒▒▒▒▒▒▄▒▐███▌▄▒▒▒▒▒▒▒▄▀▀▀▀
% ▒▒▒▒▒▐▒▒▒▒▒▄▀▒▒▒▀▀▀▒▒▒▒▄█▀░░▒▌▀▀▄▄
% ▒▒▒▒▒▒█▒▄▄▀▒▒▒▒▒▒▒▒▒▒▒░░▐▒▀▄▀▄░░░░▀
% ▒▒▒▒▒▒▒█▒▒▒▒▒▒▒▒▒▄▒▒▒▒▄▀▒▒▒▌░░▀▄
% ▒▒▒▒▒▒▒▒▀▄▒▒▒▒▒▒▒▒▀▀▀▀▒▒▒▄▀

-module(sim).
%check unit speciazl character
-export([check_bit/1,
         check_sp/1,
         check_htab/1,
         check_lf/1,
         check_cr/1,
         check_digit/1]).

%check
-export([check_mark/1, check_user_un/1, check_dquote/1, check_dquotes/1]).
-export([check_dquote_pair/1, check_hexdig/1, check_hexdigs/1, check_transport/1]).
-export([check_param_um/1, check_reserved/1, check_alpha/1, check_alphanum/1, check_token/1]).
-export([check_utf8_cont/1, check_utf8_nonascii/1, check_wsp/1, check_crlf/1, check_lws/1]).
-export([check_sws/1, check_dqtext/1, check_laquot/1, check_raquot/1, check_dis_name/1]).
-export([check_quoted_string/1, check_qvalue/1, check_ipV4/1, check_ipV6/1, check_ipv6_reference/1]).
-export([check_escape/1, check_unreserved/1, check_password/1, check_user/1]).
-export([check_label_tail/1, check_domain_label/1, check_top_label/1, check_head_hostname/1]).
-export([check_hostname/1, check_port/1, check_host/1, check_hostport/1, check_userinfo/1]).
-export([check_user_param/1, check_method_param/1, check_ttl_param/1, check_maddr_param/1]).
-export([check_lr_param/1, check_escaped/1, check_pname_pvalue/1, check_other_param/1]).
-export([check_uri_parameter/1, check_uri_parameters/1, check_sip_uri/1, check_hnv_unreserved/1]).
-export([check_hvalue/1, check_hname/1, check_header/1, check_headers/1, check_sips_uri/1]).
-export([check_uric/1, check_uric_no_slash/1, check_query/1, check_opaque_part/1, check_pchar/1]).
-export([check_param/1, check_segment/1, check_path_segments/1, check_abs_path/1]).
-export([check_tail_reg_name/1, check_reg_name/1, check_srvr/1, check_authority/1, check_net_path/1]).
-export([check_hier_part/1, check_scheme/1, check_absolute_uri/1, check_add_spec/1]).
-export([check_name_add/1,check_generic_param/1, check_kazoo_extension/1]).
-export([check_semi/1, check_star/1, check_comma/1, check_equal/1, check_gen_value/1, check_cpe/1]).
-export([check_cpq/1, check_kazoo_params/1, check_semi_kzp/1, check_hcolon/1]).
-export([check_below_cholon/1,check_kazoo_param/1,check_tail_kazoo_param/1, check_visual_sep/1]).
-export([check_phone_digit/1, check_base_phone_number/1, check_isdn_sub/1, check_token_char/1]).
-export([check_token_string/1, check_pause_character/1, check_dtmf_digit/1, check_post_dial/1]).
-export([check_network_prefix/1, check_private_prefix/1, check_phone_context_ident/1]).
-export([check_area_specifier/1, check_global_phone_number/1, check_tails_global_phone/1]).
-export([check_future_extension/1,check_order/1,check_tail/2,check_tail2/2,check_area_order/1]).
-export([check_local_phone_number/1,check_tail_pchar/1, check_tail_below_cholon/1]).

-define(DIGIT, ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]).
-define(MARK, ["-","_", ".", "!", "~", "*", "'", "(", ")"]).
-define(USER_UNRESERVED,["&", "=", "+", "$", ",", ";", "?", "/"]).
-define(HEXDIG, ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]).
-define(TRANSPORT_PARAM,["udp", "tcp", "sctp", "tls"]).
-define(PARAM_UNRESERVED,["[", "]", "/", ":", "&", "+", "$"]).
-define(RESERVED,[";", "/", "?", ":", "@", "&", "=", "+", "$", ","]).
-define(TAIL_REG_NAME, ["$", ",", ";" , ":" ,"@" , "&" , "=" , "+"]).
-define(VS_SEP, ["-", ".", "(", ")"]).
-define(TAIL_PCHAR,[":","@","&","=","+","$",","]).

%%------------------------------------------------------------------------------
%% @doc Check BIT
%% @end
%%------------------------------------------------------------------------------
-spec check_bit(BIT) -> Res when
    BIT :: char(),
    Res :: boolean().
check_bit(Text) ->
    Text =:= "0" orelse Text =:= "1".

%%------------------------------------------------------------------------------
%% @doc Check SPACE
%% @end
%%------------------------------------------------------------------------------
-spec check_sp(SP) -> Res when
    SP :: char(),
    Res :: boolean().
check_sp(Text) ->
    Text == "\s".

%%------------------------------------------------------------------------------
%% @doc Check HTAB
%% @end
%%------------------------------------------------------------------------------
-spec check_htab(HTAB) -> Res when
    HTAB :: char(),
    Res :: boolean().
check_htab(Text) ->
    Text == "\t".

%%------------------------------------------------------------------------------
%% @doc Check linefeed
%% @end
%%------------------------------------------------------------------------------
-spec check_lf(LF) -> Res when
    LF :: char(),
    Res :: boolean().
check_lf(Text) ->
    Text == "\n".

%%------------------------------------------------------------------------------
%% @doc Check carriage return
%% @end
%%------------------------------------------------------------------------------
-spec check_cr(CR) -> Res when
    CR :: char(),
    Res :: boolean().
check_cr(Text) ->
    Text == "\r".

%%------------------------------------------------------------------------------
%% @doc Check DIGIT
%% @end
%%------------------------------------------------------------------------------
-spec check_digit(DIGIT) -> Res when
    DIGIT :: char(),
    Res :: boolean().
check_digit(Text) ->
    lists:member(Text, ?DIGIT).

%%------------------------------------------------------------------------------
%% @doc Check MARK
%% @end
%%------------------------------------------------------------------------------
-spec check_mark(MARK) -> Res when
    MARK :: char(),
    Res :: boolean().
check_mark(Text) ->
    lists:member(Text, ?MARK).

%%------------------------------------------------------------------------------
%% @doc Check User Unreserved
%% @end
%%------------------------------------------------------------------------------
-spec check_user_un(UN_RE) -> Res when
    UN_RE :: char(),
    Res :: boolean().
check_user_un(Text) ->
    lists:member(Text, ?USER_UNRESERVED).

%%------------------------------------------------------------------------------
%% @doc Check DQUOTE
%% @end
%%------------------------------------------------------------------------------
-spec check_dquote(DQUOTE) -> Res when
    DQUOTE :: char(),
    Res :: boolean().
check_dquote(DQUOTE) ->
    DQUOTE == "\"".

%%------------------------------------------------------------------------------
%% @doc Check DQUOTES
%% @end
%%------------------------------------------------------------------------------
-spec check_dquotes(DQUOTES) -> Res when
    DQUOTES :: string(),
    Res :: boolean().
check_dquotes(DQUOTES) ->
    re:run(DQUOTES, "^[\"]*$") =/= nomatch.

%%------------------------------------------------------------------------------
%% @doc Check QUOTE PAIR
%% @end
%%------------------------------------------------------------------------------
-spec check_dquote_pair(QUOTE_PAIR) -> Res when
    QUOTE_PAIR :: string(),
    Res :: boolean().
check_dquote_pair([H, T]) when H == 92 ->
    (T >= 0 andalso T =< 9) orelse (T >= 11 andalso T =< 12) orelse (T >= 14 andalso T =< 127);
check_dquote_pair(_) ->
    false.

%%------------------------------------------------------------------------------
%% @doc Check HEXDIG
%% @end
%%------------------------------------------------------------------------------
-spec check_hexdig(HEXDIG) -> Res when
    HEXDIG :: char(),
    Res :: boolean().
check_hexdig(Text) ->
    lists:member(Text, ?HEXDIG).

%%------------------------------------------------------------------------------
%% @doc Check HEXDIGS
%% @end
%%------------------------------------------------------------------------------
-spec check_hexdigs(HEXDIGS) -> Res when
    HEXDIGS :: string(),
    Res :: boolean().
check_hexdigs(Text) ->
    re:run(Text, "^[0-9A-F]*$") =/= nomatch.

%%------------------------------------------------------------------------------
%% @doc Check Transport
%% @end
%%------------------------------------------------------------------------------
-spec check_transport(TRANSPORT) -> Res when
    TRANSPORT :: string(),
    Res :: boolean().
check_transport([ 116, 114, 97, 110, 115, 112, 111, 114, 116, 61 | Text]) ->
    lists:member(Text, ?TRANSPORT_PARAM);
check_transport(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check PARAM UNRESERVED
%% @end
%%------------------------------------------------------------------------------
-spec check_param_um(PARAM_UNRESERVED) -> Res when
    PARAM_UNRESERVED :: char(),
    Res :: boolean().
check_param_um(Text) ->
    lists:member(Text, ?PARAM_UNRESERVED).

%%------------------------------------------------------------------------------
%% @doc Check Reserved
%% @end
%%------------------------------------------------------------------------------
-spec check_reserved(RE) -> Res when
    RE :: char(),
    Res :: boolean().
check_reserved(Text) ->
    lists:member(Text, ?RESERVED).

%%------------------------------------------------------------------------------
%% @doc Check ALPHA
%% @end
%%------------------------------------------------------------------------------
-spec check_alpha(ALPHA) -> Res when
    ALPHA :: char(),
    Res :: boolean().
check_alpha(Text) ->
    re:run(Text,"^[A-Za-z]$") =/= nomatch.

%%------------------------------------------------------------------------------
%% @doc Check ALPHANUM
%% @end
%%------------------------------------------------------------------------------
-spec check_alphanum(ALPHANUM) -> Res when
    ALPHANUM :: string(),
    Res :: boolean().
check_alphanum(Text) ->
    re:run(Text,"^[0-9A-Za-z]$") =/= nomatch.

%%------------------------------------------------------------------------------
%% @doc Check TOKEN
%% @end
%%------------------------------------------------------------------------------
-spec check_token(string()) -> boolean().
check_token(Text) ->
    re:run(Text,"^[0-9A-Za-z-.!%*_+`'~]{1,}$") =/= nomatch.

%%------------------------------------------------------------------------------
%% @doc Check UTTF8 CONT
%% @end
%%------------------------------------------------------------------------------
-spec check_utf8_cont(char()) -> boolean().
check_utf8_cont(Text) ->
    Text >= [128] andalso Text =< "┐".

%%------------------------------------------------------------------------------
%% @doc Check UTF8 NONASCII
%% @end
%%------------------------------------------------------------------------------
-spec check_utf8_nonascii(string()) -> boolean().
check_utf8_nonascii(Text) ->
    Text >= [192] andalso Text =< [223].

%%------------------------------------------------------------------------------
%% @doc Check WSP
%% @end
%%------------------------------------------------------------------------------
-spec check_wsp(char()) -> boolean().
check_wsp(WSP) ->
    re:run(WSP, "^[\t\s]$") =/= nomatch.

%%------------------------------------------------------------------------------
%% @doc Check CRLF
%% @end
%%------------------------------------------------------------------------------
-spec check_crlf(string()) -> boolean().
check_crlf([CR, LF]) when CR == 13, LF == 10->
    true;
check_crlf(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check LWS
%% @end
%%------------------------------------------------------------------------------
-spec check_lws(nonempty_string()) -> boolean().
check_lws([]) -> true;
check_lws([32|T]) ->
    check_lws(T);
check_lws([9|T]) ->
    check_lws(T);
check_lws([13,10|T]) when T =/= []->
    check_lws(T);
check_lws(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check SWS
%% @end
%%------------------------------------------------------------------------------
-spec check_sws(string()) -> boolean().
check_sws([]) -> true;
check_sws(SWS) ->
    check_lws(SWS).

%%------------------------------------------------------------------------------
%% @doc Check QDTEXT
%% @end
%%------------------------------------------------------------------------------
-spec check_dqtext(char()) -> boolean().
check_dqtext(DQTEXT) ->
    check_lws(DQTEXT) orelse DQTEXT == [33] orelse (DQTEXT >= [35] andalso DQTEXT =< [91])
orelse (DQTEXT >= [93] andalso DQTEXT =< [126]).

-spec check_dqtexts(string()) -> boolean().
check_dqtexts([]) -> true;
check_dqtexts([H | T]) ->
    check_dqtext([H]) andalso check_dqtexts(T).

%%------------------------------------------------------------------------------
%% @doc Check QUOTE STRING
%% @end
%%------------------------------------------------------------------------------
-spec check_quoted_string(string()) -> boolean().
check_quoted_string(QUOTED_STRING) ->
    {SWS, StD} = string:take(QUOTED_STRING, " \t\r\n", false, leading),
    A = check_sws(SWS),
    {DQUOTE1, QDTEXT} = string:take(StD, "\"", false, leading),
    B =  check_dquote(DQUOTE1),
    {DQTEXT, DQUOTE2} = string:take(QDTEXT, "\"", false, trailing),
    C =  check_dquote(DQUOTE2),
    D = check_dqtexts(DQTEXT),
    E = check_dquote_pair(DQTEXT),
    Res1 = A andalso B andalso C,
    Res2 = D orelse E,
    Res1 andalso Res2.

%%------------------------------------------------------------------------------
%% @doc Check LAQUOT
%% @end
%%------------------------------------------------------------------------------
-spec check_laquot(nonempty_string()) -> boolean().
check_laquot(LAQUOT) ->
    {SWS, LAQUOT1} = string:take(LAQUOT, " \t\r\n", false, leading),
    check_sws(SWS) andalso LAQUOT1 == "<".

%%------------------------------------------------------------------------------
%% @doc Check RAQUOT
%% @end
%%------------------------------------------------------------------------------
-spec check_raquot(nonempty_string()) -> boolean().
check_raquot(RAQUOT) ->
    {RAQUOT1, SWS} = string:take(RAQUOT, " \t\r\n", false, trailing),
    check_sws(SWS) andalso RAQUOT1 == ">".

%%------------------------------------------------------------------------------
%% @doc Check DISPLAY NAME
%% @end
%%------------------------------------------------------------------------------
-spec check_dis_name(nonempty_string()) -> boolean().
check_dis_name(DPNAME) ->
    {TOKEN, LWS} = string:take(DPNAME, " \t\r\n", false, trailing),
    (check_lws(LWS) andalso check_token(TOKEN)) orelse check_quoted_string(DPNAME).

%%------------------------------------------------------------------------------
%% @doc Check QVALUE
%% @end
%%------------------------------------------------------------------------------
-spec check_qvalue(nonempty_string()) -> boolean().
check_qvalue([Head, $.| Tail]) when Head == 48->
    re:run(Tail,"^[0-9]{0,3}$") =/= nomatch;
check_qvalue([Head, $.| Tail]) when Head == 49 ->
    re:run(Tail,"^0{0,3}$") =/= nomatch;
check_qvalue(_) ->
    false.

%%------------------------------------------------------------------------------
%% @doc Check IPV4
%% @end
%%------------------------------------------------------------------------------
-spec check_ipV4(nonempty_string()) -> boolean().
check_ipV4(Text) ->
    {Res, _} = inet:parse_ipv4_address(Text),
    Res =:= ok.
%%------------------------------------------------------------------------------
%% @doc Check IPV6
%% @end
%%------------------------------------------------------------------------------
-spec check_ipV6(nonempty_string()) -> boolean().
check_ipV6(Text) ->
    {Res, _} = inet:parse_ipv6_address(Text),
    Res =:= ok.

%%------------------------------------------------------------------------------
%% @doc Check IPV6 REFERENCE
%% @end
%%------------------------------------------------------------------------------
-spec check_ipv6_reference(nonempty_string()) -> boolean().
check_ipv6_reference([91| IPV6_EXT]) ->
    case lists:last(IPV6_EXT) of
        93 ->
            IPV6 = string:sub_string(IPV6_EXT, 1, string:length(IPV6_EXT)-1),
            check_ipV6(IPV6);
        _ -> false
    end;
check_ipv6_reference(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check ESCAPE
%% @end
%%------------------------------------------------------------------------------
-spec check_escape(nonempty_string()) -> boolean().
check_escape([37, Hex1, Hex2]) ->
    check_hexdig([Hex1]) and check_hexdig([Hex2]);
check_escape(_) ->
    false.

%%------------------------------------------------------------------------------
%% @doc Check UNRESERVED
%% @end
%%------------------------------------------------------------------------------
-spec check_unreserved(nonempty_string()) -> boolean().
check_unreserved([]) -> true;
check_unreserved(UNRE) ->
    check_alphanum(UNRE) orelse check_mark(UNRE).


%%------------------------------------------------------------------------------
%% @doc Check PASSWORD
%% @end
%%------------------------------------------------------------------------------
-spec check_password(nonempty_string()) -> boolean().
check_password([]) -> true;
check_password([37, HEXDIG1, HEXDIG2 | T]) ->
    case check_escape([37 ,HEXDIG1, HEXDIG2]) of
        true -> check_password(T);
        false -> false
    end;
check_password([Value | T])
    when Value == 38 orelse Value == 61 orelse Value == 43 orelse Value == 36 orelse Value == 44 ->
      check_password(T);
check_password([Value | T]) ->
    case check_unreserved([Value]) of
        true -> check_password(T);
        false -> false
    end;
check_password(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check USER
%% @end
%%------------------------------------------------------------------------------
-spec check_user(nonempty_string()) -> boolean().
check_user([]) -> true;
check_user([37, HEXDIG1, HEXDIG2 | T]) ->
    case check_escape([37, HEXDIG1, HEXDIG2]) of
        true -> check_user(T);
        false -> false
    end;
check_user([Value | T]) ->
    case check_user_un([Value]) orelse check_unreserved([Value]) of
        true -> check_user(T);
        false -> false
    end;
check_user(_) -> false.


%%------------------------------------------------------------------------------
%% @doc Check label tail
%% @end
%%------------------------------------------------------------------------------
-spec check_label_tail(string()) -> boolean().
check_label_tail([H|[]]) ->
    check_alphanum([H]);
check_label_tail([H|T]) ->
    (check_alphanum([H]) orelse [H] =:= "-") andalso check_label_tail(T);
check_label_tail([]) -> false.

%%------------------------------------------------------------------------------
%% @doc Check domain label
%% @end
%%------------------------------------------------------------------------------
-spec check_domain_label(nonempty_string()) -> boolean().
check_domain_label([H|T]) ->
    check_alphanum([H]) andalso check_label_tail(T).

%%------------------------------------------------------------------------------
%% @doc Check top label
%% @end
%%------------------------------------------------------------------------------
-spec check_top_label(nonempty_string()) -> boolean().
check_top_label([H|T]) ->
    check_alpha([H]) andalso check_label_tail(T).

%%------------------------------------------------------------------------------
%% @doc Check Head hostname
%% @end
%%------------------------------------------------------------------------------
-spec check_head_hostname(nonempty_string()) -> boolean().
check_head_hostname([]) -> true;
check_head_hostname([H|T]) ->
    case check_domain_label(H) of
        true -> check_head_hostname(T);
        false -> false
    end.

%%------------------------------------------------------------------------------
%% @doc Check hostname
%% @end
%%------------------------------------------------------------------------------
-spec check_hostname(nonempty_string()) -> boolean().
check_hostname([]) -> false;
check_hostname(Text) ->
    LabelList = lists:delete([],string:split(Text,".",all)),
    Top = lists:last(LabelList),
    Domain = lists:droplast(LabelList),
    check_head_hostname(Domain) andalso check_top_label(Top).

%%------------------------------------------------------------------------------
%% @doc Check port
%% @end
%%------------------------------------------------------------------------------
-spec check_port(nonempty_string()) -> boolean().
check_port(PORT) ->
    re:run(PORT, "^:[0-9]*$") =/= nomatch.

%%------------------------------------------------------------------------------
%% @doc Check host
%% @end
%%------------------------------------------------------------------------------
-spec check_host(nonempty_string()) -> boolean().
check_host(HOST) ->
    % check_hostname(HOST) orelse check_ipV4(HOST) orelse check_ipv6_reference(HOST).
    check_ipV4(HOST) orelse
    (check_hostname(HOST) andalso
    re:run(HOST,"^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$") =:= nomatch).

%%------------------------------------------------------------------------------
%% @doc Check hostport
%% @end
%%------------------------------------------------------------------------------
-spec check_hostport(nonempty_string()) -> boolean().
check_hostport(HOSTPORT) ->
    case check_ipv6_reference(HOSTPORT) of
        true -> true;
        false ->
            {HOST, PORT} = string:take(HOSTPORT, ":", true),
            Res= case PORT of
                [] -> true;
                _ ->  check_port(PORT)
            end,
            %% io:fwrite("~p~n~p~n",[Res, HOST]),
            HOST =/= "" andalso check_host(HOST) andalso Res
    end.

%%------------------------------------------------------------------------------
%% @doc Check Userinfo
%% @end
%%------------------------------------------------------------------------------
-spec check_userinfo(nonempty_string()) -> boolean().
check_userinfo(USERINFO) ->
    {USER, PASSWORD1} = string:take(USERINFO, ":@", true, leading),
    case length(PASSWORD1) =:= 1 of
        true -> USER =/="" andalso (check_user(USER) orelse check_telephone_sub(USER));
        false->
            [H| PASSWORD] = lists:droplast(PASSWORD1),
            case H =:= 58 of
                true -> USER =/="" andalso (check_user(USER) orelse check_telephone_sub(USER)) andalso check_password(PASSWORD);
                false -> false
            end
    end.

%%------------------------------------------------------------------------------
%% @doc Check user param
%% @end
%%------------------------------------------------------------------------------
-spec check_user_param(nonempty_string()) -> boolean().
check_user_param([117, 115, 101, 114, 61 | Text]) ->
    Text =:= "phone" orelse Text =:= "ip" orelse check_token(Text);
check_user_param(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check method param
%% @end
%%------------------------------------------------------------------------------
-spec check_method_param(nonempty_string()) -> boolean().
check_method_param([109,101,116,104,111,100,61|Text]) ->
    Text =:= "INVITE" orelse Text=:= "ACK" orelse
    Text =:= "OPTIONS" orelse Text=:= "BYE" orelse
    Text =:= "CANCEL" orelse Text=:= "REGISTER" orelse
    check_token(Text);
check_method_param(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check check ttl param
%% @end
%%------------------------------------------------------------------------------
-spec check_ttl_param(nonempty_string()) -> boolean().
check_ttl_param([116,116,108,61|Text]) ->
     re:run(Text,"^[0-9]{1,3}$") =/= nomatch andalso (list_to_integer(Text) =< 255);
check_ttl_param(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check madd_param
%% @end
%%------------------------------------------------------------------------------
-spec check_maddr_param(nonempty_string()) -> boolean().
check_maddr_param(Text) ->
    check_hostname(Text) orelse check_ipV4(Text) or check_ipV6(Text).

%%------------------------------------------------------------------------------
%% @doc Check lr param
%% @end
%%------------------------------------------------------------------------------
-spec check_lr_param(nonempty_string()) -> boolean().
check_lr_param([108,114,61|Text]) ->
    Text =:= "lr";
check_lr_param(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check escaped
%% @end
%%------------------------------------------------------------------------------
-spec check_escaped(nonempty_string()) -> boolean().
check_escaped([]) -> true;
check_escaped([37,HEXDIG1,HEXDIG2]) ->
    check_hexdig([HEXDIG1]) andalso check_hexdig([HEXDIG2]);
check_escaped(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check pname value
%% @end
%%------------------------------------------------------------------------------
-spec check_pname_pvalue(nonempty_string()) -> boolean().
check_pname_pvalue([]) -> true;
check_pname_pvalue([37,HEXDIG1,HEXDIG2 | T]) ->
    case check_escaped([37, HEXDIG1, HEXDIG2]) of
        true -> check_pname_pvalue(T);
        false -> false
    end;
check_pname_pvalue([H | T]) ->
    case check_param_um([H]) orelse check_unreserved([H]) of
        true -> check_pname_pvalue(T);
        false -> false
    end;
check_pname_pvalue(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check other param
%% @end
%%------------------------------------------------------------------------------
-spec check_other_param(nonempty_string()) -> boolean().
check_other_param(Text) ->
    check_pname_pvalue(Text).

%%------------------------------------------------------------------------------
%% @doc Check uri parameter
%% @end
%%------------------------------------------------------------------------------
-spec check_uri_parameter(nonempty_string()) -> boolean().
check_uri_parameter(Text) ->
    check_transport(Text) orelse check_user_param(Text) orelse check_method_param(Text) orelse
    check_ttl_param(Text) orelse check_maddr_param(Text) orelse check_lr_param(Text) orelse
    check_other_param(Text).

%%------------------------------------------------------------------------------
%% @doc Check uri parameters
%% @end
%%------------------------------------------------------------------------------
-spec check_uri_parameters(nonempty_string()) -> boolean().
check_uri_parameters([]) -> true;
check_uri_parameters([59|T]) ->
    {Head, Tail} = string:take(T, ";", true, leading),
    % %% io:fwrite("~p~n~p~n",[Head, Tail]),
    Head =/= [] andalso check_uri_parameter(Head) andalso check_uri_parameters(Tail).

%%------------------------------------------------------------------------------
%% @doc Check hnv unreserved
%% @end
%%------------------------------------------------------------------------------
-spec check_hnv_unreserved(string()) -> boolean().
check_hnv_unreserved(Text) ->
    re:run(Text, "^[[/:&+$]$") =/= nomatch orelse Text == "]".

%%------------------------------------------------------------------------------
%% @doc Check hvalue
%% @end
%%------------------------------------------------------------------------------
-spec check_hvalue(char()) -> boolean().
check_hvalue([]) -> true;
check_hvalue([37, HEXDIG1, HEXDIG2 | HVALUE]) ->
    case check_escaped([37, HEXDIG1, HEXDIG2]) of
        true -> check_hvalue(HVALUE);
        false -> false
    end;
check_hvalue([H | HVALUE]) ->
    case check_unreserved([H]) orelse check_hnv_unreserved([H]) of
        true -> check_hvalue(HVALUE);
        false -> false
    end;
check_hvalue(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check hname
%% @end
%%------------------------------------------------------------------------------
-spec check_hname(nonempty_string()) -> boolean().
check_hname([]) -> false;
check_hname([37, HEXDIG1, HEXDIG2 | HNAME]) ->
    case check_escaped([37, HEXDIG1, HEXDIG2]) of
        true when HNAME =/= []-> check_hname(HNAME);
        true -> true;
        false -> false
    end;
check_hname([H | HNAME]) ->
    case check_unreserved([H]) orelse check_hnv_unreserved([H]) of
        true when HNAME =/= []-> check_hname(HNAME);
        true -> true;
        false -> false
    end;
check_hname(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check header
%% @end
%%------------------------------------------------------------------------------
-spec check_header(nonempty_string()) -> boolean().
check_header(HEADER) ->
    List = string:split(HEADER,"="),
    case length(List) of
        1 -> false;
        _ ->
            [HNAME, HVALUE] = List,
            check_hname(HNAME) andalso check_hvalue(HVALUE)
    end.

%%------------------------------------------------------------------------------
%% @doc Check headers
%% @end
%%------------------------------------------------------------------------------
-spec check_headers(nonempty_string()) -> boolean().
check_headers([H | HEADERS]) when H == 63 orelse H == 38 ->
    {HEADER, Tail} = string:take(HEADERS, "&", true),
    Res = case Tail of
            [] -> true;
            _ -> check_headers(Tail)
        end,
    check_header(HEADER) andalso Res.

%%------------------------------------------------------------------------------
%% @doc Check SIP URI
%% @end
%%------------------------------------------------------------------------------
-spec check_sip_uri(nonempty_string()) -> boolean().
check_sip_uri([115, 105, 112, 58 | URI]) ->
    [USERINFO | Tail1] = string:split(URI,"@"),
    Res = case Tail1 of
        [] -> true;
        _ when USERINFO =="" -> false;
        _ -> check_userinfo(lists:append(USERINFO,"@"))
    end,
    {HOSTPORT, Tail2} = case Tail1 of
        [] ->
            string:take(USERINFO,";",true);
         _ ->
             string:take(Tail1, ";",true)
     end,
    {URI_PARAMETERS, HEADERS} = string:take(Tail2, "?",true),
    check_hostport(HOSTPORT) andalso check_uri_parameters(URI_PARAMETERS)
    andalso (HEADERS =="" orelse check_headers(HEADERS))
    andalso Res;
check_sip_uri(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check SIPS URI
%% @end
%%------------------------------------------------------------------------------
-spec check_sips_uri(nonempty_string()) -> boolean().
% check_sips_uri([115, 105, 112, 115, 58 | URI]) ->
%     {USERINFO, Tail1} = string:take(URI,"@",true),
%     Res = case Tail1 of
%         [] -> true;
%         _ when USERINFO =="" -> false;
%         _ -> check_userinfo(lists:append(USERINFO,"@"))
%     end,
%     {HOSTPORT, Tail2} = case Tail1 of
%         [] ->
%             string:take(USERINFO,";",true);
%          _ -> string:take(string:sub_string(Tail1, 2), ";",true)
%     end,
%     {URI_PARAMETERS, HEADERS} = string:take(Tail2, "?",true),
%     check_hostport(HOSTPORT) andalso check_uri_parameters(URI_PARAMETERS)
%     andalso (HEADERS =="" orelse check_headers(HEADERS))
%     andalso Res;
% check_sips_uri(_) -> false.

check_sips_uri([115, 105, 112, 115, 58 | URI]) ->
    [USERINFO | Tail1] = string:split(URI,"@"),
    Res = case Tail1 of
        [] -> true;
        _ when USERINFO =="" -> false;
        _ -> check_userinfo(lists:append(USERINFO,"@"))
    end,
    {HOSTPORT, Tail2} = case Tail1 of
        [] ->
            string:take(USERINFO,";",true);
         _ ->
             string:take(Tail1, ";",true)
    %     [HOSTPORT, Tail2] = case Tail1 of
    %     [] ->
    %         string:split(USERINFO,";");
    %      _ ->
    %          string:split(Tail1, ";",all)
     end,
    {URI_PARAMETERS, HEADERS} = string:take(Tail2, "?",true),
    check_hostport(HOSTPORT) andalso check_uri_parameters(URI_PARAMETERS)
    andalso (HEADERS =="" orelse check_headers(HEADERS))
    andalso Res;
check_sips_uri(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check URIC
%% @end
%%------------------------------------------------------------------------------
-spec check_uric(nonempty_string()) -> boolean().
check_uric(URIC) ->
    check_reserved(URIC) orelse check_unreserved(URIC) orelse check_escaped(URIC).

%%------------------------------------------------------------------------------
%% @doc Check uric no slash
%% @end
%%------------------------------------------------------------------------------
-spec check_uric_no_slash(nonempty_string()) -> boolean().
check_uric_no_slash(URIC) ->
    check_unreserved(URIC) orelse check_escaped(URIC)
    orelse (re:run(URIC,"^[;?:@&=+$,]$") =/= nomatch).

%%------------------------------------------------------------------------------
%% @doc Check query
%% @end
%%------------------------------------------------------------------------------
-spec check_query(nonempty_string()) -> boolean().
check_query([]) -> true;
check_query([37, HEXDIG1, HEXDIG2 | QUERY]) ->
    case check_uric([37, HEXDIG1, HEXDIG2]) of
        true -> check_query(QUERY);
        false -> false
    end;
check_query([URIC| QUERY]) ->
    case check_uric([URIC]) of
        true -> check_query(QUERY);
        false -> false
    end;
check_query(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check Opaque part
%% @end
%%------------------------------------------------------------------------------
-spec check_opaque_part(nonempty_string()) -> boolean().
check_opaque_part([37, HEXDIG1, HEXDIG2 | T]) ->
    case check_escaped([37, HEXDIG1, HEXDIG2]) of
        true -> check_query(T);
        false -> false
    end;
check_opaque_part([H | T]) ->
    check_uric_no_slash([H]) andalso check_query(T);
check_opaque_part(_) -> false.

-spec check_tail_pchar(string()) -> boolean().
check_tail_pchar([]) -> true;
check_tail_pchar(Text) ->
    lists:member(Text, ?TAIL_PCHAR).

%%------------------------------------------------------------------------------
%% @doc Check pchar
%% @end
%%------------------------------------------------------------------------------
-spec check_pchar(nonempty_string()) -> boolean().
% check_pchar(Text) when Text =/= "\n" ->
%     check_unreserved(Text) andalso check_escape(Text)
% andalso re:run(Text, "^[:@&=+$,]*$") =/= nomatch;
check_pchar([]) -> true;
check_pchar([H|T]) when H =/= "\n" ->
    %% io:fwrite("~p~n~p~n",[H,T]),
    case (check_unreserved([H]) orelse check_escape([H]) orelse check_tail_pchar([H])) of
        true -> check_pchar(T);
        false -> false
    end;
check_pchar(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check param
%% @end
%%------------------------------------------------------------------------------
-spec check_param(nonempty_string()) -> boolean().
check_param(Text) ->
    check_pchar(Text).

%%------------------------------------------------------------------------------
%% @doc Check segment
%% @end
%%------------------------------------------------------------------------------
-spec check_segment(nonempty_string()) -> boolean().
check_segment([]) -> true;
check_segment(SEGMENT) ->
    {Pchar1, Pchar2} = string:take(SEGMENT, ";", true, leading),
    Res = case Pchar2 == [] of
        true -> true;
        false ->
            {Semi, Pch2} = string:take(Pchar2, ";", false, leading),
            Semi == ";" andalso check_segment(Pch2)
    end,
    check_param(Pchar1) andalso Res.

%%------------------------------------------------------------------------------
%% @doc Check path segments
%% @end
%%------------------------------------------------------------------------------
-spec check_path_segments(nonempty_string()) -> boolean().
check_path_segments([]) -> true;
check_path_segments(PATH_SEG) ->
    {SEG1, SEG2} = string:take(PATH_SEG, "/", true, leading),
    RES = case SEG2 == [] of
        true -> true;
        false ->
            {Op, Se} = string:take(SEG2, "/", false, leading),
            Op == "/" andalso check_path_segments(Se)
    end,
    check_segment(SEG1) andalso RES.

%%------------------------------------------------------------------------------
%% @doc Check abs path
%% @end
%%------------------------------------------------------------------------------
-spec check_abs_path(nonempty_string()) -> boolean().
check_abs_path([47 | T]) ->
    check_path_segments(T);
check_abs_path(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check tail reg name
%% @end
%%------------------------------------------------------------------------------
-spec check_tail_reg_name(nonempty_string()) -> boolean().
check_tail_reg_name(Text) ->
     lists:member(Text, ?TAIL_REG_NAME).

%%------------------------------------------------------------------------------
%% @doc Check reg name
%% @end
%%------------------------------------------------------------------------------
-spec check_reg_name(nonempty_string()) -> boolean().
check_reg_name([]) -> true;
check_reg_name([37,HEXDIG1,HEXDIG2|T]) ->
    case check_escaped([37,HEXDIG1,HEXDIG2]) of
        true -> check_reg_name(T);
        false -> false
    end;
check_reg_name([H|T]) ->
    case check_unreserved([H]) orelse check_tail_reg_name([H]) of
        true -> check_reg_name(T);
        false -> false
    end;
check_reg_name(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check SRVR
%% @end
%%------------------------------------------------------------------------------
-spec check_srvr(string()) -> boolean().
check_srvr([]) -> true;
check_srvr(Text) ->
    {Head,Tail} = string:take(Text,"@",true),
    case Tail of
        [] -> check_hostport(Head);
        _ ->
            {Head1,Tail1} = string:take(Tail,"@",false),
            HeadNew = Head ++ "@",
            check_userinfo(HeadNew) andalso check_hostport(Tail1) andalso Head1 =="@@"
    end.

%%------------------------------------------------------------------------------
%% @doc Check Authority
%% @end
%%------------------------------------------------------------------------------
-spec check_authority(nonempty_string()) -> boolean().
check_authority(Text) ->
    check_srvr(Text) orelse check_reg_name(Text).

%%------------------------------------------------------------------------------
%% @doc Check net path
%% @end
%%------------------------------------------------------------------------------
-spec check_net_path(nonempty_string()) -> boolean().
check_net_path([47,47|Text]) ->
   {Au,Path} =  string:take(Text, "/",true),
   check_authority(Au) andalso
   case Path of
    [] -> true;
    _ -> check_abs_path(Path)
    end;
check_net_path(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check hier part
%% @end
%%------------------------------------------------------------------------------
-spec check_hier_part(nonempty_string()) -> boolean().
check_hier_part(Text) ->
    {Path,Query} = string:take(Text,"?",true),
    (check_abs_path(Path) orelse check_net_path(Path)) andalso
    case Query of
        [] -> true;
        _ -> check_query(string:sub_string(Query,2))
    end.

%%------------------------------------------------------------------------------
%% @doc Check path scheme
%% @end
%%------------------------------------------------------------------------------
-spec check_scheme(nonempty_string()) -> boolean().
check_scheme([]) -> false;
check_scheme([H|T]) ->
    check_alpha([H]) andalso (re:run(T,"^[0-9A-Za-z+-.]{0,}$") =/= nomatch).

%%------------------------------------------------------------------------------
%% @doc Check absolute uri
%% @end
%%------------------------------------------------------------------------------
-spec check_absolute_uri(nonempty_string()) -> boolean().
check_absolute_uri(Text) ->
    {Scheme,Part} = string:take(Text,":",true),
    check_scheme(Scheme) andalso
    case Part of
        [] -> false;
        _ -> check_hier_part(string:sub_string(Part,2))
    orelse check_opaque_part(string:sub_string(Part,2))
    end.

%%------------------------------------------------------------------------------
%% @doc Check add spec
%% @end
%%------------------------------------------------------------------------------
-spec check_add_spec(nonempty_string()) -> boolean().
check_add_spec(Text) ->
    check_sip_uri(Text) orelse check_sips_uri(Text) orelse ( check_absolute_uri(Text)
andalso string:find(Text,"sip:")=:= nomatch andalso string:find(Text,"sips:")=:= nomatch).


%%------------------------------------------------------------------------------
%% @doc Check name address
%% @end
%%------------------------------------------------------------------------------
-spec check_name_add(nonempty_string()) -> boolean().
check_name_add([]) -> false;
check_name_add(NAME_ADD) ->
    {Dis, Tail1} = string:take(NAME_ADD, "<", true, leading),
    {La, Tail2} = string:take(Tail1, " \t\n\r<", false, leading),
    {ADD, Ra} = string:take(Tail2, "> \t\n\r", false, trailing),
    % %% io:fwrite("~p -- ~p -- ~p -- ~p~n",
    % [check_laquot(La), check_raquot(Ra), check_add_spec(ADD),
    % (check_dis_name(string:trim(Dis, trailing, [32, 9, "\r\n"])) orelse Dis == "")]),
    check_laquot(La) andalso check_raquot(Ra) andalso check_add_spec(ADD)
andalso (check_dis_name(string:trim(Dis, trailing, [32, 9, "\r\n"])) orelse Dis == "").

%%------------------------------------------------------------------------------
%% @doc Check SEMI
%% @end
%%------------------------------------------------------------------------------
-spec check_semi(nonempty_string()) -> boolean().
check_semi(SEMI) ->
    {Head, Tail} = string:take(SEMI, ";", true),
    {Head1, Tail1} = string:take(Tail, ";", false),
    check_sws(Head) andalso Head1 =:= ";" andalso check_sws(Tail1).

%%------------------------------------------------------------------------------
%% @doc Check STAR
%% @end
%%------------------------------------------------------------------------------
-spec check_star(nonempty_string()) -> boolean().
check_star(STAR) ->
    {Head, Tail} = string:take(STAR, "*", true),
    {Head1, Tail1} = string:take(Tail, "*", false),
    check_sws(Head) andalso Head1 =:= "*" andalso check_sws(Tail1).

%%------------------------------------------------------------------------------
%% @doc Check COMMA
%% @end
%%------------------------------------------------------------------------------
-spec check_comma(nonempty_string()) -> boolean().
check_comma(COMMA) ->
    {Head, Tail} = string:take(COMMA, ",", true),
    {Head1, Tail1} = string:take(Tail, ",", false),
    check_sws(Head) andalso Head1 =:= "," andalso check_sws(Tail1).

%%------------------------------------------------------------------------------
%% @doc Check EQUAL
%% @end
%%------------------------------------------------------------------------------
-spec check_equal(nonempty_string()) -> boolean().
check_equal(EQUAL) ->
    {Head, Tail} = string:take(EQUAL, "=", true),
    {Head1, Tail1} = string:take(Tail, "=", false),
    check_sws(Head) andalso Head1 =:= "=" andalso check_sws(Tail1).

%%------------------------------------------------------------------------------
%% @doc Check gen value
%% @end
%%------------------------------------------------------------------------------
-spec check_gen_value(nonempty_string()) -> boolean().
check_gen_value(Text) ->
    check_token(Text) orelse check_hostname(Text) orelse check_quoted_string(Text).

%%------------------------------------------------------------------------------
%% @doc Check generic param
%% @end
%%------------------------------------------------------------------------------
-spec check_generic_param(nonempty_string()) -> boolean().
check_generic_param(Text) ->
    {Head,Tail} = string:take(Text,"\s\r\t\n=", true,leading),
    Res = case Tail of
        [] -> true;
        _ ->
        {Head1,Tail1} = string:take(Tail,"\s\r\t\n=", false,leading),
        check_gen_value(Tail1) andalso check_equal(Head1)
    end,
    Head =/= [] andalso Res andalso check_token(Head).

%%------------------------------------------------------------------------------
%% @doc Check kazoo extensions
%% @end
%%------------------------------------------------------------------------------
-spec check_kazoo_extension(nonempty_string()) -> boolean().
check_kazoo_extension(Text) ->
    check_generic_param(Text).

%%------------------------------------------------------------------------------
%% @doc Check delta second
%% @end
%%------------------------------------------------------------------------------
-spec check_delta_second(nonempty_string()) -> boolean().
check_delta_second(Text) ->
    re:run(Text, "^[0-9]*$") =/= nomatch.

%%------------------------------------------------------------------------------
%% @doc Check cp express
%% @end
%%------------------------------------------------------------------------------
-spec check_cpe(nonempty_string()) -> boolean().
check_cpe([101,120,112,105,114,101,115|Tail]) ->
    {_Head1,Tail1} = string:take(Tail,"\s\r\t\n=", true,leading),
    case Tail1 of
        [] -> false;
        _ ->
            {Head2,Tail2} = string:take(Tail1,"\s\r\t\n=", false,leading),
            check_delta_second(Tail2) andalso check_equal(Head2)
    end;
check_cpe(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check cp q
%% @end
%%------------------------------------------------------------------------------
-spec check_cpq(nonempty_string()) -> boolean().
check_cpq([113|Tail]) ->
    {_Head1,Tail1} = string:take(Tail,"\s\r\t\n=", true,leading),
    case Tail1 of
        [] -> false;
        _ ->
            {Head2,Tail2} = string:take(Tail1,"\s\r\t\n=", false,leading),
            check_qvalue(Tail2) andalso check_equal(Head2)
    end;
check_cpq(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check Kazoo params
%% @end
%%------------------------------------------------------------------------------
-spec check_kazoo_params(nonempty_string()) -> boolean().
check_kazoo_params([]) -> false;
check_kazoo_params(Text) ->
    check_cpq(Text) orelse check_cpe(Text) orelse check_kazoo_extension(Text).

%%------------------------------------------------------------------------------
%% @doc Check SEMI Kazoo param
%% @end
%%------------------------------------------------------------------------------
-spec check_semi_kzp(nonempty_string()) -> boolean().
check_semi_kzp([H|Text]) ->
    check_semi([H]) andalso check_kazoo_params(Text);
check_semi_kzp(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check HCOLON
%% @end
%%------------------------------------------------------------------------------
-spec check_hcolon(nonempty_string) -> boolean().
check_hcolon(HCOLON) ->
    {_WSP, T1} = string:take(HCOLON, " \t", false, leading),
    {H1, SWS} = string:take(T1, ":", false, leading),
    H1 == ":" andalso check_sws(SWS).

check_tail_loop(List) when List =/= [] ->
    case check_kazoo_params(lists:last(List)) of
        true ->
            check_tail_loop(lists:droplast(List));
        false -> false
    end;
check_tail_loop([]) -> true;
check_tail_loop(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check tail kazoo param
%% @end
%%------------------------------------------------------------------------------
-spec check_tail_kazoo_param(nonempty_string()) -> boolean().
check_tail_kazoo_param([]) -> true;
check_tail_kazoo_param(Text) ->
    [Head | Tail] = [string:trim(Ele,both,[32,9,"\r\n"]) || Ele <- string:split(Text, ";", all)],
    Res = case lists:member([],Tail) of
        true -> false;
        false ->
            check_tail_loop(Tail)
            % check_tail_kazoo_param(Tail)
    end,
     Head =/= [] andalso check_kazoo_params(Head) andalso Res.
    % Head =/= [] andalso check_semi_kzp(Head) andalso Res;
% check_tail_kazoo_param(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check kazoo param
%% @end
%%------------------------------------------------------------------------------
-spec check_kazoo_param(nonempty_string()) -> boolean().
check_kazoo_param(Text) ->
    case lists:member(60, Text) andalso lists:member(61, Text) of
        true ->
            {Head, Tail} = string:take(Text, ">", true, trailing),
            %% io:fwrite("~p == ~p~n", [Head, Tail]),
            Res = case Tail of
                [] -> true;
                _ ->
                    check_tail_kazoo_param(string:trim(Tail, leading, [32, 59, 9, "\r\n"]))
            end,
            (check_name_add(Head) orelse check_add_spec(Head)) andalso Res;
        false ->
            {Head, Tail} = string:take(Text,";", true),
            %% io:fwrite("~p~n~p~n", [Head,Tail]),
            Res = case Tail of
                [] -> true;
                _ -> check_tail_kazoo_param(string:trim(Tail, leading, [32, 59, 9, "\r\n"]))
            end,
            % %% io:fwrite("~p~n~p~n~p~n", [check_name_add(Head), check_add_spec(Head), Res]),
            (check_name_add(Head) orelse check_add_spec(Head)) andalso Res
    end.

%%------------------------------------------------------------------------------
%% @doc Check tail below HCOLON
%% @end
%%------------------------------------------------------------------------------
-spec check_tail_below_cholon(string()) -> boolean().
check_tail_below_cholon([]) -> true;
check_tail_below_cholon([Head | Tail]) ->
    % ? (Head =:= [] andalso check_kazoo_param(Tail)) orelse
    check_kazoo_param(Head) andalso
        case Tail of
            [] -> true;
             _ -> check_tail_below_cholon(Tail)
        end;
check_tail_below_cholon(_) -> false.

%%------------------------------------------------------------------------------
%% @doc Check below HCOLON
%% @end
%%------------------------------------------------------------------------------
-spec check_below_cholon(nonempty_string()) -> boolean().
check_below_cholon([]) -> false;
check_below_cholon(Text) ->
    case check_star(Text) of
        true -> true;
        false ->
            [Head |Tail] = [string:trim(Ele,both,[32,9,"\r\n"]) || Ele <- string:split(Text, ",", all)],
            %% io:fwrite("Check below HCOLON ne` ~p ==== ~p~n", [Head, Tail]),
            Res = case lists:member([],Tail) of
                true -> false;
                false -> check_tail_below_cholon(Tail)
            end,
            Head =/= [] andalso check_kazoo_param(Head) andalso Res

    end.

%%------------------------------------------------------------------------------
%% @doc Check visual seperator
%% @end
%%------------------------------------------------------------------------------
-spec check_visual_sep(char()) -> boolean().
check_visual_sep(Text) ->
    lists:member(Text, ?VS_SEP).

%%------------------------------------------------------------------------------
%% @doc Check phone digit
%% @end
%%------------------------------------------------------------------------------
-spec check_phone_digit(char()) -> boolean().
check_phone_digit(Text) ->
    check_digit(Text) orelse check_visual_sep(Text).

%%------------------------------------------------------------------------------
%% @doc Check base phone number
%% @end
%%------------------------------------------------------------------------------
-spec check_base_phone_number(nonempty_string()) -> boolean().
check_base_phone_number([]) -> false;
check_base_phone_number([H | []]) ->
    check_phone_digit([H]);
check_base_phone_number([H | T]) ->
    case check_phone_digit([H]) of
        true -> check_base_phone_number(T);
        false -> false
    end.
%%------------------------------------------------------------------------------
%% @doc Check isdn subscriber
%% @end
%%------------------------------------------------------------------------------
-spec check_isdn_sub(nonempty_string()) -> boolean().
check_isdn_sub([105, 115, 117, 98, 61 | T]) ->
    check_base_phone_number(T).

%%------------------------------------------------------------------------------
%% @doc Check token char
%% @end
%%------------------------------------------------------------------------------
-spec check_token_char(char()) -> boolean().
check_token_char(TOKEN_CHAR) ->
    TOKEN_CHAR == [33] orelse (TOKEN_CHAR >= [35] andalso TOKEN_CHAR =< [39])
orelse (TOKEN_CHAR >= [42] andalso TOKEN_CHAR =< [43])
orelse TOKEN_CHAR == [45] orelse TOKEN_CHAR == [46]
orelse (TOKEN_CHAR >= [48] andalso TOKEN_CHAR =< [57])
orelse (TOKEN_CHAR >= [65] andalso TOKEN_CHAR =< [90])
orelse (TOKEN_CHAR >= [94] andalso TOKEN_CHAR =< [122])
orelse TOKEN_CHAR == [124] orelse TOKEN_CHAR == [126].

-spec check_token_string(nonempty_string()) -> boolean().
check_token_string([]) -> false;
check_token_string([H | []]) ->
    check_token_char([H]);
check_token_string([H | T]) ->
    VALUE_T = check_token_char([H]),
    case VALUE_T of
        true -> check_token_string(T);
        false -> false
    end.

-spec check_future_extension(nonempty_string()) -> boolean().
% check_future_extension([59|T]) ->
%     {Head,Tail}=string:take(T,"=",true),
%     {Head1,Tail1} = string:take(Tail,"=",false),
%     {Head2,Tail2}=string:take(Tail1,"?",true),
%     {Head3,Tail3}=string:take(Tail2,"?",false),
%     % %% io:fwrite("~p~n~p~n~p~n~p~n",[Head,Tail,Head2,Tail2]),
%     Res = case Tail2 of
%         [] -> true;
%         _ when Tail2 =/= [] ->
%         (check_token_string(Head2) andalso check_token_string(Tail3));
%         _ -> (check_token_string(Tail1) orelse check_quoted_string(Tail1))
%         end,
%     check_token_string(Head) andalso Res;
% check_future_extension(_) -> false.

check_future_extension(T) ->

    {Head,Tail}=string:take(T,"=",true),
    {_Head1,Tail1} = string:take(Tail,"=",false),
    {Head2,Tail2}=string:take(Tail1,"?",true),
    {_Head3,Tail3}=string:take(Tail2,"?",false),
    % %% io:fwrite("~p~n~p~n~p~n~p~n",[Head,Tail,Head2,Tail2]),

    Res = case Tail2 of

        [] -> true;

        _ when Tail2 =/= [] ->

             (check_token_string(Head2) andalso check_token_string(Tail3));

        _ ->  (check_token_string(Tail1) orelse  check_quoted_string(Tail1))

        end,

            check_token_string(Head) andalso Res.

% check_future_extension(_) -> false.
-spec check_1s_pause(char()) -> boolean().
check_1s_pause(T) ->
    T =:= "p".

-spec check_wfdt(char()) -> boolean().
check_wfdt(T) ->
    T =:= "w".

-spec check_pause_character(char()) -> boolean().
check_pause_character(T) ->
    check_1s_pause(T) orelse check_wfdt(T).

-spec check_dtmf_digit(char()) -> boolean().
check_dtmf_digit(T) ->
    T =:= "*" orelse T =:= "#" orelse T =:= "A" orelse T =:= "B" orelse  T =:= "C" orelse
    T =:= "D".

-spec check_post_dial(nonempty_string()) -> boolean().
check_post_dial([H | []]) -> check_phone_digit([H]) orelse check_dtmf_digit([H]) orelse check_pause_character([H]);
check_post_dial([ 112, 111, 115, 116, 100, 61 | T])->
    case T of
       [] -> false;
        _ -> check_post_dial(T)
    end;
check_post_dial([H | T]) ->
    case check_phone_digit([H]) orelse check_dtmf_digit([H]) orelse check_pause_character([H]) of
        true -> check_post_dial(T);
        false -> false
    end;
check_post_dial(_) -> false.


check_local_network_prefix(DIGITS) ->
    re:run(DIGITS,"^[0-9A-D-.()*#pw]+$") =/= nomatch.


check_global_network_prefix([43|DIGITS]) ->
    re:run(DIGITS,"^[0-9-.()]+$") =/= nomatch;
check_global_network_prefix(_) -> false.

-spec check_network_prefix(nonempty_string()) -> boolean().
check_network_prefix(PREFIX) ->
    check_local_network_prefix(PREFIX) orelse check_global_network_prefix(PREFIX).

-spec check_private_prefix(char()) -> boolean().
check_private_prefix([H | PREFIX]) when
                    (H >= 16#21 andalso H =< 16#22) orelse
                    (H >= 16#24 andalso H =< 16#27) orelse
                    (H >= 16#3C andalso H =< 16#40) orelse
                    (H >= 16#45 andalso H =< 16#4F) orelse
                    (H >= 16#51 andalso H =< 16#56) orelse
                    (H >= 16#58 andalso H =< 16#60) orelse
                    (H >= 16#65 andalso H =< 16#6F) orelse
                    (H >= 16#71 andalso H =< 16#76) orelse
                    (H >= 16#78 andalso H =< 16#7E) orelse
                    H =:= 16#2C orelse H == 16#2F orelse H =:= 16#3A ->
    re:run(PREFIX,"^[\x21-\x3A\x3c-\x7E]*$") =/= nomatch;
check_private_prefix(_) -> false.

-spec check_phone_context_ident(nonempty_string()) -> boolean().
check_phone_context_ident(IDENT) ->
    check_network_prefix(IDENT) orelse check_private_prefix(IDENT).

-spec check_area_specifier(nonempty_string()) -> boolean().
check_area_specifier(AREA_SPECIFIER) ->
    {PHONE_TAG, PHONE_IDENT} = string:take(AREA_SPECIFIER,"=",true),
    case PHONE_IDENT of
        [] -> false;
        _ when PHONE_TAG =/= "phone-context" -> false;
        _ ->
            IDENT = string:sub_string(PHONE_IDENT,2),
            check_phone_context_ident(IDENT)
    end.


-spec check_global_phone_number(nonempty_string()) -> boolean().
check_global_phone_number([]) -> false;
check_global_phone_number([43|T]) ->
   {Head,Tail} = string:take(T,";",true),
   Res = check_base_phone_number(Head),
   [_Head2 | Res2] = string:split(Tail,";",all),
   %% io:fwrite("~p~n~p~n", [Res,Res2]),
   Res andalso check_tail(Res2,0);
check_global_phone_number(_) -> false.

-spec check_tail(list(), integer()) -> boolean().
check_tail([], _) -> true;
check_tail([H | T], Count) ->
    A = string:find(H,"postd="),
    case string:find(H,"isub=") of

        nomatch when A =:= nomatch ->

            check_order([H|T]);

        nomatch when Count =:= 0 orelse Count =:= 1 ->

            check_post_dial(H) andalso check_tail(T,Count + 2);

        _ when Count =/= 0 ->

            false;

        _ ->

            check_isdn_sub(H) andalso check_tail(T,Count+1)

    end;
check_tail(_,_) -> false.

-spec check_tails_global_phone(string()) -> boolean().
check_tails_global_phone([]) -> true;
check_tails_global_phone([59|T]) ->
    Tail = string:split(T,";",all),
    check_order(Tail);
check_tails_global_phone(_) -> false.

-spec check_order(string()) -> boolean().
check_order([]) -> true;
check_order([[]| _T]) -> false;
check_order([H | T]) ->
   Res =  case string:find(H,"phone-context=") of
        nomatch -> check_future_extension(H);
        _ -> check_area_specifier(H)
    end,
    Res andalso check_order(T).

-spec check_area_order(list()) -> boolean().
check_area_order([]) -> false;
check_area_order([H|T]) ->
    check_area_specifier(H) andalso check_order(T).

-spec check_tail2(list(), integer()) -> boolean().
check_tail2([],_) -> false;
check_tail2([H | T], Count) ->
    A = string:find(H,"postd="),
    case string:find(H,"isub=") of

        nomatch when A =:= nomatch ->

            check_area_order([H|T]);

        nomatch when Count =:= 0 orelse Count =:= 1 ->

            check_post_dial(H) andalso check_tail2(T,Count + 2);

        _ when Count =/= 0 ->

            false;

        _ ->

            check_isdn_sub(H) andalso check_tail2(T,Count+1)

    end;
check_tail2(_,_) -> false.

-spec check_local_phone_number(nonempty_string()) -> boolean().
check_local_phone_number([]) -> false;
check_local_phone_number(Text) ->
    {Head, Tail} = string:take(Text, ";", true),
    Res = check_local_network_prefix(Head),
    [_Head2 | Tail2] = string:split(Tail, ";", all),
    Res andalso check_tail2(Tail2, 0).

check_telephone_sub([]) -> false;
check_telephone_sub(Text) ->
    check_global_phone_number(Text) orelse check_local_phone_number(Text).
