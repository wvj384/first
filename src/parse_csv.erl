-module(parse_csv).
-export([parse/1]).

parse(Path) -> 
	{ok, Binary}=file:read_file(Path),
%	io:format("~w",[Binary]), 
	[parse_p(X) || X <- binary:split(Binary,<<"\n">>,[global])].

parse_p(X) ->
	List=binary:split(X,<<",">>,[global]), 
	list_to_tuple([ get_type(Y) || Y <- List]).

get_type(<<"\"",Rest/binary>>) -> 
	Size=size(Rest)-1, 
	<<String:Size/binary,_>>=Rest, 
	binary_to_list(String); 
get_type(B) ->
	List_B=binary_to_list(B), 
	try list_to_integer(List_B) of
	I -> I
	catch
	error:_ -> catch list_to_float(List_B)

end.
