!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !MODULE: diag56_mod.f
!
! !DESCRIPTION: Module DIAG56\_MOD contains arrays and routines for archiving 
!  the ND56 diagnostic -- lightning flash rates. 
!\\
!\\
! !INTERFACE:
!
      MODULE DIAG56_MOD
!
! !USES:
!
      IMPLICIT NONE
      PRIVATE
!
! !PUBLIC MEMBER FUNCTIONS:
!
      PUBLIC :: CLEANUP_DIAG56
      PUBLIC :: INIT_DIAG56
      PUBLIC :: WRITE_DIAG56
      PUBLIC :: ZERO_DIAG56
!
! !PUBLIC DATA MEMBERS:
!
      ! Scalars
      INTEGER,              PUBLIC :: ND56
      INTEGER, PARAMETER,   PUBLIC :: PD56 = 3

      ! Arrays
      REAL*4,  ALLOCATABLE, PUBLIC :: AD56(:,:,:)
!
! !REVISION HISTORY:
!  11 May 2006 - R. Yantosca - Initial version
!  (1 ) Replace TINY(1d0) with 1d-32 to avoid problems on SUN 4100 platform
!        (bmy, 9/5/06)
!  (2 ) Now divide AD56 by the # of A-6 timesteps (ltm, bmy, 3/7/07)
!  15 Sep 2010 - R. Yantosca - Added ProTeX headers
!EOP
!------------------------------------------------------------------------------
!BOC
      CONTAINS
!EOC    
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: zero_diag56
!
! !DESCRIPTION: Subroutine ZERO\_DIAG03 zeroes the ND03 diagnostic arrays. 

!\\
!\\
! !INTERFACE:
!
      SUBROUTINE ZERO_DIAG56
! 
! !REVISION HISTORY: 
!  11 May 2006 - R. Yantosca - Initial version
!  15 Sep 2010 - R. Yantosca - Added ProTeX headers
!EOP
!------------------------------------------------------------------------------
!BOC
      !=================================================================
      ! ZERO_DIAG56 begins here!
      !=================================================================

      ! Exit if ND56 is turned off
      IF ( ND56 == 0 ) RETURN

      ! Zero arrays
      AD56(:,:,:) = 0e0

      END SUBROUTINE ZERO_DIAG56
!EOC    
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: 
!
! !DESCRIPTION: Subroutine WRITE\_DIAG56 writes the ND03 diagnostic arrays 
!  to the binary punch file at the proper time. 
!\\
!\\
! !INTERFACE:
!
      SUBROUTINE WRITE_DIAG56
!
! !USES:
!
      USE BPCH2_MOD,    ONLY : BPCH2, GET_MODELNAME, GET_HALFPOLAR
      USE FILE_MOD,     ONLY : IU_BPCH
      USE GRID_MOD,     ONLY : GET_XOFFSET, GET_YOFFSET
      USE TIME_MOD,     ONLY : GET_CT_A6,   GET_DIAGb,  GET_DIAGe

#     include "CMN_SIZE"     ! Size parameters
#     include "CMN_DIAG"     ! TINDEX
!
! !REMARKS:
!   # : Field    : Description              : Units          : Scale factor
!  --------------------------------------------------------------------------
!  (1 ) LFLASH-$ : Lightning flash rate     : flashes/min/km2 : SCALE_A6
!  (2 ) LFLASH-$ : Intra-cloud flash rate   : flashes/min/km2 : SCALE_A6
!  (3 ) LFLASH-$ : Cloud-ground flash rate  : flashes/min/km2 : SCALE_A6
! 
! !REVISION HISTORY: 
!  11 May 2006 - R. Yantosca - Initial version
!  (1 ) Replace TINY(1d0) with 1d-32 to avoid problems on SUN 4100 platform
!        (bmy, 9/5/06)
!  (2 ) Now scale AD56 by the # of A-6 timesteps (ltm, bmy, 3/7/07)
!  15 Sep 2010 - R. Yantosca - Added ProTeX headers
!EOP
!------------------------------------------------------------------------------
!BOC
!
! !LOCAL VARIABLES:
!
      INTEGER               :: CENTER180, HALFPOLAR,   IFIRST
      INTEGER               :: JFIRST,    LFIRST,      M,      N         
      REAL*4                :: ARRAY(IIPAR,JJPAR,1)
      REAL*4                :: LONRES,    LATRES
      REAL*8                :: DIAGb,     DIAGe,       SCALE
      CHARACTER(LEN=20)     :: MODELNAME 
      CHARACTER(LEN=40)     :: CATEGORY,  RESERVED,    UNIT

      !=================================================================
      ! WRITE_DIAG56 begins here!
      !=================================================================

      ! Exit if ND03 is turned off
      IF ( ND56 == 0 ) RETURN

      ! Initialize
      CENTER180 = 1
      DIAGb     = GET_DIAGb()
      DIAGe     = GET_DIAGe()
      HALFPOLAR = GET_HALFPOLAR()
      IFIRST    = GET_XOFFSET( GLOBAL=.TRUE. ) + 1
      JFIRST    = GET_YOFFSET( GLOBAL=.TRUE. ) + 1
      LATRES    = DJSIZE
      LFIRST    = 1
      LONRES    = DISIZE
      MODELNAME = GET_MODELNAME()
      RESERVED  = ''
      SCALE     = DBLE( GET_CT_A6() ) + 1d-32
        
      !=================================================================
      ! Write data to the bpch file
      !=================================================================

      ! Loop over ND03 diagnostic tracers
      DO M = 1, TMAX(56)

         ! Define quantities
         N            = TINDEX(56,M)
         CATEGORY     = 'LFLASH-$'
         UNIT         = 'flashes/min/km2'
         ARRAY(:,:,1) = AD56(:,:,N) / SCALE

         ! Write data to disk
         CALL BPCH2( IU_BPCH,   MODELNAME, LONRES,   LATRES,
     &               HALFPOLAR, CENTER180, CATEGORY, N,
     &               UNIT,      DIAGb,     DIAGe,    RESERVED,   
     &               IIPAR,     JJPAR,     1,        IFIRST,     
     &               JFIRST,    LFIRST,    ARRAY(:,:,1) )
      ENDDO

      END SUBROUTINE WRITE_DIAG56
!EOC    
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: init_diag56
!
! !DESCRIPTION: Subroutine INIT\_DIAG56 allocates all module arrays, 5/11/06)
!\\
!\\
! !INTERFACE:
!
      SUBROUTINE INIT_DIAG56
!
! !USES:
!
      USE ERROR_MOD,    ONLY : ALLOC_ERR
   
#     include "CMN_SIZE" 
! 
! !REVISION HISTORY: 
!  11 May 2006 - R. Yantosca - Initial version
!  15 Sep 2010 - R. Yantosca - Added ProTeX headers
!EOP
!------------------------------------------------------------------------------
!BOC
!
! !LOCAL VARIABLES:
!
      INTEGER :: AS
      
      !=================================================================
      ! INIT_DIAG03 begins here!
      !=================================================================

      ! Exit if ND56 is turned off
      IF ( ND56 == 0 ) RETURN

      ! 2-D array ("LFLASH-$")
      ALLOCATE( AD56( IIPAR, JJPAR, PD56 ), STAT=AS )
      IF ( AS /= 0 ) CALL ALLOC_ERR( 'AD56' )

      ! Zero arrays
      CALL ZERO_DIAG56

      END SUBROUTINE INIT_DIAG56
!EOC    
!------------------------------------------------------------------------------
!          Harvard University Atmospheric Chemistry Modeling Group            !
!------------------------------------------------------------------------------
!BOP
!
! !IROUTINE: cleanup_diag56 
!
! !DESCRIPTION: Subroutine CLEANUP\_DIAG56 deallocates all module arrays
!\\
!\\
! !INTERFACE:
!
      SUBROUTINE CLEANUP_DIAG56
! 
! !REVISION HISTORY:
!  11 May 2006 - R. Yantosca - Initial version
!  15 Sep 2010 - R. Yantosca - Added ProTeX headers
!EOP
!------------------------------------------------------------------------------
!BOC
      !=================================================================
      ! CLEANUP_DIAG56 begins here!
      !=================================================================
      IF ( ALLOCATED( AD56 ) ) DEALLOCATE( AD56 ) 

      END SUBROUTINE CLEANUP_DIAG56
!EOC
      END MODULE DIAG56_MOD
