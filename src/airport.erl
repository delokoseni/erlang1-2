-module(airport).

-export([
    start_control/0,
    start_sensors/0,
    start_autotrap/0,
    start_loader/0,
    start_airplane/0,
    control/0,
    sensors/0,
    autotrap/0,
    loader/0,
    airplane/0
]).

node_name(Name) ->
    {_, Host} = lists:splitwith(fun(X) -> X =/= $@ end, atom_to_list(node())),
    list_to_atom(atom_to_list(Name) ++ Host).

start_control() ->
    register(control, spawn(?MODULE, control, [])).

control() ->
    io:format("[control ~p] Started~n", [self()]),
    loop_control().

loop_control() ->
    receive
        {landing_request, AirplanePid} ->
            io:format("[control] Landing request~n"),

            {sensors, node_name(sensors)} ! {get_status, self()},

            receive
                {runway_status, Status} ->
                    io:format("[control] Runway status: ~p~n", [Status]),
                    handle_runway_status(Status, AirplanePid)
            end,
            loop_control()
    end.

handle_runway_status(0, AirplanePid) ->
    AirplanePid ! {landing_denied};

handle_runway_status(1, AirplanePid) ->
    AirplanePid ! {landing_allowed},
    wait_for_landing().

wait_for_landing() ->
    receive
        {landed} ->
            io:format("[control] Plane landed~n"),

            {autotrap, node_name(autotrap)} ! {start, self()},
            receive {done_autotrap} -> ok end,

            {loader, node_name(loader)} ! {start, self()},
            receive {done_loader} -> ok end
    end.

start_sensors() ->
    register(sensors, spawn(?MODULE, sensors, [])).

sensors() ->
    io:format("[sensors ~p] Started~n", [self()]),
    loop_sensors().

loop_sensors() ->
    receive
        {get_status, From} ->
            Status = rand:uniform(2) - 1,
            io:format("[sensors] Status: ~p~n", [Status]),
            From ! {runway_status, Status},
            loop_sensors()
    end.

start_autotrap() ->
    register(autotrap, spawn(?MODULE, autotrap, [])).

autotrap() ->
    io:format("[autotrap ~p] Started~n", [self()]),
    loop_autotrap().

loop_autotrap() ->
    receive
        {start, ControlPid} ->
            io:format("[autotrap] Working...~n"),
            timer:sleep(2000),
            io:format("[autotrap] Done~n"),
            ControlPid ! {done_autotrap},
            loop_autotrap()
    end.

start_loader() ->
    register(loader, spawn(?MODULE, loader, [])).

loader() ->
    io:format("[loader ~p] Started~n", [self()]),
    loop_loader().

loop_loader() ->
    receive
        {start, ControlPid} ->
            io:format("[loader] Working...~n"),
            timer:sleep(2000),
            io:format("[loader] Done~n"),
            ControlPid ! {done_loader},
            loop_loader()
    end.

start_airplane() ->
    spawn(?MODULE, airplane, []).

airplane() ->
    io:format("[airplane ~p] Flying~n", [self()]),

    {control, node_name(control)} ! {landing_request, self()},

    receive
        {landing_denied} ->
            io:format("[airplane] Landing denied~n");

        {landing_allowed} ->
            io:format("[airplane] Landing allowed~n"),
            timer:sleep(1000),
            {control, node_name(control)} ! {landed}
    end.