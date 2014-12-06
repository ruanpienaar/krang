-module(krang_page_controller, [Req]).
-compile(export_all).

home('GET', URI) ->
    % io:format("URI : ~p\n",[URI]),
    {output, "Hello, world!"}.

home_json('GET',_) ->
    {json,[{homepage,"Hello World!"}]}.

home_template('GET',_)  ->
    {ok, [{item, "Hello, world!"}]}.

list('GET',_) ->
    Recs = boss_db:find(home, []),
    {ok, [{items, Recs}]}.

create('GET', []) ->
    %% ok OR {ok,[]} is fine
    ok;
create('POST', []) ->
    HomeText = Req:post_param("home_text"),
    NewHomeText = home:new(id, HomeText),
    case NewHomeText:save() of
        {ok, SavedGreeting} ->
            {redirect, [{action, "list"}]};
        {error, ErrorList} ->
            {ok, [{errors, ErrorList}, {new_msg, NewHomeText}]}
    end.

goodbye('POST', []) ->
    ok = boss_db:delete(Req:post_param("del_id")),
    {redirect, [{action, "list"}]}.

send_test_message('GET', []) ->
    TestMessage = "Free at last!",
    boss_mq:push("test-channel", TestMessage),
    {output, TestMessage}.

pull('GET', [LastTimestamp]) ->
    {ok, Timestamp, Greetings} = boss_mq:pull("new-greetings", list_to_integer(LastTimestamp)),
    {json, [{timestamp, Timestamp}, {greetings, Greetings}]}.

live('GET', []) ->
    Greetings = boss_db:find(greeting, []),
    Timestamp = boss_mq:now("new-greetings"),
    {ok, [{greetings, Greetings}, {timestamp, Timestamp}]}.