(* types.ml
   Définitions de types partagés pour le simulateur de drone.
*)

type vec3 = { x : float; y : float; z : float }

type gps = { lat : float; lon : float; alt : float }

type orientation = { roll : float; pitch : float; yaw : float }

type motor = {
  id : int;
  thrust : float; (* poussée actuelle en newtons simulés *)
}

type sensors_data = {
  imu_acc : vec3;    (* accélération mesurée *)
  imu_gyro : vec3;   (* vitesse angulaire mesurée *)
  gps : gps;         (* position GNSS simulée *)
  battery_v : float; (* tension de batterie simulée *)
  lidar_range : float option; (* distance mesurée par lidar, si disponible *)
}

type control_output = {
  motor_thrusts : (int * float) list; (* id, thrust commandée [0..1] normalisée *)
  yaw_rate_cmd : float;               (* commande de rotation autour de z *)
}

type mission =
  | Idle
  | Takeoff of float  (* altitude cible *)
  | Transit of gps    (* aller à un point GPS *)
  | Deliver of gps    (* largage / point de livraison *)
  | ReturnHome
  | Land

type telemetry = {
  timestamp : float;
  pos : gps;
  vel : vec3;
  orient : orientation;
  battery_v : float;
  mission : mission;
}
