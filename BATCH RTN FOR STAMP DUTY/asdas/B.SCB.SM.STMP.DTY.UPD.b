*-----------------------------------------------------------------------------
SUBROUTINE B.SCB.SM.STMP.DTY.UPD(Y.SECURITY.CODE)
*-----------------------------------------------------------------------------
* Modification History :
*
* [8220461] - [18th Sep 2026] - [15990649] - Worker for the Stamp Duty exemption extract batch.

*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SECURITY.MASTER
    $INSERT I_B.SCB.SM.STMP.DTY.UPD.COMMON

*
    GOSUB PROCESS
RETURN
*===========
PROCESS:
*===========

    IF Y.SECURITY.CODE THEN
        CALL F.READ(FN.SECURITY.MASTER,Y.SECURITY.CODE,R.SECURITY.MASTER,F.SECURITY.MASTER,SM.ERR)
        
        R.SECURITY.MASTER<SC.SCM.LOCAL.REF,Y.LWM.GSD.POS> = 0
        CALL F.LIVE.WRITE(FN.SECURITY.MASTER,Y.SECURITY.CODE,R.SECURITY.MASTER)
		CALL OCOMO("Stamp duty exemption applied - SECURITY.MASTER updated: ":Y.SECURITY.CODE)
    END

RETURN

END
