(* interface du contrôleur *)
open Types

val pid_update :
  setpoint:float ->
  measurement:float ->
  dt:float ->
  (float * float * float) ->  (* gains P,I,D *)
  (float * (float -> unit))   (* sortie normale [0..1], et reset function pour l'intégrateur *)
