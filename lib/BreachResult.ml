open Base

type t = {path: Path.t; completed_daemons: Daemon.t List.t}

let score result =
  List.fold result.completed_daemons ~init:0 ~f:(fun acc d -> acc + d.score)

let mk ~path ~daemons_progress =
  let completed_daemons =
    List.filter_map daemons_progress ~f:DaemonProgress.get_complete_daemon
  in
  {path; completed_daemons}

let compare a b =
  match Int.compare (score a) (score b) with
  | 0 ->
      Int.compare
        (List.length a.completed_daemons)
        (List.length b.completed_daemons)
  | x ->
      x

let best_of a b = match compare a b with -1 -> b | _ -> a

let best_of_option a b =
  match (a, b) with
  | r, None | None, r ->
      r
  | Some a, Some b ->
      Some (best_of a b)
