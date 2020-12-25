(* open Base *)
open Lib.Breach_protocol

let example_matrix = BreachMatrix.of_list [
  ["E9" ; "BD" ; "55" ; "1C"] ;
  ["E9" ; "1C" ; "BD" ; "BD"] ;
  ["1C" ; "BD" ; "55" ; "E9"] ;
  ["55" ; "E9" ; "1C" ; "BD"] ;
]

let () =
  Stdio.print_endline "Paths for matrix:";
  Stdio.print_endline (BreachMatrix.to_string example_matrix);
  let paths = expand_paths ~matrix:example_matrix ~buffer_size:6 in
  (* List.iter (fun path -> Stdio.print_endline (Path.to_string path)) paths *)
  Stdio.printf "num paths: %d\n" (List.length paths)
