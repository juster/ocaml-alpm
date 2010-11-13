type log_level = LogError | LogWarning | LogDebug | LogFunction

exception AlpmError of string

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

(* String List Options *)
val setopt_cachedirs  : string list -> unit
val getopt_cachedirs  : unit -> string list
val addopt_cachedir   : string -> unit
val remopt_cachedir   : string -> unit
val setopt_noupgrades : string list -> unit
val getopt_noupgrades : unit -> string list
val addopt_noupgrade  : string -> unit
val remopt_noupgrade  : string -> unit
val setopt_noextracts : string list -> unit
val getopt_noextracts : unit -> string list
val addopt_noextract  : string -> unit
val remopt_noextract  : string -> unit
val setopt_ignorepkgs : string list -> unit
val getopt_ignorepkgs : unit -> string list
val addopt_ignorepkg  : string -> unit
val remopt_ignorepkg  : string -> unit
val setopt_ignoregrps : string list -> unit
val getopt_ignoregrps : unit -> string list
val addopt_ignoregrp  : string -> unit
val remopt_ignoregrp  : string -> unit

(* Boolean Options *)
val setopt_usesyslog : bool -> unit
val getopt_usesyslog : unit -> bool
val setopt_usedelta : bool -> unit
val getopt_usedelta : unit -> bool

(* Callbacks *)
val enable_logcb : (log_level -> string -> unit) -> unit
val disable_logcb : unit -> unit

val enable_dlcb : (string -> int -> int -> unit) -> unit
val disable_dlcb : unit -> unit

val enable_totaldlcb : (int -> unit) -> unit
val disable_totaldlcb : unit -> unit

val enable_fetchcb : (string -> string -> bool -> int) -> unit
val disable_fetchcb : unit -> unit
