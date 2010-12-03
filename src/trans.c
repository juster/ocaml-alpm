#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/fail.h>
#include <caml/callback.h>
#include <caml/alloc.h>
#include <caml/custom.h>

#include <alpm.h>
#include <alpm_list.h>

#include "core.h"
#include "datatypes.h"

CAMLprim value oalpm_trans_init ( value flaglist )
{
    pmtransflag_t bitflags;
    CAMLparam1( flaglist );
    bitflags = caml_to_alpm_transflaglist( flaglist );
    OALPMreturn( alpm_trans_init( bitflags, NULL, NULL, NULL ));
}

CAMLprim value oalpm_trans_release ( value unit )
{
    CAMLparam1( unit );
    OALPMreturn( alpm_trans_release());
}

CAMLprim value oalpm_trans_interrupt ( value unit )
{
    CAMLparam1( unit );
    OALPMreturn( alpm_trans_interrupt() );
}

CAMLprim value oalpm_sync_sysupgrade ( value enable_downgrade )
{
    CAMLparam1( enable_downgrade );
    OALPMreturn( alpm_sync_sysupgrade( Val_bool( enable_downgrade )));
}

CAMLprim value oalpm_sync_target ( value target )
{
    CAMLparam1( target );
    OALPMreturn( alpm_sync_target( String_val( target )));
}

CAMLprim value oalpm_add_target ( value target )
{
    CAMLparam1( target );
    OALPMreturn( alpm_add_target( String_val( target )));
}

CAMLprim value oalpm_remove_target ( value target )
{
    CAMLparam1( target );
    OALPMreturn( alpm_remove_target( String_val( target )));
}

CAMLprim value oalpm_sync_dbtarget ( value db, value target )
{
    CAMLparam2( db, target );
    OALPMreturn( alpm_sync_dbtarget( Database_val( db ),
                                     String_val( target )));
}
