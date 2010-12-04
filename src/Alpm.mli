(** OCAML library for the ArchLinux Package Manager. *)

type log_level = LogError | LogWarning | LogDebug | LogFunction
type reason    = Explicit | Dependency
type compare   = Less | Equal | Greater

(** The modifier for a package/version dependency. *)
type dependency_modifier = 
  | Any     (** When there is only the package name. *)
  | Exactly (** == *)
  | Above   (** <  *)
  | Below   (** >  *)
  | AtLeast (** >= *)
  | AtMost  (** <= *)

(** A package dependency describing the necessary version of
    a package required by another package. *)
type dependency = { package  : string;
                    modifier : dependency_modifier;
                    version  : string; }

(** A module for dependency functions. *)
module Dep:
    sig
      val string_of_depmod: dependency_modifier -> string
      val depmod_of_string: string -> dependency_modifier
      val string_of_dep: dependency -> string
      val dep_of_string: string -> dependency
    end

class type package =
  object
    method name     : string
    method filename : string
    method version  : string
    method desc     : string
    method url      : string
    method packager : string
    method md5sum   : string
    method arch     : string

    method requiredby : string list
    method licenses   : string list
    method groups     : string list
    method optdepends : string list
    method conflicts  : string list
    method provides   : string list
    method deltas     : string list
    method replaces   : string list
    method files      : string list
    method backup     : string list

    method size       : int
    method isize      : int
    method download_size : int

    method builddate   : float
    method installdate : float

    method scriptlet  : bool
    method forced     : bool

    method checkmd5sum : unit

    method reason     : reason
    method deps       : dependency list
    method db         : database
  end
and database =
  object
    method name       : string
    method find       : string -> package
    method packages   : package list
    method search     : string list -> package list
    method groups     : package_group list
    method find_group : string -> package_group
  end
and sync_database =
  object
    inherit database
    method url    : string
    method addurl : string -> unit
    method update : bool -> unit
  end
and local_database =
  object
    inherit database
    method set_pkg_reason : string -> reason -> unit
  end
and package_group =
  object
    method name     : string
    method packages : package list
  end

exception Error of string
exception NoLocalDB

val init         : unit -> unit
val release      : unit -> unit
val load_pkgfile : string -> package

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
val register_local : unit -> local_database
val register_sync  : string -> sync_database
val localdb : unit   -> local_database
val syncdbs : unit   -> sync_database list
val repodb  : string -> sync_database

val vercmp  : string -> string -> compare

(* TRANSACTIONS *)
module Trans:
  sig
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
    val enable_eventcb  : (event -> unit) -> unit
    val disable_eventcb : unit -> unit

    type conv_data =
        InstallIgnore    of (package)
      | ReplacePackage   of (package * package * string)
      | PackageConflict  of (string  * string  * string)
      | CorruptedPackage of (string)
      | LocalNewer       of (package)
      | RemovePackages   of (package list)
    val enable_convcb  : (conv_data -> bool) -> unit
    val disable_convcb : unit -> unit

    type prog_type =
        ProgAdd
      | ProgUpgrade
      | ProgRemove
      | ProgConflicts
    val enable_progresscb : (prog_type -> string -> int -> int -> int)
      -> unit
    val disable_progresscb : unit -> unit

        (* Transaction Types *)
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

    val init       : trans_flag list -> unit
    val prepare    : unit -> unit
    val commit     : unit -> unit
    val release    : unit -> unit
    val additions  : unit -> package list
    val removals   : unit -> package list
    val sysupgrade : bool -> unit
    val sync       : string -> unit
    val addpkgfile : string -> unit
    val remove     : string -> unit
    val syncfromdb : string -> string -> unit
  end

  (* Accessors *)
