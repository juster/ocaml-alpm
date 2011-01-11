#ifndef _OALPM_TRANS_H
#define _OALPM_TRANS_H

#define OALPM_TRANS_CB( NAME )                                  \
    static value * NAME ## _callback = NULL;                    \
                                                                \
    CAMLprim value oalpm_toggle_ ## NAME ## _cb ( value flag )  \
    {                                                           \
        CAMLparam1( flag );                                     \
        if ( Bool_val( flag )) {                                \
            NAME ## _callback =                                 \
                caml_named_value( #NAME " callback" );          \
        }                                                       \
        else {                                                  \
            NAME ## _callback = NULL ;                          \
        }                                                       \
        CAMLreturn( Val_unit );                                 \
    }

/* Transaction data types */

pmtransflag_t caml_to_alpm_transflag ( value flag );
pmtransflag_t caml_to_alpm_transflaglist ( value flag_list );

#endif
