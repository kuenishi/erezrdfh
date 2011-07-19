-module(erezrdfh_SUITE).

-include_lib("eunit/include/eunit.hrl").
push_and_pop(MPRC, V)->
    QueueName = <<"testo">>,
    {Ret0, MPRC2} = mprc:call(MPRC, push, [QueueName,V]),
    {Ret1, MPRC3} = mprc:call(MPRC2, pop, [QueueName]),
    ?assertEqual({ok,V}, Ret1),
    MPRC3.
    
easy_test()->
    ok=erezrdfh:start(),
    ok=mprc:start(),

    {ok,S} = mprc:connect(localhost,9199,[]),

    QueueName = <<"testo">>,
    {Ret,MPRC0} = mprc:call(S, new_queue, [QueueName]),
    ?assertEqual({ok, true}, Ret),

    Value = 2344,
    {Ret0, MPRC1} = mprc:call(MPRC0, push, [QueueName,Value]),

    ?assertEqual({ok, true}, Ret0),

    A=2937845, B=238945029038453490, C=A+B,
    {Ret0, MPRC2} = mprc:call(MPRC1, push, [QueueName,C]),


    {Ret1, MPRC3} = mprc:call(MPRC2, pop, [QueueName]),
    ?assertEqual({ok,Value}, Ret1),
    {Ret2, MPRC4} = mprc:call(MPRC3, pop, [QueueName]),
    ?assertEqual({ok,C}, Ret2),

    {{ok,_Result},_} = mprc:call(MPRC4, status, []),

    push_and_pop(MPRC4, <<"adfasdfsfad">>),

    {{ok,true},_} = mprc:call(S, del_queue, [QueueName]),

    ok=mprc:stop(),
    ok=erezrdfh:stop().
