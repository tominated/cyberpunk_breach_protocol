open Base
open Lib

type t =
  | ParseError
  | InvalidInput of {id: Int.t}
  | Result of BreachResult.t Option.t
[@@deriving sexp]
