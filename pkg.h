#ifndef _OALPM_PKG_H
#define _OALPM_PKG_H

#define OALPM_PKG_ACCESSOR( NAME, CAML_VAL )                            \
    CAMLprim value oalpm_pkg_ ## NAME ( value package )                 \
    {                                                                   \
        pmpkg_t * pkg;                                                  \
        CAMLparam1( package );                                          \
        pkg = Package_val( package );                                   \
        CAMLreturn( CAML_VAL ( alpm_pkg_ ## NAME ( pkg )));             \
    }

#define OALPM_PKG_GET_STR( NAME ) \
    OALPM_PKG_ACCESSOR( get_ ## NAME, caml_copy_string )

#define OALPM_PKG_STRLIST( NAME ) \
    OALPM_PKG_ACCESSOR( NAME, CAML_STR_LIST )

#define OALPM_PKG_LONG( NAME ) \
    OALPM_PKG_ACCESSOR( NAME, Val_long )

#define OALPM_PKG_FLOAT( NAME ) \
    OALPM_PKG_ACCESSOR( NAME, caml_copy_double )

/* #define OALPM_PKG_FLOAT( NAME )                                         \ */
/*     CAMLprim value oalpm_pkg_ ## NAME ( value package )                 \ */
/*     {                                                                   \ */
/*         pmpkg_t * pkg;                                                  \ */
/*         CAMLparam1( package );                                          \ */
/*         CAMLlocal1( fvalue );                                           \ */
/*         pkg = Package_val( package );                                   \ */
/*         fvalue = caml_alloc( 1, Double_tag );                           \ */
/*         CAMLreturn( CAML_VAL ( alpm_pkg_ ## NAME ( pkg )));             \ */
/*     } */

#define OALPM_PKG_HAS_BOOL( NAME ) \
    OALPM_PKG_ACCESSOR( has_ ## NAME, Val_bool )

#endif
