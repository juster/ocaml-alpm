#ifndef _OALPM_DATATYPES_H
#define _OALPM_DATATYPES_H

typedef value (*alpm_elem_conv)( void * );
value alpm_to_caml_list ( alpm_list_t *list, alpm_elem_conv converter );
value alpm_to_caml_strelem ( void * elem );

#define CAML_STR_LIST( LIST ) \
    alpm_to_caml_list( LIST, alpm_to_caml_strelem )

typedef void * (*caml_elem_conv)( value );
alpm_list_t * caml_to_alpm_list ( value list, caml_elem_conv converter );
void * caml_to_alpm_strelem ( value str );

#define ALPM_STR_LIST( LIST ) \
    caml_to_alpm_list( LIST, caml_to_alpm_strelem )

#endif
