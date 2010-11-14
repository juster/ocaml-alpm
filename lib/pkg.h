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

#endif
