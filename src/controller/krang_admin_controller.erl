-module(krang_admin_controller, [Req]).
-compile(export_all).

index('GET',_) ->
    krang_session:check_session(Req:headers()).

users('GET',_) ->
    krang_session:check_session(Req:headers()).

settings('GET',_) ->
    krang_session:check_session(Req:headers()).

status('GET',_) ->
    krang_session:check_session(Req:headers()).

login('POST',_) ->
    case Req:post_param("un") of 
        UN when UN =:= [];
                UN =:= undefined ->
            {redirect,[{action,"login"}]};  %% TODO: include error message .........
        UN ->
            case Req:post_param("pw") of 
                PW when PW =:= [];
                        PW =:= undefined ->
                    {redirect,[{action,"login"}]}; %% TODO: include error message .........
                PW ->
                    case krang_credentials:match_creds(UN,PW) of 
                        true ->
                            SessionID = krang_session:save_auth_session([{un,UN}, {pw,PW}]),
                            {redirect,[{action,"index"}], [{"Set-Cookie","s="++SessionID}] };
                        false ->
                            {redirect,[{action,"login"}]}  %% TODO: include error message .........
                    end
            end
    end;
login('GET',_) ->
    krang_session:check_login_session(Req:headers()).

logout(_,_) -> 
    Headers = Req:headers(),
    ok = krang_session:delete_session(Headers),
    {redirect,[{action,"index"}], [{"Set-Cookie","token=deleted; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT"}] }. 