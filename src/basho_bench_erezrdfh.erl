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

-define(QNAME, <<"erezrdfh_bench">>).

new(_Id)->

    Server = basho_bench_config:get(msgpack_server),
    Port = basho_bench_config:get(msgpack_port),

    {ok, S} = erezrdfh_client:connect(Server, Port, []),
    {ok, _} = erezrdfh_client:new_queue(S, ?QNAME),
    {ok, S}.

run(get, _KeyGen, _ValueGen, State)->
%    Key = 
    S = State,
    erezrdfh_client:pop(S, ?QNAME),
    {ok, S};

run(put, _KeyGen, ValueGen, State)->
%    Key = 
    S = State,
    erezrdfh_client:push(S, ?QNAME, ValueGen()),
    {ok, S};

run(delete, _KeyGen, ValueGen, State) ->
    S = State,
    erezrdfh_client:push(S, ?QNAME, ValueGen()),
    erezrdfh_client:pop(S, ?QNAME),
    {ok, S}.
