-module(krang_user, [Id,Email,PasswdHash,Verified]).
-compile(export_all).

-define(SECRET_STRING, "Not telling secrets!").

session_identifier() ->
    mochihex:to_hex(erlang:md5(?SECRET_STRING ++ Id)).

check_password(Passwd) ->
    Salt = mochihex:to_hex(erlang:md5(Email)),
    user_lib:hash_password(Passwd, Salt) =:= PasswdHash.

login_cookies() ->
    [
        mochiweb_cookies:cookie("uid",
                                Id,
                                [{path, "/"}]),
        mochiweb_cookies:cookie("sid",
                                session_identifier(),
                                [{path, "/"}])
    ].