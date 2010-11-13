type log_level = LogError | LogWarning | LogDebug | LogFunction
type database

exception AlpmError of string
exception NoLocalDB

(* Basic ALPM functions *)
external init    : unit -> unit = "oalpm_initialize"
external release : unit -> unit = "oalpm_release"

(* Options *)

(* String Options *)
external set_root : string -> unit = "oalpm_option_set_root"
external get_root : unit -> string = "oalpm_option_get_root"
external set_dbpath : string -> unit = "oalpm_option_set_dbpath"
external get_dbpath : unit -> string = "oalpm_option_get_dbpath"
external set_logfile : string -> unit = "oalpm_option_set_logfile"
external get_logfile : unit -> string = "oalpm_option_get_logfile"
external set_arch : string -> unit = "oalpm_option_set_arch"
external get_arch : unit -> string = "oalpm_option_get_arch"
(* There is no set_lockfile. *)
external get_lockfile : unit -> string = "oalpm_option_get_lockfile"

(* String List Options *)
external set_cachedirs : string list -> unit = "oalpm_option_set_cachedirs"
external get_cachedirs : unit -> string list = "oalpm_option_get_cachedirs"
external add_cachedir : string -> unit = "oalpm_option_add_cachedir"
external rem_cachedir : string -> unit = "oalpm_option_rem_cachedir"
external set_noupgrades : string list -> unit = "oalpm_option_set_noupgrades"
external get_noupgrades : unit -> string list = "oalpm_option_get_noupgrades"
external add_noupgrade : string -> unit = "oalpm_option_add_noupgrade"
external rem_noupgrade : string -> unit = "oalpm_option_rem_noupgrade"
external set_noextracts : string list -> unit = "oalpm_option_set_noextracts"
external get_noextracts : unit -> string list = "oalpm_option_get_noextracts"
external add_noextract : string -> unit = "oalpm_option_add_noextract"
external rem_noextract : string -> unit = "oalpm_option_rem_noextract"
external set_ignorepkgs : string list -> unit = "oalpm_option_set_ignorepkgs"
external get_ignorepkgs : unit -> string list = "oalpm_option_get_ignorepkgs"
external add_ignorepkg : string -> unit = "oalpm_option_add_ignorepkg"
external rem_ignorepkg : string -> unit = "oalpm_option_rem_ignorepkg"
external set_ignoregrps : string list -> unit = "oalpm_option_set_ignoregrps"
external get_ignoregrps : unit -> string list = "oalpm_option_get_ignoregrps"
external add_ignoregrp : string -> unit = "oalpm_option_add_ignoregrp"
external rem_ignoregrp : string -> unit = "oalpm_option_rem_ignoregrp"

(* Boolean Options *)
external set_usesyslog : bool -> unit = "oalpm_option_set_usesyslog"
external get_usesyslog : unit -> bool = "oalpm_option_get_usesyslog"
external set_usedelta : bool -> unit = "oalpm_option_set_usedelta"
external get_usedelta : unit -> bool = "oalpm_option_get_usedelta"

(* Callback Options *)

external disable_logcb     : unit -> unit = "oalpm_disable_log_cb"
external disable_dlcb      : unit -> unit = "oalpm_disable_dl_cb"
external disable_totaldlcb : unit -> unit = "oalpm_disable_totaldl_cb"
external disable_fetchcb   : unit -> unit = "oalpm_disable_fetch_cb"

external oalpm_enable_log_cb     : unit -> unit = "oalpm_enable_log_cb"
external oalpm_enable_dl_cb      : unit -> unit = "oalpm_enable_dl_cb"
external oalpm_enable_totaldl_cb : unit -> unit = "oalpm_enable_totaldl_cb"
external oalpm_enable_fetch_cb   : unit -> unit = "oalpm_enable_fetch_cb"

let enable_logcb cb =
  Callback.register "log callback" cb ; oalpm_enable_log_cb ()
let enable_dlcb cb =
  Callback.register "dl callback" cb ; oalpm_enable_dl_cb ()
let enable_totaldlcb cb =
  Callback.register "totaldl callback" cb ; oalpm_enable_totaldl_cb ()
let enable_fetchcb cb =
  Callback.register "fetch callback" cb ; oalpm_enable_fetch_cb ()

(* Database accessors/mutators *)
external register : string -> database    = "oalpm_register"
external localdb  : unit -> database      = "oalpm_localdb"
external syncdbs  : unit -> database list = "oalpm_syncdbs"

external db_name  : database -> string    = "oalpm_db_get_name"
external db_url   : database -> string    = "oalpm_db_get_url"
external db_addurl : database -> string -> unit = "oalpm_db_add_url"

(* We must register our exception to allow the C code to use it. *)
let () =
  Callback.register_exception "AlpmError" (AlpmError "any string") ;
  Callback.register_exception "NoLocalDB" (NoLocalDB)
