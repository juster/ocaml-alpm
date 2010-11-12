exception Error of string

val init    : unit -> unit
val release : unit -> unit

(* OPTIONS *)

(* String Get/Set Options *)
val setopt_root      : string -> unit
val getopt_root      : unit   -> string
val setopt_dbpath    : string -> unit
val getopt_dbpath    : unit   -> string
val setopt_logfile   : string -> unit
val getopt_logfile   : unit   -> string
val setopt_arch      : string -> unit
val getopt_arch      : unit   -> string
val getopt_lockfile  : unit   -> string

