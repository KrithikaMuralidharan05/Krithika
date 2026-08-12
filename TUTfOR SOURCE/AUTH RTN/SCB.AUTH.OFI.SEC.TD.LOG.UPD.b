SUBROUTINE SCB.AUTH.OFI.SEC.TD.LOG.UPD
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* Modification History :
* Development Ref : ADO-8057472  
* Developed by    : Abhilasha K M
* Date            : 27-Jun-2025
* Description     : Authorisation routine attached in VERSION>SEC.TRADE,FI.STD, SEC.TRADE,FI.BCP.STD, SEC.TRADE,SCB.OMGEO.FI.REV, SEC.TRADE,FI.REV
*                   this routin will update the SCB.OFI.SEC.TRADE.LOG after authorisation as "AUTHORISED" and after reversal "REVERSED". 
*-----------------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SEC.TRADE
    $INSERT I_F.SCB.OFI.SEC.TRADE.LOG


    GOSUB INIT
    GOSUB UPDATE.SCB.OFI.SEC.TRADE.LOG
   
RETURN

INIT:
*****
    FN.OFI.SEC.TD.LOG = 'F.SCB.OFI.SEC.TRADE.LOG'
    F.OFI.SEC.TD.LOG = ''
    CALL OPF(FN.OFI.SEC.TD.LOG,F.OFI.SEC.TD.LOG)
    Y.APP = "SEC.TRADE"
    Y.FLD ="LR.OFI.TRD.REF"
    CALL MULTI.GET.LOC.REF(Y.APP,Y.FLD,Y.FLD.POS)
    Y.OFI.TRD.REF.POS = Y.FLD.POS<1,1>

RETURN


UPDATE.SCB.OFI.SEC.TRADE.LOG:
******************************    
    R.SCB.OFI.SEC.TD.LOG = ""
    OFI.SEC.TD.LOG = ""
    Y.OFI.TRD.REF.NO = R.NEW(SC.SBS.LOCAL.REF)<1,Y.OFI.TRD.REF.POS>
 
    Y.REC.STAT = R.NEW(SC.SBS.RECORD.STATUS)

    IF Y.REC.STAT EQ 'RNAU' THEN
      Y.TRADE.STATUS = 'REVERSED'
    END ELSE
      Y.TRADE.STATUS = 'AUTHORISED'
    END
    
    CALL F.READ(FN.OFI.SEC.TD.LOG,Y.OFI.TRD.REF.NO,R.SCB.OFI.SEC.TD.LOG,F.OFI.SEC.TD.LOG,OFI.SEC.TD.LOG)
    
    IF R.SCB.OFI.SEC.TD.LOG THEN
       R.SCB.OFI.SEC.TD.LOG<SCBOFI.TRADE.STATUS> = Y.TRADE.STATUS
       CALL F.WRITE(FN.OFI.SEC.TD.LOG,Y.OFI.TRD.REF.NO,R.SCB.OFI.SEC.TD.LOG)
    END

RETURN

END
