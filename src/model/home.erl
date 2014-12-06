-module(home, [Id, Text]).
-compile(export_all).

validation_tests() ->
    [{fun() -> length(Text) > 0 end, 
        "Greeting must be non-empty!"},
     {fun() -> length(Text) =< 140 end,
        "Greeting must be tweetable, and not too large!"}
    ].

before_create() ->
    %% Abort with :
    %% {error, "Do you kiss your mother with that mouth?"}
    ModifiedRecord = set(text,re:replace(Text,"masticate", "chew",[{return, list}])),
    {ok, ModifiedRecord}.

% after_create() ->
%     boss_mq:push("new-greetings", THIS).

%% WAtch:
% {ok, WatchId3} = boss_news:watch("homes",
%        fun(created, NewGreeting) ->
%            boss_mq:push("new-homes", NewGreeting);
%           (deleted, OldGreeting) ->
%            boss_mq:push("old-homes", OldGreeting) end).
