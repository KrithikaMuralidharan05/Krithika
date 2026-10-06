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
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SECURITY.MASTER
    $INSERT I_B.SCB.SM.STMP.DTY.UPD.COMMON

	
    GOSUB SELECT.PARA
RETURN


*===========
SELECT.PARA:
*===========
	
    SEL.LIST = ''

    SEL.CMD = 'SELECT ':FN.SECURITY.MASTER:' WITH STOCK.EXCHANGE EQ "104" AND SUB.ASSET.TYPE EQ "118" AND LWM.GSD NE 0'
	
    CALL EB.READLIST(SEL.CMD,SEL.LIST.1,'',NO.OF.RECS.1,SEL.ERR.1)
	
    SEL.CMD = 'SELECT ':FN.SECURITY.MASTER:' WITH STOCK.EXCHANGE EQ "361" AND COMPANY.DOMICILE EQ "IE" AND LWM.GSD NE 0'
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
