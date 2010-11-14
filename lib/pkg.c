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

CAMLprim value oalpm_pkg_checkmd5sum ( value package )
{
    CAMLparam1( package );
    OALPMreturn( alpm_pkg_checkmd5sum( Package_val( package )));
}


