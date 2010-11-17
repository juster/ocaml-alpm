open Ocamlbuild_plugin

let oalpm_stub_libs = [ "callbacks.o" ; "core.o" ;
                        "datatypes.o" ; "db.o" ; "opts.o" ;
                        "pkg.o" ]

let _ =
  dispatch begin function
    | After_rules ->
        (* Test program doesn't link with oalpm funcs without this. *)
        ocaml_lib "libalpm" ;

        (* If a target has the use_libalpm flag then libalpm.a is
           a dependency of that target. *)
        dep [ "ocaml" ; "link" ; "use_libalpm" ] [ "libalpm.a" ] ;

        let link_specs = S [ A "-cclib" ; A "-lalpm" ;
                             (S (List.map (fun x -> A x) oalpm_stub_libs)) ]
        in

        (* Add the -lalpm linker flag and .o object files to the
           command when compiling libalpm.a so it is automatically used
           when the libalpm.a library is linked/created. *)

        flag [ "native" ; "ocaml" ; "link" ; "library" ]
          link_specs ;

        (* Use the link specs when linking our executable for
           byte-compiling *)
        flag [ "byte" ; "program" ; "ocaml" ; "link" ; "use_libalpm" ]
          (S [ A "-custom" ; link_specs ]) ;

    | _ -> ()
  end
