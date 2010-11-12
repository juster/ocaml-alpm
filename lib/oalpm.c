#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/fail.h>
#include <caml/callback.h>
#include <alpm.h>
#include "oalpm.h"

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
