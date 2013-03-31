%%%-------------------------------------------------------------------
%%% File    : erezrdfh_srv.erl
%%% Author  : UENISHI Kota <kuenishi@gmail.com>
%%% Description : 
%%%
%%% Created : 19 Jul 2011 by UENISHI Kota <kuenishi@gmail.com>
%%%-------------------------------------------------------------------
-module(erezrdfh_srv).

-include_lib("eunit/include/eunit.hrl").
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
    {ok, #state{}}.

%b2a(BinName)->erlang:binary_to_atom(BinName,latin1).
%a2b(Name)->erlang:atom_to_binary(Name,latin1).

%% get_all_keys(_,'$end_of_table',List)->List;
%% get_all_keys(Table,Key,List)->
%%     Key2=ets:next(Table,Key),
%%     get_all_keys(Table,Key2,[a2b(Key)|List]).

status()->
    []. %get_all_keys(?MODULE,ets:first(?MODULE), [])}.

new_queue(Name)->
    ok=gen_server:call(erezrdfh_queue, {new_queue, Name}),
    true.

del_queue(Name)->
    ok=gen_server:call(erezrdfh_queue, {del_queue, Name}),
    true.
    
push(Name,Obj)->
    ok = gen_server:call(erezrdfh_queue, {push,Name,Obj}),
    true.

pop(Name)->
    case gen_server:call(erezrdfh_queue, {pop, Name}) of
	{ok, V} -> V;
	{error, empty} -> <<"empty">>
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


