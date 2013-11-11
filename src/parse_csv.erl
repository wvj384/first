-module(parse_csv).
-export([parse/1]).

parse(Path) -> 
	{ok, Binary}=file:read_file(Path),
%	Binary. 
	[parse_p(binary:split(X,<<",">>,[global])) || X <- binary:split(Binary,<<"\n">>,[global])].

parse_p(List) -> [binary_to_list(X) || X <- List].
