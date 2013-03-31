%%%-------------------------------------------------------------------
%%% File    : erezrdfh.erl
%%% Author  : UENISHI Kota <kuenishi@gmail.com>
%%% Description : 
%%%
%%% Created : 19 Jul 2011 by UENISHI Kota <kuenishi@gmail.com>
%%%-------------------------------------------------------------------
-module(erezrdfh).

-export([start/0, stop/0]).

start()->
    ok=application:start(erezrdfh).

stop()->
    ok=application:stop(erezrdfh).
%    halt(). % FIXME: separate from stop/0 call.


-include_lib("eunit/include/eunit.hrl").
easy_test()->
    ok=application:start(ranch),
    ok=application:start(erezrdfh),
    ok=application:stop(erezrdfh),
    ok=application:stop(ranch).
