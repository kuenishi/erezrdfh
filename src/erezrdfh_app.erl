-module(erezrdfh_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    {ok, _Pid} = msgpack_rpc_server:start(erezrdfh_srv, 16, tcp,
                                         erezrdfh_srv, [{port, 9199}]),
    erezrdfh_sup:start_link().

stop(_State) ->
    ok.
