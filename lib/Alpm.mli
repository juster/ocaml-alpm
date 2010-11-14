type log_level = LogError | LogWarning | LogDebug | LogFunction
type database
type package

exception AlpmError of string
exception NoLocalDB

val init    : unit -> unit
val release : unit -> unit

(* OPTIONS *)

(* String Get/Set Options *)
val set_root      : string -> unit
val get_root      : unit   -> string
val set_dbpath    : string -> unit
val get_dbpath    : unit   -> string
val set_logfile   : string -> unit
val get_logfile   : unit   -> string
val set_arch      : string -> unit
val get_arch      : unit   -> string
val get_lockfile  : unit   -> string

(* String List Options *)
val set_cachedirs  : string list -> unit
val get_cachedirs  : unit -> string list
val add_cachedir   : string -> unit
val rem_cachedir   : string -> unit
val set_noupgrades : string list -> unit
val get_noupgrades : unit -> string list
val add_noupgrade  : string -> unit
val rem_noupgrade  : string -> unit
val set_noextracts : string list -> unit
val get_noextracts : unit -> string list
val add_noextract  : string -> unit
val rem_noextract  : string -> unit
val set_ignorepkgs : string list -> unit
val get_ignorepkgs : unit -> string list
val add_ignorepkg  : string -> unit
val rem_ignorepkg  : string -> unit
val set_ignoregrps : string list -> unit
val get_ignoregrps : unit -> string list
val add_ignoregrp  : string -> unit
val rem_ignoregrp  : string -> unit

(* Boolean Options *)
val set_usesyslog : bool -> unit
val get_usesyslog : unit -> bool
val set_usedelta : bool -> unit
val get_usedelta : unit -> bool

(* Callbacks *)
val enable_logcb : (log_level -> string -> unit) -> unit
val disable_logcb : unit -> unit

val enable_dlcb : (string -> int -> int -> unit) -> unit
val disable_dlcb : unit -> unit

val enable_totaldlcb : (int -> unit) -> unit
val disable_totaldlcb : unit -> unit

val enable_fetchcb : (string -> string -> bool -> int) -> unit
val disable_fetchcb : unit -> unit

(* Database mutators/accessors *)
val new_db  : string -> database
val localdb : unit -> database
val syncdbs : unit -> database list
val db      : string -> database

(* Database functions *)
val db_name     : database -> string
val db_url      : database -> string
val db_addurl   : database -> string -> unit
val db_packages : database -> package list

(* PACKAGES *)
val pkg_name : package -> string
val pkg_filename : package -> string
val pkg_version : package -> string
val pkg_desc : package -> string
val pkg_url : package -> string
val pkg_packager : package -> string
val pkg_md5sum : package -> string
val pkg_arch : package -> string
