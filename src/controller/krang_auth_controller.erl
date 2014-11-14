-module(krang_auth_controller, [Req]).
-compile(export_all).

index(_,_) ->
    {ok,[{"title","auth"}]}.

login('POST',URI) ->
    {output,<<"ok">>}.

signup('POST',URI) ->
    case lists:map(fun(PostParam) -> Req:post_param(PostParam) end,
            ["r_em","r_pw","r_cpw"]) of
        [Email,Pwd,CPwd] when Email =:= undefined;
                              Pwd   =:= undefined;
                              CPwd  =:= undefined ->
            krang_common:log("All Input fields empty!"),
            {redirect,"auth"}; %% XXX Improve errors !!!
        [Email,Pwd,CPwd] when Pwd =/= CPwd ->
            krang_common:log("Password Confirmation doesn't match!"),
            {redirect,"auth"}; %% XXX Improve errors !!!
        [Email,Pwd,CPwd] when Pwd =:= CPwd ->
            krang_common:log("Everything good!"),
            %% generate verify token
            VerifyToken = "a1b2c3d4",
            %% Create email
            %% Send email here
            %% Hash Pwd
            HashPwd = Pwd,
            S = krang_signup:new(id, Email, VerifyToken, HashPwd),
            case S:save() of
                {ok,SavedEntry} ->
                    {redirect,"success"};
                Error ->
                    {redirect,"auth"} %% XXX Improve errors !!!
            end
    end.

success() ->
    ok.