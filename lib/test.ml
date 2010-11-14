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
  Alpm.init () ;
  Alpm.enable_logcb logger ;
  Alpm.set_root "/" ;
  Alpm.set_dbpath "/var/lib/pacman" ;
  Alpm.add_cachedir "/var/cache/pacman/pkg" ;
  Alpm.set_logfile "test.log" ;
  let perlpkg = Alpm.load_pkgfile "perl-5.12.0-0-i686.pkg.tar.xz" in
  print_endline (perlpkg#name ^ " " ^ perlpkg#version)
