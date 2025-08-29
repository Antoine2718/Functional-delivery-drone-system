(* Contrôleurs PID pour altitude et attitude, très simplifiés pour la simulation *)

open Types
open Utils

type pid_state = {
  mutable integrator : float;
  mutable last_err : float option;
}

let make_pid_state () = { integrator = 0.0; last_err = None }

let pid_step state ~setpoint ~measurement ~dt ~gains:(kp, ki, kd) =
  let err = setpoint -. measurement in
  state.integrator <- state.integrator +. err *. dt;
  let d = match state.last_err with
    | None -> 0.0
    | Some last -> (err -. last) /. dt
  in
  state.last_err <- Some err;
  let out = kp *. err +. ki *. state.integrator +. kd *. d in
  out, (fun () -> state.integrator <- 0.0)

(* wrapper retournant commande normalisée [0..1] *)
let pid_update ~setpoint ~measurement ~dt (kp, ki, kd) =
  let state = make_pid_state () in
  let out, reset = pid_step state ~setpoint ~measurement ~dt ~gains:(kp, ki, kd) in
  let norm = clamp (out /. 20.0) 0.0 1.0 in
  (norm, reset)
