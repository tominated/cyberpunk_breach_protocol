open Base
open Lib

type t =
  { id: Int.t
  ; matrix: String.t List.t List.t
  ; daemons: Daemon.t list
  ; buffer_size: Int.t }
[@@deriving sexp]
