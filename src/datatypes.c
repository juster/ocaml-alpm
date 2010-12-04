#include <stdlib.h>
#include <stdio.h>
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

CUSTOM_ALPM_TYPE( db, Database )
CUSTOM_ALPM_TYPE( pkg, Package )

void finalize_autofree_pkg ( value package )
{
    fprintf( stderr, "FREEING PACKAGE!\n" );
    alpm_pkg_free( Package_val( package ));
    return;
}

static struct custom_operations alpm_pkg_free_opts = {
    "org.archlinux.caml.alpm.pkg.autofree",
    finalize_autofree_pkg,
    custom_compare_default,
    custom_hash_default,
    custom_serialize_default,
    custom_deserialize_default,
};

value alloc_alpm_pkg_autofree ( pmpkg_t * pkg )
{
    value custom = alloc_custom( &alpm_pkg_free_opts,
                                 sizeof ( pmpkg_t * ),
                                 0, 1 );
    Package_val( custom ) = pkg;
    return custom;
}

value alpm_to_caml_list ( alpm_list_t * list, alpm_elem_conv converter )
{
    CAMLparam0();
    CAMLlocal1( cell );

    if ( list ) {
        cell = caml_alloc( 2, 0 );
        Store_field( cell, 0, (*converter)( list->data ));
        Store_field( cell, 1, alpm_to_caml_list( list->next, converter ));
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

value alpm_to_caml_dependency ( void * elem )
{
    CAMLparam0();
    CAMLreturn( caml_copy_dependency( (pmdepend_t *) elem ));
}

value alpm_to_caml_grpelem ( void * elem )
{
    CAMLparam0();
    CAMLreturn( caml_copy_group( (pmgrp_t *) elem ));
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

value alpm_to_caml_pkgelem ( void * elem )
{
    return alloc_alpm_pkg( (pmpkg_t *) elem );
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

value caml_copy_depmod ( pmdepmod_t depmod )
{
    int idx;
    CAMLparam0();
    CAMLlocal1( camldepmod );

    if ( depmod > 6 ) {
        caml_invalid_argument( "Unrecognized depmod data-type" );
    }
    idx = depmod - 1;

    camldepmod = Val_int( idx );
    CAMLreturn( camldepmod );
}

value caml_copy_dependency ( pmdepend_t * dep )
{
    CAMLparam0();
    CAMLlocal1( camldep );
    camldep = caml_alloc( 3, 0 );
    Store_field( camldep, 0, caml_copy_string( dep->name ));
    Store_field( camldep, 1, caml_copy_depmod( dep->mod ));
    if ( dep->mod == PM_DEP_MOD_ANY ) {
        Store_field( camldep, 2, caml_copy_string( "" ));
    }
    else {
        Store_field( camldep, 2, caml_copy_string( dep->version ));
    }
    CAMLreturn( camldep );
}

value caml_copy_group ( pmgrp_t * group )
{
    CAMLparam0();
    CAMLlocal1( camlgroup );

    camlgroup = caml_alloc( 2, 0 );
    Store_field( camlgroup, 0, caml_copy_string( group->name ));
    Store_field( camlgroup, 1, CAML_PKG_LIST( group->packages ));
    CAMLreturn( camlgroup );
}
