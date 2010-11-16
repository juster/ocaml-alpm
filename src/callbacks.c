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

    vsnprintf( buffer, 255, fmt, args );

    while ( (level >>= 1) > 0 ) {
        ++typeidx;
    }

    caml_callback2( *log_callback, Val_int( typeidx ),
                    caml_copy_string( buffer ));

    return;
}

void oalpm_dl_cb ( const char * filename, off_t xfered, off_t total )
{
    caml_callback3( *dl_callback, caml_copy_string( filename ),
                    Val_int( xfered ), Val_int( total ));
    return;
}

void oalpm_totaldl_cb ( off_t total )
{
    caml_callback( *totaldl_callback, Val_int( total ));
    return;
}

int  oalpm_fetch_cb ( const char * url, const char * localpath, int force )
{
    int result;
    result = caml_callback3( *fetch_callback,
                             caml_copy_string( url ),
                             caml_copy_string( localpath ),
                             Val_bool( force ));
    return Int_val( result );
}

                   
