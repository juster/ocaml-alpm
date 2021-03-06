#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/fail.h>
#include <caml/callback.h>
#include <caml/alloc.h>
#include <string.h>
#include <alpm.h>

#include "core.h"
#include "datatypes.h"
#include "errors.h"

CAMLprim value oalpm_db_get_name ( value db )
{
    CAMLparam1( db );
    CAMLreturn( caml_copy_string( alpm_db_get_name( Database_val( db ))));
}

CAMLprim value oalpm_db_get_url ( value db )
{
    CAMLparam1( db );
    
    pmdb_t * alpmdb = Database_val( db );
    if ( strcmp( alpm_db_get_name( alpmdb ), "local" ) == 0 ) {
        caml_failwith( FAIL_LOCALDB_URL );
    }

    CAMLreturn( caml_copy_string( alpm_db_get_url( alpmdb )));
}

CAMLprim value oalpm_db_add_url ( value db, value url )
{
    CAMLparam2( db, url );
    OALPMreturn( alpm_db_setserver( Database_val( db ),
                                    String_val( url )));
}

CAMLprim value oalpm_db_get_pkg ( value db, value pkgname )
{
    pmpkg_t * alpm_pkg;
    pmdb_t * alpm_db;
    CAMLparam2( db, pkgname );
    alpm_db  = Database_val( db );
    alpm_pkg = alpm_db_get_pkg( alpm_db, String_val( pkgname ));
    if ( alpm_pkg == NULL ) {
        caml_raise_constant( *caml_named_value( "Not_found" ));        
    }
    CAMLreturn( alloc_alpm_pkg( alpm_pkg ));
}

CAMLprim value oalpm_db_get_pkgcache ( value db )
{
    alpm_list_t * pkg_list;

    CAMLparam1( db );
    pkg_list = alpm_db_get_pkgcache( Database_val( db ));
    CAMLreturn( CAML_PKG_LIST( pkg_list ));
}

CAMLprim value oalpm_db_update ( value force, value db )
{
    int ret;
    CAMLparam2( force, db );
    ret = alpm_db_update( Bool_val( force ), Database_val( db ));
    if ( ret > 0 ) {
        raise_alpm_error();
    }
    CAMLreturn( Val_unit );
}

CAMLprim value oalpm_db_search ( value db, value keywords )
{
    alpm_list_t * alpm_keywords;
    pmdb_t * alpm_db;

    alpm_keywords = ALPM_STR_LIST( keywords );
    alpm_db = Database_val( db );

    CAMLparam2( db, keywords );
    CAMLreturn( CAML_PKG_LIST( alpm_db_search( alpm_db, alpm_keywords )));
}

CAMLprim value oalpm_db_readgrp ( value db, value group_name )
{
    pmgrp_t * alpm_grp;
    pmdb_t * alpm_db;

    CAMLparam2( db, group_name );
    alpm_db = Database_val( db );
    alpm_grp = alpm_db_readgrp( alpm_db, String_val( group_name ));

    if ( alpm_grp == NULL ) {
        caml_raise_constant( *caml_named_value( "Not_found" ));
    }

    CAMLreturn( caml_copy_group( alpm_grp ));
}

CAMLprim value oalpm_db_get_grpcache ( value db )
{
    pmdb_t * alpm_db;

    CAMLparam1( db );
    alpm_db = Database_val( db );
    CAMLreturn( CAML_GRP_LIST( alpm_db_get_grpcache( alpm_db )));
}

CAMLprim value oalpm_db_set_pkgreason ( value db, value pkgname,
                                        value pkgreason )
{
    CAMLparam3( db, pkgname, pkgreason );

    OALPMreturn( alpm_db_set_pkgreason( Database_val( db ),
                                        String_val( pkgname ),
                                        Int_val( pkgreason )));
}
