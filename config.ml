(* Paramètres configurables (simulation) *)

let dt = 0.02 (* pas de simulation en secondes (50 Hz) *)

let home_origin = { Types.lat = 48.8566; lon = 2.3522; alt = 35.0 } (* Paris par défaut *)

let mass = 1.5 (* kg, masse du drone simulé *)
let gravity = 9.80665

let max_thrust_per_motor = 15.0 (* newtons par moteur maximum dans la simulation *)

let motor_count = 4

let battery_nominal_v = 16.8 (* 4S LiPo en volts *)
let battery_capacity_mah = 5200.0
let battery_internal_resistance = 0.05
