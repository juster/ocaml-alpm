#include <string.h>

#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/fail.h>
#include <caml/callback.h>
#include <caml/alloc.h>
#include <caml/custom.h>

#include <alpm.h>
#include <alpm_list.h>

#include "core.h"
#include "datatypes.h"
#include "trans.h"

/* CALLBACKS ****************************************************************/

/* These define mutators/accessors for callbacks. */

OALPM_TRANS_CB( event )
OALPM_TRANS_CB( conv  )
OALPM_TRANS_CB( prog  )

/* The following C functions are wrappers that call our CAML callbacks */

static void oalpm_event_cb ( pmtransevt_t type, void * one, void * two )
{
    CAMLparam0();
    CAMLlocal1( event );

    if ( event_callback == NULL ) CAMLreturn0;
    
    switch ( type ) {
    case PM_TRANS_EVT_INTERCONFLICTS_DONE:
        event = caml_alloc( 1, 0 );
        Store_field( event, 0, alloc_alpm_pkg( (pmpkg_t *)one ));
        break;
    case PM_TRANS_EVT_UPGRADE_START:
        event = caml_alloc( 1, 1 );
        Store_field( event, 0, alloc_alpm_pkg( (pmpkg_t *)one ));
        break;
    case PM_TRANS_EVT_UPGRADE_DONE:
        event = caml_alloc( 2, 2 );
        Store_field( event, 0, alloc_alpm_pkg( (pmpkg_t *)one ));
        Store_field( event, 1, alloc_alpm_pkg( (pmpkg_t *)two ));
        break;
    case PM_TRANS_EVT_DELTA_PATCHES_DONE:
        event = caml_alloc( 2, 3 );
        Store_field( event, 0, caml_copy_string( (char *)one ));
        Store_field( event, 1, caml_copy_string( (char *)two ));
        break;
    case PM_TRANS_EVT_DELTA_PATCH_FAILED:
        event = caml_alloc( 1, 4 );
        Store_field( event, 0, caml_copy_string( (char *)one ));
        break;
    case PM_TRANS_EVT_SCRIPTLET_INFO:
        event = caml_alloc( 1, 5 );
        Store_field( event, 0, caml_copy_string( (char *)one ));
        break;
    case PM_TRANS_EVT_RETRIEVE_START:
        event = caml_alloc( 1, 6 );
        Store_field( event, 0, caml_copy_string( (char *)one ));
        break;
    default:
        event = Val_int( type - 1 );
    }

    caml_callback( *event_callback, event );
    CAMLreturn0;
}

static void oalpm_conv_cb ( pmtransconv_t type,
                            void * one, void * two, void * three,
                            int * answer )
{
    CAMLparam0();
    CAMLlocal2( event, response );

    if ( conv_callback == NULL ) return;

    /* Tags for the block must match the order the variant type
       is defined in. */

    switch ( type ) {
	case PM_TRANS_CONV_INSTALL_IGNOREPKG:
        /* ( package ) */
        event = caml_alloc( 1, 0 );
        Store_field( event, 0, alloc_alpm_pkg( (pmpkg_t *)one ));
        break;
	case PM_TRANS_CONV_REPLACE_PKG:
        /* ( package * package * string ) */
        event = caml_alloc( 3, 1 );
        Store_field( event, 0, alloc_alpm_pkg( (pmpkg_t *)one ));
        Store_field( event, 1, alloc_alpm_pkg( (pmpkg_t *)two ));
        Store_field( event, 2, caml_copy_string( (char *)three ));
        break;
	case PM_TRANS_CONV_CONFLICT_PKG:
        /* ( string, string, string ) */
        event = caml_alloc( 3, 2 );
        Store_field( event, 0, caml_copy_string( (char *)one ));
        Store_field( event, 1, caml_copy_string( (char *)two ));
        Store_field( event, 2, caml_copy_string( (char *)three ));
        break;
	case PM_TRANS_CONV_CORRUPTED_PKG:
        /* ( string ) */
        event = caml_alloc( 1, 3 );
        Store_field( event, 0, caml_copy_string( (char *)one ));
        break;
	case PM_TRANS_CONV_LOCAL_NEWER:
        /* ( package ) */
        event = caml_alloc( 1, 4 );
        Store_field( event, 0, alloc_alpm_pkg( (pmpkg_t *)one ));
        break;
	case PM_TRANS_CONV_REMOVE_PKGS:
        /* ( package list ) */
        event = caml_alloc( 1, 5 );
        Store_field( event, 0, CAML_PKG_LIST( (alpm_list_t *)one ));
        break;
    default:
        /* Abort the callback if we don't know the conversation type. */
        return;
    }

    response = caml_callback( *conv_callback, event );
    *answer  = Bool_val( response );
    CAMLreturn0;
}

static void oalpm_prog_cb ( pmtransprog_t type, const char * pkg,
                            int percent, int total_count, int total_pos )
{
    CAMLparam0();
    CAMLlocalN( args, 5 );

    switch ( type ) {
	case PM_TRANS_PROGRESS_ADD_START:
        args[0] = Val_int( 0 );
        break;
	case PM_TRANS_PROGRESS_UPGRADE_START:
        args[0] = Val_int( 1 );
        break;
	case PM_TRANS_PROGRESS_REMOVE_START:
        args[0] = Val_int( 2 );
        break;
	case PM_TRANS_PROGRESS_CONFLICTS_START:
        args[0] = Val_int( 3 );
        break;
    default:
        return;
    }

    args[1] = caml_copy_string( pkg );
    args[2] = Val_int( percent );
    args[3] = Val_int( total_count );
    args[4] = Val_int( total_pos );

    caml_callbackN( *prog_callback, 5, args );
    CAMLreturn0;
}

/****************************************************************************/
/* TRANSACTION DATA TYPES
 */

/* Flags */
pmtransflag_t caml_to_alpm_transflag ( value flag )
{
    int flag_idx = Int_val( flag );
    if ( flag_idx >= 3  ) ++flag_idx;
    if ( flag_idx >= 7  ) ++flag_idx;
    if ( flag_idx >= 12 ) ++flag_idx;
    return (1 << flag_idx);
}

pmtransflag_t caml_to_alpm_transflaglist ( value flag_list )
{
    pmtransflag_t bitflags;

    if ( ! Is_block( flag_list )) { return 0; }
    bitflags  = caml_to_alpm_transflag    ( Field( flag_list, 0 ));
    bitflags |= caml_to_alpm_transflaglist( Field( flag_list, 1 ));
    return bitflags;
}

/* ERRORS */

value alpm_to_caml_conflict ( void * data )
{
    pmconflict_t * conflict = data;
    const char * str;

    CAMLparam0();
    CAMLlocal2( conflict_rec, packages );
    packages     = caml_alloc( 2, 0 );
    conflict_rec = caml_alloc( 2, 0 );

    str = alpm_conflict_get_package1( conflict );
    Store_field( packages, 0, caml_copy_string( str ));
    str = alpm_conflict_get_package2( conflict );
    Store_field( packages, 1, caml_copy_string( str ));
    Store_field( conflict_rec, 0, packages );

    str = alpm_conflict_get_reason( conflict );
    Store_field( conflict_rec, 1, caml_copy_string( str ));
    
    CAMLreturn( conflict_rec );
}

value alpm_to_caml_fileconflict ( void * data )
{
    pmfileconflict_t * conflict = data;
    const char * str;

    CAMLparam0();
    CAMLlocal2( conflict_rec, conflict_type );

    switch ( alpm_fileconflict_get_type( conflict )) {
    case PM_FILECONFLICT_TARGET:     conflict_type = Val_int( 0 ); break;
    case PM_FILECONFLICT_FILESYSTEM: conflict_type = Val_int( 1 ); break;
    default:
        caml_failwith( "Unrecognized fileconflict type" );
    }

    conflict_rec = caml_alloc( 4, 0 );
    Store_field( conflict_rec, 0, conflict_type );
    str = alpm_fileconflict_get_target( conflict );
    Store_field( conflict_rec, 1, caml_copy_string( str ));
    str = alpm_fileconflict_get_file( conflict );
    Store_field( conflict_rec, 2, caml_copy_string( str ));
    str = alpm_fileconflict_get_ctarget( conflict );
    Store_field( conflict_rec, 3, caml_copy_string( str ));

    CAMLreturn( conflict_rec );
}

value alpm_to_caml_depmissing ( void * data )
{
    pmdepmissing_t * dm = data;
    const char * str;
    CAMLparam0();
    CAMLlocal2( depmiss, dep );
    
    dep     = caml_copy_dependency( alpm_miss_get_dep( dm ));
    depmiss = caml_alloc( 3, 0 );
    str = alpm_miss_get_target( dm );
    Store_field( depmiss, 0, caml_copy_string( str ));
    str = alpm_miss_get_causingpkg( dm );
    Store_field( depmiss, 1, caml_copy_string( str ));
    Store_field( depmiss, 2, dep );

    CAMLreturn( depmiss );
}

/****************************************************************************/

CAMLprim value oalpm_trans_init ( value flaglist )
{
    pmtransflag_t bitflags;
    alpm_trans_cb_event    eventcb = NULL;
    alpm_trans_cb_conv     convcb  = NULL;
    alpm_trans_cb_progress progcb  = NULL;

    CAMLparam1( flaglist );
    bitflags = caml_to_alpm_transflaglist( flaglist );

    if ( event_callback != NULL ) eventcb = oalpm_event_cb;
    if ( conv_callback  != NULL ) convcb  = oalpm_conv_cb;
    if ( prog_callback  != NULL ) progcb  = oalpm_prog_cb;

    OALPMreturn( alpm_trans_init( bitflags, eventcb, convcb, progcb ));
}

CAMLprim value oalpm_trans_prepare ( value unit )
{
    alpm_list_t * errors;

    CAMLparam1( unit );
    OALPMreturn( alpm_trans_prepare( &errors ));
}

CAMLprim value oalpm_trans_commit ( value unit )
{
    alpm_list_t * errors;

    CAMLparam1( unit );
    OALPMreturn( alpm_trans_commit( &errors ));
}

CAMLprim value oalpm_trans_release ( value unit )
{
    CAMLparam1( unit );
    OALPMreturn( alpm_trans_release());
}

CAMLprim value oalpm_trans_interrupt ( value unit )
{
    CAMLparam1( unit );
    OALPMreturn( alpm_trans_interrupt());
}

CAMLprim value oalpm_trans_get_add ( value unit )
{
    CAMLparam1( unit );
    CAMLreturn( CAML_PKG_LIST( alpm_trans_get_add()));
}

CAMLprim value oalpm_trans_get_remove ( value unit )
{
    CAMLparam1( unit );
    CAMLreturn( CAML_PKG_LIST( alpm_trans_get_remove()));
}

CAMLprim value oalpm_sync_sysupgrade ( value enable_downgrade )
{
    CAMLparam1( enable_downgrade );
    OALPMreturn( alpm_sync_sysupgrade( Bool_val( enable_downgrade )));
}

CAMLprim value oalpm_sync_target ( value target )
{
    CAMLparam1( target );
    OALPMreturn( alpm_sync_target( String_val( target )));
}

CAMLprim value oalpm_add_target ( value target )
{
    CAMLparam1( target );
    OALPMreturn( alpm_add_target( String_val( target )));
}

CAMLprim value oalpm_remove_target ( value target )
{
    CAMLparam1( target );
    OALPMreturn( alpm_remove_target( String_val( target )));
}

CAMLprim value oalpm_sync_dbtarget ( value db, value target )
{
    CAMLparam2( db, target );
    OALPMreturn( alpm_sync_dbtarget( String_val( db ),
                                     String_val( target )));
}
