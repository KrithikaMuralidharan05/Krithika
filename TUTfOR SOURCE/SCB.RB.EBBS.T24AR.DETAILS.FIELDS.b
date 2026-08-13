SUBROUTINE SCB.RB.EBBS.T24AR.DETAILS.FIELDS
*-----------------------------------------------------------------------------
*  This table is used to store the eBBS response status
*
* 03-10-2025   ADO-10450834 - Anitha Rani S - New Template to store 'DATE' 'COMPANY.CODE' 'PORTFOLIO.NO', 'ACTION.TYPE' & 'FAILURE.REASON'
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_METHODS.AND.PROPERTIES
    $INSERT I_F.PGM.FILE
*-----------------------------------------------------------------------------
    GOSUB INITIALISE
    GOSUB DEFINE.FIELDS
RETURN
*-----------------------------------------------------------------------------
DEFINE.FIELDS:
*---------
    Z+=1 ; F(Z) = "DATE"                 ; N(Z) = "15"     ; T(Z) = "ANY"    ; T(Z)<3> = 'NOINPUT'
	Z+=1 ; F(Z) = "COMPANY.CODE"         ; N(Z) = "20"     ; T(Z) = "ANY"    ; T(Z)<3> = 'NOINPUT'
	Z+=1 ; F(Z) = "XX<PORTFOLIO.NO"      ; N(Z) = "35"     ; T(Z) = "ANY"    ; T(Z)<3> = 'NOINPUT'
    Z+=1 ; F(Z) = "XX-ACTION.TYPE"       ; N(Z) = "10"     ; T(Z) = "A"    ; T(Z)<3> = 'NOINPUT'
    Z+=1 ; F(Z) = "XX>FAILURE.REASON"    ; N(Z) = "500"     ; T(Z) = "ANY"  ; T(Z)<3> = 'NOINPUT'
    Z+=1 ; F(Z) = "RESERVED.5"           ; N(Z) = "35"     ; T(Z) = ""     ; T(Z)<3> = 'NOINPUT'	
    Z+=1 ; F(Z) = "RESERVED.4"           ; N(Z) = "35"     ; T(Z) = ""     ; T(Z)<3> = 'NOINPUT'	
    Z+=1 ; F(Z) = "RESERVED.3"           ; N(Z) = "35"     ; T(Z) = ""     ; T(Z)<3> = 'NOINPUT'
    Z+=1 ; F(Z) = "RESERVED.2"           ; N(Z) = "35"     ; T(Z) = ""     ; T(Z)<3> = 'NOINPUT'
    Z+=1 ; F(Z) = "RESERVED.1"           ; N(Z) = "35"     ; T(Z) = ""     ; T(Z)<3> = 'NOINPUT'
*-----------------------------------------------------------------------------
    V = Z
RETURN
*-------------------------------------------------------------------------------
INITIALISE:
*---------
    MAT F = "" ; MAT N = "" ; MAT T = ""
    MAT CHECKFILE = "" ; MAT CONCATFILE = ""
    ID.CHECKFILE = "" ; ID.CONCATFILE = ""
    ID.F = "" ; ID.N = "25" ; ID.T = "ANY" 
    Z = 0
RETURN
END