*
SUBROUTINE B.SCB.TRADE.EQD.BUY.FUNDING.SELECT

*-----------------------------------------------------------------------------
* Modification History :
*
* Raghavan K - 28-Jul-2026 - ADORef: 14393564 - EQD - Funding Grouping Logic enhancement to have Authorization Date as Calendar Date
* ----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SEC.TRADE
    $INSERT I_F.SCB.TRADE.UPD.EQD.BUY.FUND
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_B.SCB.TRADE.EQD.BUY.FUNDING.COMMON
    $INSERT I_F.DATES
    $INSERT I_F.BENEFICIARY
    $INSERT I_F.COMPANY
*
    GOSUB OPEN.FILES
*
RETURN
*=========
OPEN.FILES:
*=========
    Y.LWORK.DAY = R.DATES(EB.DAT.LAST.WORKING.DAY)
    Y.COMPANY = ID.COMPANY
    Y.DATE.TODAY = OCONV(DATE(),"D4/")
    Y.CAL.DATE = Y.DATE.TODAY[7,4]:Y.DATE.TODAY[1,2]:Y.DATE.TODAY[4,2]
*
    SEL.CMD = 'SELECT ':FN.SCB.TRADE.UPD.EQD.BUY.FUND:' WITH @ID LIKE EQD...':Y.CAL.DATE:'...'
*
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.OF.RECS,SEL.ERR)
*    
    IF Y.COMPANY[1,2] EQ 'SG' THEN
        GOSUB FILTER.SNG.IDS
    END ELSE
        SEL.LIST = SEL.LIST
    END
	
	CALL OCOMO("SEL.LIST: ":SEL.LIST)
	
    CALL BATCH.BUILD.LIST('', SEL.LIST)
RETURN
*=============
FILTER.SNG.IDS:
*=============
    Y.SEL.LIST.CNT = DCOUNT(SEL.LIST,FM)
   
    Y.COUNTER = 1
    LOOP
    WHILE Y.COUNTER LE Y.SEL.LIST.CNT
   
        Y.SEL.LIST.FIN = FIELD(SEL.LIST,FM,Y.COUNTER)
        Y.SEL.LIST.CCY = FIELD(Y.SEL.LIST.FIN,'.',2)
   
        IF Y.SEL.LIST.CCY EQ 'SGD' THEN
            SEL.LIST.SGD<-1> = Y.SEL.LIST.FIN
        END ELSE
            SEL.LIST.ACU<-1> = Y.SEL.LIST.FIN
        END
	 
        Y.COUNTER = Y.COUNTER + 1
    REPEAT
   
    IF Y.COMPANY EQ 'SG1090400' THEN
        SEL.LIST = ''
        SEL.LIST = SEL.LIST.SGD
    END ELSE
        SEL.LIST = ''
        SEL.LIST = SEL.LIST.ACU
	
    END
   
RETURN

END

