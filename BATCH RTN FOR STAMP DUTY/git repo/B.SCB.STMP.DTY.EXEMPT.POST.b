*-----------------------------------------------------------------------------
SUBROUTINE B.SCB.STMP.DTY.EXEMPT.POST
*-----------------------------------------------------------------------------
* Modification History :
*
* [Author] - [Date] - [ADO Ref] - POST for the Stamp Duty exemption extract batch.
*   Collates the run's extract lines (temp records written by the worker),
*   writes the final CSV to AMEX.FILES and clears the temp records.
*
* Called From:  BATCH>SNG/B.SCB.STMP.DTY.EXEMPT
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_BATCH.FILES
    $INSERT I_F.DATES
    $INSERT I_B.SCB.STMP.DTY.EXEMPT.COMMON
*
    GOSUB INIT
    GOSUB PROCESS
RETURN
*=========
INIT:
*=========
    FN.AMEX.FILES = 'AMEX.FILES'
    F.AMEX.FILES = ''
    CALL OPF(FN.AMEX.FILES,F.AMEX.FILES)
    CALL OPF(FN.TEMP.STMP.DTY.EXEMPT,F.TEMP.STMP.DTY.EXEMPT)
*
    Y.LWD = R.DATES(EB.DAT.LAST.WORKING.DAY)
    Y.FINAL.FILE.NAME = BATCH.DETAILS<3,1>
    Y.FINAL.FILE.NAME = FIELD(Y.FINAL.FILE.NAME,'*',2)
    Y.FINAL.FILE.NAME = EREPLACE(Y.FINAL.FILE.NAME,"<LWD>",Y.LWD)
    IF Y.FINAL.FILE.NAME EQ '' THEN Y.FINAL.FILE.NAME = 'STMPDTYEXMPT*':Y.LWD:'.csv'
RETURN
*===========
PROCESS:
*===========
    SEL.CMD = 'SELECT ':FN.TEMP.STMP.DTY.EXEMPT:' WITH @ID LIKE STMPEXMPT:':Y.RUN.CAL.DATE:':...'
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.OF.RECS,SEL.ERR)
*
    R.FINAL = ''
    IF NO.OF.RECS THEN
        Y.DELIM = ','
        Y.UTS.HDR = "Trade ID":Y.DELIM:"Security Code":Y.DELIM:"Customer No":Y.DELIM:"Stock Exchange":Y.DELIM:
        Y.UTS.HDR := "Sub Asset Type":Y.DELIM:"Company Domicile":Y.DELIM:"Trade Date":Y.DELIM:"Value Date":Y.DELIM:
        Y.UTS.HDR := "Customer Txn Code":Y.DELIM:"CU Fees Misc":Y.DELIM:"BR Fees Misc":Y.DELIM:"Exemption Status"
        R.FINAL = Y.UTS.HDR
*
        Y.CNT = 1
        LOOP
        WHILE Y.CNT LE NO.OF.RECS
            Y.TEMP.ID = SEL.LIST<Y.CNT>
            R.TEMP = ''
            CALL F.READ(FN.TEMP.STMP.DTY.EXEMPT,Y.TEMP.ID,R.TEMP,F.TEMP.STMP.DTY.EXEMPT,TEMP.ERR)
            IF R.TEMP THEN
                R.FINAL<-1> = R.TEMP
                CALL F.DELETE(FN.TEMP.STMP.DTY.EXEMPT,Y.TEMP.ID)
            END
            Y.CNT = Y.CNT + 1
        REPEAT
*
        IF R.FINAL THEN
            WRITE R.FINAL TO F.AMEX.FILES,Y.FINAL.FILE.NAME
        END
    END
    CALL OCOMO("B.SCB.STMP.DTY.EXEMPT - EXTRACTED : ":NO.OF.RECS:" -> ":Y.FINAL.FILE.NAME)
RETURN
END