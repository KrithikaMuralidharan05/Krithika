*-----------------------------------------------------------------------------
* <Rating>6361</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE V.CALC.MKT.CHGS.GB
*
* Modification History
*
* 30/12/09 - Panneer - MIA & NYK Cleanup Activity applied to this routine.
* 8057472  - Real time Trade from OFI to T24
* 18/06/25 - Lakshmi Narayanan - E variable has been made null for the OFI Trade version
*          - as it should not raise fatal error for Real time Request.
*==============================================================================
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CURRENCY
    $INSERT I_F.SECURITY.MASTER
    $INSERT I_F.CUSTOMER.SECURITY
    $INSERT I_F.CUSTOMER
    $INSERT I_F.SC.TRANS.TYPE
    $INSERT I_F.STK.EXC.LOCAL
    $INSERT I_F.COMPANY
    $INSERT I_F.SC.STD.SEC.TRADE
    $INSERT I_F.SC.PARAMETER
    $INSERT I_F.SEC.TRADE
    $INSERT I_F.SCB.MKT.CHG.PARAM
    $INSERT I_F.STOCK.EXCHANGE
    $INSERT I_F.SCB.WM.H.LOCAL.PARAM
*
    CUSTOMER.NO = ''
    IF AF = SC.SBS.CU.BRKR.COMM THEN
        CUSTOMER.FLAG = 'C'
        CUSTOMER.NO = R.NEW(SC.SBS.CUSTOMER.NO)<1,AV>
    END
*
    IF AF = SC.SBS.BR.BROKER.COMM THEN
        CUSTOMER.FLAG = 'B'
        CUSTOMER.NO = R.NEW(SC.SBS.BROKER.NO)<1,AV>
    END
    SECURITY.NO = R.NEW(SC.SBS.SECURITY.CODE)
*
    DR.CODE = "" ; CR.CODE = "" ; TRANS.KEY = ""
*
*
    F.LOCAL = ''
    EQTY.FLAG = ''
    CALL OPF("F.STK.EXC.LOCAL",F.LOCAL)
    SECMASTER = ""
    CALL OPF ("F.SECURITY.MASTER",SECMASTER)
    F.CCY = ""
    CALL OPF("F.CURRENCY",F.CCY)
    F.SC.STD.SEC.TRADE = ''
    CALL OPF('F.SC.STD.SEC.TRADE',F.SC.STD.SEC.TRADE)
    
*To fetch the Version list of OFI Trades created
    FN.LOCAL.PARAM = 'F.SCB.WM.H.LOCAL.PARAM'
    F.LOCAL.PARAM = ''
    CALL OPF(FN.LOCAL.PARAM,F.LOCAL.PARAM)
    
    CALL F.READ(FN.LOCAL.PARAM,'SCB.PVB.OFI.PARAM',R.REC.SCB.LOCAL.PARAM,F.LOCAL.PARAM,R.LOCAL.ERR)
    FIELD.NAME = R.REC.SCB.LOCAL.PARAM<SCBWM.PRM.FIELD.NAME>
    LOCATE "VERSION.LIST" IN FIELD.NAME<1,1> SETTING SUB.POS THEN
        Y.VERSION.LIST = R.REC.SCB.LOCAL.PARAM<SCBWM.PRM.FIELD.VALUE><1,SUB.POS>
    END
    Y.VERSION = APPLICATION:PGM.VERSION
    GOSUB OFI.VERSION.CHECK
*OFI

    K.SC.STD.SEC.TRADE = ID.COMPANY
    R.SC.STD.SEC.TRADE = '' ; ETEXT = ''
    CALL F.READ('F.SC.STD.SEC.TRADE',K.SC.STD.SEC.TRADE,R.SC.STD.SEC.TRADE,F.SC.STD.SEC.TRADE,ETEXT)
    IF ETEXT THEN
        E = 'RECORD & NOT FOUND ON FILE &':FM:K.SC.STD.SEC.TRADE:VM:'F.SC.STD.SEC.TRADE'
        GOTO BRK
    END
    F.SC.PARAMETER = ''
    CALL OPF('F.SC.PARAMETER',F.SC.PARAMETER)
*
    READ R.SC.PARAMETER FROM F.SC.PARAMETER, ID.COMPANY ELSE
        E = '& MISSING FROM F.SC.PARAMETER':@FM:ID.COMPANY
        GOTO BRK
    END
*
    CCY.MKT = R.SC.PARAMETER<SC.PARAM.DEFAULT.CCY.MARKET>
*
    K.LOCAL = ID.COMPANY
    R.LOCAL = '' ; ETEXT = ''
    CALL F.READ('F.STK.EXC.LOCAL',K.LOCAL,R.LOCAL,F.LOCAL,ETEXT)
    IF ETEXT THEN
        E = 'RECORD & NOT FOUND ON FILE &':FM:K.LOCAL:VM:'F.STK.EXC.LOCAL'
        GOTO BRK
    END
    SM.REC = '' ; ETEXT = ''
    CALL F.READ('F.SECURITY.MASTER',SECURITY.NO,SM.REC,SECMASTER,ETEXT)
    IF ETEXT THEN
        E = 'RECORD & NOT FOUND ON FILE &':FM:SECURITY.NO:VM:'F.SECURITY.MASTER'
        GOTO BRK
    END
    IF SM.REC<SC.SCM.BOND.OR.SHARE> = "S" THEN EQTY.FLAG = 1
*     ********* CHECK THE BELOW CODE *****
    IF SM.REC<SC.SCM.COMPANY.DOMICILE> = "LI" THEN SM.REC<SC.SCM.COMPANY.DOMICILE> = "CH"
*
    TRADE.CCY = R.NEW(SC.SBS.TRADE.CCY)
    STK.EXC.F=""
*
* READ CUSTOMER RECORD
*
    FN.CUSTOMER = 'F.CUSTOMER' ; FP.CUSTOMER = '' ; R.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,FP.CUSTOMER)
    ETEXT = ''
    CALL F.READ(FN.CUSTOMER,CUSTOMER.NO,R.CUSTOMER,FP.CUSTOMER,ETEXT)
    IF ETEXT THEN
        E = 'RECORD & NOT FOUND ON FILE &':FM:CUSTOMER.NO:VM:FN.CUSTOMER
        GOTO BRK
    END
*
* READ CUSTOMER SECURITY RECORD
*
    FN.CUSTOMER.SECURITY = 'F.CUSTOMER.SECURITY' ; FP.CUSTOMER.SECURITY = ''
    R.CUSTOMER.SECURITY = '' ;ETEXT = ''
    CALL OPF (FN.CUSTOMER.SECURITY,FP.CUSTOMER.SECURITY)
    CALL F.READ(FN.CUSTOMER.SECURITY,CUSTOMER.NO,R.CUSTOMER.SECURITY,FP.CUSTOMER.SECURITY,ETEXT)
    IF ETEXT THEN
        E = 'RECORD & NOT FOUND ON FILE &':FM:CUSTOMER.NO:VM:FN.CUSTOMER.SECURITY
        GOTO BRK
    END
*
    IF CUSTOMER.FLAG = 'C' THEN
        MISC.FEES.CAT = R.SC.STD.SEC.TRADE<SC.SST.CL.MISC.FEES.CAT>
        MISC.FEES.DB.CODE = R.SC.STD.SEC.TRADE<SC.SST.CL.MIS.DB.TRANS.CD>
        MISC.FEES.CR.CODE = R.SC.STD.SEC.TRADE<SC.SST.CL.MIS.CR.TRANS.CD>
    END ELSE
        MISC.FEES.CAT = R.SC.STD.SEC.TRADE<SC.SST.BR.MISC.FEES.CAT>
        MISC.FEES.DB.CODE = R.SC.STD.SEC.TRADE<SC.SST.BR.MIS.DB.TRANS.CD>
        MISC.FEES.CR.CODE = R.SC.STD.SEC.TRADE<SC.SST.BR.MIS.CR.TRANS.CD>
    END
*
    ST.TAX.CAT = R.LOCAL<SE.LCL.STAMP.TAX.CAT>
    ST.TAX.CR.CODE = R.LOCAL<SE.LCL.ST.CR.TRANS.CODE>
    ST.TAX.DB.CODE = R.LOCAL<SE.LCL.ST.DB.TRANS.CODE>
*
    IF CUSTOMER.FLAG = 'C' THEN
        EBV.FEES.CAT = R.LOCAL<SE.LCL.EBV.FEES.CAT>
    END ELSE
* For broker it should be a Diff Category ****** CHECK THE BELOW CODE *****
        EBV.FEES.CAT = '12272'
    END
    EBV.FEES.DB.CODE = R.LOCAL<SE.LCL.EF.DB.TRANS.CODE>
    EBV.FEES.CR.CODE = R.LOCAL<SE.LCL.EF.CR.TRANS.CODE>
*
    CU.FLAG = ''
    BR.FLAG = ''
    CHK.VAL = '0.00' ; CHK.VAL1 = '0.00' ; CHK.VAL2 = '0.00'
    CONSID = '0.00' ;
    R.MCP = '' ;
    UK.LEVY = '0.00' ; CU.STMP.DTY = '0.00' ; CU.FLAG = ''
    CU.TRD.FEE = '0.00' ; CU.CLR.FEE = '0.00' ; NO.OF.CHGS = ''
    STK.CNTRY = '' ; CU.TRAN.LVY = '0.00' ; POS = ''
    TRANS.CODE = '' ; MCP.ERR = '' ; MCP.ID = '' ; I = '' ; ACC.SWP.FLG = ''
    IF CUSTOMER.FLAG = 'C' THEN
        TRA.CODE = R.NEW(SC.SBS.CUST.TRANS.CODE)<1,AV>
        CU.FLAG = 1
    END ELSE
        TRA.CODE = R.NEW(SC.SBS.BR.TRANS.CODE)<1,AV>
        BR.FLAG = 1
    END
* CALL DBR("SC.TRA.CODE":FM:SC.TRN.SECURITY.DR.CODE:FM:".A",TRA.CODE,TRANS.KEY)
* CALL DBR("SC.TRANS.TYPE":FM:SC.TRN.SECURITY.DR.CODE:FM:".A",TRANS.KEY,DR.CODE)
* CALL DBR("SC.TRANS.TYPE":FM:SC.TRN.SECURITY.CR.CODE:FM:".A",TRANS.KEY,CR.CODE)
*********Changes for T24-S*****************
    STR.CODE = '' ; TRANS.KEY = '' ; ETEXT = ''
    FN.SC.TRA.CODE = 'F.SC.TRA.CODE' ; FP.SC.TRA.CODE = ''
    CALL OPF(FN.SC.TRA.CODE,FP.SC.TRA.CODE)
    CALL F.READ(FN.SC.TRA.CODE,TRA.CODE,TRANS.KEY,FP.SC.TRA.CODE,ETEXT)
    IF ETEXT THEN
        E = 'RECORD & NOT FOUND ON FILE &':FM:TRA.CODE:VM:FN.SC.TRA.CODE
        GOTO BRK
    END
    FN.SC.TRANS.TYPE = 'F.SC.TRANS.TYPE' ; FP.SC.TRANS.TYPE = '' ; R.SC.TRANS.TYPE = ''
    ETEXT = '' ; DR.CODE ='' ; CR.CODE = ''
    CALL OPF(FN.SC.TRANS.TYPE,FP.SC.TRANS.TYPE)
    CALL F.READ(FN.SC.TRANS.TYPE,TRANS.KEY,R.SC.TRANS.TYPE,FP.SC.TRANS.TYPE,ETEXT)
    IF ETEXT THEN
        E = 'RECORD & NOT FOUND ON FILE &':FM:TRANS.KEY:VM:FN.SC.TRANS.TYPE
        GOTO BRK
    END
    DR.CODE = R.SC.TRANS.TYPE<SC.TRN.SECURITY.DR.CODE>
    CR.CODE = R.SC.TRANS.TYPE<SC.TRN.SECURITY.CR.CODE>
*********Changes for T24-E*****************
    IF TRA.CODE = DR.CODE THEN
        SEL.FLAG = 1
        TRANS.CODE = 'SAL'
    END ELSE
        SEL.FLAG = 0
        TRANS.CODE = 'PUR'
    END
*
    FN.STK.EXCH = "F.STOCK.EXCHANGE"
    F.STK.EXCH = ''
    CALL OPF(FN.STK.EXCH,F.STK.EXCH)
*
    R.STK = ''
    STK.EXCH = '' ; STK.ERR = '' ; THRESH.AMT = ''
    STK.EXCH = R.NEW(SC.SBS.STOCK.EXCHANGE)
    CALL F.READ(FN.STK.EXCH,STK.EXCH,R.STK,F.STK.EXCH,STK.ERR)
    STK.CNTRY = R.STK<SC.STE.CALC.COUNTRY>
***** NEW CHANGE *****
    IF R.STK<SC.STE.CALC.COUNTRY> = '' THEN STK.CNTRY = R.STK<SC.STE.DOMICILE>
    MCP.ID = STK.CNTRY
*
*----- NEW: Stamp Duty exemption - HK ETF (SEHK 104 + SUB.ASSET.TYPE 118) and LSE IE (LSE 361 + COMPANY.DOMICILE IE)
    Y.SUB.ASSET.TYPE = SM.REC<SC.SCM.SUB.ASSET.TYPE>
    Y.COMPANY.DOMICILE = SM.REC<SC.SCM.COMPANY.DOMICILE>
    Y.STAMP.DUTY.EXEMPT = ''
    CALL SCB.STMP.DTY.EXEMPT(STK.EXCH,Y.SUB.ASSET.TYPE,Y.COMPANY.DOMICILE,Y.STAMP.DUTY.EXEMPT)
*----- END NEW
*
    FN.MCP = "F.SCB.MKT.CHG.PARAM"
    F.MCP = ''
    R.MCP = ''
    MCP.ERR = ''
    CONSID = ''
    CALL OPF(FN.MCP,F.MCP)
*
    CALL F.READ(FN.MCP,MCP.ID,R.MCP,F.MCP,MCP.ERR)
    NO.TRANS.TYPE = DCOUNT(R.NEW(SC.MCP.CHARGE.TYPE),VM)
    LOCATE TRANS.CODE IN R.MCP<SC.MCP.TRANS.TYPE,1> SETTING POS ELSE POS = 0
    NO.OF.CHGS = DCOUNT(R.MCP<SC.MCP.CHARGE.TYPE><1,POS>,SM)

    IF CU.FLAG THEN CONSID = R.NEW(SC.SBS.CU.GROSS.ACCR)<1,AV>
    IF BR.FLAG THEN CONSID = R.NEW(SC.SBS.BR.GROSS.ACCR)<1,AV>
*
*
    IF MESSAGE NE 'VAL' AND COMI NE '' THEN
        IF CUSTOMER.FLAG EQ 'C' THEN
            IF COMI NE R.NEW(SC.SBS.CU.BRKR.COMM)<1,AV> THEN RETURN
        END
        IF CUSTOMER.FLAG EQ 'B' THEN
            IF COMI NE R.NEW(SC.SBS.BR.BROKER.COMM)<1,AV> THEN RETURN
        END
    END
    IF POS AND EQTY.FLAG THEN
        IF STK.CNTRY = "HK" THEN
*  For HK Stock Exchange *
            FOR I = 1 TO NO.OF.CHGS
                BEGIN CASE
                    CASE R.MCP<SC.MCP.CHARGE.TYPE,POS,I> = "STAMP.DUTY"   ;* Stamp Duty calculation *
                        IF Y.STAMP.DUTY.EXEMPT THEN
*   Exception: HK ETF (SEHK 104 + SUB.ASSET.TYPE 118) - Stamp Duty fee not applied
                            CU.STMP.DTY = '0.00'
                            CHK.VAL = CU.STMP.DTY
                        END ELSE
                            IF R.MCP<SC.MCP.PERCENTAGE,POS,I> THEN
                                CU.STMP.DTY = (R.MCP<SC.MCP.PERCENTAGE,POS,I> * CONSID) / 100
                                CHK.VAL = CU.STMP.DTY
                            END ELSE CHK.VAL = CONSID
                            GOSUB CHECK.PARAMS
                            CU.STMP.DTY = CHK.VAL
                        END
*
                    CASE R.MCP<SC.MCP.CHARGE.TYPE,POS,I> = "TRADING.FEES" ;* Trading fee calculation *
                        IF R.MCP<SC.MCP.PERCENTAGE,POS,I> THEN
                            CU.TRD.FEE = (R.MCP<SC.MCP.PERCENTAGE,POS,I> * CONSID) / 100
                            CHK.VAL = CU.TRD.FEE
                        END ELSE CHK.VAL = CONSID
                        GOSUB CHECK.PARAMS
                        CU.TRD.FEE = CHK.VAL
*
                    CASE R.MCP<SC.MCP.CHARGE.TYPE,POS,I> = "TRANSACTION.LEVY"       ;* Transaction levy calculation *
                        IF R.MCP<SC.MCP.PERCENTAGE,POS,I> THEN
                            CU.TRAN.LVY = (R.MCP<SC.MCP.PERCENTAGE,POS,I> * CONSID) / 100
                            CHK.VAL = CU.TRAN.LVY
                        END ELSE CHK.VAL = CONSID
                        GOSUB CHECK.PARAMS
                        CU.TRAN.LVY = CHK.VAL
                END CASE
            NEXT I

            IF CU.FLAG THEN   ;* Customer side *
                IF MESSAGE NE 'VAL' THEN
                    COMI = CU.STMP.DTY + CU.TRAN.LVY + CU.TRD.FEE
                END ELSE R.NEW(SC.SBS.CU.BRKR.COMM)<1,AV> = CU.STMP.DTY + CU.TRAN.LVY + CU.TRD.FEE
            END ELSE
                IF MESSAGE NE 'VAL' THEN
                    COMI = CU.STMP.DTY + CU.TRAN.LVY + CU.TRD.FEE
                END ELSE R.NEW(SC.SBS.BR.BROKER.COMM)<1,AV> = CU.STMP.DTY + CU.TRAN.LVY + CU.TRD.FEE          ;* broker side *
            END
        END
        IF STK.CNTRY = "SG" THEN        ;* Fo Singapore Stock Echange *
            FOR I = 1 TO NO.OF.CHGS
                BEGIN CASE
                    CASE R.MCP<SC.MCP.CHARGE.TYPE,POS,I> = "CLEARING"     ;* Clearing calculation *
                        IF R.MCP<SC.MCP.PERCENTAGE,POS,I> THEN
                            CU.CLR.FEE = (R.MCP<SC.MCP.PERCENTAGE,POS,I> * CONSID) / 100
                            CHK.VAL = CU.CLR.FEE
                        END ELSE CHK.VAL = CONSID
                        GOSUB CHECK.PARAMS
                        CU.CLR.FEE = CHK.VAL
*
                    CASE R.MCP<SC.MCP.CHARGE.TYPE,POS,I> = "TRADING.FEES" ;* Trading Fee calculation *
                        IF R.MCP<SC.MCP.PERCENTAGE,POS,I> THEN
                            CU.TRD.FEE = (R.MCP<SC.MCP.PERCENTAGE,POS,I> * CONSID) / 100
                            CHK.VAL = CU.TRD.FEE
                        END ELSE CHK.VAL = CONSID
                        GOSUB CHECK.PARAMS
                        CU.TRD.FEE = CHK.VAL
                END CASE
            NEXT I
            IF CU.FLAG THEN   ;* Customer updation *
                IF MESSAGE NE 'VAL' THEN
                    COMI = CU.CLR.FEE + CU.TRD.FEE
                END ELSE R.NEW(SC.SBS.CU.BRKR.COMM)<1,AV> = CU.CLR.FEE + CU.TRD.FEE
            END ELSE
                IF MESSAGE NE 'VAL' THEN
                    COMI = CU.CLR.FEE + CU.TRD.FEE
                END ELSE R.NEW(SC.SBS.BR.BROKER.COMM)<1,AV> = CU.CLR.FEE + CU.TRD.FEE     ;* Broker updation *
            END
        END
        IF STK.CNTRY = "CH" THEN        ;* For Swiss stock exchange *
            FOR I = 1 TO NO.OF.CHGS
                BEGIN CASE
                    CASE R.MCP<SC.MCP.CHARGE.TYPE,POS,I> = "TRANSACTION.TAX"        ;* Transaction tax calculation *
                        IF R.MCP<SC.MCP.PERCENTAGE,POS,I> THEN
                            CU.STMP.DTY = (R.MCP<SC.MCP.PERCENTAGE,POS,I> * CONSID) / 100
                            CHK.VAL = CU.STMP.DTY
                        END ELSE CHK.VAL = CONSID
                        GOSUB CHECK.PARAMS
                        CU.STMP.DTY = CHK.VAL
                END CASE
            NEXT I
            IF CU.FLAG THEN   ;* Customer Updation *
                IF MESSAGE NE 'VAL' THEN
                    COMI = CU.STMP.DTY
                END ELSE R.NEW(SC.SBS.CU.BRKR.COMM)<1,AV> = CU.STMP.DTY
            END ELSE
                IF MESSAGE NE 'VAL' THEN
                    COMI = CU.STMP.DTY
                END ELSE R.NEW(SC.SBS.BR.BROKER.COMM)<1,AV> = CU.STMP.DTY       ;* Broker Updation *
            END
        END
        IF STK.CNTRY = "GB" THEN        ;* For UK stock Exchange *
            FOR I = 1 TO NO.OF.CHGS
                BEGIN CASE
                    CASE R.MCP<SC.MCP.CHARGE.TYPE,POS,I> = "STAMP.DUTY"   ;* Stamp Duty Calculation *
                        IF Y.STAMP.DUTY.EXEMPT THEN
*   Exception: LSE IE (LSE 361 + COMPANY.DOMICILE IE) - Stamp Duty fee not applied
                            CU.STMP.DTY = '0.00'
                            CHK.VAL = CU.STMP.DTY
                        END ELSE
                            IF R.MCP<SC.MCP.PERCENTAGE,POS,I> THEN
                                CU.STMP.DTY = (R.MCP<SC.MCP.PERCENTAGE,POS,I> * CONSID) / 100
                                CHK.VAL = CU.STMP.DTY
                            END ELSE CHK.VAL = CONSID
                            GOSUB CHECK.PARAMS
                            CU.STMP.DTY = CHK.VAL
                        END
*
                    CASE R.MCP<SC.MCP.CHARGE.TYPE,POS,I> = "LEVY"         ;* Levy Calculation *
                        IF R.MCP<SC.MCP.PERCENTAGE,POS,I> THEN
                            UK.LEVY = (R.MCP<SC.MCP.PERCENTAGE,POS,I> * CONSID) / 100
                            CHK.VAL = UK.LEVY
                        END ELSE CHK.VAL = CONSID
                        GOSUB CHECK.PARAMS
                        UK.LEVY = CHK.VAL
                END CASE
            NEXT I
            IF CU.FLAG THEN   ;* Customer Side *
                IF MESSAGE NE 'VAL' THEN
                    COMI = CU.STMP.DTY + UK.LEVY
                END ELSE R.NEW(SC.SBS.CU.BRKR.COMM)<1,AV> = CU.STMP.DTY + UK.LEVY
            END ELSE
                IF MESSAGE NE 'VAL' THEN
                    COMI = UK.LEVY + CU.STMP.DTY
                END ELSE R.NEW(SC.SBS.BR.BROKER.COMM)<1,AV> = UK.LEVY + CU.STMP.DTY       ;* Broker Side *
            END
        END
    END
RETURN
*
CHECK.PARAMS:
*
* check for rounding factor *
*      IF CU.FLAG THEN
*         CHK.ACC = R.NEW(SC.SBS.CU.ACCOUNT.CCY)<1,AV>
*      END ELSE
*         CHK.ACC = R.NEW(SC.SBS.BR.ACCOUNT.CCY)<1,AV>
*      END
    IF R.MCP<SC.MCP.ROUND.FACTOR,POS,I> THEN
        IF MOD(CHK.VAL,2) THEN
            CHK.VAL1 = FIELD(CHK.VAL,".",1)
            CHK.VAL2 = FIELD(CHK.VAL,".",2)
            IF CHK.VAL2 > 0 THEN CHK.VAL2 = 1
            CHK.VAL = CHK.VAL1 + CHK.VAL2
        END
    END
* check for minimum *
    IF R.MCP<SC.MCP.CHG.MINIMUM,POS,I> THEN
        IF TRADE.CCY NE R.MCP<SC.MCP.CURRENCY> THEN         ;**** CCY CHANGE
            CHG.AMT = R.MCP<SC.MCP.CHG.MINIMUM,POS,I>
            GOSUB PERF.EXCH
            IF CHK.VAL < Y.AMT1 THEN    ;**** CCY CHANGE
                CHK.VAL = Y.AMT1
            END
        END ELSE
            IF CHK.VAL LT R.MCP<SC.MCP.CHG.MINIMUM,POS,I> THEN
                CHK.VAL = R.MCP<SC.MCP.CHG.MINIMUM,POS,I>
            END
        END
    END
* check for maximum *
    IF R.MCP<SC.MCP.CHG.MAXIMUM,POS,I> THEN
        IF TRADE.CCY NE R.MCP<SC.MCP.CURRENCY> THEN
            CHG.AMT = R.MCP<SC.MCP.CHG.MAXIMUM,POS,I>
            GOSUB PERF.EXCH
            IF CHK.VAL > Y.AMT1 THEN
                CHK.VAL = Y.AMT1
            END
        END ELSE
            IF CHK.VAL > R.MCP<SC.MCP.CHG.MAXIMUM,POS,I> THEN
                CHK.VAL = R.MCP<SC.MCP.CHG.MAXIMUM,POS,I>
            END
        END
    END
* check for any maximum consideration set *
    IF R.MCP<SC.MCP.THRES.AMT,POS,I> THEN
        IF TRADE.CCY NE R.MCP<SC.MCP.CURRENCY> THEN
            CHG.AMT = R.MCP<SC.MCP.THRES.CHG,POS,I>
            CALL EXCHRATE(CCY.MKT,TRADE.CCY,CHK.VAL,R.MCP<SC.MCP.CURRENCY>,THRESH.AMT,'','','','','')
            GOSUB PERF.EXCH
            IF THRESH.AMT > R.MCP<SC.MCP.THRES.AMT,POS,I> THEN
                CHK.VAL = Y.AMT1
            END ELSE
                CHK.VAL = '0.00'
            END
        END ELSE
            IF CONSID > R.MCP<SC.MCP.THRES.AMT,POS,I> THEN
                CHK.VAL = R.MCP<SC.MCP.THRES.CHG,POS,I>
            END ELSE
                CHK.VAL = '0.00'
            END
        END
    END
    IF CHK.VAL THEN
        CALL EB.ROUND.AMOUNT(TRADE.CCY,CHK.VAL,CCY.MKT,'')
    END
RETURN
*
PERF.EXCH:
    Y.AMT1 = ''
    IF CHG.AMT THEN
        CALL EXCHRATE(CCY.MKT,R.MCP<SC.MCP.CURRENCY>,CHG.AMT,TRADE.CCY,Y.AMT1,'','','','','')       ;* To Convert CHK.VAL into Chg param Currency
    END ELSE
        Y.AMT1 = CHK.VAL
    END
RETURN
*
*******************
OFI.VERSION.CHECK:
*******************
*OFI Version list matches with current version.
    Y.VERSION.FLG = ''
    LOCATE Y.VERSION IN Y.VERSION.LIST<1,1,1> SETTING ASST.POS THEN
        Y.VERSION.FLG = '1'
    END
RETURN
*
*----------*
* ERROR    *
*----------*
BRK:
    
    ETEXT = E
    IF Y.VERSION.FLG THEN
        E = ''
    END
*    CALL FATAL.ERROR('V.CALC.MKT.CHGS.GB')
*******************
* END OF CODING.
*******************
END
