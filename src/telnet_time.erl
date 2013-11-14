-module(telnet_time).
-export([start/1]).

start(Port) ->
	{ok,Socket} = gen_tcp:listen(Port,[binary,{active,false}]),
	spawn(fun() -> accepter(Socket) end),
	ok.

accepter(ListenS) ->
	{ok,Sock} = gen_tcp:accept(ListenS),
	spawn(fun() -> accepter(ListenS) end),
	self() ! send,
	handle(Sock).

handle(Sock) ->
	inet:setopts(Sock,[{active,once}]),
	receive
		send ->
			[H,M,S]=[integer_to_binary(X) || X<- tuple_to_list(time())],
			Time = <<H/binary, " hours ", M/binary, " minutes ", S/binary, " seconds\n">>,
			gen_tcp:send(Sock,Time);
		{tcp,Sock,<<"exit\r\n">>} -> gen_tcp:close(Sock)
	end,
	erlang:send_after(5000,self(),send),
	handle(Sock).
	 
