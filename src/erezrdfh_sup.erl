
-module(erezrdfh_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    erezrdfh_srv=ets:new(erezrdfh_srv,[public,named_table,set]),
    %% Child = {erezrdfh_process,
    %%          {msgpack_rpc_server,
    %%           start,
    %%           [erezrdfh_srv, 3, tcp, erezrdfh_srv,
    %%            [{port,9199}]]
    %%          },
    %%          permanent, 5000, worker, [erezrdfh_srv]},
    %% ok = supervisor:check_childspecs([Child]),
    {ok, { {one_for_one, 5, 10}, []} }.

%% -include_lib("eunit/include/eunit.hrl").
%% easy_test()->
%%     {ok,Pid}=erezrdfh_sup:start_link(),
%%     ?assert(is_pid(Pid)).
