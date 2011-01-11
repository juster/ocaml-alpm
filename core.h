#ifndef _OALPM_H
#define _OALPM_H

#define raise_alpm_error()                                      \
    caml_raise_with_string( *caml_named_value( "AlpmError" ),   \
                            alpm_strerrorlast())
    
#define OALPMreturn( RET )                      \
    if ( RET == -1 ) { raise_alpm_error(); }    \
    CAMLreturn( Val_unit ) /* no semicolon */

#endif
