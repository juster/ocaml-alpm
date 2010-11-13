#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/fail.h>
#include <caml/callback.h>
#include <caml/alloc.h>
#include <string.h>
#include <alpm.h>

#include "core.h"
#include "datatypes.h"

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
        caml_failwith( "The local database has no url" );
    }

    CAMLreturn( caml_copy_string( alpm_db_get_url( alpmdb )));
}

CAMLprim value oalpm_db_add_url ( value db, value url )
{
    CAMLparam2( db, url );
    OALPMreturn( alpm_db_setserver( Database_val( db ),
                                    String_val( url )));
}
