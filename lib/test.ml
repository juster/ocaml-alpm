let rec print_list list =
  match list with
    []     -> print_endline ""
  | hd::tl -> print_endline hd ; print_list tl ;;

let level_string level =
  match level with
    Alpm.LogWarning  -> "warning"
  | Alpm.LogDebug    -> "debug"
  | Alpm.LogError    -> "error"
  | Alpm.LogFunction -> "function"

let logger level msg =
  print_string ( "LOG [" ^ ( level_string level ) ^ "] " ^ msg )

let _ =
  Alpm.init ();
  Alpm.enable_logcb logger ;
  Alpm.set_root "/";
  Alpm.add_cachedir "/lib/cache/pacman" ;
  print_list ( Alpm.get_cachedirs () ) ;
  Alpm.disable_logcb () ;
  Alpm.add_cachedir "/bad/" ;
  print_list ( Alpm.get_cachedirs () ) ;
  Alpm.set_cachedirs [ "/lib/cache/pacman" ; "/cache" ] ;
  print_list ( Alpm.get_cachedirs () ) ;
  Alpm.set_usedelta true ;
  print_endline
    ( if Alpm.get_usedelta () then "Using deltas"
    else "Not using deltas" ) ;
  Alpm.set_usesyslog false ;
  print_endline
    ( if Alpm.get_usesyslog () then "Using the syslog"
    else "Not using the syslog" ) ;
  Alpm.enable_logcb logger ;
  let localdb = Alpm.new_db "local" in
  let extradb = Alpm.new_db "extra" in
  let communitydb = Alpm.new_db "community" in
  
  let dbs = Alpm.syncdbs () in
  print_int (List.length dbs) ; print_newline ();

  print_endline (Alpm.db_name (List.hd dbs));
  Alpm.db_addurl (List.hd dbs) "http://juster.info";
  print_endline (Alpm.db_url extradb);

  let lookupdb = Alpm.db "community" in
  if (Alpm.db_name lookupdb) <> (Alpm.db_name communitydb) then
    raise (Failure "db func could not lookup community") ;
  print_endline "db func works";

  print_endline ("DBNotFound error " ^
                 (try Alpm.db "foobar" ; "doesn't fire"
                 with Alpm.DBNotFound -> "fires off")) ;

  let test_localurl unit =
    print_endline
      (try Alpm.db_url localdb with Failure(str) -> "ERROR: " ^ str)
  in test_localurl ()
  
