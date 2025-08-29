(* Modèle simplifié de la batterie *)

let estimate_soc ~v =
  (* simple mapping linéaire entre tension et SOC*)
  let vmin = 10.0 and vmax = 16.8 in
  let soc = (v -. vmin) /. (vmax -. vmin) in
  max 0.0 (min 1.0 soc)
