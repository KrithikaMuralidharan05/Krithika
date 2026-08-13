* @ValidationCode : MjotOTg5NDQ5MzAzOklTTy04ODU5LTE6MTc1NjExODg4NjYxMzo4MjI2NTI5Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIwX1NQMTAuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 25 Aug 2025 16:18:06
* @ValidationInfo : Encoding          : ISO-8859-1
* @ValidationInfo : User Name         : 8226529
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R20_SP10.0
*-----------------------------------------------------------------------------
* <Rating>175</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE E.BLK.NEW.STR.ST.NAU.TXN(RET.ARR)

***********************************************************************************************************************
* Author - Kavitha D
* Date   - 22.09.2025
* Desc  - This is a Nofile enquiry to select INAU transactions from SECURITY.TRANSFER & SEC.TRADE applications.

* Author          : V V Sriniketh
* Reference       : 12946570
* Date            : 29 APR 2026
* Description     : Notional & Strike Price Data Mapping in Sec Trade Enquiry
*                   Mapped Net Amount, Block Id & Block Quantity for Underlying SM for SEC.TRADE txns
*                   Display Block Quantity Values even when Block Id is Null

*** 4th June 2026 - Krithika - 14166306- EQD - ST15 Override Handling (via Bulk Validation & Authorization Functionality)

* Incoming Arguments
* ------------------
*
*  -NA-
* Outgoing Arguments
* ------------------
* RET.ARR
******************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.SECURITY.TRANSFER
    $INSERT I_F.SEC.TRADE
    $INSERT I_F.SECURITY.MASTER
    $INSERT I_F.SECURITY.SUPP
    $INSERT I_F.CUSTOMER


    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB SUB.ASSET
    GOSUB Y.CNTY.CDE
	
	GOSUB SEC.TRD.SEL.LIST
    GOSUB SEC.TRFR.SEL.LIST
	
	CONVERT @VM TO ')' IN RET.ARR
	
	RET.ARR = SORT(RET.ARR)
	CONVERT ')' TO @VM IN RET.ARR
RETURN

INIT:
*---*
    LOC.REF.APP = 'SECURITY.SUPP':@FM:'SEC.TRADE':@FM:'SECURITY.TRANSFER':@FM:'CUSTOMER'		;*TAFJUPG - S/E
	LOC.REF.FLD = 'LED.UNDER.SM':@VM:'LED.STRIKE.PRIC':@VM:'LED.NOTIONAL':@FM:'LED.OPT.SM.ID':@VM:'LED.TICKET.TYPE':@VM:'LWM.SUB.ACCOUNT':@VM:'TRD.MOD.VERIF':@VM:'LED.BLOCK.QTY':@VM:'BLOCK.ID':@VM:'UNBLOCK.ID':@VM:'LED.UNBLOCK.QTY':@FM:'LED.TICKET.TYPE':@VM:'TRD.MOD.VERIF':@VM:'LED.BLOCK.QTY':@VM:'BLOCK.ID':@VM:'UNBLOCK.ID':@VM:'LED.UNBLOCK.QTY':@FM:'PAPERLESS.ADV'


    LOC.REF.POS = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APP,LOC.REF.FLD,LOC.REF.POS)

    UNDER.SM.POS = LOC.REF.POS<1,1>
	STRIKE.POS = LOC.REF.POS<1,2>
    NOTIONAL.POS = LOC.REF.POS<1,3>
    OPT.SM.POS = LOC.REF.POS<2,1>
    TRD.TICKET.TYP.POS = LOC.REF.POS<2,2>
    SUB.ACC.POS = LOC.REF.POS<2,3>
    ST.TRD.POS = LOC.REF.POS<2,4>
	ST.BLK.Q.POS = LOC.REF.POS<2,5>
    ST.BLK.POS  = LOC.REF.POS<2,6>
    ST.UBLK.POS = LOC.REF.POS<2,7>
    ST.UBLK.Q.POS = LOC.REF.POS<2,8>
	TRFR.TICKET.TYP.POS = LOC.REF.POS<3,1>
    STR.TRD.POS = LOC.REF.POS<3,2>
	STR.BLK.Q.POS = LOC.REF.POS<3,3>
    STR.BLK.POS  = LOC.REF.POS<3,4>
    STR.UBLK.POS = LOC.REF.POS<3,5>
    STR.UBLK.Q.POS = LOC.REF.POS<3,6>
    Y.PAPLESS.ADV.POS = LOC.REF.POS<4,1>
    ENQ.NAME = ENQ.SELECTION<1>


RETURN

OPEN.FILES:
*---------*

    FN.SECURITY.TRANSFER.NAU = 'F.SECURITY.TRANSFER$NAU'
    F.SECURITY.TRANSFER.NAU = ''
    CALL OPF(FN.SECURITY.TRANSFER.NAU,F.SECURITY.TRANSFER.NAU)

    FN.SEC.TRADE.NAU = 'F.SEC.TRADE$NAU'
    F.SEC.TRADE.NAU = ''
    CALL OPF(FN.SEC.TRADE.NAU,F.SEC.TRADE.NAU)

    FN.SECURITY.MASTER = 'F.SECURITY.MASTER'
    F.SECURITY.MASTER = ''
    CALL OPF(FN.SECURITY.MASTER,F.SECURITY.MASTER)

    FN.SECURITY.SUPP = 'F.SECURITY.SUPP'
    F.SECURITY.SUPP = ''
    CALL OPF(FN.SECURITY.SUPP,F.SECURITY.SUPP)


    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER  = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)


RETURN

SUB.ASSET:
**********

    Y.SUB.ASSET = ''
    Y.ID = 'SYSTEM'
    CALL AEB.GET.VAL('SYSTEM','AQDQ.SAT',PARAM.VAL.OUT1,PARAM.CNT.OUT1,ERR.PARAM.OUT1)
    Y.SUB.ASSET = PARAM.VAL.OUT1

RETURN


Y.CNTY.CDE:
***********

    Y.CTY.ID1 = ID.COMPANY
    Y.CC1     = Y.CTY.ID1[1,2]

RETURN

SEC.TRFR.SEL.LIST:
*----------------*


    IF ENQ.NAME MATCHES "SCB.BLK.EQD.NAU.NEW.TXNS" THEN
        
        SEL.CMD = "SELECT ":FN.SECURITY.TRANSFER.NAU:" WITH RECORD.STATUS EQ 'INAU' AND CUST.REMARKS LIKE NEW... AND LED.TICKET.TYPE NE '' AND CO.CODE LIKE ":Y.CC1:'... BY SECURITY.NO'
    END
    
    IF ENQ.NAME MATCHES "SCB.BLK.EQD.NAU.FIX.TFR" THEN


        SEL.CMD = "SELECT ":FN.SECURITY.TRANSFER.NAU:" WITH RECORD.STATUS EQ 'INAU' AND CUST.REMARKS UNLIKE NEW... AND LED.TICKET.TYPE NE '' AND CO.CODE LIKE ":Y.CC1:'... BY SECURITY.NO'

    END
    KEY.LIST = '' ; SELECTED = ''
    CALL EB.READLIST(SEL.CMD,KEY.LIST,'',SELECTED,'')
	

    IF KEY.LIST THEN
        GOSUB SEC.TRFR.PROCESS
    END

RETURN

SEC.TRD.SEL.LIST:
*---------------*
    IF ENQ.NAME MATCHES "SCB.BLK.EQD.NAU.NEW.TXNS" THEN
    
        SEL.CMD = "SELECT ":FN.SEC.TRADE.NAU:" WITH RECORD.STATUS EQ 'INAU' AND CU.NARRATIVE LIKE NEW... AND LED.TICKET.TYPE NE '' AND CO.CODE LIKE ":Y.CC1:'... BY SECURITY.CODE'
    END


    IF ENQ.NAME MATCHES "SCB.BLK.EQD.NAU.FIX.TRADE"  THEN
        SEL.CMD = "SELECT ":FN.SEC.TRADE.NAU:" WITH RECORD.STATUS EQ 'INAU' AND CU.NARRATIVE UNLIKE NEW... AND LED.TICKET.TYPE NE '' AND CO.CODE LIKE ":Y.CC1:'... BY SECURITY.CODE'
	END
	
    IF ENQ.NAME MATCHES "SCB.BLK.EQD.NAU.FIX.TRADE.ST15" THEN
        SEL.CMD = "SELECT ":FN.SEC.TRADE.NAU:" WITH RECORD.STATUS EQ 'INAU' OR WITH RECORD.STATUS EQ 'INAO' AND CU.NARRATIVE UNLIKE NEW... AND LED.TICKET.TYPE NE '' AND CO.CODE LIKE ":Y.CC1:'... BY SECURITY.CODE'
	END
	
    SC.TRD.LIST = '' SELECTED = ''
	
    CALL EB.READLIST(SEL.CMD,SC.TRD.LIST,'',SELECTED,'')
   	
    IF SC.TRD.LIST THEN
        GOSUB SEC.TRD.PROCESS
    END

SEC.TRFR.PROCESS:
*---------------*

    Y.APPLICATION = 'SECURITY.TRANSFER'
    Y.SUB.ASST.TYP = ''

    LOOP
        REMOVE Y.SC.TFR.ID FROM KEY.LIST SETTING SC.TFR.POS
    WHILE Y.SC.TFR.ID : SC.TFR.POS

        R.SECURITY.TRANSFER.NAU = ''
        CALL F.READ(FN.SECURITY.TRANSFER.NAU,Y.SC.TFR.ID,R.SECURITY.TRANSFER.NAU,F.SECURITY.TRANSFER.NAU,ERR.SC.TFR)
        TRD.MOD.VER = R.SECURITY.TRANSFER.NAU<SC.STR.LOCAL.REF,STR.TRD.POS>

        IF TRD.MOD.VER NE 'MODIFIED' THEN

            Y.SM.ID = R.SECURITY.TRANSFER.NAU<SC.STR.SECURITY.NO>
            GOSUB SEC.MASTER.BLK

            Y.CUS.ID = R.SECURITY.TRANSFER.NAU<SC.STR.CUSTOMER.NO>
            GOSUB GET.PAPERLESS.ADV.DETS

            Y.SUB.ASST.TYP = R.SECURITY.MASTER<SC.SCM.SUB.ASSET.TYPE>

            IF Y.SUB.ASSET EQ Y.SUB.ASST.TYP THEN

                Y.TYP.SM = 'OPTION SM'
                Y.OPT.SEC.NO = R.SECURITY.TRANSFER.NAU<SC.STR.SECURITY.NO>
                GOSUB SEC.MASTER.BLK
                Y.OPT.SEC.NAME = R.SECURITY.MASTER<SC.SCM.SHORT.NAME>
                R.SECURITY.SUPP = ''
                CALL F.READ(FN.SECURITY.SUPP,Y.OPT.SEC.NO,R.SECURITY.SUPP,F.SECURITY.SUPP,ERR.SUPP)
                Y.ULY.SEC.NO = R.SECURITY.SUPP<SC.SSP.LOCAL.REF,UNDER.SM.POS>
                Y.STRIKE.PRICE = R.SECURITY.SUPP<SC.SSP.LOCAL.REF,STRIKE.POS>
                R.SECURITY.MASTER.ULY = ''
                CALL F.READ(FN.SECURITY.MASTER,Y.ULY.SEC.NO,R.SECURITY.MASTER.ULY,F.SECURITY.MASTER,ERR.SM)
                Y.ULY.SEC.NAME = R.SECURITY.MASTER.ULY<SC.SCM.SHORT.NAME>
                Y.DEPO = R.SECURITY.TRANSFER.NAU<SC.STR.DEPOSITORY>
                Y.SEC.CURR = R.SECURITY.TRANSFER.NAU<SC.STR.SECURITY.CCY>
                Y.TXN.TYP = R.SECURITY.TRANSFER.NAU<SC.STR.TRANSACTION.TYPE>
                Y.NO.NOM = R.SECURITY.TRANSFER.NAU<SC.STR.NO.NOMINAL>
                Y.TICKET.TYPE = R.SECURITY.TRANSFER.NAU<SC.STR.LOCAL.REF,TRFR.TICKET.TYP.POS>
                Y.REC.STAT = R.SECURITY.TRANSFER.NAU<SC.STR.RECORD.STATUS>
                Y.DATIME = R.SECURITY.TRANSFER.NAU<SC.STR.DATE.TIME>
				Y.CU.REMARK = R.SECURITY.TRANSFER.NAU<SC.STR.CUST.REMARKS,1>
                
                Y.BR.G.AMT = ''
                Y.BR.NET.AMT = R.SECURITY.TRANSFER.NAU<SC.STR.BR.NET.AMT>
                
                Y.BLK.ID = R.SECURITY.TRANSFER.NAU<SC.STR.LOCAL.REF,STR.BLK.POS,1>
                Y.BLK.QTY = R.SECURITY.TRANSFER.NAU<SC.STR.LOCAL.REF,STR.BLK.Q.POS,1>
                 
                IF Y.BLK.ID EQ '' AND Y.BLK.QTY EQ '' THEN
                    Y.BLK.ID = R.SECURITY.TRANSFER.NAU<SC.STR.LOCAL.REF,STR.UBLK.POS,1>
                    Y.BLK.QTY = R.SECURITY.TRANSFER.NAU<SC.STR.LOCAL.REF,STR.UBLK.Q.POS,1>
                END
                IF Y.CU.REMARK[1,3] MATCHES 'NEW' THEN
                    Y.NOTIONAL = R.SECURITY.SUPP<SC.SSP.LOCAL.REF,NOTIONAL.POS>
                END ELSE
                    Y.NOTIONAL = ''
                END
                Y.TRADE.DATE = R.SECURITY.TRANSFER.NAU<SC.STR.TRADE.DATE>
                Y.VALUE.DATE = R.SECURITY.TRANSFER.NAU<SC.STR.VALUE.DATE>
                Y.SEC.ACC = R.SECURITY.TRANSFER.NAU<SC.STR.SECURITY.ACC>
                Y.OVERRIDE = R.SECURITY.TRANSFER.NAU<SC.STR.OVERRIDE>
                Y.INPUTTER = R.SECURITY.TRANSFER.NAU<SC.STR.INPUTTER,1>
                Y.AUTHORISER = R.SECURITY.TRANSFER.NAU<SC.STR.AUTHORISER>
                IF Y.OVERRIDE THEN
                    GOSUB PROCESS.OVERRIDES
                END

                Y.APPL.ID = Y.SC.TFR.ID
                GOSUB BUILD.RETURN.ARRAY

            END
        END

    REPEAT
RETURN

SEC.MASTER.BLK:
***************

    R.SECURITY.MASTER = ''

    CALL F.READ(FN.SECURITY.MASTER,Y.SM.ID,R.SECURITY.MASTER,F.SECURITY.MASTER,ERR.SM)

RETURN


SEC.TRD.PROCESS:
*--------------*

    Y.APPLICATION = 'SEC.TRADE'
    Y.SUB.ASST.TYP = ''
    Y.SM.ID = ''
	

    LOOP
        REMOVE Y.SC.TRD.ID FROM SC.TRD.LIST SETTING SC.TRD.POS
    WHILE Y.SC.TRD.ID : SC.TRD.POS
        R.SEC.TRADE.NAU = ''
        Y.TRADE.DATE = '' ; Y.VALUE.DATE = ''; Y.SEC.ACC = '' ; Y.GROSS.AMT = '' ; Y.NET.AMT = '' ; Y.DEPO = ''
        Y.LWM.SUB.ACC = '' ; Y.BRK.NO = '' ; Y.OVERRIDES = '' ; Y.INPUTTER = '' ; Y.AUTHORISER = ''
	    Y.BR.G.AMT = '' ; Y.BR.NET.AMT = '' ; Y.NOTIONAL = '' ; Y.BLK.ID = '' ;Y.BLK.QTY = '' ;Y.STRIKE.PRICE = ''
        CALL F.READ(FN.SEC.TRADE.NAU,Y.SC.TRD.ID,R.SEC.TRADE.NAU,F.SEC.TRADE.NAU,ERR.SC.TRD)
        ST.TRD.MOD.VER = R.SEC.TRADE.NAU<SC.SBS.LOCAL.REF,ST.TRD.POS>

        IF ST.TRD.MOD.VER NE 'MODIFIED' THEN

            Y.SM.ID = R.SEC.TRADE.NAU<SC.SBS.SECURITY.CODE>
            GOSUB SEC.MASTER.BLK
            Y.CUS.ID = R.SEC.TRADE.NAU<SC.SBS.CUSTOMER.NO>
            GOSUB GET.PAPERLESS.ADV.DETS
            Y.SUB.ASST.TYP = R.SECURITY.MASTER<SC.SCM.SUB.ASSET.TYPE>
            IF Y.SUB.ASSET EQ Y.SUB.ASST.TYP THEN

                R.SECURITY.MASTER.ULY = ''
				Y.ST.FLAG =''
                Y.TYP.SM = 'OPTION SM'
                Y.OPT.SEC.NO = R.SEC.TRADE.NAU<SC.SBS.SECURITY.CODE>
                Y.OPT.SEC.NAME = R.SECURITY.MASTER<SC.SCM.SHORT.NAME>
                GOSUB OPT.UNDERLYING.SM.DATA ; *
                Y.ULY.SEC.NO = R.SECURITY.SUPP<SC.SSP.LOCAL.REF,UNDER.SM.POS>
****** Read the SECURITY.MASTER record using ULY.SEC.NO id for extracting the SHORT.NAME*******

                CALL F.READ(FN.SECURITY.MASTER,Y.ULY.SEC.NO,R.SECURITY.MASTER.ULY,F.SECURITY.MASTER,ERR.SM)
                Y.ULY.SEC.NAME = R.SECURITY.MASTER.ULY<SC.SCM.SHORT.NAME>

                Y.SEC.CURR = R.SEC.TRADE.NAU<SC.SBS.SECURITY.CURRENCY>
                Y.TXN.TYP = R.SEC.TRADE.NAU<SC.SBS.CUST.TRANS.CODE>
                Y.NO.NOM = R.SEC.TRADE.NAU<SC.SBS.CUST.NO.NOM>
                Y.TICKET.TYPE = R.SEC.TRADE.NAU<SC.SBS.LOCAL.REF,TRD.TICKET.TYP.POS>
                Y.REC.STAT = R.SEC.TRADE.NAU<SC.SBS.RECORD.STATUS>
                Y.DATIME = R.SEC.TRADE.NAU<SC.SBS.DATE.TIME>
                Y.TRADE.DATE = R.SEC.TRADE.NAU<SC.SBS.TRADE.DATE>
                Y.VALUE.DATE = R.SEC.TRADE.NAU<SC.SBS.VALUE.DATE>
                Y.SEC.ACC = R.SEC.TRADE.NAU<SC.SBS.CUST.SEC.ACC>
                Y.GROSS.AMT = R.SEC.TRADE.NAU<SC.SBS.CU.GROSS.AM.TRD>
                Y.NET.AMT = R.SEC.TRADE.NAU<SC.SBS.CU.NET.AM.TRD>
                Y.DEPO = R.SEC.TRADE.NAU<SC.SBS.DEPOSITORY>
                Y.LWM.SUB.ACC = R.SEC.TRADE.NAU<SC.SBS.LOCAL.REF,SUB.ACC.POS>
                Y.BRK.NO = R.SEC.TRADE.NAU<SC.SBS.BR.ACC.NO>

                Y.BR.G.AMT = R.SEC.TRADE.NAU<SC.SBS.BR.GROSS.AM.TRD>
				
                Y.OVERRIDE = R.SEC.TRADE.NAU<SC.SBS.OVERRIDE>
                Y.INPUTTER = R.SEC.TRADE.NAU<SC.SBS.INPUTTER,1>
                Y.AUTHORISER = R.SEC.TRADE.NAU<SC.SBS.AUTHORISER>

                IF Y.OVERRIDE THEN
                    GOSUB PROCESS.OVERRIDES
                END
				
				
                Y.APPL.ID = Y.SC.TRD.ID     ;* Murex_OTC_FIX_S
                      FINDSTR 'ST15' IN Y.OVERRIDES SETTING S.POS THEN
                        Y.ST.FLAG =1
                      END
                      IF Y.ST.FLAG AND ENQ.NAME MATCHES "SCB.BLK.EQD.NAU.FIX.TRADE.ST15" THEN
                        GOSUB BUILD.RETURN.ARRAY    ;* Murex_OTC_FIX_E	
                      END 
                      IF NOT(Y.ST.FLAG) AND ENQ.NAME MATCHES "SCB.BLK.EQD.NAU.FIX.TRADE" THEN
                        GOSUB BUILD.RETURN.ARRAY    ;* Murex_OTC_FIX_E	
                      END               
                				
            END ELSE

******* IF UNDERLYING.TXN then OPTION.SM value should extract from LED.OPT.SM.ID(LOCAL.REF) of SEC.TRADE appln******

                R.SECURITY.MASTER.OPT = ''

                Y.ULY.SEC.NO = R.SEC.TRADE.NAU<SC.SBS.SECURITY.CODE>
                Y.ULY.SEC.NAME = R.SECURITY.MASTER<SC.SCM.SHORT.NAME>

                Y.OPT.SEC.NO = R.SEC.TRADE.NAU<SC.SBS.LOCAL.REF,OPT.SM.POS>
                GOSUB OPT.UNDERLYING.SM.DATA ; *
******* Read the SECURITY.MASTER record using OPT.SEC.NO id for extracting the SHORT.NAME******

                CALL F.READ(FN.SECURITY.MASTER,Y.OPT.SEC.NO,R.SECURITY.MASTER.OPT,F.SECURITY.MASTER,ERR.SM)

                Y.ULY.SAT = R.SECURITY.MASTER.OPT<SC.SCM.SUB.ASSET.TYPE>
                ULY.ASST.POS = ''
				Y.ST.FLAG =''
                IF Y.ULY.SAT EQ Y.SUB.ASSET THEN      ;* Murex_OTC_FIX_E
                    Y.OPT.SEC.NAME = R.SECURITY.MASTER.OPT<SC.SCM.SHORT.NAME>
                    Y.SEC.CURR = R.SEC.TRADE.NAU<SC.SBS.SECURITY.CURRENCY>

                    IF R.SECURITY.MASTER NE '' THEN
                        Y.TYP.SM = 'UNDERLYING SM'
                    END ELSE
                        Y.TYP.SM = ''
                    END
                    Y.TXN.TYP = R.SEC.TRADE.NAU<SC.SBS.CUST.TRANS.CODE>
                    Y.NO.NOM = R.SEC.TRADE.NAU<SC.SBS.CUST.NO.NOM>
                    Y.TICKET.TYPE = R.SEC.TRADE.NAU<SC.SBS.LOCAL.REF,TRD.TICKET.TYP.POS>
                    Y.REC.STAT = R.SEC.TRADE.NAU<SC.SBS.RECORD.STATUS>
                    Y.DATIME = R.SEC.TRADE.NAU<SC.SBS.DATE.TIME>
                    Y.TRADE.DATE = R.SEC.TRADE.NAU<SC.SBS.TRADE.DATE>
                    Y.VALUE.DATE = R.SEC.TRADE.NAU<SC.SBS.VALUE.DATE>
                    Y.SEC.ACC = R.SEC.TRADE.NAU<SC.SBS.CUST.SEC.ACC>
                    Y.GROSS.AMT = R.SEC.TRADE.NAU<SC.SBS.CU.GROSS.AM.TRD>
                    Y.NET.AMT = R.SEC.TRADE.NAU<SC.SBS.CU.NET.AM.TRD>
                    Y.DEPO = R.SEC.TRADE.NAU<SC.SBS.DEPOSITORY>
                    Y.LWM.SUB.ACC = R.SEC.TRADE.NAU<SC.SBS.LOCAL.REF,SUB.ACC.POS>
                    Y.BRK.NO = R.SEC.TRADE.NAU<SC.SBS.BR.ACC.NO>
                    Y.BR.G.AMT = R.SEC.TRADE.NAU<SC.SBS.BR.GROSS.AM.TRD>
					
                    Y.OVERRIDE = R.SEC.TRADE.NAU<SC.SBS.OVERRIDE>
                    Y.INPUTTER = R.SEC.TRADE.NAU<SC.SBS.INPUTTER,1>
                    Y.AUTHORISER = R.SEC.TRADE.NAU<SC.SBS.AUTHORISER>
                    IF Y.OVERRIDE THEN
                        GOSUB PROCESS.OVERRIDES
                    END
					
                    Y.APPL.ID = Y.SC.TRD.ID     ;* Murex_OTC_FIX_S
                    FINDSTR 'ST15' IN Y.OVERRIDES SETTING S.POS THEN
                        Y.ST.FLAG =1
                      END
                      IF Y.ST.FLAG AND ENQ.NAME MATCHES "SCB.BLK.EQD.NAU.FIX.TRADE.ST15" THEN
                        GOSUB BUILD.RETURN.ARRAY    ;* Murex_OTC_FIX_E	
                      END 
                      IF NOT(Y.ST.FLAG) AND ENQ.NAME MATCHES "SCB.BLK.EQD.NAU.FIX.TRADE" THEN
                        GOSUB BUILD.RETURN.ARRAY    ;* Murex_OTC_FIX_E	
                      END
					
                END
        END         ;* Murex_OTC_FIX_S/E
			
	END	

REPEAT
	
RETURN
*---------------------*
*** <region name= OPT.UNDERLYING.SM.DATA>
OPT.UNDERLYING.SM.DATA:
*** <desc> </desc>

    R.SECURITY.SUPP = ''
    CALL F.READ(FN.SECURITY.SUPP,Y.OPT.SEC.NO,R.SECURITY.SUPP,F.SECURITY.SUPP,ERR.SUPP)
    Y.STRIKE.PRICE = R.SECURITY.SUPP<SC.SSP.LOCAL.REF,STRIKE.POS>
    Y.CU.NARR = R.SEC.TRADE.NAU<SC.SBS.CU.NARRATIVE,1>
    IF Y.CU.NARR[1,3] MATCHES 'NEW' THEN
        Y.NOTIONAL = R.SECURITY.SUPP<SC.SSP.LOCAL.REF,NOTIONAL.POS>
    END ELSE
        Y.NOTIONAL = ''
    END
    Y.BR.NET.AMT = R.SEC.TRADE.NAU<SC.SBS.BR.NET.AM.TRD>
            
    Y.BLK.ID = R.SEC.TRADE.NAU<SC.SBS.LOCAL.REF,ST.BLK.POS>
    Y.BLK.QTY = R.SEC.TRADE.NAU<SC.SBS.LOCAL.REF,ST.BLK.Q.POS>
                 
    IF Y.BLK.ID EQ '' AND Y.BLK.QTY EQ '' THEN
        Y.BLK.ID = R.SEC.TRADE.NAU<SC.SBS.LOCAL.REF,ST.UBLK.POS>
        Y.BLK.QTY = R.SEC.TRADE.NAU<SC.SBS.LOCAL.REF,ST.UBLK.Q.POS>
    END
            
RETURN
*---------------------*

GET.PAPERLESS.ADV.DETS:
*---------------------*

    R.CUSTOMER   = ''
    CUSTOMER.ERR = ''
    CALL F.READ(FN.CUSTOMER,Y.CUS.ID,R.CUSTOMER,F.CUSTOMER,CUSTOMER.ERR)
    IF R.CUSTOMER THEN
        Y.PAPERLESS.ADV = R.CUSTOMER<EB.CUS.LOCAL.REF,Y.PAPLESS.ADV.POS>
    END

RETURN

BUILD.RETURN.ARRAY:
*-----------------*
    IF RET.ARR = '' THEN
		RET.ARR = Y.OPT.SEC.NO:"*":Y.APPL.ID:"*":Y.TYP.SM:"*":Y.APPLICATION:"*":Y.OPT.SEC.NAME:"*":Y.ULY.SEC.NO:"*":Y.ULY.SEC.NAME:"*":Y.SEC.CURR:"*":Y.TXN.TYP:"*":Y.NO.NOM:"*":Y.TICKET.TYPE:"*":Y.REC.STAT:"*":Y.DATIME:"*":Y.PAPERLESS.ADV:"*":Y.TRADE.DATE:"*":Y.VALUE.DATE:"*":Y.SEC.ACC:"*":Y.GROSS.AMT:"*":Y.NET.AMT:"*":Y.DEPO:"*":Y.LWM.SUB.ACC:"*":Y.BRK.NO:"*":Y.BR.G.AMT:"*":Y.BR.NET.AMT:"*":Y.NOTIONAL:"*":Y.BLK.ID:"*":Y.BLK.QTY:"*":Y.STRIKE.PRICE:"*":Y.OVERRIDES:"*":Y.INPUTTER:"*":Y.AUTHORISER
    END ELSE
        RET.ARR := @FM:Y.OPT.SEC.NO:"*":Y.APPL.ID:"*":Y.TYP.SM:"*":Y.APPLICATION:"*":Y.OPT.SEC.NAME:"*":Y.ULY.SEC.NO:"*":Y.ULY.SEC.NAME:"*":Y.SEC.CURR:"*":Y.TXN.TYP:"*":Y.NO.NOM:"*":Y.TICKET.TYPE:"*":Y.REC.STAT:"*":Y.DATIME:"*":Y.PAPERLESS.ADV:"*":Y.TRADE.DATE:"*":Y.VALUE.DATE:"*":Y.SEC.ACC:"*":Y.GROSS.AMT:"*":Y.NET.AMT:"*":Y.DEPO:"*":Y.LWM.SUB.ACC:"*":Y.BRK.NO:"*":Y.BR.G.AMT:"*":Y.BR.NET.AMT:"*":Y.NOTIONAL:"*":Y.BLK.ID:"*":Y.BLK.QTY:"*":Y.STRIKE.PRICE:"*":Y.OVERRIDES:"*":Y.INPUTTER:"*":Y.AUTHORISER
    END
      Y.TRADE.DATE = '' ; Y.VALUE.DATE = ''; Y.SEC.ACC = '' ; Y.GROSS.AMT = '' ; Y.NET.AMT = '' ; Y.DEPO = ''
        Y.LWM.SUB.ACC = '' ; Y.BRK.NO = '' ; Y.OVERRIDES = '' ; Y.INPUTTER = '' ; Y.AUTHORISER = ''
	    Y.BR.G.AMT = '' ; Y.BR.NET.AMT = '' ; Y.NOTIONAL = '' ; Y.BLK.ID = '' ;Y.BLK.QTY = '' ;Y.STRIKE.PRICE = ''
       


RETURN

*-----------------
PROCESS.OVERRIDES:
*-----------------

    Y.OVD.CNT = DCOUNT(Y.OVERRIDE,@VM)
*
    FOR I= 1 TO Y.OVD.CNT
   
        Y.OVERRIDE.LINE = ''; Y.OVERRIDE.MSG = '' ; Y.START.POS = ''
        Y.OVERRIDE.LINE = Y.OVERRIDE<1,I>
        Y.START.POS     = INDEX(Y.OVERRIDE.LINE,'}',1)
        Y.OVERRIDE.MSG  = Y.OVERRIDE.LINE[Y.START.POS+1,999]
        CHANGE '~' TO @FM IN Y.OVERRIDE.MSG
        CHANGE '{' TO @FM IN Y.OVERRIDE.MSG
        CHANGE '}' TO @VM IN Y.OVERRIDE.MSG
        CHANGE @SM TO '#' IN Y.OVERRIDE.MSG
        CHANGE '*' TO '#' IN Y.OVERRIDE.MSG
        CALL TXT(Y.OVERRIDE.MSG)

        BEGIN CASE
            CASE Y.OVERRIDES
                Y.OVERRIDES:=@VM:Y.OVERRIDE.MSG
            CASE NOT(Y.OVERRIDES)
                Y.OVERRIDES =Y.OVERRIDE.MSG
        END CASE

    NEXT I
RETURN

END
