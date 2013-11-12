-module(ping_pong).
-export([start/0,start_ping/2,ping/1]).

start() -> Pid=spawn(fun() -> ping(pong) end),
	spawn(fun() -> start_ping(Pid,ping) end),
	started.
	
ping(A) -> 
	{AR,PidR}=receive
	{B, Pid} -> {B, Pid}
	end,
	io:format("~p from ~p~n",[AR,PidR]),
	timer:sleep(random:uniform(3000)),
	PidR ! {A, self()},
	ping(A).  
start_ping(Pid,A) -> 
	timer:sleep(1000),
	Pid ! {A, self()},
	ping(A). 
