open Types

val init : unit -> unit
val send_mission : mission -> unit
val run_simulation : float -> unit
val get_telemetry : unit -> telemetry option
