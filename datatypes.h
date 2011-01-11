#ifndef _OALPM_DATATYPES_H
#define _OALPM_DATATYPES_H

/* copied from libalpm's deps.h */
/* Dependency */
struct __pmdepend_t {
	pmdepmod_t mod;
	char *name;
	char *version;
};

/* copied from groups.h */
struct __pmgrp_t {
	/** group name */
	char *name;
	/** list of pmpkg_t packages */
	alpm_list_t *packages;
};

/* List conversion */
typedef value (*alpm_elem_conv)( void * );
value alpm_to_caml_list ( alpm_list_t * list, alpm_elem_conv converter );
value alpm_to_caml_strelem ( void * elem );
value alpm_to_caml_dbelem ( void * elem );
value alpm_to_caml_pkgelem ( void * elem );
value alpm_to_caml_dependency( void * elem );
value alpm_to_caml_grpelem ( void * elem );

typedef void * (*caml_elem_conv)( value );
alpm_list_t * caml_to_alpm_list ( value list, caml_elem_conv converter );
void * caml_to_alpm_strelem ( value str );

#define CAML_STR_LIST( LIST ) alpm_to_caml_list( LIST, alpm_to_caml_strelem )
#define CAML_DB_LIST( LIST )  alpm_to_caml_list( LIST, alpm_to_caml_dbelem  )
#define CAML_PKG_LIST( LIST ) alpm_to_caml_list( LIST, alpm_to_caml_pkgelem )
#define CAML_DEP_LIST( LIST ) \
    alpm_to_caml_list( LIST, alpm_to_caml_dependency )
#define CAML_GRP_LIST( LIST ) \
    alpm_to_caml_list( LIST, alpm_to_caml_grpelem )

#define ALPM_STR_LIST( LIST ) \
    caml_to_alpm_list( LIST, caml_to_alpm_strelem )

/* Custom data-types, wrappers around pointers to ALPM data-types */
#define CUSTOM_ALPM_VAL( TYPE, VALUE ) \
    ( *(( TYPE ** ) Data_custom_val( VALUE )))
#define Database_val( VALUE )   CUSTOM_ALPM_VAL( pmdb_t, VALUE  )
#define Package_val( VALUE )    CUSTOM_ALPM_VAL( pmpkg_t, VALUE )

#define CUSTOM_ALPM_TYPE( TYPE, CAMLVAL )                           \
    static struct custom_operations alpm_ ## TYPE ##_opts = {       \
        "org.archlinux.caml.alpm." #TYPE ,                          \
        custom_finalize_default,                                    \
        custom_compare_default,                                     \
        custom_hash_default,                                        \
        custom_serialize_default,                                   \
        custom_deserialize_default,                                 \
    };                                                              \
                                                                    \
    value alloc_alpm_ ## TYPE ( pm ## TYPE ## _t * data )           \
    {                                                               \
        value custom = alloc_custom( &alpm_ ## TYPE ## _opts,       \
                                     sizeof ( pm ## TYPE ## _t * ), \
                                     0, 1 );                        \
        CAMLVAL ## _val( custom ) = data;                           \
        return custom;                                              \
    }

value alloc_alpm_db  ( pmdb_t * db );
value alloc_alpm_pkg ( pmpkg_t * pkg );
value alloc_alpm_pkg_autofree ( pmpkg_t * pkg );

/* Other user-defined types */

value caml_copy_depmod ( pmdepmod_t depmod );
value caml_copy_dependency ( pmdepend_t * dep );
value caml_copy_group ( pmgrp_t * group );

#endif
