-module(krang_auth_controller, [Req]).
-compile(export_all).

index(_,_) ->
    {redirect,"action"}.

action(_,_) ->
    %% Check if logged in...
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
            {redirect,"action"};
        [Email,Pwd,CPwd] when Pwd =/= CPwd ->
            krang_common:log("Password Confirmation doesn't match!"),
            {redirect,"action"};
        [Email,Pwd,CPwd] when Pwd =/= CPwd ->
            {redirect,"action"};
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
                    krang_common:log("DB Rec saved"),
                    {redirect,"signup_success"};
                Error ->
                    krang_common:log("DB Rec not saved"),
                    {redirect,"action"}
            end
    end.


success() ->
    ok.

signup_success(_,_) ->
    {ok, []}.
