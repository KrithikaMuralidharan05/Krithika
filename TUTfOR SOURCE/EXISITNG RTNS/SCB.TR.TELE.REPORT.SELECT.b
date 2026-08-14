*-----------------------------------------------------------------------------
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE SCB.TR.TELE.REPORT.SELECT
*-------------------------------------------------------------------------------------------------------------------------------
* Description: Multithreaded routine Select routine to extract the securities whose price/static details are not updated by Reuters
*
*
*-------------------------------------------------------------------------------------------------------------------------------
* Author     : Praveen
* Date       : 19 Apr 2017
* Reference  : 16005203
*-----------------------------------------------------------------------------
* Incoming Argument : Nil
* Outgoing Argument : Nil
*-------------------------------------------------------------------------------------------------------------------------------
* Modification History :
*-------------------------------------------------------------------------------------------------------------------------------
* Date            Who         Reference                        Description
*
* 19-Apr-17      Praveen    Telekurs Displacement            Initial Draft for Telekurs Exception report
*
*
* 15/11/2020 - Code conversion for R08 to R20 TAFJ Upgrade.
*			   Cob issue missing routine 1622328
*
* 13-July-2026 - T24 TDS Price Convergence - Tolerance Report Changes - ADO-14318681 - V V Sriniketh
*-----------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_BATCH.FILES
    $INSERT I_F.SCB.WM.H.LOCAL.PARAM
    $INSERT I_SCB.TR.TELE.REPORT.COMMON
*-----------------------------------------------------------------------
*
    GOSUB INITIALIZE
*
RETURN
*-----------------------------------------------------------------------
INITIALIZE:
*----------
*
* TAFJUPG -  USING LOCAL.TABLE AS CORE FIELD IS OBSOLETE - S
*    SEL.CMD = "SELECT ":FN.SECURITY.MASTER:" WITH PRICE.UPDATE.CODE EQ '1' AND SEC.POSN.EXISTS EQ 'Y'"
    SEL.CMD = "SELECT ":FN.SECURITY.MASTER:" WITH PRICE.UPDATE.CODE EQ 1 40 41 AND LWM.SEC.POSN.EX EQ 'Y'"
* TAFJUPG -  USING LOCAL.TABLE AS CORE FIELD IS OBSOLETE - E
    CALL EB.READLIST (SEL.CMD,Y.SM.ID,"",Y.SM.REC.CNT,Y.SM.ERR)
    IF Y.SM.REC.CNT THEN
        CALL BATCH.BUILD.LIST('',Y.SM.ID)
    END
*
RETURN
*-----------------------------------------------------------------------
END
