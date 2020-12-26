open Base

type t = {daemon: Daemon.t; sequence_left: string List.t}

let of_daemon (daemon : Daemon.t) =
  {daemon; sequence_left= daemon.breach_sequence}

let step ~(value : string) ~(buffer_left : int) (progress : t) : t =
  match (progress.sequence_left, progress.daemon.breach_sequence) with
  (* Not enough room in the buffer to complete, just bail *)
  | sequence_left, _ when List.length sequence_left > buffer_left ->
      progress
  (* The daemon has been activated *)
  | [], _ ->
      progress
  (* We hit the next value in the sequence left to process *)
  | head :: sequence_left, _ when String.equal head value ->
      {progress with sequence_left}
  (* We didn't get the next value, but we got the first value, so reset from there *)
  | _, head :: sequence_left when String.equal head value ->
      {progress with sequence_left}
  (* No value match, reset progress *)
  | _ ->
      {progress with sequence_left= progress.daemon.breach_sequence}

let step_all ~value ~buffer_left = List.map ~f:(step ~value ~buffer_left)

let is_done ~buffer_left {sequence_left; _} =
  match sequence_left with
  | [] ->
      true
  | incomplete ->
      List.length incomplete > buffer_left

let all_done ~buffer_left = List.for_all ~f:(is_done ~buffer_left)

let is_complete {sequence_left; _} = List.is_empty sequence_left

let get_complete_daemon progress =
  if is_complete progress then Some progress.daemon else None

let score {sequence_left; daemon} =
  match sequence_left with [] -> daemon.score | _ -> 0

let total_score = List.fold ~init:0 ~f:(fun acc dp -> acc + score dp)
