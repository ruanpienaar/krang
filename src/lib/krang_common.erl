-module(krang_common).

-export([ log/1,
          log/2,
          from_binary/1,
          to_binary/1,
          site_base_url/0,
          rand_hash_32/0,
          md5_hash/1
]).

-include("../include/krang_logger.hrl").

log(Msg) ->
    ?INFO(Msg,[]).

log(Msg,Fmt) ->
    ?INFO(Msg,Fmt).

-spec from_binary( Binary::binary() ) -> string().
%% @doc converts Binary into its hexadecimal representation
from_binary(<<Hi:4,Lo:4,Rest/binary>>) ->
  [int_to_char(Hi), int_to_char(Lo) | from_binary(Rest) ];

from_binary(<<>>) ->
  [].

-spec to_binary( HexString::string() ) -> binary().
%% @doc converts the hexadecimal string HexString into its binary representation
to_binary(Binary) when is_binary(Binary) ->
  to_binary( binary_to_list(Binary) );

to_binary([HiChar,LoChar|Rest]) ->
  Hi = char_to_int(HiChar),
  Lo = char_to_int(LoChar),
  ERest = to_binary(Rest),
  <<Hi:4, Lo:4, ERest/binary>>;

to_binary([]) ->
  <<>>.

int_to_char(Int) when is_integer(Int), Int >= 0, Int =< 9 -> $0 + Int;

int_to_char(Int) when is_integer(Int), Int > 9, Int =< 15 ->
  (Int - 10) + $A.


char_to_int(Char) when is_integer(Char), Char >= $0, Char =< $9 ->
  Char - $0;

char_to_int(Char) when is_integer(Char), Char >= $A, Char =< $F ->
  (10 + (Char - $A));

char_to_int(Invalid) ->
  throw({invalid_hex_character, [Invalid] }).

site_base_url() ->
    {ok,[H|_]} = application:get_env(krang,domains),
    "http://"++H++":8001".

rand_hash_32() ->
    from_binary( crypto:strong_rand_bytes(32) ).

md5_hash(Pwd) ->
    crypto:hash(md5,Pwd).