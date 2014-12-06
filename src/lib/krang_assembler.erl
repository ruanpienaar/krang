-module(krang_assembler).
-export([to_prop/1]).

to_prop(Rec) when element(1,Rec) =:= image ->
    {image,Id,Name} = Rec,
    {ok,[{id,Id},{name,Name}]};
to_prop(Rec) when element(1,Rec) =:= gallery ->
    {gallery,Id,Name,Images} = Rec,
    {ok,[{id,Id},{name,Name},{images,Images}]}.

to_rec({image,{id,Id},{name,Name}}) ->
    {image,Id,Name};
to_rec({gallery,{id,Id},{name,Name},{images,Images}}) ->
    {gallery,Id,Name,Images}.