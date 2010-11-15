#ifndef _OALPM_PKG_H
#define _OALPM_PKG_H

#define OALPM_PKG_GET_STR( NAME )                                       \
    CAMLprim value oalpm_pkg_get_ ## NAME ( value package )             \
    {                                                                   \
        pmpkg_t * pkg;                                                  \
        CAMLparam1( package );                                          \
        pkg = Package_val( package );                                   \
        CAMLreturn( caml_copy_string( alpm_pkg_get_ ## NAME ( pkg )));  \
    }

#define OALPM_PKG_GET_STRLIST( NAME )                           \
    CAMLprim value oalpm_pkg_ ## NAME ( value package )         \
    {                                                           \
        pmpkg_t * pkg;                                          \
        CAMLparam1( package );                                  \
        pkg = Package_val( package );                           \
        CAMLlocal1( list );                                     \
        list = CAML_STR_LIST( alpm_pkg_ ## NAME ( pkg ));       \
        CAMLreturn( list );                                     \
    }

#define OALPM_PKG_LONG( NAME )                                          \
    CAMLprim value oalpm_pkg_ ## NAME ( value package )                 \
    {                                                                   \
        pmpkg_t * pkg;                                                  \
        CAMLparam1( package );                                          \
        pkg = Package_val( package );                                   \
        CAMLreturn( Val_long( alpm_pkg_ ## NAME ( pkg )));              \
    }

#define OALPM_PKG_HAS_BOOL( NAME )                              \
    CAMLprim value oalpm_pkg_has_ ## NAME ( value package )     \
    {                                                           \
        pmpkg_t * pkg;                                          \
        CAMLparam1( package );                                  \
        pkg = Package_val( package );                           \
        CAMLreturn( Val_bool( alpm_pkg_has_ ## NAME ( pkg )));   \
    }

#endif
