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

-include_lib("basho_bench/include/basho_bench.hrl").

-define(QNAME, <<"erezrdfh_bench">>).

new(_Id)->
    %% Make sure the path is setup such that we can get at riak_client
    case code:which(mprc) of
        non_existing ->
            ?FAIL_MSG("~s requires erezrdfh module to be available on code path.\n",
                      [?MODULE]);
        _ ->
            ok
    end,
    try mprc:start() catch _:_ -> ok end,

    Server = basho_bench_config:get(msgpack_server),
    Port = basho_bench_config:get(msgpack_port),

%    {ok, MPRC} = mprc:connect(Server, Port, [tcp]),
    {ok, MPRC} = mprc:connect(Server, Port, []),
%    {{ok,<<"ok">>}, _} = mprc:call(MPRC, new_queue, [?QNAME]),
    {ok, MPRC}.

run(get, _KeyGen, _ValueGen, State)->
%    Key = 
    MPRC = State,
    {{ok,_}, MPRC2} = mprc:call(MPRC, pop, [?QNAME]),
    {ok, MPRC2};

run(put, _KeyGen, ValueGen, State)->
%    Key = 
    MPRC = State,
    {{ok,<<"ok">>}, MPRC2} = mprc:call(MPRC, push, [?QNAME, ValueGen()]),
    {ok, MPRC2};

run(delete, _KeyGen, ValueGen, State) ->
    {{ok,<<"ok">>}, MPRC} = mprc:call(State, push, [?QNAME, ValueGen()]),
    {{ok,_}, MPRC2} = mprc:call(MPRC, pop, [?QNAME]),
    {ok, MPRC2}.
