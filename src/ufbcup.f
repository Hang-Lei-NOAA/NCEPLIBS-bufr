      SUBROUTINE UFBCUP(LUBIN,LUBOT)

C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C
C SUBPROGRAM:    UFBCUP
C   PRGMMR: WOOLLEN          ORG: NP20       DATE: 1994-01-06
C
C ABSTRACT: THIS SUBROUTINE MAKES ONE COPY OF EACH UNIQUE ELEMENT IN AN
C   INPUT SUBSET BUFFER INTO THE IDENTICAL MNEMONIC SLOT IN THE OUTPUT
C   SUBSET BUFFER.
C
C PROGRAM HISTORY LOG:
C 1994-01-06  J. WOOLLEN -- ORIGINAL AUTHOR
C 1998-07-08  J. WOOLLEN -- REPLACED CALL TO CRAY LIBRARY ROUTINE
C                           "ABORT" WITH CALL TO NEW INTERNAL BUFRLIB
C                           ROUTINE "BORT"
C 1999-11-18  J. WOOLLEN -- THE NUMBER OF BUFR FILES WHICH CAN BE
C                           OPENED AT ONE TIME INCREASED FROM 10 TO 32
C                           (NECESSARY IN ORDER TO PROCESS MULTIPLE
C                           BUFR FILES UNDER THE MPI)
C 2003-11-04  S. BENDER  -- ADDED REMARKS/BUFRLIB ROUTINE
C                           INTERDEPENDENCIES
C 2003-11-04  D. KEYSER  -- MAXJL (MAXIMUM NUMBER OF JUMP/LINK ENTRIES)
C                           INCREASED FROM 15000 TO 16000 (WAS IN
C                           VERIFICATION VERSION); UNIFIED/PORTABLE FOR
C                           WRF; ADDED DOCUMENTATION (INCLUDING
C                           HISTORY); OUTPUTS MORE COMPLETE DIAGNOSTIC
C                           INFO WHEN ROUTINE TERMINATES ABNORMALLY
C
C USAGE:    CALL UFBCUP (LUBIN, LUBOT)
C   INPUT ARGUMENT LIST:
C     LUBIN    - INTEGER: FORTRAN LOGICAL UNIT NUMBER FOR INPUT BUFR 
C                FILE
C     LUBOT    - INTEGER: FORTRAN LOGICAL UNIT NUMBER FOR OUTPUT BUFR 
C                FILE
C
C REMARKS:
C    THIS ROUTINE CALLS:        BORT     STATUS
C    THIS ROUTINE IS CALLED BY: None
C                               Normally called only by application
C                               programs.
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN 77
C   MACHINE:  PORTABLE TO ALL PLATFORMS
C
C$$$

      INCLUDE 'bufrlib.prm'

      COMMON /TABLES/ MAXTAB,NTAB,TAG(MAXJL),TYP(MAXJL),KNT(MAXJL),
     .                JUMP(MAXJL),LINK(MAXJL),JMPB(MAXJL),
     .                IBT(MAXJL),IRF(MAXJL),ISC(MAXJL),
     .                ITP(MAXJL),VALI(MAXJL),KNTI(MAXJL),
     .                ISEQ(MAXJL,2),JSEQ(MAXJL)

      COMMON /MSGCWD/ NMSG(NFILES),NSUB(NFILES),MSUB(NFILES),
     .                INODE(NFILES),IDATE(NFILES)
      COMMON /USRINT/ NVAL(NFILES),INV(MAXSS,NFILES),VAL(MAXSS,NFILES)

      CHARACTER*10 TAG,TAGI(MAXJL),TAGO
      CHARACTER*3  TYP
      DIMENSION    NINI(MAXJL)
      REAL*8       VAL

C----------------------------------------------------------------------
C----------------------------------------------------------------------

C  CHECK THE FILE STATUSES AND I-NODE
C  ----------------------------------

      CALL STATUS(LUBIN,LUI,IL,IM)
      IF(IL.EQ.0) GOTO 900
      IF(IL.GT.0) GOTO 901
      IF(IM.EQ.0) GOTO 902
      IF(INODE(LUI).NE.INV(1,LUI)) GOTO 903

      CALL STATUS(LUBOT,LUO,IL,IM)
      IF(IL.EQ.0) GOTO 904
      IF(IL.LT.0) GOTO 905
      IF(IM.EQ.0) GOTO 906

C  MAKE A LIST OF UNIQUE TAGS IN INPUT BUFFER
C  ------------------------------------------

      NTAG = 0

      DO 5 NI=1,NVAL(LUI)
      NIN = INV(NI,LUI)
      IF(ITP(NIN).GE.2) THEN
         DO NV=1,NTAG
         IF(TAGI(NV).EQ.TAG(NIN)) GOTO 5
         ENDDO
         NTAG = NTAG+1
         NINI(NTAG) = NI
         TAGI(NTAG) = TAG(NIN)
      ENDIF
5     ENDDO

      IF(NTAG.EQ.0) GOTO 907

C  GIVEN A LIST MAKE ONE COPY OF COMMON ELEMENTS TO OUTPUT BUFFER
C  --------------------------------------------------------------

      DO 10 NV=1,NTAG
      NI = NINI(NV)
      DO NO=1,NVAL(LUO)
      TAGO = TAG(INV(NO,LUO))
      IF(TAGI(NV).EQ.TAGO) THEN
         VAL(NO,LUO) = VAL(NI,LUI)
         GOTO 10
      ENDIF
      ENDDO
10    ENDDO

C  EXITS
C  -----

      RETURN
900   CALL BORT('BUFRLIB: UFBCUP - INPUT BUFR FILE IS CLOSED, IT '//
     . 'MUST BE OPEN FOR INPUT')
901   CALL BORT('BUFRLIB: UFBCUP - INPUT BUFR FILE IS OPEN FOR '//
     . 'OUTPUT, IT MUST BE OPEN FOR INPUT')
902   CALL BORT('BUFRLIB: UFBCUP - A MESSAGE MUST BE OPEN IN INPUT '//
     . 'BUFR FILE, NONE ARE')
903   CALL BORT('BUFRLIB: UFBCUP - LOCATION OF INTERNAL TABLE FOR '//
     . 'INPUT BUFR FILE DOES NOT AGREE WITH EXPECTED LOCATION IN '//
     . 'INTERNAL SUBSET ARRAY')
904   CALL BORT('BUFRLIB: UFBCUP - OUTPUT BUFR FILE IS CLOSED, IT '//
     . 'MUST BE OPEN FOR OUTPUT')
905   CALL BORT('BUFRLIB: UFBCUP - OUTPUT BUFR FILE IS OPEN FOR '//
     . 'INPUT, IT MUST BE OPEN FOR OUTPUT')
906   CALL BORT('BUFRLIB: UFBCUP - A MESSAGE MUST BE OPEN IN OUTPUT '//
     . 'BUFR FILE, NONE ARE')
907   CALL BORT('BUFRLIB: UFBCUP - THERE ARE NO ELEMENTS (TAGS) IN '//
     . 'INPUT SUBSET BUFFER')
      END
