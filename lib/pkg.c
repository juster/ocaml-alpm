#include <string.h>

#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/fail.h>
#include <caml/callback.h>
#include <caml/alloc.h>

#include <alpm.h>

#include "core.h"
#include "datatypes.h"
#include "errors.h"
#include "pkg.h"

OALPM_PKG_GET_STR( filename )
OALPM_PKG_GET_STR( name )
OALPM_PKG_GET_STR( version )
OALPM_PKG_GET_STR( desc )
OALPM_PKG_GET_STR( url )
OALPM_PKG_GET_STR( packager )
OALPM_PKG_GET_STR( md5sum )
OALPM_PKG_GET_STR( arch )

OALPM_PKG_GET_STRLIST( compute_requiredby )
OALPM_PKG_GET_STRLIST( get_licenses )
OALPM_PKG_GET_STRLIST( get_groups )
OALPM_PKG_GET_STRLIST( get_optdepends )
OALPM_PKG_GET_STRLIST( get_conflicts )
OALPM_PKG_GET_STRLIST( get_provides )
OALPM_PKG_GET_STRLIST( get_deltas )
OALPM_PKG_GET_STRLIST( get_replaces )
OALPM_PKG_GET_STRLIST( get_files )
OALPM_PKG_GET_STRLIST( get_backup )

OALPM_PKG_GET_LONG( size )
OALPM_PKG_GET_LONG( isize )

OALPM_PKG_HAS_BOOL( scriptlet )
OALPM_PKG_HAS_BOOL( force )

CAMLprim value oalpm_pkg_checkmd5sum ( value package )
{
    pmpkg_t * pkg;
    pmdb_t  * db;
    CAMLparam1( package );
    pkg = Package_val( package );
    db  = alpm_pkg_get_db( pkg );
    if ( strcmp( alpm_db_get_name( db ), "local" ) == 0 ) {
        caml_failwith( FAIL_CHECK_LOCALPKG );
    }
    OALPMreturn( alpm_pkg_checkmd5sum( pkg ));
}

CAMLprim value oalpm_pkg_get_db ( value package )
{
    CAMLparam1( package );
    CAMLreturn( alloc_alpm_db( alpm_pkg_get_db( Package_val( package ))));
}

CAMLprim value oalpm_pkg_get_reason ( value package )
{
    CAMLparam1( package );
    CAMLreturn( Val_int( alpm_pkg_get_reason( Package_val( package ))));
}

