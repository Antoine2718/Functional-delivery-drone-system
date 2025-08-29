(* arrêt d'urgence, atterrissage automatique en cas de batterie faible *)

open Types

let battery_threshold = 11.5

let monitor_and_mitigate telemetry =
  if telemetry.battery_v < battery_threshold then (
    Logger.log "Alerte sécurité: tension batterie faible (%0.2f V). Demande ReturnHome." telemetry.battery_v;
    Some Mission.ReturnHome
  ) else None
