open Alpm
open Unix

let string_of_loglevel level =
  match level with
    LogWarning  -> "warning"
  | LogDebug    -> "debug"
  | LogError    -> "error"
  | LogFunction -> "function"

let logger level msg =
  print_string ( "LOG [" ^ ( string_of_loglevel level ) ^ "] " ^ msg )

let _ =
  let cwd = getcwd () in
  let root = cwd ^ "/tmp/" in
  Alpm.init () ;
  Alpm.enable_logcb logger ;
  Alpm.set_root root ;
  Alpm.set_dbpath (root ^ "db") ;
  Alpm.add_cachedir (root ^ "cache") ;
  Alpm.set_logfile (root ^ "test.log") ;

  let extradb = Alpm.new_db "extra" in
  extradb#addurl "ftp://ftp.osuosl.org/pub/archlinux/extra/os/i686" ;
  extradb#update true ;
