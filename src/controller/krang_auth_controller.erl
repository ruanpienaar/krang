-module(krang_auth_controller, [Req]).
%% TODO: only export function's that will be exposed as URL's. 
%% So that you can abstract simmilar pieces of code into smaller functions.

%% TODO: make all the redirection abs paths
-compile(export_all).

action(_,_) ->
    %% Check if logged in...

    case Req:cookie("_boss_session") of 
        undefined ->
            {ok,[]};
        Cookie ->
            {redirect,"auth_status"}
    end.

login('POST',URI) ->
    Email = Req:post_param("em"),
    PW = Req:post_param("pw"),
    Passwd = krang_common:md5_hash(PW),
    io:format("Passwd : ~p\n",[Passwd]),
    case boss_db:find(krang_user,
                [{'email','equals',Email},
                 {'passwd','equals',Passwd},
                 {'verified','equals',true}]) of
        [] ->
            {redirect,krang_common:site_base_url()++"/auth/action"};
        [{krang_user,Id,Email,Passwod,true}] ->
            % BackendCookie = krang_common:md5_hash(Email),
            Cookie = boss_session:new_session("_boss_session"),
            io:format("Cookie: ~p\n",[Cookie]),
            ok = boss_session:set_session_data(Cookie,email,Email),
            {redirect,"auth_status"}
    end.

logoff('GET',_) ->
    case Req:cookie("_boss_session") of 
        undefined ->
            {redirect,krang_common:site_base_url()++"/auth/action"};
        Cookie ->
            io:format("Cookie : ~p\n",[Cookie]),
            ok = boss_session:delete_session(Cookie),
            {output,<<"mmm">>}
    end.

auth_status('GET',_) ->
    case Req:cookie("_boss_session") of 
        undefined ->
            {redirect,krang_common:site_base_url()++"/auth/action"};
        Cookie ->
            io:format("Cookie ! ~p\n",[Cookie]),
            io:format("Email  ! ~p\n",[boss_session:get_session_data(Cookie,email)]),
            {output,<<"mmm">>}
    end.

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
        [Email,Pwd,CPwd] when Pwd =:= CPwd ->
            VerifyToken =
                krang_common:rand_hash_32(),
            ConfirmationUrl =
                krang_common:site_base_url()++"/auth/confirm_email"
                ++ "?vt="++VerifyToken 
                ++ "&em="++Email,
            %% Create email
            %% Send email here
            HashPwd = krang_common:md5_hash(Pwd),
            S = krang_signup:new(id, VerifyToken, Email),
            case S:save() of
                {ok,SavedEntry} ->
                    krang_common:log("Email ~p registered...",[Email]),
                    U = krang_user:new(id, Email, HashPwd, false),
                    case U:save() of
                        {ok,SavedEntry2} ->
                            krang_common:log("User ~p created...",[Email]),
                            {redirect,"signup_success"};
                        Error ->
                            {redirect,"action?error=user_creation_failed"}
                    end;
                Error ->
                    krang_common:log("DB Rec not saved"),
                    krang_common:log(Error),
                    {redirect,"action?error=registration_failed"}
            end
    end.

signup_success(_,_) ->
    {ok, []}.

confirm_email('GET',[]) ->
    VerifyToken = Req:query_param("vt"),
    Email       = Req:query_param("em"),
    io:format("VerifyToken : ~p\n",[VerifyToken]),
    case boss_db:find(krang_signup,[{'conf_hash','equals',VerifyToken},
                                    {'email','equals',Email}]) of 
        [] ->
            {redirect,krang_common:site_base_url()++"/auth/action"};
        [{krang_signup,Id, ConfHash, Email}] ->
            case boss_db:find(krang_user,[{'email','equals',Email}]) of 
                [] ->
                    {redirect,krang_common:site_base_url()++"/auth/action"};
                [{krang_user,UserId,Email,Passwd,false}] ->
                    ok = boss_db:delete(Id),
                    {ok,_SavedRec} 
                        = boss_db:save_record(
                            {krang_user,UserId,Email,Passwd,true}),
                    {ok,[]}
            end
    end;
confirm_email('GET',URI) ->
    krang_common:log("Unknown confirm email call on ~p:\n",[URI]),
    %% TODO: find a better way of redirecting....
    {redirect,krang_common:site_base_url()++"/auth/action"}.

