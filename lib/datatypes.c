#include <stdlib.h>
#include <string.h>

#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/fail.h>
#include <caml/callback.h>
#include <caml/alloc.h>
#include <caml/custom.h>

#include <alpm.h>
#include <alpm_list.h>

#include "datatypes.h"

value alpm_to_caml_list ( alpm_list_t * list, alpm_elem_conv converter )
{
    CAMLparam0();
    CAMLlocal1( cell );

    if ( list ) {
        cell = caml_alloc( 2, 0 );
        Store_field( cell, 1, alpm_to_caml_list( list->next, converter ));
        Store_field( cell, 0, (*converter)( list->data ));
    }
    else {
        cell = Val_int( 0 );
    }

    CAMLreturn( cell );
}

value alpm_to_caml_strelem ( void * elem )
{
    CAMLparam0();
    CAMLreturn( caml_copy_string( (char *) elem ));
}

static alpm_list_t * build_alpm_list ( value list,
                                       caml_elem_conv converter,
                                       alpm_list_t **last )
{
    alpm_list_t * elem, * next;

    if ( Is_block( list )) {
        elem = malloc( sizeof( alpm_list_t ));
        elem->prev = NULL;
        elem->data = (*converter)( Field( list, 0 ));

        next = caml_to_alpm_list( Field( list, 1 ), converter );
        elem->next = next;

        if ( next == NULL ) *last = elem;
        else next->prev = elem;
    }
    else {
        /* Field 0 of the block list should be 0. */
        elem = NULL;
    }

    return elem;
}

value alpm_to_caml_dbelem ( void * elem )
{
    return alloc_alpm_db( (pmdb_t *) elem );
}


alpm_list_t * caml_to_alpm_list ( value list,
                                  caml_elem_conv converter )
{
    alpm_list_t * head, * tail;

    head = tail = NULL;
    head = build_alpm_list( list, converter, &tail );
    if ( head && tail ) head->prev = tail;

    return head;
}

void * caml_to_alpm_strelem ( value str )
{
    char * alpm_str;
    int len;

    len = caml_string_length( str );
    alpm_str = calloc( len, sizeof( char ));
    if ( alpm_str == NULL ) return NULL;

    memcpy( alpm_str, String_val( str ),
            len * sizeof( char ));

    return (void *) alpm_str;
}

static struct custom_operations alpm_db_opts = {
    "org.archlinux.caml.alpm.database",
    custom_finalize_default,
    custom_compare_default,
    custom_hash_default,
    custom_serialize_default,
    custom_deserialize_default,
};

value alloc_alpm_db ( pmdb_t * db )
{
    value camldb = alloc_custom( &alpm_db_opts,
                                 sizeof ( pmdb_t * ),
                                 0, 1 );
    Database_val( camldb ) = db;
    return camldb;
}

