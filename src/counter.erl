-module(counter).
-behaviour(gen_server).
 
%% API
-export([start_link/0, inc/1]).
 
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
terminate/2, code_change/3]).
 
-define(SERVER, ?MODULE).

start_link() ->
gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).
 
%%% gen_server callbacks
init([]) ->
{ok, 0}.
 
handle_call(_Request, _From, Counter) ->
Reply = {ok, Counter+1},
{reply, Reply, Counter + 1}.
 
handle_cast(Msg, State) ->
io:format("got cast! ~p~n", [Msg]),
{noreply, State}.
 
handle_info(_Info, State) ->
{noreply, State}.
 
terminate(_Reason, _State) ->
ok.
 
code_change(_OldVsn, State, _Extra) ->
{ok, State}.
 
%%% Internal functions

inc(A) -> gen_server:call(A,inc).
