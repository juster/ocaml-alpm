#ifndef _OALPM_OPTIONS_H
#define _OALPM_OPTIONS_H

#include "datatypes.h"

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

#define OALPM_SET_OPT_STRLIST( NAME ) \
    CAMLprim value oalpm_option_set_ ## NAME ( value strlist )  \
    {                                                           \
        CAMLparam1( strlist );                                  \
        alpm_option_set_ ## NAME ( ALPM_STR_LIST( strlist ));   \
        CAMLreturn( Val_unit );                                 \
    }

#define OALPM_GET_OPT_STRLIST( NAME )                           \
    CAMLprim value oalpm_option_get_ ## NAME ( value unit )     \
    {                                                           \
        CAMLparam1( unit );                                     \
        CAMLlocal1( list );                                     \
        list = CAML_STR_LIST( alpm_option_get_ ## NAME () );    \
        CAMLreturn( list );                                     \
    }

#define OALPM_ADD_OPT_STRLIST( NAME )                      \
    CAMLprim value oalpm_option_add_ ## NAME ( value str ) \
    {                                                      \
        CAMLparam1( str );                                 \
        alpm_option_add_ ## NAME ( String_val( str ));     \
        CAMLreturn( Val_unit );                            \
    }

#define OALPM_REM_OPT_STRLIST( NAME )           \
    CAMLprim value oalpm_option_rem_ ## NAME ( value str ) \
    {                                                      \
        CAMLparam1( str );                                 \
        alpm_option_remove_ ## NAME ( String_val( str ));     \
        CAMLreturn( Val_unit );                            \
    }

#define OALPM_OPT_STRLIST( NAME )      \
    OALPM_SET_OPT_STRLIST( NAME ## s ) \
    OALPM_GET_OPT_STRLIST( NAME ## s ) \
    OALPM_ADD_OPT_STRLIST( NAME )      \
    OALPM_REM_OPT_STRLIST( NAME )

#endif /*_OALPM_OPTIONS_H*/
