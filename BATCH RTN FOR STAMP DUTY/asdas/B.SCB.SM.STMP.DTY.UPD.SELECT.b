*-----------------------------------------------------------------------------
SUBROUTINE B.SCB.SM.STMP.DTY.UPD.SELECT
*-----------------------------------------------------------------------------
* Modification History :
*
* [8220461] - [1st Oct 2026] - [15990649] - Worker for the Stamp Duty exemption extract batch.
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
