*-----------------------------------------------------------------------------
SUBROUTINE B.SCB.STMP.DTY.EXEMPT.SELECT
*-----------------------------------------------------------------------------
* Modification History :
*
* [Author] - [Date] - [ADO Ref] - SELECT for the Stamp Duty exemption extract batch.
*   Selects trades standing on the configured exempt stock exchanges from the
*   current day list (F.SCB.SEC.TRADES.LDAY) and the previous days list
*   (F.SEC.TRADES.MDAY). Exchange values come from the COMMON set in LOAD.
*
* Called From:  BATCH>SNG/B.SCB.STMP.DTY.EXEMPT
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_BATCH.FILES
    $INSERT I_TSA.COMMON
    $INSERT I_B.SCB.STMP.DTY.EXEMPT.COMMON
*
    GOSUB BUILD.EXCH.LIST
    GOSUB SELECT.LDAY
    GOSUB SELECT.MDAY
    CALL BATCH.BUILD.LIST('',Y.SEL.LIST)
RETURN
*=================
BUILD.EXCH.LIST:
*=================
    Y.EXCH.CSV = ''
    IF Y.SEHK.EXCHANGES THEN Y.EXCH.CSV = Y.SEHK.EXCHANGES
    IF Y.LSE.EXCHANGES THEN
        IF Y.EXCH.CSV THEN Y.EXCH.CSV := ',' : Y.LSE.EXCHANGES
        ELSE Y.EXCH.CSV = Y.LSE.EXCHANGES
        END
    END
    IF NOT(Y.EXCH.CSV) THEN
        CALL OCOMO("B.SCB.STMP.DTY.EXEMPT - No exempt stock exchanges configured")
        Y.SEL.LIST = ''
    END
RETURN
*===========
SELECT.LDAY:
*===========
    IF NOT(Y.EXCH.CSV) THEN RETURN
    SEL.CMD = 'SELECT ':FN.SCB.SEC.TRADES.LDAY:' WITH STOCK.EXCHANGE EQ ':Y.EXCH.CSV
    CALL EB.READLIST(SEL.CMD,Y.SEL.LIST1,'',NO.OF.RECS1,SEL.ERR1)
    Y.SEL.LIST = Y.SEL.LIST1
    CALL OCOMO("B.SCB.STMP.DTY.EXEMPT - LDAY SELECTED : ":NO.OF.RECS1)
RETURN
*===========
SELECT.MDAY:
*===========
    IF NOT(Y.EXCH.CSV) THEN RETURN
    SEL.CMD = 'SELECT ':FN.SEC.TRADES.MDAY:' WITH STOCK.EXCHANGE EQ ':Y.EXCH.CSV
    CALL EB.READLIST(SEL.CMD,Y.SEL.LIST2,'',NO.OF.RECS2,SEL.ERR2)
    IF Y.SEL.LIST2 THEN
        Y.SEL.LIST<-1> = Y.SEL.LIST2
        CALL OCOMO("B.SCB.STMP.DTY.EXEMPT - MDAY SELECTED : ":NO.OF.RECS2)
    END
RETURN
END