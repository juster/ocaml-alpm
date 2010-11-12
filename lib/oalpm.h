#ifndef _OALPM_H
#define _OALPM_H

#define OALPMreturn( RET ) \
    if ( RET == -1 ) {     \
        caml_raise_with_string( *caml_named_value( "AlpmError" ),  \
                                alpm_strerrorlast());           \
    }                                                           \
    CAMLreturn( Val_unit ) /* no semicolon */

#endif
