-module(erezrdfh_SUITE).

-include_lib("eunit/include/eunit.hrl").
push_and_pop(MPRC, V)->
    QueueName = <<"testo">>,
    {ok,true} = msgpack_rpc_client:call(MPRC, push, [QueueName,V]),
    Ret1 = msgpack_rpc_client:call(MPRC, pop, [QueueName]),
    ?assertEqual({ok,V}, Ret1).
    
easy_test()->
    ok=application:start(ranch),
    ok=erezrdfh:start(),

    {ok,S} = msgpack_rpc_client:connect(tcp,localhost,9199,[]),

    QueueName = <<"testo">>,
    Ret = msgpack_rpc_client:call(S, new_queue, [QueueName]),
    ?assertEqual({ok, true}, Ret),

    Value = 2344,
    Ret0 = msgpack_rpc_client:call(S, push, [QueueName,Value]),
    ?assertEqual({ok, true}, Ret0),

    A=2937845, B=238945029038453490, C=A+B,
    Ret0 = msgpack_rpc_client:call(S, push, [QueueName,C]),

    Ret1 = msgpack_rpc_client:call(S, pop, [QueueName]),
    ?assertEqual({ok,Value}, Ret1),
    Ret2 = msgpack_rpc_client:call(S, pop, [QueueName]),
    ?assertEqual({ok,C}, Ret2),

    {ok,_Result} = msgpack_rpc_client:call(S, status, []),

    push_and_pop(S, <<"adfasdfsfad">>),

    {ok,true} = msgpack_rpc_client:call(S, del_queue, [QueueName]),

    ok=msgpack_rpc_client:close(S),
    ok=application:stop(erezrdfh),
    ok=application:stop(ranch).
