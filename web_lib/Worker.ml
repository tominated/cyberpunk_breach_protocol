open Base
open Js_of_ocaml
open Lib

let on_message _ =
  let matrix = BreachProtocol.Test.TestBestPath.matrix in
  let daemons = BreachProtocol.Test.TestBestPath.daemons in
  let buffer_size = 8 in
  let best_path = BreachProtocol.best_path ~matrix ~daemons ~buffer_size in
  let response =
    match best_path with
    | Some result ->
        Sexp.to_string @@ BreachResult.sexp_of_t result
    | _ ->
        Sexp.to_string @@ Option.sexp_of_t BreachResult.sexp_of_t None
  in
  Worker.post_message response
