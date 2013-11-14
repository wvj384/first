-module(telnet_csv).
-export([start/1]).

start(Port) ->
	{ok,Socket} = gen_tcp:listen(Port,[binary,{active,false}]),
	spawn(fun() -> accepter(Socket) end),
	ok.

accepter(ListenS) ->
	{ok,Sock} = gen_tcp:accept(ListenS),
	spawn(fun() -> accepter(ListenS) end),
	handle(Sock).

handle(Sock) ->
	inet:setopts(Sock,[{active,once}]),
	receive
		{tcp,Sock,<<"load\r\n">>} ->
			csv_ets:load(),
			gen_tcp:send(Sock,<<"-> Done\r\n">>);

		{tcp,Sock,<<"save\r\n">>} ->
			csv_ets:save(),
			gen_tcp:send(Sock,<<"-> Done\r\n">>);

		{tcp,Sock,<<"read ",Rest/binary>>} ->
			Size=size(Rest)-2,
			<<Param:Size/binary,_/binary>> = Rest,
			case csv_ets:read(binary_to_list(Param)) of
				no_such_user -> gen_tcp:send(Sock,<<"-> no_such_user\r\n">>);
				L -> gen_tcp:send(Sock,parse_back(L))
			end;
		{tcp,Sock,<<"write ",Rest/binary>>} ->
			Size=size(Rest)-2,
                        <<Param:Size/binary,_/binary>> = Rest,
			case binary:split(Param,<<" ">>,[global]) of
				[A,B] -> 
					Res=csv_ets:write(binary_to_list(A),get_type(B)),
		                        gen_tcp:send(Sock,<<"-> Done\r\n">>);
				_ -> gen_tcp:send(Sock,<<"-> incorrect\r\n">>)
			end;
			
		{tcp,Sock,<<"exit\r\n">>} -> gen_tcp:close(Sock);

		{tcp,Sock,Bin} -> gen_tcp:send(Sock,<<"-> unknown ", Bin/binary,"\r\n">>)
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
