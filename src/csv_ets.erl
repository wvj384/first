-module(csv_ets).
-export([load/0,read/1,write/2,save/0]).

load() ->
	ets:new(users,[named_table]), 
	ets:insert(users,parse_csv:parse("/root/wvj384/first/users.csv")).
read(UserId) -> 
	case ets:lookup(users,UserId) of
	[] -> no_such_user;
	L -> L
	end.
write(UserId,Amount) -> 
	ets:insert(users,[{UserId,Amount}]).

save() -> 
	List= << <<(parse_back(X))/binary,"\n">> || X <- ets:tab2list(users)>>,
	file:write_file("/root/wvj384/first/users.csv", List).

parse_back(X) -> 
	<< <<(parse_to_b(Y))/binary,",">> || Y <- tuple_to_list(X)>>.

parse_to_b(X) when is_list(X) -> list_to_binary(["\""|X]++"\"");
parse_to_b(X) when is_integer(X) -> list_to_binary(integer_to_list(X));
parse_to_b(X) when is_float(X) -> list_to_binary(float_to_list(X)).
