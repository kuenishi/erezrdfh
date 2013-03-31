%%%-------------------------------------------------------------------
%%% @author UENISHI Kota <uenishi.kota@lab.ntt.co.jp>
%%% @copyright (C) 2011, UENISHI Kota
%%% @doc
%%%
%%% @end
%%% Created : 10 May 2011 by UENISHI Kota <uenishi.kota@lab.ntt.co.jp>
%%%-------------------------------------------------------------------
-module(basho_bench_erezrdfh).
-export([new/1, run/4]).

%% -include_lib("basho_bench/include/basho_bench.hrl").

-define(QNAME, <<"erezrdfh_bench">>).

new(_Id)->

    Server = basho_bench_config:get(msgpack_server),
    Port = basho_bench_config:get(msgpack_port),

    {ok, S} = erezrdfh_client:connect(Server, Port, []),
%    {{ok,<<"ok">>}, _} = mprc:call(MPRC, new_queue, [?QNAME]),
    {ok, S}.

run(get, _KeyGen, _ValueGen, State)->
%    Key = 
    S = State,
    {ok,true} = erezrdfh_client:pop(S, ?QNAME),
    {ok, S};

run(put, _KeyGen, ValueGen, State)->
%    Key = 
    S = State,
    {ok,true} = erezrdfh_client:push(S, ?QNAME, ValueGen()),
    {ok, S};

run(delete, _KeyGen, ValueGen, State) ->
    S = State,
    {ok,true} = erezrdfh_client:push(S, ?QNAME, ValueGen()),
    {ok,true} = erezrdfh_client:pop(S, ?QNAME),
    {ok, S}.
