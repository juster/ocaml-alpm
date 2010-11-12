type option_name  = RootDir

exception Error of string

(* Basic ALPM functions *)
external init    : unit -> unit = "oalpm_initialize"
external release : unit -> unit = "oalpm_release"

(* Options *)

(* String Options *)
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

(* String List Options *)
external setopt_cachedirs : string list -> unit = "oalpm_option_set_cachedirs"
external getopt_cachedirs : unit -> string list = "oalpm_option_get_cachedirs"
external addopt_cachedir : string -> unit = "oalpm_option_add_cachedir"
external remopt_cachedir : string -> unit = "oalpm_option_rem_cachedir"
external setopt_noupgrades : string list -> unit = "oalpm_option_set_noupgrades"
external getopt_noupgrades : unit -> string list = "oalpm_option_get_noupgrades"
external addopt_noupgrade : string -> unit = "oalpm_option_add_noupgrade"
external remopt_noupgrade : string -> unit = "oalpm_option_rem_noupgrade"
external setopt_noextracts : string list -> unit = "oalpm_option_set_noextracts"
external getopt_noextracts : unit -> string list = "oalpm_option_get_noextracts"
external addopt_noextract : string -> unit = "oalpm_option_add_noextract"
external remopt_noextract : string -> unit = "oalpm_option_rem_noextract"
external setopt_ignorepkgs : string list -> unit = "oalpm_option_set_ignorepkgs"
external getopt_ignorepkgs : unit -> string list = "oalpm_option_get_ignorepkgs"
external addopt_ignorepkg : string -> unit = "oalpm_option_add_ignorepkg"
external remopt_ignorepkg : string -> unit = "oalpm_option_rem_ignorepkg"
external setopt_ignoregrps : string list -> unit = "oalpm_option_set_ignoregrps"
external getopt_ignoregrps : unit -> string list = "oalpm_option_get_ignoregrps"
external addopt_ignoregrp : string -> unit = "oalpm_option_add_ignoregrp"
external remopt_ignoregrp : string -> unit = "oalpm_option_rem_ignoregrp"

(* We must register our exception to allow the C code to use it. *)
let () =
  Callback.register_exception "AlpmError" (Error "any string")
