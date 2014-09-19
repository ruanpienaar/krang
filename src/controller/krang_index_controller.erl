-module(krang_index_controller, [Req]).
-compile(export_all).

landing(_,_) ->
    {redirect,"index"}.

index(_,_) ->
    {ok,[]}.