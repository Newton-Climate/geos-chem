! $Id: global_o3_mod.f,v 1.1 2004/07/15 18:17:46 bmy Exp $
      MODULE GLOBAL_O3_MOD
!
!******************************************************************************
!  Module GLOBAL_O3_MOD contains variables and routines for reading the
!  global monthly mean O3 concentration from disk.  These are needed for the 
!  offline sulfate/aerosol simulation. (rjp, bmy, 7/13/04)
!
!  Module Variables:
!  ===========================================================================
!  (1 ) O3 (REAL*8)       : Stores global monthly mean O3 field
!  
!  Module Routines:
!  =========================================================================== 
!  (1 ) GET_GLOBAL_O3     : Reads global monthly mean HO3 from disk
!  (2 ) INIT_GLOBAL_O3    : Allocates & initializes the HO3 array
!  (3 ) CLEANUP_GLOBAL_O3 : Deallocates the HO3 array
!
!  GEOS-CHEM modules referenced by global_O3_mod.f
!  ============================================================================
!  (1 ) bpch2_mod.f    : Module containing routines for binary punch file I/O
!  (2 ) error_mod.f    : Module containing NaN and other error check routines
!  (3 ) transfer_mod.f : Module containing routines to cast & resize arrays
!
!  NOTES:
!******************************************************************************
!     
      IMPLICIT NONE

      !=================================================================
      ! MODULE PRIVATE DECLARATIONS -- keep certain internal variables 
      ! and routines from being seen outside "global_hO3_mod.f"
      !=================================================================

      ! PRIVATE module variables
      PRIVATE :: INIT_GLOBAL_O3

      !=================================================================
      ! MODULE VARIABLES
      !=================================================================

      ! Array to store global monthly mean OH field
      REAL*8, ALLOCATABLE :: O3(:,:,:)

      !=================================================================
      ! MODULE ROUTINES -- follow below the "CONTAINS" statement 
      !=================================================================
      CONTAINS

!------------------------------------------------------------------------------

      SUBROUTINE GET_GLOBAL_O3( THISMONTH )
!
!******************************************************************************
!  Subroutine GET_GLOBAL_O3 reads monthly mean O3 data fields.  
!  These are needed for simulations such as offline sulfate/aerosol. 
!  (bmy, 7/13/04)
!
!  Arguments as Input:
!  ===========================================================================
!  (1 ) THISMONTH (INTEGER) : Current month number (1-12)
!
!  NOTES:
!  (1 ) Minor bug fix in FORMAT statements (bmy, 3/23/03)
!  (2 ) Cosmetic changes (bmy, 3/27/03)
!******************************************************************************
!
      ! References to F90 modules
      USE BPCH2_MOD
      USE TRANSFER_MOD, ONLY : TRANSFER_3D

      IMPLICIT NONE

#     include "CMN_SIZE"   ! Size parameters
#     include "CMN_SETUP"  ! DATA_DIR

      ! Arguments
      INTEGER, INTENT(IN)  :: THISMONTH

      ! Local variables
      INTEGER              :: I, J, L
      REAL*4               :: ARRAY(IGLOB,JGLOB,LGLOB)
      REAL*8               :: XTAU
      CHARACTER(LEN=255)   :: FILENAME

      ! First time flag
      LOGICAL, SAVE        :: FIRST = .TRUE. 

      !=================================================================
      ! GET_GLOBAL_O3 begins here!
      !=================================================================

      ! Allocate O3 array, if this is the first call
      IF ( FIRST ) THEN
         CALL INIT_GLOBAL_O3
         FIRST = .FALSE.
      ENDIF

      ! File name
      FILENAME = TRIM( DATA_DIR ) // 'sulfate_sim_200210/O3.' //
     &           GET_NAME_EXT()  // '.' // GET_RES_EXT()

      ! Echo some information to the standard output
      WRITE( 6, 110 ) TRIM( FILENAME )
 110  FORMAT( '     - GET_GLOBAL_O3: Reading ', a )

      ! Get the TAU0 value for the start of the given month
      ! Assume "generic" year 1985 (TAU0 = [0, 744, ... 8016])
      XTAU = GET_TAU0( THISMONTH, 1, 1985 )
 
      ! Read O3 data (v/v) from the binary punch file (tracer #32)
      CALL READ_BPCH2( FILENAME, 'IJ-AVG-$', 32,     
     &                 XTAU,      IGLOB,     JGLOB,     
     &                 LLTROP,    ARRAY,     QUIET=.TRUE. )

      ! Assign data from ARRAY to the module variable O3
      CALL TRANSFER_3D( ARRAY, O3 )

      ! Return to calling program
      END SUBROUTINE GET_GLOBAL_O3

!------------------------------------------------------------------------------

      SUBROUTINE INIT_GLOBAL_O3
!
!******************************************************************************
!  Subroutine INIT_GLOBAL_O3 allocates the O3 module array (bmy, 7/13/04)
!
!  NOTES:
!  (1 ) Now references ALLOC_ERR from "error_mod.f" (bmy, 7/13/04)
!******************************************************************************
!
      ! References to F90 modules
      USE ERROR_MOD, ONLY : ALLOC_ERR

#     include "CMN_SIZE"  ! Size parameters

      ! Local variables
      INTEGER             :: AS

      !=================================================================
      ! INIT_GLOBAL_O3 begins here!
      !=================================================================
      ALLOCATE( O3( IIPAR, JJPAR, LLPAR ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'O3' )
      O3 = 0d0

      ! Return to calling program
      END SUBROUTINE INIT_GLOBAL_O3
      
!------------------------------------------------------------------------------

      SUBROUTINE CLEANUP_GLOBAL_O3
!
!******************************************************************************
!  Subroutine CLEANUP_GLOBAL_O3 deallocates the O3 array. (bmy, 7/13/04)
!******************************************************************************
!                               
      !=================================================================
      ! CLEANUP_GLOBAL_O3 begins here!
      !=================================================================
      IF ( ALLOCATED( O3 ) ) DEALLOCATE( O3 ) 
     
      ! Return to calling program
      END SUBROUTINE CLEANUP_GLOBAL_O3

!------------------------------------------------------------------------------

      END MODULE GLOBAL_O3_MOD
