(* utils.ml
   Fonctions utilitaires générales.
*)

open Types

let clamp v a b =
  if v < a then a else if v > b then b else v

let now_seconds =
  (* simple compteur monotone basé sur Pervasives *)
  let t0 = Unix.gettimeofday () in
  fun () -> Unix.gettimeofday () -. t0

let vec3_add a b = { x = a.x +. b.x; y = a.y +. b.y; z = a.z +. b.z }
let vec3_sub a b = { x = a.x -. b.x; y = a.y -. b.y; z = a.z -. b.z }
let vec3_scale s v = { x = s *. v.x; y = s *. v.y; z = s *. v.z }

let distance3 a b =
  let dx = a.x -. b.x and dy = a.y -. b.y and dz = a.z -. b.z in
  sqrt (dx *. dx +. dy *. dy +. dz *. dz)

(* conversion GPS très simplifiée pour la simulation: lat/lon -> métrique *)
let earth_radius = 6.371e6

let gps_to_cartesian ~origin (g: gps) =
  (* projection equirectangulaire approximative autour d'une origine *)
  let deg_to_rad d = d *. Float.pi /. 180. in
  let dlat = deg_to_rad (g.lat -. origin.lat) in
  let dlon = deg_to_rad (g.lon -. origin.lon) in
  let x = earth_radius *. dlon *. cos (deg_to_rad origin.lat) in
  let y = earth_radius *. dlat in
  { x; y; z = g.alt -. origin.alt }

let cartesian_to_gps ~origin (v: vec3) =
  let rad_to_deg r = r *. 180. /. Float.pi in
  let dlat = v.y /. earth_radius in
  let dlon = v.x /. (earth_radius *. cos (origin.lat *. Float.pi /. 180.)) in
  { lat = origin.lat +. rad_to_deg dlat;
    lon = origin.lon +. rad_to_deg dlon;
    alt = origin.alt +. v.z }
