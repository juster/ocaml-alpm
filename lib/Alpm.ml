type log_level = LogError | LogWarning | LogDebug | LogFunction
type alpm_database
type alpm_package
type alpm_package_autofree = alpm_package

exception AlpmError of string
exception NoLocalDB

(* Basic ALPM functions *)
external init         : unit -> unit = "oalpm_initialize"
external release      : unit -> unit = "oalpm_release"
external oalpm_load_pkgfile : string -> alpm_package = "oalpm_load_pkgfile"

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
external oalpm_register : string -> alpm_database
    = "oalpm_register"
external option_get_localdb : unit -> alpm_database
    = "oalpm_option_get_localdb"
external oalpm_syncdbs : unit -> alpm_database list
    = "oalpm_syncdbs"

(* PACKAGES *)
external pkg_name     : alpm_package -> string = "oalpm_pkg_get_name"
external pkg_filename : alpm_package -> string = "oalpm_pkg_get_filename"
external pkg_version  : alpm_package -> string = "oalpm_pkg_get_version"
external pkg_desc     : alpm_package -> string = "oalpm_pkg_get_desc"
external pkg_url      : alpm_package -> string = "oalpm_pkg_get_url"
external pkg_packager : alpm_package -> string
    = "oalpm_pkg_get_packager"
external pkg_md5sum   : alpm_package -> string = "oalpm_pkg_get_md5sum"
external pkg_arch     : alpm_package -> string = "oalpm_pkg_get_arch"
external pkg_checkmd5sum : alpm_package -> unit = "oalpm_pkg_checkmd5sum"

external pkg_requiredby : alpm_package -> string list
    = "oalpm_pkg_compute_requiredby"
external pkg_get_licenses : alpm_package -> string list
    = "oalpm_pkg_get_licenses"
external pkg_get_groups : alpm_package -> string list
    = "oalpm_pkg_get_groups"
external pkg_get_optdepends : alpm_package -> string list
    = "oalpm_pkg_get_optdepends"
external pkg_get_conflicts : alpm_package -> string list
    = "oalpm_pkg_get_conflicts"
external pkg_get_provides : alpm_package -> string list
    = "oalpm_pkg_get_provides"
external pkg_get_deltas : alpm_package -> string list
    = "oalpm_pkg_get_deltas"
external pkg_get_replaces : alpm_package -> string list
    = "oalpm_pkg_get_replaces"
external pkg_get_files : alpm_package -> string list
    = "oalpm_pkg_get_files"
external pkg_get_backup : alpm_package -> string list
    = "oalpm_pkg_get_backup"

class package pkg_data =
  object
    method name     = pkg_name pkg_data
    method filename = pkg_filename pkg_data
    method version  = pkg_version pkg_data
    method desc     = pkg_desc pkg_data
    method url      = pkg_url pkg_data
    method packager = pkg_packager pkg_data
    method md5sum   = pkg_md5sum pkg_data
    method arch     = pkg_arch pkg_data
    method checkmd5sum = pkg_checkmd5sum pkg_data

    method requiredby = pkg_requiredby pkg_data
    method licenses   = pkg_get_licenses pkg_data
    method groups     = pkg_get_groups pkg_data
    method optdepends = pkg_get_optdepends pkg_data
    method conflicts  = pkg_get_conflicts pkg_data
    method provides   = pkg_get_provides pkg_data
    method deltas     = pkg_get_deltas pkg_data
    method replaces   = pkg_get_replaces pkg_data
    method files      = pkg_get_files pkg_data
    method backup     = pkg_get_backup pkg_data
  end

let load_pkgfile path = new package (oalpm_load_pkgfile path)

(* DATABASES *)
external db_name      : alpm_database -> string    = "oalpm_db_get_name"
external db_url       : alpm_database -> string    = "oalpm_db_get_url"
external db_addurl    : alpm_database -> string -> unit = "oalpm_db_add_url"
external db_pkgcache  : alpm_database -> alpm_package list
    = "oalpm_db_get_pkgcache"

class database db_data =
  object
    method name     = db_name db_data
    method url      = db_url db_data
    method addurl url = db_addurl db_data url
    method packages =
      List.map (fun pkg -> new package pkg) (db_pkgcache db_data)
  end

let new_db name  = new database (oalpm_register name)
let localdb unit = new database (option_get_localdb ())
let syncdbs unit =
  List.map (fun rawdb -> new database rawdb) (oalpm_syncdbs ())

let db name =
  let rec find_db name dblist =
    match dblist with
      []     -> raise Not_found
    | hd::tl -> if hd#name = name then hd else find_db name tl
  in find_db name (syncdbs ())

(* We must register our exception to allow the C code to use it. *)
let () =
  Callback.register_exception "AlpmError" (AlpmError "any string") ;
  Callback.register_exception "NoLocalDB" (NoLocalDB)
