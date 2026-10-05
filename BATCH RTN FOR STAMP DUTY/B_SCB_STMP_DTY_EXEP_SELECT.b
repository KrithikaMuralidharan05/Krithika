*-----------------------------------------------------------------------------
SUBROUTINE B.SCB.STMP.DTY.EXEP.SELECT
*-----------------------------------------------------------------------------
* Modification History :
*
* [8220461] - [18th Sep 2026] - [15990649] - Worker for the Stamp Duty exemption extract batch.
* <date> - <ADO ref> - <author> - Split into SELECT / LOAD / worker routines so the batch can
*          run multi-threaded (BATCH>MLT). This routine builds the combined id list and hands
*          it off via BATCH.BUILD.LIST. One-time setup moved to B.SCB.STMP.DTY.EXEP.LOAD, and
*          B.SCB.STMP.DTY.EXEP now processes one SECURITY.MASTER id per thread.
*
* Called From:  BATCH>MLT/B.SCB.STMP.DTY.EXEMPT
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SECURITY.MASTER

*
    GOSUB OPEN.FILES
    GOSUB SELECT.PARA
RETURN
*===========
OPEN.FILES:
*===========
* Opened locally rather than via the shared COMMON insert - SELECT runs once, single-threaded,
* before B.SCB.STMP.DTY.EXEP.LOAD sets up the COMMON values the worker threads will use.

    FN.SECURITY.MASTER = 'F.SECURITY.MASTER'
    F.SECURITY.MASTER = ''
    CALL OPF(FN.SECURITY.MASTER,F.SECURITY.MASTER)

RETURN
*===========
SELECT.PARA:
*===========
* Both SELECTs target the same application and their criteria are mutually exclusive on
* STOCK.EXCHANGE (104 vs 361), so the two result lists are simply concatenated with no risk
* of duplicate ids being queued twice.

    SEL.LIST = ''

    SEL.CMD = 'SELECT ':FN.SECURITY.MASTER:' WITH STOCK.EXCHANGE EQ 104 AND SUB.ASSET.TYPE EQ 118 AND LWM.GSD NE 0'
    CALL EB.READLIST(SEL.CMD,SEL.LIST.1,'',NO.OF.RECS.1,SEL.ERR.1)

    SEL.CMD = 'SELECT ':FN.SECURITY.MASTER:' WITH STOCK.EXCHANGE EQ 361 AND COMPANY.DOMICILE EQ IE AND LWM.GSD NE 0'
    CALL EB.READLIST(SEL.CMD,SEL.LIST.2,'',NO.OF.RECS.2,SEL.ERR.2)

    SEL.LIST = SEL.LIST.1
    IF SEL.LIST.2 NE '' THEN
        IF SEL.LIST NE '' THEN
            SEL.LIST := @FM : SEL.LIST.2
        END ELSE
            SEL.LIST = SEL.LIST.2
        END
    END

    CALL OCOMO("SEL.LIST: ":SEL.LIST)

    CALL BATCH.BUILD.LIST('', SEL.LIST)
RETURN

END
