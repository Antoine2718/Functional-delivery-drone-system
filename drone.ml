(* Couche supérieure qui orchestre la simulation, la planification, les contrôleurs. *)

open Types
open Utils

let origin = Config.home_origin

let world = ref (Sim.init_world ~origin)

let mission = ref Mission.Idle

and telemetry = ref None

and stop_flag = ref false

(* noeuds internes *)
module Ctrls = struct
  let alt_pid_state = Controllers.make_pid_state ()
  let kp = 3.0 and ki = 0.5 and kd = 0.2
  let compute_controls sensors current_mission dt =
    (* contrôleur d'altitude basique *)
    let target_alt =
      match current_mission with
      | Mission.Takeoff a -> a
      | Mission.Transit _ -> 20.0
      | Mission.Deliver _ -> 5.0
      | Mission.ReturnHome -> 20.0
      | _ -> 0.0
    in
    let alt_cmd_raw, reset_fn = Controllers.pid_step alt_pid_state ~setpoint:target_alt ~measurement:sensors.gps.alt ~dt ~gains:(kp, ki, kd) in
    let normalized = clamp (alt_cmd_raw /. 20.0) 0.0 1.0 in
    let motor_cmds = List.init Config.motor_count (fun i -> (i, normalized)) in
    { motor_thrusts = motor_cmds; yaw_rate_cmd = 0.0 }
end

let init () =
  Random.self_init ();
  world := Sim.init_world ~origin;
  mission := Idle;
  stop_flag := false;
  telemetry := None;
  Logger.log "Initialisation du drone (simulation) complétée."

let send_mission m =
  mission := m;
  Logger.log "Mission reçue: %s" (
    match m with
    | Idle -> "Idle"
    | Takeoff a -> Printf.sprintf "Takeoff vers %0.1fm" a
    | Transit _ -> "Transit"
    | Deliver _ -> "Deliver"
    | ReturnHome -> "ReturnHome"
    | Land -> "Land"
  )

let get_telemetry () = !telemetry

let run_simulation duration =
  let t_end = now_seconds () +. duration in
  let dt = Config.dt in
  while now_seconds () < t_end && not !stop_flag do
    let sensors = Sim.read_sensors ~world:!world ~origin in
    let ctrl = Ctrls.compute_controls sensors !mission dt in
    Sim.step_physics !world ctrl dt;
    telemetry := Some {
      timestamp = now_seconds ();
      pos = Sim.read_sensors ~world:!world ~origin .gps;
      vel = !world.vel;
      orient = !world.orient;
      battery_v = !world.battery_v;
      mission = !mission;
    };
    Logger.log "Sim step: pos z=%0.2f m, battery=%0.2f V" (!world.pos.z) (!world.battery_v);
    Unix.sleepf dt
  done;
  Logger.log "Simulation terminée (durée simulée %0.1fs)." duration
