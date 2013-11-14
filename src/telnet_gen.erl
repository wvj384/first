-module(telnet_gen).
-export([start/1]).

start(Port) ->
	{ok,Socket} = gen_tcp:listen(Port,[binary,{active,false}]),
	Pid=spawn_link(fun() -> accepter(Socket) end),
	{ok, Pid}.

accepter(ListenS) ->
	{ok,Sock} = gen_tcp:accept(ListenS),
	spawn(fun() -> accepter(ListenS) end),
	handle(Sock).

handle(Sock) ->
	inet:setopts(Sock,[{active,once}]),
	receive
		{tcp,Sock,<<"save\r\n">>} ->
                        gen_serv_csv:save_csv(),
                        gen_tcp:send(Sock,<<"-> Done\r\n">>);
		{tcp,Sock,<<"read ",Rest/binary>>} ->
			Size=size(Rest)-2,
			<<Param:Size/binary,_/binary>> = Rest,
			case gen_serv_csv:read(gen_serv_csv,binary_to_list(Param)) of
				{ok,no_such_user} -> gen_tcp:send(Sock,<<"-> no_such_user\r\n">>);
				{ok,L} -> gen_tcp:send(Sock,parse_back(L))
			end;
		{tcp,Sock,<<"write ",Rest/binary>>} ->
			Size=size(Rest)-2,
                        <<Param:Size/binary,_/binary>> = Rest,
			case binary:split(Param,<<" ">>,[global]) of
				[A,B] ->
					AN=binary_to_list(A),
					BN=get_type(B),
					io:format("~p~n~p~n",[AN,BN]), 
					gen_serv_csv:write(gen_serv_csv,AN,BN),
		                        gen_tcp:send(Sock,<<"-> Done\r\n">>);
				_ -> gen_tcp:send(Sock,<<"-> incorrect\r\n">>)
			end;
			
		{tcp,Sock,<<"exit\r\n">>} -> gen_tcp:close(Sock);

		{tcp,Sock,Bin} -> gen_tcp:send(Sock,<<"-> unknown ", Bin/binary>>)
	end,
	handle(Sock).

get_type(B) ->
        try binary_to_integer(B) of
        I -> I
        catch
        error:_ -> catch binary_to_float(B)
end.


parse_back([X]) ->
        Bin= << <<(parse_to_b(Y))/binary,"  ">> || Y <- tuple_to_list(X)>>,
	<<"-> ",Bin/binary,"\r\n">>.

parse_to_b(X) when is_list(X) -> list_to_binary([X]);
parse_to_b(X) when is_integer(X) -> list_to_binary(integer_to_list(X));
parse_to_b(X) when is_float(X) -> list_to_binary(float_to_list(X)).
