-module(krang_session).
-export([check_session/1,
         check_login_session/1,
         has_auth_session/1, 
         save_auth_session/1,
         delete_session/1
         ]).

%%--------------------------------------------------------------------------------------------------------------------

check_session(Headers) ->
    case krang_session:has_auth_session(Headers) of 
        true  -> {ok,[]};
        false -> {redirect,[{action,"login"}]}  %% TODO: include error message .........
    end.

check_login_session(Headers) ->
    case krang_session:has_auth_session(Headers) of 
        true  -> {redirect,[{action,"index"}]};
        false -> {ok,[]}
    end.

has_auth_session(Headers) ->
    case proplists:get_value(cookie,Headers) of 
        undefined ->
            false;
        CookieVal ->
            CookieProplist = get_cookie_proplist(CookieVal),
            case session_value(CookieProplist) of 
                undefined ->
                    false;
                SessionID ->
                    io:format("SessionID: ~p\nData:~p\n",[SessionID,boss_session:get_session_data(SessionID)]),
                    case boss_session:get_session_data(SessionID, auth) of
                        {error,Reason} -> false;
                        true           -> true;
                        undefined      -> false %% session_expired
                    end
            end
    end.

save_auth_session(Props) ->
    Cookie = "changeme", %% TODO: make this a hash or some random value...........
    SessionID = boss_session:new_session(Cookie),
    ok = boss_session:set_session_data(SessionID,auth,true),
    ok = boss_session:set_session_data(SessionID,un,proplists:get_value(un,Props)),
    ok = boss_session:set_session_data(SessionID,pw,proplists:get_value(pw,Props)),
    SessionID.

delete_session(Headers) ->
    case proplists:get_value(cookie,Headers) of     
        undefined ->
            ok;
        CookieVal ->
            CookieProplist = get_cookie_proplist(CookieVal),
            case session_value(CookieProplist) of 
                undefined -> ok;
                SessionID -> boss_session:delete_session(SessionID)
            end
    end.

%%--------------------------------------------------------------------------------------------------------------------

get_cookie_proplist(CookieVal) ->
    case string:tokens(CookieVal,"; ") of 
        [] -> %% mmmm ,.....
            false;
        CookieValEntries ->
            lists:map(fun(Entry) -> 
                case string:tokens(Entry,"=") of
                    [Col,Val] ->
                        {Col,Val};
                    _ -> 
                        []%% mmm, should not happen...
                end
            end, CookieValEntries)
    end.

session_value(CookieProplist) ->
    proplists:get_value("s",CookieProplist).