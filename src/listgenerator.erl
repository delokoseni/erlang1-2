%%%-------------------------------------------------------------------
%%% @author Артур
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. март 2026 12:50
%%%----------------------------------------------------------
%%%
%%%
%%%
%%%
%%%
%%%
%%% ---------
-module(listgenerator).
-author("Артур").

%% API
-export([listGenerator/1, listGeneratorParallel/1]).

listGenerator(N) when N < 10 -> [N];
listGenerator(N) -> listGenerator(N div 10) ++ [N rem 10].

listGeneratorParallel(N) ->
    Self = self(),
    spawn(fun() -> worker(N, {result, Self}) end),
    receive
        {result, Res} -> Res
    end.

worker(N, {Tag, Parent}) when N < 10 ->
    Parent ! {Tag, [N]};

worker(N, {Tag, Parent}) ->
    Self = self(),
    spawn(fun() -> worker(N div 10, {left, Self}) end),
  spawn(fun() -> worker(N rem 10, {right, Self}) end),
    {Left, Right} = collect(undefined, undefined),
    Parent ! {Tag, Left ++ Right}.

collect(undefined, undefined) ->
    receive
        {left, L} -> collect(L, undefined);
        {right, R} -> collect(undefined, R)
    end;

collect(L, undefined) ->
    receive
        {right, R} -> {L, R}
    end;

collect(undefined, R) ->
    receive
        {left, L} -> {L, R}
    end.