-module(krang_mnesia_init).
-export([init/0, stop/1]).

-define(APPNAME,krang).

init() ->
    init_db ().

init_db () ->
  init_db ([node ()]).

init_db (Nodes) ->
  mnesia:create_schema(Nodes),
  mnesia:change_table_copy_type(schema, node(), disc_copies),
  mnesia:start(),
  ModelList = [ list_to_atom(M) || M <- boss_files:model_list(?APPNAME) ],
  ExistingTables = mnesia:system_info(tables),
  Tables = (ModelList ++ ['_ids_']) -- ExistingTables,
  create_model_tables(Nodes, Tables).

create_model_tables(_, []) -> ok;
create_model_tables(Nodes, [Model | Models]) ->
  [create_model_table(Nodes, Model)] ++
   create_model_tables(Nodes, Models).

create_model_table(Nodes, '_ids_') ->
  create_table(Nodes, '_ids_', [type, id]);

create_model_table(Nodes, Model) ->
  Record = boss_record_lib:dummy_record(Model),
  { Model, create_table(Nodes, Model, Record:attribute_names ()) }.

create_table(Nodes, Table, Attribs) ->
  {atomic,ok} = mnesia:create_table(Table,
    [ { disc_copies, Nodes   },
      { attributes,  Attribs } ]),
  ok.

stop(_) ->
    ok.