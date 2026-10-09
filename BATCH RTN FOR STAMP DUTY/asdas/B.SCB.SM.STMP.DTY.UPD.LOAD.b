*-----------------------------------------------------------------------------
SUBROUTINE B.SCB.SM.STMP.DTY.UPD.LOAD
*-----------------------------------------------------------------------------
* Modification History :
*
* <1st Oct 2026> - <15990649> - <Krithika> - New LOAD step for the multi-threaded B.SCB.STMP.DTY.EXEP
*          batch. Runs once, single-threaded, before the worker threads start; resolves the
*          LWM.GSD local ref position and opens F.SECURITY.MASTER into COMMON so every
*          threaded call of B.SCB.SM.STMP.DTY.UPD can reuse them instead of repeating the same
*          CALL OPF / CALL MULTI.GET.LOC.REF per id.
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SECURITY.MASTER
    $INSERT I_B.SCB.SM.STMP.DTY.UPD.COMMON

*
    GOSUB OPEN.FILES
RETURN
*===========
OPEN.FILES:
*===========
    
	FN.SECURITY.MASTER = 'F.SECURITY.MASTER'
    F.SECURITY.MASTER = ''
    CALL OPF(FN.SECURITY.MASTER,F.SECURITY.MASTER)

    Y.LOC.REF.APP = 'SECURITY.MASTER'
    Y.LOC.REF.FLD = 'LWM.GSD'
    Y.LOC.REF.POS = ''
    CALL MULTI.GET.LOC.REF(Y.LOC.REF.APP,Y.LOC.REF.FLD,Y.LOC.REF.POS)
    Y.LWM.GSD.POS = Y.LOC.REF.POS<1,1>

RETURN

END
