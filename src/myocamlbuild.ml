open Ocamlbuild_plugin

let oalpm_stub_libs = [ "callbacks.o" ; "core.o" ;
                        "datatypes.o" ; "db.o" ; "opts.o" ;
                        "pkg.o" ]

let _ =
  dispatch begin function
    | After_rules ->
        (* Test program doesn't link with oalpm funcs without this. *)
        ocaml_lib "libalpm" ;

        (* If a target has the use_libalpm flag then alpm.a is
           a dependency of that target. *)
        dep [ "ocaml" ; "link" ; "use_libalpm" ] [ "libalpm.a" ] ;

        (* Add the -lalpm linker flag when compiling libalpm.a so it
           is automatically used whenever the library is linked to. *)

        (* We must also add the C .o object files for some odd reason. *)
        flag [ "ocaml" ; "link" ; "library" ]
          ( S ( [ A "-cclib" ; A "-lalpm" ]
               @ (List.map (fun x -> A x) oalpm_stub_libs) ) )
    | _ -> ()
  end
