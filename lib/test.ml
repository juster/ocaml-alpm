let rec print_list list =
  match list with
    []     -> print_endline ""
  | hd::tl -> print_endline hd ; print_list tl ;;

let _ =
  Alpm.init ();
  Alpm.setopt_root "/";
  Alpm.addopt_cachedir "/lib/cache/pacman" ;
  print_list ( Alpm.getopt_cachedirs () ) ;
  Alpm.addopt_cachedir "/bad/" ;
  print_list ( Alpm.getopt_cachedirs () ) ;
  Alpm.setopt_cachedirs [ "/lib/cache/pacman" ; "/cache" ] ;
  print_list ( Alpm.getopt_cachedirs () ) ;
  Alpm.setopt_usedelta true ;
  print_endline
    ( if Alpm.getopt_usedelta () then "Using deltas"
      else "Not using deltas" ) ;
  Alpm.setopt_usesyslog false ;
  print_endline
    ( if Alpm.getopt_usesyslog () then "Using the syslog"
    else "Not using the syslog" ) ;;
