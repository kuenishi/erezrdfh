%% Copyright (C) 2009-2013 UENISHI Kota
%%
%% Created : 17 Feb 2013
%%
-module(erezrdfh_queue_nif).
-on_load(init/0).

-export([init/0, new_queue/1, del_queue/1,
         push/2, pop/1]).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

init()->
    SoName =
        case code:priv_dir(?MODULE) of
            {error, bad_name} ->
                case code:which(?MODULE) of
                    Filename when is_list(Filename) ->
                        filename:join([filename:dirname(Filename),"../priv", "erezrdfh_drv"]);
                    _ ->
                        filename:join("../priv", "erezrdfh_drv")
                end;
            Dir ->
                filename:join(Dir, "erezrdfh_drv")
        end,
    erlang:load_nif(SoName, 0).

-spec new_queue(binary()) -> ok.
new_queue(_)->
    throw(nif_not_loaded).

del_queue(_)->
    throw(nif_not_loaded).

push(_,_)->
    throw(nif_not_loaded).

pop(_)->
    throw(nif_not_loaded).


-ifdef(TEST).

mini_test()->
    ok = erezrdfh_queue_nif:new_queue(<<"hoge">>).

-endif.
