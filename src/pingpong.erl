%%%-------------------------------------------------------------------
%%% @author sergey
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Mar 2026 18:58
%%%-------------------------------------------------------------------
-module(pingpong).
-author("sergey").


%% API
-export([main/0]).

ping(PidPong) ->
  io:format("[ping]I'm Ping. Sending ping to Pong (Pid ~w)...~n", [PidPong]),
  PidPong ! {ping, self()},
  io:format("[ping]Waiting for pong...~n"),
  receive
    pong -> io:format("[ping]pong received from Pong~n",[])
  end,
  io:format("[ping]Ping done!~n").

pong() ->
  io:format("[pong]I'm Pong, my pid is ~w~n", [self()]),
  receive
    {ping, PidPing} -> io:format("[pong]Ping received, sending pong to ~w~n", [PidPing]), PidPing ! pong;
    true -> io:format("[pong]Bad message")
  end,
  io:format("[pong]Pong done~n").


main() -> spawn(fun() -> ping(
                                spawn(fun() -> pong() end))
                          end).






