-module(krang_common).
-compile(export_all).
-include("../include/krang_logger.hrl").

log(Msg) ->
    ?INFO(Msg,[]).
