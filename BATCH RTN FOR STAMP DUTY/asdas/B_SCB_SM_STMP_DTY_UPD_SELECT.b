*-----------------------------------------------------------------------------
SUBROUTINE B.SCB.SM.STMP.DTY.UPD.SELECT
*-----------------------------------------------------------------------------
* Modification History :
*
* [8220461] - [1st Oct 2026] - [15990649] - Worker for the Stamp Duty exemption extract batch.
** Split into SELECT / LOAD / worker routines so the batch can
*          run multi-threaded . This routine builds the combined id list and hands
*          it off via BATCH.BUILD.LIST. One-time setup moved to B.SCB.STMP.DTY.EXEP.LOAD, and
*          B.SCB.SM.STMP.DTY.UPD now processes one SECURITY.MASTER id per thread.
* <6th Oct 2026> - <15990649> - <review feedback> - SELECT runs before LOAD in the batch
*          sequence, so FN.SECURITY.MASTER from COMMON was still blank when SEL.CMD was built
*          here - restored a local file open so SELECT.PARA always has a valid file name.
*          Also simplified the list-merge to the reviewed SEL.LIST<-1>= form (with the
*          SEL.LIST initialisation the review screenshot omitted, needed before <-1> append).
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SECURITY.MASTER
    $INSERT I_B.SCB.SM.STMP.DTY.UPD.COMMON

	
    GOSUB OPEN.FILES
    GOSUB SELECT.PARA
RETURN
*===========
OPEN.FILES:
*===========
* SELECT always runs before LOAD in the batch sequence, so FN.SECURITY.MASTER cannot be relied
* on from COMMON here yet - it is opened locally so SEL.CMD below always has a valid file name.

    FN.SECURITY.MASTER = 'F.SECURITY.MASTER'
    F.SECURITY.MASTER = ''
    CALL OPF(FN.SECURITY.MASTER,F.SECURITY.MASTER)

RETURN
*===========
SELECT.PARA:
*===========

    SEL.LIST = ''

    SEL.CMD1 = 'SELECT ':FN.SECURITY.MASTER:' WITH STOCK.EXCHANGE EQ "104" AND SUB.ASSET.TYPE EQ "118" AND LWM.GSD NE 0'
    SEL.CMD2 = 'SELECT ':FN.SECURITY.MASTER:' WITH STOCK.EXCHANGE EQ "361" AND COMPANY.DOMICILE EQ "IE" AND LWM.GSD NE 0'

    CALL EB.READLIST(SEL.CMD1,SEL.LIST1,'',SEL.CNT1,SEL.ERR)
    CALL EB.READLIST(SEL.CMD2,SEL.LIST2,'',SEL.CNT2,SEL.ERR)

    IF SEL.LIST1 THEN SEL.LIST<-1> = SEL.LIST1
    IF SEL.LIST2 THEN SEL.LIST<-1> = SEL.LIST2

    CALL OCOMO("SEL.LIST: ":SEL.LIST)

    CALL BATCH.BUILD.LIST('', SEL.LIST)
RETURN

END
