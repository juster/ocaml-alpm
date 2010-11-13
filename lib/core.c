#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/fail.h>
#include <caml/callback.h>
#include <caml/alloc.h>
#include <string.h>
#include <alpm.h>

#include "core.h"
#include "datatypes.h"

CAMLprim value oalpm_initialize ( value unit )
{
    CAMLparam1( unit );
    OALPMreturn( alpm_initialize());
    CAMLreturn( Val_unit );
}

CAMLprim value oalpm_release ( value unit )
{
    CAMLparam1( unit );
    OALPMreturn( alpm_release());
}

CAMLprim value oalpm_version ( value unit )
{
    CAMLparam1( unit );
    CAMLreturn( caml_copy_string( alpm_version() ));
}

CAMLprim value oalpm_register ( value name )
{
    pmdb_t * db;
    char * str;

    CAMLparam1( name );
    str = String_val( name );
    if ( strcmp( str, "local" ) == 0 ) {
        db = alpm_db_register_local();
    }
    else {
        db = alpm_db_register_sync( str );
    }

    CAMLreturn( alloc_alpm_db( db ));
}

CAMLprim value oalpm_localdb ( value unit )
{
    pmdb_t * db;

    CAMLparam1( unit );
    db = alpm_option_get_localdb();
    if ( db == NULL ) {
        caml_raise_constant( *caml_named_value( "NoLocalDB" ));
    }

    CAMLreturn( alloc_alpm_db( db ));
}

CAMLprim value oalpm_syncdbs ( value unit )
{
    CAMLparam1( unit );
    CAMLreturn( CAML_DB_LIST( alpm_option_get_syncdbs() ));
}
