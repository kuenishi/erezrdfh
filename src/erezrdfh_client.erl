%%%-------------------------------------------------------------------
%%% @author UENISHI Kota <kuenishi@gmail.com>
%%% @copyright (C) 2013, UENISHI Kota
%%% @doc
%%%
%%% @end
%%% Created : 31 Mar 2013 by UENISHI Kota <kuenishi@gmail.com>
%%%-------------------------------------------------------------------
-module(erezrdfh_client).

-export([connect/3, new_queue/2, push/3, pop/2, del_queue/2,
         status/1, close/1]).

-spec connect(Host::any(), inet:port_number(), proplists:proplists())
             -> {ok, pid()} | {error, any()}.
connect(Host, Port, Opts) ->
    msgpack_rpc_client:connect(tcp, Host, Port, Opts).

-spec new_queue(pid(), atom()) -> {ok, true} | {error, any()}.
new_queue(S, QueueName) ->
    msgpack_rpc_client:call(S, new_queue, [QueueName]).

-spec push(pid(), atom(), msgpack:msgpack_term())
          -> {ok, true} | {error, term()}.
push(S, QueueName, Term) ->
    msgpack_rpc_client:call(S, push, [QueueName, Term]).

-spec pop(pid(), atom())-> {ok, msgpack:msgpack_term()} | {error, term()}.
pop(S, QueueName) ->
    msgpack_rpc_client:call(S, pop, [QueueName]).

-spec del_queue(pid(), atom())-> {ok, true} | {error, term()}.
del_queue(S, QueueName) ->
    msgpack_rpc_client:call(S, del_queue, [QueueName]).

-spec status(pid()) -> {ok, list()} | {error, term()}.
status(S) ->
    msgpack_rpc_client:call(S, status, []).

-spec close(pid) -> {ok, true} | {error, term()}.
close(S) ->
    msgpack_rpc_client:close(S).
