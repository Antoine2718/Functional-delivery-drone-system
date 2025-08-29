(* Moteur physique simplifié pour la simulation.
   
IMPORTANT : il s'agit d'un simulateur - aucune ligne ne commande du matériel réel.
*)

open Types
open Utils

(* état physique *)
type world = {
  mutable pos : vec3;
  mutable vel : vec3;
  mutable orient : orientation;
  mutable angvel : vec3;
  mutable motors : motor array;
  mutable battery_v : float;
}

let init_world ~origin =
  {
    pos = gps_to_cartesian ~origin { lat = origin.lat; lon = origin.lon; alt = origin.alt };
    vel = { x = 0.; y = 0.; z = 0. };
    orient = { roll = 0.; pitch = 0.; yaw = 0. };
    angvel = { x = 0.; y = 0.; z = 0. };
    motors = Array.init Config.motor_count (fun i -> { id = i; thrust = 0. });
    battery_v = Config.battery_nominal_v;
  }

let step_physics world (ctrl: control_output) dt =
  (* applique commandes sur moteurs puis intègre la dynamique très approximative *)
  (* mettre à jour thrusts *)
  Array.iteri (fun i m ->
    let cmd = try List.assoc i ctrl.motor_thrusts with Not_found -> 0.0 in
    (* normalisé [0..1] *)
    let cmd = clamp cmd 0.0 1.0 in
    m.thrust <- cmd *. Config.max_thrust_per_motor
  ) world.motors;
  (* somme de pousses verticales en approximation corps aligné *)
  let total_thrust =
    Array.fold_left (fun acc m -> acc +. m.thrust) 0. world.motors
  in
  (* accélération verticale *)
  let acc_z = (total_thrust /. Config.mass) -. Config.gravity in
  (* mise à jour vitesse et position *)
  world.vel <- { world.vel with z = world.vel.z +. acc_z *. dt };
  world.pos <- { world.pos with z = world.pos.z +. world.vel.z *. dt };
  (* consommation batterie simplifiée selon puissance fournie *)
  let power = total_thrust *. world.vel.z |> abs_float in
  let delta_v = (power *. dt) /. (3600.0 *. Config.battery_capacity_mah /. 1000.0) in
  world.battery_v <- world.battery_v -. delta_v;
  if world.battery_v < 10.0 then world.battery_v <- 10.0; (* plancher *)

  (* orientation / yaw simple: intégration yaw_rate *)
  world.angvel <- { world.angvel with z = ctrl.yaw_rate_cmd };
  world.orient <- { world.orient with yaw = world.orient.yaw +. world.angvel.z *. dt }

let read_sensors ~world ~origin =
  (* fournit des mesures bruitées simulées *)
  let noise f = (Random.float 1.0 -. 0.5) *. f in
  {
    imu_acc = { x = noise 0.02; y = noise 0.02; z = (-.Config.gravity) +. noise 0.05 };
    imu_gyro = { x = world.angvel.x +. noise 0.01; y = world.angvel.y +. noise 0.01; z = world.angvel.z +. noise 0.01 };
    gps = cartesian_to_gps ~origin world.pos;
    battery_v = world.battery_v +. noise 0.02;
    lidar_range = None;
  }
