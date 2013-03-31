%%%-------------------------------------------------------------------
%%% File    : erezrdfh_queue.erl
%%% Author  : UENISHI Kota <kuenishi@gmail.com>
%%% Description : 
%%%
%%% Created : 19 Jul 2011 by UENISHI Kota <kuenishi@gmail.com>
%%%-------------------------------------------------------------------
-module(erezrdfh_queue).

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

% -record(state, {}).

%%====================================================================
%% API
%%====================================================================
%%--------------------------------------------------------------------
%% Function: start_link() -> {ok,Pid} | ignore | {error,Error}
%% Description: Starts the server
%%--------------------------------------------------------------------
start_link() ->
    ?MODULE=ets:new(?MODULE,[public,named_table,set]),
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%====================================================================
%% gen_server callbacks
%%====================================================================

%%--------------------------------------------------------------------
%% Function: init(Args) -> {ok, State} |
%%                         {ok, State, Timeout} |
%%                         ignore               |
%%                         {stop, Reason}
%% Description: Initiates the server
%%--------------------------------------------------------------------
init([]) ->
    {ok, none}.

%%--------------------------------------------------------------------
%% Function: %% handle_call(Request, From, State) -> {reply, Reply, State} |
%%                                      {reply, Reply, State, Timeout} |
%%                                      {noreply, State} |
%%                                      {noreply, State, Timeout} |
%%                                      {stop, Reason, Reply, State} |
%%                                      {stop, Reason, State}
%% Description: Handling call messages
%%--------------------------------------------------------------------
handle_call({new_queue, Name}, _, Q) ->
    ets:insert_new(?MODULE, {Name, queue:new()}),
    {reply, ok, Q};

handle_call({push,Name,V}, _, Q)->
    case ets:lookup(?MODULE, Name) of
        [{Name,E0}] ->
            E = queue:in(V,E0),
            ets:insert(?MODULE, {Name, E}),
            {reply, ok, Q};
        [] ->
            {reply, {error, no_such_queue}, Q}
    end;
            
handle_call({pop, Name}, _, Q)->
    case ets:lookup(?MODULE, Name) of
        [{Name,E0}] ->
            case queue:out(E0) of
                {{value,Item},E}->
                    ets:insert(?MODULE, {Name, E}),
                    {reply,{ok,Item}, Q};
                {empty,_} ->
                    {reply,{error,empty}, Q}
            end;
        [] ->
            {reply, {error, no_such_queue}, Q}
    end;

handle_call(stop,_From,Q)->
    {stop, normal, ok,Q};
handle_call(_Request, _From, Q) ->
    Reply = ok,
    {reply, Reply, Q}.

%%--------------------------------------------------------------------
%% Function: handle_cast(Msg, State) -> {noreply, State} |
%%                                      {noreply, State, Timeout} |
%%                                      {stop, Reason, State}
%% Description: Handling cast messages
%%--------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% Function: handle_info(Info, State) -> {noreply, State} |
%%                                       {noreply, State, Timeout} |
%%                                       {stop, Reason, State}
%% Description: Handling all non call/cast messages
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% Function: terminate(Reason, State) -> void()
%% Description: This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any necessary
%% cleaning up. When it returns, the gen_server terminates with Reason.
%% The return value is ignored.
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% Func: code_change(OldVsn, State, Extra) -> {ok, NewState}
%% Description: Convert process state when code is changed
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%--------------------------------------------------------------------
%%% Internal functions
%%--------------------------------------------------------------------
