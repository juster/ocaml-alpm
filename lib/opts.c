#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/alloc.h>
#include <alpm.h>

#include "core.h"
#include "opts.h"

/* STRING OPTIONS ***********************************************************/

OALPM_OPT_STR( root      )
OALPM_OPT_STR( dbpath    )
OALPM_OPT_STR( logfile   )

OALPM_GET_OPT_STR( lockfile )
OALPM_GET_OPT_STR( arch     )

/* set_arch is different: it returns void in libalpm */
CAMLprim value oalpm_option_set_arch ( value new_str )
{
    CAMLparam1( new_str );
    alpm_option_set_arch( String_val( new_str ));
    CAMLreturn( Val_unit );
}
