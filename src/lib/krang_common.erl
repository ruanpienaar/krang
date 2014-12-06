-module(krang_common).
-compile(export_all).

log(Msg) ->
    io:format("~p\n",[Msg]).
