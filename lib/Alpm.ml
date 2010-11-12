type option_name  = RootDir

exception Error of string

(* Basic ALPM functions *)
external init    : unit -> unit = "oalpm_initialize"
external release : unit -> unit = "oalpm_release"

(* Options *)
external setopt_root : string -> unit = "oalpm_option_set_root"
external getopt_root : unit -> string = "oalpm_option_get_root"
external setopt_dbpath : string -> unit = "oalpm_option_set_dbpath"
external getopt_dbpath : unit -> string = "oalpm_option_get_dbpath"
external setopt_logfile : string -> unit = "oalpm_option_set_logfile"
external getopt_logfile : unit -> string = "oalpm_option_get_logfile"
external setopt_arch : string -> unit = "oalpm_option_set_arch"
external getopt_arch : unit -> string = "oalpm_option_get_arch"
(* There is no setopt_lockfile. *)
external getopt_lockfile : unit -> string = "oalpm_option_get_lockfile"

(* We must register our exception to allow the C code to use it. *)
let () =
  Callback.register_exception "AlpmError" (Error "any string")
