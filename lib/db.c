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

CAMLprim value oalpm_db_get_pkgcache ( value db )
{
    alpm_list_t * pkg_list;

    CAMLparam1( db );
    pkg_list = alpm_db_get_pkgcache( Database_val( db ));
    CAMLreturn( CAML_PKG_LIST( pkg_list ));
}
