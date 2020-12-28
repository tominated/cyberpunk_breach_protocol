open Base

type t = {path: Path.t; completed_daemons: Daemon.t List.t}

let score result =
  List.fold result.completed_daemons ~init:0 ~f:(fun acc d -> acc + d.score)

let mk ~path ~daemons_progress =
  let path = List.rev path in
  let completed_daemons =
    List.filter_map daemons_progress ~f:DaemonProgress.get_complete_daemon
  in
  {path; completed_daemons}

let equal a b =
  Path.equal a.path b.path
  && List.equal Daemon.equal a.completed_daemons b.completed_daemons

let to_string {path; completed_daemons} =
  Printf.sprintf "path: %s\ncompleted:\n%s" (Path.to_string path)
    (String.concat ~sep:"\n" @@ List.map completed_daemons ~f:Daemon.to_string)

let compare a b =
  match Int.compare (score a) (score b) with
  | 0 ->
      Int.compare (List.length b.path) (List.length a.path)
  | x ->
      x

let best_of = Comparable.max compare

let best_of_option a b =
  match (a, b) with
  | r, None | None, r ->
      r
  | Some a, Some b ->
      Some (best_of a b)

module Test = struct
  let breach_result = Alcotest.testable (Fmt.of_to_string to_string) equal

  module TestBestOf = struct
    let mk_path (values : String.t List.t) =
      List.mapi values ~f:(fun i value : Cell.t -> {value; coord= (i, i)})

    let daemon_a : Daemon.t =
      {name= "a"; breach_sequence= ["1C"; "55"; "FF"]; score= 1}

    let daemon_b : Daemon.t =
      {name= "b"; breach_sequence= ["55"; "FF"; "7A"]; score= 2}

    let higher_score_wins () =
      let path_a = mk_path ["55"; "1C"; "55"; "FF"] in
      let path_b = mk_path ["1C"; "55"; "FF"; "7A"] in
      let br_a : t = {path= path_a; completed_daemons= [daemon_a]} in
      let br_b : t = {path= path_b; completed_daemons= [daemon_a; daemon_b]} in
      Alcotest.check breach_result "higher score wins" br_b (best_of br_a br_b)

    let shorter_path_wins () =
      let path_a = mk_path ["55"; "1C"; "55"; "FF"] in
      let path_b = mk_path ["1C"; "55"; "FF"] in
      let br_a : t = {path= path_a; completed_daemons= [daemon_a]} in
      let br_b : t = {path= path_b; completed_daemons= [daemon_a]} in
      Alcotest.check breach_result "shorter path wins" br_b (best_of br_a br_b)

    let test () = higher_score_wins () ; shorter_path_wins ()

    let test_case = Alcotest.test_case "best_of" `Quick test
  end

  let test_suite = [TestBestOf.test_case]
end
