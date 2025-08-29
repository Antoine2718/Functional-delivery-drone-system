(* Stockage orientée simulation *)

let log_mutex = Mutex.create ()

let log fmt =
  Printf.ksprintf (fun s ->
    Mutex.lock log_mutex;
    let t = Unix.gettimeofday () in
    Printf.printf "[%0.3f] %s\n%!" t s;
    Mutex.unlock log_mutex
  ) fmt
