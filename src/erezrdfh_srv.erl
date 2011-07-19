%%%-------------------------------------------------------------------
%%% File    : erezrdfh_srv.erl
%%% Author  : UENISHI Kota <kuenishi@gmail.com>
%%% Description : 
%%%
%%% Created : 19 Jul 2011 by UENISHI Kota <kuenishi@gmail.com>
%%%-------------------------------------------------------------------
-module(erezrdfh_srv).


%% rpc methods
-export([status/0, new_queue/1,del_queue/1,
	 push/2, pop/1]).

%% API
-export([init/1, handle_call/3, terminate/2, code_change/3]).

-record(state, {}).
%%====================================================================
%% API
%%====================================================================
init(_Argv)->
    ?MODULE=ets:new(?MODULE,[public,named_table,set]),
    {ok, #state{}}.

b2a(BinName)->erlang:binary_to_atom(BinName,latin1).
a2b(Name)->erlang:atom_to_binary(Name,latin1).

get_all_keys(_,'$end_of_table',List)->List;
get_all_keys(Table,Key,List)->
    Key2=ets:next(Table,Key),
    get_all_keys(Table,Key2,[a2b(Key)|List]).

status()->
    {reply, get_all_keys(?MODULE,ets:first(?MODULE), [])}.

new_queue(Name)->
    true=ets:insert(?MODULE,{b2a(Name),queue:new()}),
    {reply,ok}.

del_queue(Name)->
    true=ets:delete(?MODULE,b2a(Name)),
    {reply,ok}.
    
push(BinName,Obj)->
    Name=b2a(BinName),
    [{Name,Q}|_] = ets:lookup(?MODULE,Name),
    true=ets:insert(?MODULE,{Name,queue:in(Obj,Q)}),
    {reply,ok}.

pop(BinName)->
    Name=b2a(BinName),
    [{Name,Q}|_] = ets:lookup(?MODULE,Name),
    case queue:out(Q) of
	{{value,Item},Q2}->
	    true=ets:insert(?MODULE,{Name,Q2}),
	    {reply,Item};
	{empty,Q} ->
	    {reply,empty}
    end.
    

handle_call(_Request, _From, State)->
    Reply=ok,
    {reply, Reply, State}.

terminate(_Reason, State)->
    {ok, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%====================================================================
%% Internal functions
%%====================================================================


