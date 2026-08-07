*----------------------------------------------------------------------------------
* <Rating>-50</Rating>
*-------------------------------------------------------------------------------
SUBROUTINE SCB.INP.DEF.BR.AMT
*-----------------------------------------------------------------------------
*
* Input routine attached to security transfer versions
* IN - N/A OUT - N/A

*-----------------------------------------------------------------------------
* Modification:-
*---------------
*
* 23/07/2026 - Krithika  15129104 Input routine attached to security transfer versions
*
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SCB.PVB.EQD.GROUP.TODAY
    $INSERT I_F.SECURITY.TRANSFER


*-----------------------------------------------------------------------------

    FN.SCB.PVB.EQD.GROUP.TODAY = 'F.SCB.PVB.EQD.GROUP.TODAY'
    F.SCB.PVB.EQD.GROUP.TODAY = ''
    CALL OPF(FN.SCB.PVB.EQD.GROUP.TODAY,F.SCB.PVB.EQD.GROUP.TODAY)
		
    Y.APPLICATION = 'SECURITY.TRANSFER'
    Y.FLD = 'LWM.ST.GRP.ID'
    Y.LOC.POS = ''
    CALL MULTI.GET.LOC.REF(Y.APPLICATION,Y.FLD,Y.LOC.POS)
    Y.LWM.ST.GRP.ID.POS   = Y.LOC.POS<1,1>
	
	
    Y.GRP.ID = R.NEW(SC.STR.LOCAL.REF)<1,Y.LWM.ST.GRP.ID.POS>
	
	IF Y.GRP.ID[1,3] NE "EQD" THEN
        Y.GRP.ID = Y.GRP.ID[8,99]
    END
	
	CCY = FIELD(Y.GRP.ID,'.',5)
	
    IF Y.GRP.ID THEN
        CALL F.READ(FN.SCB.PVB.EQD.GROUP.TODAY,Y.GRP.ID,R.SCB.PVB.EQD.GROUP.TODAY,F.SCB.PVB.EQD.GROUP.TODAY,ST.GRP.ERR)
        Y.SEC.TRADE.ID = R.SCB.PVB.EQD.GROUP.TODAY<SCB.EQD.ST.SEC.TRADE.ID>
        TOT.GR.AMT = SUM(R.SCB.PVB.EQD.GROUP.TODAY<SCB.EQD.ST.BR.GROSS.AMT.TRD>)
		
    END

    R.NEW(SC.STR.BR.NET.AMT) = TOT.GR.AMT
	R.NEW(SC.STR.CUST.NET.AMT) = TOT.GR.AMT


RETURN
*----------------------------------------------------------------------------
END
