*-----------------------------------------------------------------------------
SUBROUTINE B.SCB.STMP.DTY.EXEMPT(Y.SEC.TRADE.ID)
*-----------------------------------------------------------------------------
* Modification History :
*
* [Author] - [Date] - [ADO Ref] - Worker for the Stamp Duty exemption extract batch.
*   Evaluates a single trade against the shared rule SCB.STMP.DTY.EXEMPT
*   (single source of truth with the online calc V.CALC.MKT.CHGS.GB). For
*   exempt trades writes one CSV line into a per-run temp record (keyed
*   'STMPEXMPT:<run-cal-date>:<trade.id>') which doubles as the processed
*   marker, so re-runs/restarts never duplicate output. The trade itself is
*   NOT updated - extraction/flagging only, consumed by POST.
*
* Called From:  BATCH>SNG/B.SCB.STMP.DTY.EXEMPT
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SEC.TRADE
    $INSERT I_F.SECURITY.MASTER
    $INSERT I_B.SCB.STMP.DTY.EXEMPT.COMMON
*
    GOSUB OPEN.FILES
    GOSUB PROCESS
RETURN
*===========
OPEN.FILES:
*===========
    CALL OPF(FN.SEC.TRADE,F.SEC.TRADE)
    CALL OPF(FN.SECURITY.MASTER,F.SECURITY.MASTER)
    CALL OPF(FN.TEMP.STMP.DTY.EXEMPT,F.TEMP.STMP.DTY.EXEMPT)
RETURN
*===========
PROCESS:
*===========
    Y.TEMP.ID = 'STMPEXMPT:':Y.RUN.CAL.DATE:':':Y.SEC.TRADE.ID
    R.TEMP = ''
    CALL F.READ(FN.TEMP.STMP.DTY.EXEMPT,Y.TEMP.ID,R.TEMP,F.TEMP.STMP.DTY.EXEMPT,TEMP.ERR)
    IF R.TEMP THEN
        CALL OCOMO("B.SCB.STMP.DTY.EXEMPT - Already processed : ":Y.SEC.TRADE.ID)
        RETURN
    END
*
    R.SEC.TRADE = ''
    CALL F.READ(FN.SEC.TRADE,Y.SEC.TRADE.ID,R.SEC.TRADE,F.SEC.TRADE,TRD.ERR)
    IF NOT(R.SEC.TRADE) THEN
        CALL OCOMO("B.SCB.STMP.DTY.EXEMPT - Trade not found : ":Y.SEC.TRADE.ID)
        RETURN
    END
*
    Y.STOCK.EXCHANGE = R.SEC.TRADE<SC.SBS.STOCK.EXCHANGE>
    Y.SECURITY.CODE = R.SEC.TRADE<SC.SBS.SECURITY.CODE>
    Y.SUB.ASSET.TYPE = ''
    Y.COMPANY.DOMICILE = ''
    R.SECURITY.MASTER = ''
    CALL F.READ(FN.SECURITY.MASTER,Y.SECURITY.CODE,R.SECURITY.MASTER,F.SECURITY.MASTER,SM.ERR)
    IF R.SECURITY.MASTER THEN
        Y.SUB.ASSET.TYPE = R.SECURITY.MASTER<SC.SCM.SUB.ASSET.TYPE>
        Y.COMPANY.DOMICILE = R.SECURITY.MASTER<SC.SCM.COMPANY.DOMICILE>
    END ELSE
        CALL OCOMO("B.SCB.STMP.DTY.EXEMPT - Security master not found : ":Y.SECURITY.CODE)
    END
*
    CALL SCB.STMP.DTY.EXEMPT(Y.STOCK.EXCHANGE,Y.SUB.ASSET.TYPE,Y.COMPANY.DOMICILE,Y.EXEMPT.FLAG)
*
    IF Y.EXEMPT.FLAG EQ '1' THEN
        Y.DLM = ','
        Y.CUST.NO = R.SEC.TRADE<SC.SBS.CUSTOMER.NO>
        Y.TRADE.DATE = R.SEC.TRADE<SC.SBS.TRADE.DATE>
        Y.VALUE.DATE = R.SEC.TRADE<SC.SBS.VALUE.DATE>
        Y.TXN.CODE = R.SEC.TRADE<SC.SBS.CUST.TRANS.CODE,1>
        Y.CU.FEES = R.SEC.TRADE<SC.SBS.CU.FEES.MISC>
        Y.BR.FEES = R.SEC.TRADE<SC.SBS.BR.FEES.MISC>
        Y.LINE = Y.SEC.TRADE.ID:Y.DLM:Y.SECURITY.CODE:Y.DLM:Y.CUST.NO:Y.DLM:Y.STOCK.EXCHANGE:Y.DLM:
        Y.LINE := Y.SUB.ASSET.TYPE:Y.DLM:Y.COMPANY.DOMICILE:Y.DLM:Y.TRADE.DATE:Y.DLM:Y.VALUE.DATE:Y.DLM:
        Y.LINE := Y.TXN.CODE:Y.DLM:Y.CU.FEES:Y.DLM:Y.BR.FEES:Y.DLM:'STAMP.DUTY.EXEMPT'
        R.TEMP = Y.LINE
        CALL F.WRITE(FN.TEMP.STMP.DTY.EXEMPT,Y.TEMP.ID,R.TEMP)
        CALL OCOMO("B.SCB.STMP.DTY.EXEMPT - EXEMPT : ":Y.SEC.TRADE.ID)
        Y.EXEMPT.CNT += 1
    END
RETURN
END