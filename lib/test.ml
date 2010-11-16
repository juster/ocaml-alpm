open Alpm
open Alpm.Dep
open Printf
open Unix

let rec print_list list =
  match list with
    []     -> print_endline ""
  | hd::tl -> print_endline hd ; print_list tl ;;

let level_string level =
  match level with
    LogWarning  -> "warning"
  | LogDebug    -> "debug"
  | LogError    -> "error"
  | LogFunction -> "function"

let logger level msg =
  print_string ( "LOG [" ^ ( level_string level ) ^ "] " ^ msg )

let _ =
  Alpm.init () ;
  Alpm.enable_logcb logger ;
  Alpm.set_root "/" ;
  Alpm.set_dbpath "/var/lib/pacman" ;
  Alpm.add_cachedir "/var/cache/pacman/pkg" ;
  Alpm.set_logfile "test.log" ;

  let time_str secs =
    let t = Unix.localtime secs in
    sprintf "%d:%d %d/%d/%d" t.tm_hour t.tm_min (t.tm_mon + 1)
      t.tm_mday (t.tm_year + 1900)
  in
  
  let localdb = Alpm.new_db "local" in print_endline (localdb#name) ;
  let pkgs = localdb#packages in
  let dump_perl_pkg pkg =
    print_endline ("Perl package is in the " ^ pkg#db#name ^ " database.") ;
    print_endline ("Installed " ^
                   ( match pkg#reason with
                   |  Explicit -> "explicitly."
                   |  Dependency -> "as a dependency.")) ;
    printf "Package size is %d\nInstalled size is %d\n" pkg#size pkg#isize ;
    printf "Download size is %d\n" pkg#download_size ;

    printf "Build date is %s\n" (time_str pkg#builddate) ;
    printf "Install date is %s\n" (time_str pkg#installdate) ;

    printf "Forced is %s\nScriptlet is %s\n"
      (string_of_bool pkg#forced) (string_of_bool pkg#scriptlet) ;

    try
      pkg#checkmd5sum ;
    with Failure(str) -> print_endline "Checkmd5sum failed properly." ;
  in

  List.iter (fun pkg -> if pkg#name = "perl" then dump_perl_pkg pkg) pkgs ;
  let vercmp_msg foo bar =
    match vercmp foo bar with
    | Less -> "less than"
    | Equal -> "equal to"
    | Greater -> "greater than"
  in

  let test_vercmp foo bar =
    printf "%s is %s %s\n" foo (vercmp_msg foo bar) bar
  in
  test_vercmp "1.9" "1.1" ;
  test_vercmp "1.001" "1.1";
  test_vercmp "1.001" "1.0001";
  test_vercmp "1.001001" "1.1001";
  test_vercmp "1.1234" "1.2345";

  print_endline (string_of_dep { package = "pacman";
                                 modifier = Below;
                                 version = "2.5" });


    
  (* let perlpkg = Alpm.load_pkgfile "perl-5.12.0-0-i686.pkg.tar.xz" in *)
  (* print_endline (perlpkg#name ^ " " ^ perlpkg#version) *)
