open Str

type log_level = LogError | LogWarning | LogDebug | LogFunction
type reason    = Explicit | Dependency
type compare   = Less | Equal | Greater

type alpm_database
type alpm_package
type alpm_package_autofree = alpm_package

type dependency_modifier =
  | Any     (** When there is only the package name. *)
  | Exactly (** == *)
  | Above   (** <  *)
  | Below   (** >  *)
  | AtLeast (** >= *)
  | AtMost  (** <= *)

type dependency = { package  : string;
                    modifier : dependency_modifier;
                    version  : string; }

module Dep =
  struct
    let string_of_depmod modifier =
      match modifier with
      | Any     -> ""
      | Exactly -> "=="
      | AtLeast -> ">="
      | AtMost  -> "<="
      | Above   -> ">"
      | Below   -> "<"
    let depmod_of_string depmod =
      match depmod with
      | ""   -> Any (* this is a little funky ... *)
      | "==" -> Exactly
      | ">=" -> AtLeast
      | "<=" -> AtMost
      | ">"  -> Above
      | "<"  -> Below
      | _    -> raise (Failure "Invalid dependency string")
    let string_of_dep dep =
      if dep.modifier = Any
         || (dep.version = "0" && dep.modifier = AtLeast) then
        dep.package
      else
        dep.package ^ (string_of_depmod dep.modifier) ^ dep.version
    let dep_of_string depstr =
      if not (string_match (regexp
                              "\\(.+\\)\\(==\\|<\\|>\\|<=\\|>=\\)\\(.+\\)")
                depstr 0)
      then
        { package = depstr; modifier = Any; version = ""; }
      else
        { package  = (matched_group 1 depstr);
          modifier = (depmod_of_string (matched_group 2 depstr));
          version  = (matched_group 3 depstr); }
  end

exception AlpmError of string
exception NoLocalDB

(* Basic ALPM functions *)
external init         : unit -> unit = "oalpm_initialize"
external release      : unit -> unit = "oalpm_release"
external oalpm_load_pkgfile : string -> alpm_package = "oalpm_load_pkgfile"
external vercmp       : string -> string -> compare
    = "oalpm_pkg_vercmp"

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
external oalpm_register_sync : string -> alpm_database
    = "oalpm_register_sync"
external oalpm_register_local : unit -> alpm_database
    = "oalpm_register_local"
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
external pkg_get_db : alpm_package -> alpm_database
    = "oalpm_pkg_get_db"
external pkg_get_reason : alpm_package -> reason
    = "oalpm_pkg_get_reason"
external pkg_get_size : alpm_package -> int
    = "oalpm_pkg_get_size"
external pkg_get_isize : alpm_package -> int
    = "oalpm_pkg_get_isize"
external pkg_download_size : alpm_package -> int
    = "oalpm_pkg_download_size"
external pkg_get_builddate : alpm_package -> float
    = "oalpm_pkg_get_builddate"
external pkg_get_installdate : alpm_package -> float
    = "oalpm_pkg_get_installdate"
external pkg_has_scriptlet : alpm_package -> bool
    = "oalpm_pkg_has_scriptlet"
external pkg_has_force : alpm_package -> bool
    = "oalpm_pkg_has_force"
external pkg_get_depends : alpm_package -> dependency list
    = "oalpm_pkg_get_depends"

(* DATABASES *)
external db_name      : alpm_database -> string    = "oalpm_db_get_name"
external db_url       : alpm_database -> string    = "oalpm_db_get_url"
external db_addurl    : alpm_database -> string -> unit = "oalpm_db_add_url"
external db_pkgcache  : alpm_database -> alpm_package list
    = "oalpm_db_get_pkgcache"
external db_update    : bool -> alpm_database -> unit
    = "oalpm_db_update"
external db_get_pkg   : alpm_database -> string -> alpm_package
    = "oalpm_db_get_pkg"
external db_search    : alpm_database -> string list -> alpm_package list
    = "oalpm_db_search"
external db_get_grpcache : alpm_database -> ( string * alpm_package list ) list
    = "oalpm_db_get_grpcache"
external db_readgrp : alpm_database -> string -> ( string * alpm_package list )
    = "oalpm_db_readgrp"
external db_set_pkgreason : alpm_database -> string -> reason -> unit
    = "oalpm_db_set_pkgreason"

class package pkg_data =
  object(self)
    method name     = pkg_name pkg_data
    method filename = pkg_filename pkg_data
    method version  = pkg_version pkg_data
    method desc     = pkg_desc pkg_data
    method url      = pkg_url pkg_data
    method packager = pkg_packager pkg_data
    method md5sum   = pkg_md5sum pkg_data
    method arch     = pkg_arch pkg_data (**)
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

    method reason     = pkg_get_reason pkg_data

    method size          = pkg_get_size pkg_data
    method isize         = pkg_get_isize pkg_data
    method download_size = pkg_download_size pkg_data

    method builddate   = pkg_get_builddate pkg_data
    method installdate = pkg_get_installdate pkg_data

    method scriptlet  = pkg_has_scriptlet pkg_data
    method forced     = pkg_has_force pkg_data

    method deps       = pkg_get_depends pkg_data
    method db         = new database (pkg_get_db pkg_data)
  end
and database db =
  object
    method name            = db_name db
    method find name       = new package (db_get_pkg db name)
    method packages        =
      List.map (fun pkg -> new package pkg) (db_pkgcache db)
    method search keywords =
      List.map (fun pkg -> new package pkg) (db_search db keywords)
    method groups          =
      List.map (fun grp_pair -> new package_group grp_pair)
        (db_get_grpcache db)
    method find_group name = new package_group (db_readgrp db name)
  end
and sync_database db =
  object
    inherit database db
    method url          = db_url db
    method addurl url   = db_addurl db url
    method update force = db_update force db
  end
and local_database db =
  object
    inherit database db
    method set_pkg_reason name pkgreason =
      db_set_pkgreason db name pkgreason
  end
and package_group group_tuple =
  object
    val pkgobj_list = List.map (fun pkg -> new package pkg)
        (snd group_tuple)
    method name     = (fst group_tuple :string )
    method packages = pkgobj_list
  end

let load_pkgfile path = new package (oalpm_load_pkgfile path)
let register_sync name = new sync_database (oalpm_register_sync name)
let register_local unit = new local_database (oalpm_register_local ())
let localdb unit = new local_database (option_get_localdb ())
let syncdbs unit =
  List.map (fun rawdb -> new sync_database rawdb) (oalpm_syncdbs ())

let repodb name =
  let rec find_db name dblist =
    match dblist with
      []     -> raise Not_found
    | hd::tl -> if hd#name = name then hd else find_db name tl
  in find_db name (syncdbs ())

(* TRANSACTIONS *)
module Trans =
  struct
    (* Callbacks *)
    type event =
        CheckDepsStart
      | CheckDepsDone
      | FileConflictsStart
      | FileConflictsDone
      | ResolveDepsStart
      | ResolveDepsDone
      | InterConflictsStart
      | InterConflictsDone of package
      | AddStart
      | AddDone
      | RemoveStart
      | RemoveDone
      | UpgradeStart of (package)
      | UpgradeDone of (package * package)
      | IntegrityStart
      | IntegrityDone
      | DeltaIntegrityStart
      | DeltaIntegrityDone
      | DeltaPatchesStart
      | DeltaPatchesDone of (string * string)
      | DeltaPatchStart
      | DeltaPatchDone
      | DeltaPatchFailed of string
      | Scriptlet of string
      | Retrieve  of string
    external oalpm_toggle_event_cb : bool -> unit = "oalpm_toggle_event_cb"
    let enable_eventcb cb =
      Callback.register "event callback" cb ;
      oalpm_toggle_event_cb true
    let disable_eventcb unit = oalpm_toggle_event_cb false

    type conv_data =
        InstallIgnore    of (package)
      | ReplacePackage   of (package * package * string)
      | PackageConflict  of (string  * string  * string)
      | CorruptedPackage of (string)
      | LocalNewer       of (package)
      | RemovePackages   of (package list)
    external oalpm_toggle_conv_cb : bool -> unit = "oalpm_toggle_conv_cb"
    let enable_convcb cb =
      Callback.register "conv callback" cb ;
      oalpm_toggle_conv_cb true
    let disable_convcb unit = oalpm_toggle_conv_cb false

    type prog_type =
        ProgAdd
      | ProgUpgrade
      | ProgRemove
      | ProgConflicts
    external oalpm_toggle_prog_cb : bool -> unit = "oalpm_toggle_prog_cb"
    let enable_progresscb cb =
      Callback.register "prog callback" cb ;
      oalpm_toggle_prog_cb true
    let disable_progresscb unit = oalpm_toggle_prog_cb false

    type trans_flag =
        NoDeps
      | Force
      | NoSave
      | Cascade
      | Recurse
      | DBOnly
      | AllDeps
      | DownloadOnly
      | NoScriptlet
      | NoConflicts
      | Needed
      | AllExplicit
      | Unneeded
      | Recurseall
      | NoLock

    (* Error Types *)
    type conflict = { packages: ( string * string );
                      reason:   string; }

    type file_conflict_kind = PackageConflict | FileConflict
    type file_conflict      = { kind:    file_conflict_kind;
                                target:  string;
                                file:    string;
                                ctarget: string; }

    type dep_missing = { target: string;
                         cause:  string;
                         dep:    dependency; }

    type trans_error =
        Conflict       of conflict list
      | FileConflict   of file_conflict list
      | DepMissing     of dep_missing list
      | InvalidDelta   of string list
      | InvalidPackage of string list
      | InvalidArch    of string list

    exception TransError of trans_error

    external init       : trans_flag list -> unit    = "oalpm_trans_init"
    external prepare    : unit -> unit               = "oalpm_trans_prepare"
    external commit     : unit -> unit               = "oalpm_trans_commit"
    external release    : unit -> unit               = "oalpm_trans_release"
    external sysupgrade : bool -> unit               = "oalpm_sync_sysupgrade"
    external sync       : string -> unit             = "oalpm_sync_target"
    external addpkgfile : string -> unit             = "oalpm_add_target"
    external remove     : string -> unit             = "oalpm_remove_target"
    external syncfromdb : string -> string -> unit   = "oalpm_sync_dbtarget"

    (* Functions returning package objects must be wrapped in OCAML code. *)
    external oalpm_trans_get_add : unit -> alpm_package list 
        = "oalpm_trans_get_add"
    external oalpm_trans_get_remove : unit -> alpm_package list 
        = "oalpm_trans_get_remove"
    let additions unit =
      List.map (fun rawpkg -> new package rawpkg) (oalpm_trans_get_add ())
    let removals unit =
      List.map (fun rawpkg -> new package rawpkg) (oalpm_trans_get_remove ())

  end

(* We must register our exception to allow the C code to use it. *)
let () =
  Callback.register_exception "AlpmError" (AlpmError "string") ;
  Callback.register_exception "TransError"
    (Trans.TransError (Trans.InvalidPackage ["string"])) ;
  Callback.register_exception "Not_found" (Not_found) ;
