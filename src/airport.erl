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

start_control() ->
    Pid = spawn(?MODULE, control, []),
    global:register_name(control, Pid),
    io:format("[control] Started and registered globally~n"),
    Pid.

control() ->
    io:format("[control ~p] Started~n", [self()]),
    loop_control().

loop_control() ->
    SensorsPid = global:whereis_name(sensors),
    AutotrapPid = global:whereis_name(autotrap),
    LoaderPid = global:whereis_name(loader),
    receive
        {landing_request, AirplanePid} ->
            io:format("[control] Landing request from ~p~n", [AirplanePid]),

            SensorsPid ! {get_status, self()},
            receive
                {runway_status, Status} ->
                    io:format("[control] Runway status: ~p~n", [Status]),
                    handle_runway_status(Status,
                        AirplanePid,
                        AutotrapPid,
                        LoaderPid)
            end,
            loop_control()
    end.

handle_runway_status(0, AirplanePid, _AutotrapPid, _LoaderPid) ->
    AirplanePid ! {landing_denied};
handle_runway_status(1, AirplanePid, AutotrapPid, LoaderPid) ->
    AirplanePid ! {landing_allowed},
    wait_for_landing(AirplanePid, AutotrapPid, LoaderPid).

wait_for_landing(AirplanePid, AutotrapPid, LoaderPid) ->
    receive
        {landed} ->
            io:format("[control] Plane landed~n"),
            AutotrapPid ! {start, self()},
            receive {done_autotrap} -> ok end,
            LoaderPid ! {start, self()},
            receive {done_loader} -> ok end
    end.

start_sensors() ->
    Pid = spawn(?MODULE, sensors, []),
    global:register_name(sensors, Pid),
    io:format("[sensors] Started and registered globally~n"),
    Pid.

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
    Pid = spawn(?MODULE, autotrap, []),
    global:register_name(autotrap, Pid),
    io:format("[autotrap] Started and registered globally~n"),
    Pid.

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
    Pid = spawn(?MODULE, loader, []),
    global:register_name(loader, Pid),
    io:format("[loader] Started and registered globally~n"),
    Pid.

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
    Pid = spawn(?MODULE, airplane, []),
    io:format("[airplane] Started ~p~n", [Pid]),
    Pid.

airplane() ->
    ControlPid = global:whereis_name(control),
    io:format("[airplane ~p] Flying~n", [self()]),
    ControlPid ! {landing_request, self()},
    receive
        {landing_denied} ->
            io:format("[airplane] Landing denied~n");
        {landing_allowed} ->
            io:format("[airplane] Landing allowed~n"),
            timer:sleep(1000),
            ControlPid ! {landed}
    end.