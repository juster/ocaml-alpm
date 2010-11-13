#ifndef _OALPM_CALLBACKS_H
#define _OALPM_CALLBACKS_H

#include <alpm.h>

#define OALPM_CALLBACK( NAME )                                  \
    static value * NAME ## _callback;                           \
                                                                \
    CAMLprim value oalpm_enable_ ## NAME ## _cb ( value unit )  \
    {                                                           \
        CAMLparam1( unit );                                     \
        NAME ## _callback = caml_named_value( #NAME " callback" );  \
        alpm_option_set_ ## NAME ## cb ( oalpm_ ## NAME ## _cb );   \
        CAMLreturn( Val_unit );                                 \
    }                                                           \
                                                                \
    CAMLprim value oalpm_disable_ ## NAME ## _cb ( value unit ) \
    {                                                           \
        CAMLparam1( unit );                                     \
        NAME ## _callback = NULL;                               \
        alpm_option_set_ ## NAME ## cb ( NULL );                \
        CAMLreturn( Val_unit );                                 \
    }
    
void oalpm_log_cb ( pmloglevel_t level, char * fmt, va_list args );
void oalpm_dl_cb ( const char * filename, off_t xfered, off_t total );
void oalpm_totaldl_cb ( off_t total );
int  oalpm_fetch_cb ( const char * url, const char * localpath, int force );

#endif
