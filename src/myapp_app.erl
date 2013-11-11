-module(myapp_app).
-include_lib("proper/include/proper.hrl").
-include_lib("eunit/include/eunit.hrl").
-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
-export([find_el/2,del_el/2,div_l/2,split/1]).
%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    myapp_sup:start_link().
stop(_State) ->
    ok.
find_el(1,[H|_]) -> H;
find_el(El,[_|T]) when El>1 -> find_el(El-1,T).

%prop_delete() ->
%	?FORALL({X,L}, {integer(),list(integer())},
%		not lists:member(X,lists:delete(X,L))).

prop_find() ->
	?FORALL({X,L}, {integer(),list(integer())},
	lists:nth(X,L)=:=find_el(X,L)).

proper_test() ->
	?assertEqual([],
	proper:module(?MODULE,[{to_file,user},{numtests,1000}])
	).

del_el(El,List) -> del_el(El,List,[]).
del_el(El,[_|T],Acc) when El==1 -> del_el(El-1,T,Acc);
del_el(El,[H|T],Acc) -> del_el(El-1,T,[H|Acc]);
del_el(_,[], Acc) -> lists:reverse(Acc).


div_l(Len,List) -> div_l(Len,List,[]).
div_l(1,[H|T],Acc) -> {lists:reverse([H|Acc]),T};
div_l(Len,[H|T],Acc) -> div_l(Len-1,T,[H|Acc]).

first_test() ->
	?assertEqual(find_el(2,[1,3,5]),3),
	?assertError(badarith, find_el(abc,[1,2])).

split(List) -> split(List, []).
split([],Acc) -> lists:reverse(Acc);
split([H|T],Acc) -> split(T,norm(H,Acc)).

norm([H|T],Acc) -> norm(T,norm(H,Acc));
norm([],Acc) -> Acc;
norm(Var,Acc) -> [Var|Acc].


