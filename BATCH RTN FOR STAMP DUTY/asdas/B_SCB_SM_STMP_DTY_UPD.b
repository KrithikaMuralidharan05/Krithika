*-----------------------------------------------------------------------------
SUBROUTINE B.SCB.SM.STMP.DTY.UPD(Y.SECURITY.CODE)
*-----------------------------------------------------------------------------
* Modification History :
*
* [8220461] - [18th Sep 2026] - [15990649] - Worker for the Stamp Duty exemption extract batch.
* <date> - <ADO ref> - <author> - Converted to a multi-threaded worker: the two SELECTs and the
*          REMOVE...SETTING loop that used to drive this routine have moved to
*          B.SCB.SM.STMP.DTY.UPD.SELECT, and the one-time file open / local ref position lookup
*          has moved to B.SCB.STMP.DTY.EXEP.LOAD (shared via I_B.SCB.STMP.DTY.EXEP.COMMON).
*          This routine now processes exactly the one id it is called with.
* <6th Oct 2026> - <15990649> - <review feedback> - Removed the unused Y.LWD.GSD read, and
*          added an OCOMO audit line after F.LIVE.WRITE to record which SECURITY.MASTER id
*          was updated.
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
