#ifndef _OALPM_OPTIONS_H
#define _OALPM_OPTIONS_H

#define OALPM_SET_OPT_STR( NAME )                                       \
    CAMLprim value oalpm_option_set_ ## NAME ( value new_str )          \
    {                                                                   \
        CAMLparam1( new_str );                                          \
        OALPMreturn( alpm_option_set_ ## NAME ( String_val( new_str ))); \
    }

#define OALPM_GET_OPT_STR( NAME )                                   \
    CAMLprim value oalpm_option_get_ ## NAME ( value unit )         \
    {                                                               \
        CAMLparam1( unit );                                         \
        CAMLreturn( caml_copy_string( (char *)                      \
                                      alpm_option_get_ ## NAME ()));    \
    }

#define OALPM_OPT_STR( NAME ) \
    OALPM_GET_OPT_STR( NAME ) \
    OALPM_SET_OPT_STR( NAME )

#endif /*_OALPM_OPTIONS_H*/
