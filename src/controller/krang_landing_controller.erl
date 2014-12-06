-module(krang_landing_controller, [Req]).
-compile(export_all).

index(_,_) ->
    %% View landing/index.html
    {ok,List} = file:list_dir(code:priv_dir(krang)++"/static/img/"),
    GifList = lists:map(fun(I) -> [{name,I}] end, List),
    {ok,[{images,GifList}]}.