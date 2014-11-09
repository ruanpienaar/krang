-module(krang_auth_controller, [Req]).
-compile(export_all).

index(_,_) ->
<<<<<<< HEAD
    {redirect,"auth/action"}.

action(_,_) ->
    {ok,[{"title","auth"}]}.

login('POST',URI) ->
    {output,<<"ok">>}.

signup('POST',URI) ->
    case lists:map(fun(PostParam) -> Req:post_param(PostParam) end, ["r_em","r_pw","r_cpw"]) of
        [Email,Pwd,CPwd] when Email =:= undefined;
                              Pwd   =:= undefined;
                              CPwd  =:= undefined ->
            {redirect,"auth/action"}; %% XXX Improve errors !!!
        [Email,Pwd,CPwd] when Pwd =/= CPwd ->
            {redirect,"auth/action"}; %% XXX Improve errors !!!
        [Email,Pwd,CPwd] when Pwd =:= CPwd ->
            %% generate verify token
            VerifyToken = "test",
            %% Create email
            %% Send email here
            %% Hash Pwd
            HashPwd = Pwd,
            S = krang_signup:new(id, Email, VerifyToken, HashPwd),
            case S:save() of
                {ok,SavedEntry} ->
                    {redirect,"auth/signup_success"};
                Error ->
                    {redirect,"auth/action"} %% XXX Improve errors !!!
            end
    end.

signup_success(_,_) ->
    {ok,[{base_path,"../"}]}.
