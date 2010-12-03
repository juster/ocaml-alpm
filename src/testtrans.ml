open Alpm
open Alpm.Trans
open Printf

let level_string level =
  match level with
    LogWarning  -> "warning"
  | LogDebug    -> "debug"
  | LogError    -> "error"
  | LogFunction -> "function"

let logger level msg =
  match level with
    LogFunction -> ()
  | _ -> print_string ( "LOG [" ^ ( level_string level ) ^ "] " ^ msg )

let logevent event =
  match event with
    CheckDepsStart -> print_endline "Checking dependencies..."
  | CheckDepsDone  -> ()
  | FileConflictsStart -> print_endline "Checking file conflicts..."
  | FileConflictsDone  -> ()
  | ResolveDepsStart -> print_endline "Resolving dependencies..."
  | ResolveDepsDone  -> ()
  | InterConflictsStart -> print_endline "Checking package conflicts..."
  | InterConflictsDone(pkg)
    -> print_endline (" checked " ^ pkg#name)
  | AddStart -> print_endline "Adding package..."
  | AddDone  -> ()
  | RemoveStart -> print_endline "Removing package..."
  | RemoveDone  -> ()
  | UpgradeStart(pkg) -> print_endline ("Upgrading " ^ pkg#name)
  | UpgradeDone(pkgOne, pkgTwo) -> ()
  | IntegrityStart -> print_endline "Checking integrity of packages..."
  | IntegrityDone  -> ()
  | DeltaIntegrityStart -> ()
  | DeltaIntegrityDone  -> ()
  | DeltaPatchesStart -> ()
  | DeltaPatchesDone(huh,wtf) -> ()
  | DeltaPatchStart -> ()
  | DeltaPatchDone  -> ()
  | DeltaPatchFailed(badpatch) -> ()
  | Scriptlet(contents) -> print_endline ("Running scriptlet:\n" ^ contents)
  | Retrieve(thing) -> print_endline ("Retrieving " ^ thing)

let print_trans_pkgs unit =
  let addlist = Trans.additions () in
  let remlist = Trans.removals ()  in
  begin
    if (List.length addlist) > 0 then
      print_endline ("Installing packages: "
                     ^ String.concat " "
                         (List.map (fun pkg -> pkg#name) addlist))
  end ;
  begin
    if (List.length remlist) > 0 then
      print_endline ("Removing packages: "
                       ^ String.concat " "
                           (List.map (fun pkg -> pkg#name) remlist))
  end

let _ =
  Alpm.init () ;
  Alpm.set_root "/" ;
  Alpm.set_dbpath "/var/lib/pacman" ;
  Alpm.add_cachedir "/var/cache/pacman/pkg" ;
  Alpm.set_logfile "test.log" ;
  Alpm.register_local () ;

  Alpm.enable_logcb logger ;
  Alpm.Trans.enable_eventcb logevent;
  Alpm.Trans.init [ Cascade ];
  print_endline "Initialized transaction.";
  begin
    try
      Alpm.Trans.remove "cairo";
      Alpm.Trans.prepare ();
      print_trans_pkgs ();
      Alpm.Trans.commit ();
    with Alpm.Error(str) -> print_endline ("ERROR: " ^ str)
  end;
  Alpm.Trans.release ();
  print_endline "Released transaction.";

  Alpm.release ();
