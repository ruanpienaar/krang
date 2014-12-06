-module(krang_gallery_controller, [Req]).
-compile(export_all).

-define(UPLOAD_PATH,"./src/view/gallery/uploads/").

index('GET',_) ->
    list('GET',[]).

view('GET', [GalleryName]) ->
    case boss_db:find(gallery,[{name,eq,GalleryName}]) of
        [{gallery,GalleryId,GalleryName,Images}] ->
            Is = lists:map(fun(ImageID) -> 
                case boss_db:find(ImageID) of 
                    {image,Id,Name} -> [{name,Name}];
                    _               -> []
                end
            end,Images),
            {ok,[{gallery_name,GalleryName}, {gallery_images,Is}]};
        _ ->
            {output,<<"gallery missing">>}
    end.

create('GET', URI) ->
    {ok,[]};
create('POST',URI) ->
    GalleryName = Req:post_param("name"),
    G = gallery:new(id, GalleryName,[]), 
    case G:save() of 
        {ok,SavedGallery} ->
            {redirect, [{action, "list"}]};
        {error, ErrorList} ->
            {ok, [{errors,ErrorList}, {gallery_name,GalleryName}]}
    end.

list('GET',_) ->
    Galleries = boss_db:find(gallery, []),
    {ok,[{galleries,Galleries}]}. 

upload('GET',[GalleryName]) ->
    {ok,[{gallery_name,GalleryName}]};
upload('GET',_) ->
    {redirect, [{action, "list"}]};
upload('POST',["upload",GalleryName]) ->
    PostFiles = Req:post_files(),
    lists:foreach(fun(I) -> 
        OrigName = I:original_name(),
        TempFile = I:temp_file(),
        _Size = I:size(),
        _HtmlFieldName = I:field_name(),
        NewI = image:new(id,OrigName),
        case NewI:save() of 
            {ok,{image,ImageId,OrigName}} ->
                case boss_db:find(gallery,[{name,eq,GalleryName}]) of
                    [] ->
                        io:format("Gallery Missing !!! \n\n"),
                        ok;
                    [{gallery,GalleryId,GalleryName,Images}] ->
                        {ok,_} = boss_db:save_record({gallery,GalleryId,GalleryName,[ ImageId | Images ]}),
                        case file:rename(TempFile, ?UPLOAD_PATH++OrigName) of
                            ok ->
                                io:format("File Moved !!! \n\n");
                            {error,Reason} ->
                                io:format("move error, reason: ~p !!! \n\n",[Reason]),
                                error
                        end
                end;
            _ ->
                io:format("mmmmmmmmmmm\n\n\n"),
                ok
        end
     end,PostFiles),
    {redirect, [{action, "list"}]}.

uploads('GET',[ImgName]) ->
    io:format("~p\n",[ImgName]),
    {ok,Bin} = file:read_file(?UPLOAD_PATH++ImgName),
    MimeType = mimetypes:filename(ImgName),
    {output,Bin,[{"Content-Type",MimeType}]}.
