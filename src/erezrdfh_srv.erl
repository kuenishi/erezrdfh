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

b2a(BinName)->erlang:binary_to_atom(BinName,latin1).
a2b(Name)->erlang:atom_to_binary(Name,latin1).

get_all_keys(_,'$end_of_table',List)->List;
get_all_keys(Table,Key,List)->
    Key2=ets:next(Table,Key),
    get_all_keys(Table,Key2,[a2b(Key)|List]).

status()->
    {reply, []}. %get_all_keys(?MODULE,ets:first(?MODULE), [])}.

new_queue(Name)->
    {ok,Pid}=erezrdfh_queue:start_link(b2a(Name)),
    unlink(Pid),
%    register(b2a(Name),Pid),
    {reply,ok}.

del_queue(Name)->
    gen_server:call(b2a(Name), stop),
    {reply,ok}.
    
push(Name,Obj)->
    ok = gen_server:call(b2a(Name), {push,Obj}),
    {reply,ok}.

pop(Name)->
    case gen_server:call(b2a(Name), pop) of
	{ok, V} -> {reply, V};
	empty -> {reply, empty}
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


