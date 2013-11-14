-module(gen_serv_csv).
-behaviour(gen_server).
 
%% API
-export([start_link/0,stop/1,read/2,write/3,save_csv/0]).
 
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
terminate/2, code_change/3]).
 
-define(SERVER, ?MODULE).

start_link() ->
gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).
 
%%% gen_server callbacks
init([]) ->
csv_ets:load(),
% State = Saved
{ok, true}.
 
handle_call({read,Name}, _From, State) ->
Reply ={ok, csv_ets:read(Name)},
{reply, Reply, State};
handle_call({write, Name, Amount}, _From, _State) ->
Reply ={ok, csv_ets:write(Name,Amount)},
{reply, Reply, false}.
 
handle_cast(stop, State) ->
{stop,normal,State};
handle_cast(Msg, State) ->
io:format("got cast! ~p~n", [Msg]),
{noreply, State}.
 
handle_info(_Info, State) ->
{noreply, State}.
 
terminate(_Reason, true) ->
%io:format("~p~n",[State]),
ok;
terminate(_Reason, false) ->
csv_ets:save(),
ok.
 
code_change(_OldVsn, State, _Extra) ->
{ok, State}.
 
%%% Internal functions

read(Pid,User) ->
	gen_server:call(Pid,{read,User}).

write(Pid,User,Amount) ->
	gen_server:call(Pid,{write,User,Amount}).

stop(Pid) ->
	gen_server:cast(Pid,stop).

save_csv() ->
	csv_ets:save().
