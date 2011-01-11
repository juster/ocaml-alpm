#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/alloc.h>
#include <stdarg.h>
#include <stdio.h>

#include "callbacks.h"

OALPM_CALLBACK( log     )
OALPM_CALLBACK( dl      )
OALPM_CALLBACK( totaldl )
OALPM_CALLBACK( fetch   )

void oalpm_log_cb ( pmloglevel_t level, char * fmt, va_list args )
{
    char buffer[256];
    int typeidx = 0;

    CAMLparam0();
    CAMLlocal2( type, message );

    vsnprintf( buffer, 255, fmt, args );

    while ( (level >>= 1) > 0 ) {
        ++typeidx;
    }

    type    = Val_int( typeidx );
    message = caml_copy_string( buffer );
    caml_callback2( *log_callback, type, message );

    CAMLreturn0;
}

void oalpm_dl_cb ( const char * filename, off_t xfered, off_t total )
{
    CAMLparam0();
    CAMLlocal3( caml_fname, caml_xfered, caml_total );
    caml_fname  = caml_copy_string( filename );
    caml_xfered = Val_int( xfered );
    caml_total  = Val_int( total );
    caml_callback3( *dl_callback, caml_fname, caml_xfered, caml_total );
    CAMLreturn0;
}

void oalpm_totaldl_cb ( off_t total )
{
    CAMLparam0();
    CAMLlocal1( caml_total );
    caml_total = Val_int( total );
    caml_callback( *totaldl_callback, caml_total );
    CAMLreturn0;
}

int  oalpm_fetch_cb ( const char * url, const char * localpath, int force )
{
    int result;
    CAMLparam0();
    CAMLlocal3( caml_url, caml_dir, caml_force );

    caml_url   = caml_copy_string( url );
    caml_dir   = caml_copy_string( localpath );
    caml_force = Val_bool( force );
    
    result = caml_callback3( *fetch_callback,
                             caml_url, caml_dir, caml_force );
    CAMLreturn( Int_val( result ));
}
