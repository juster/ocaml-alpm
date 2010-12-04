#ifndef _OALPM_TRANS_H
#define _OALPM_TRANS_H

/* copied from libalpm/conflict.h */

struct __pmconflict_t {
	char *package1;
	char *package2;
	char *reason;
};

struct __pmfileconflict_t {
	char *target;
	pmfileconflicttype_t type;
	char *file;
	char *ctarget;
};

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
