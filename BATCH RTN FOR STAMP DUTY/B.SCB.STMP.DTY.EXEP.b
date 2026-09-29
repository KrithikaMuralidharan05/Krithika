*-----------------------------------------------------------------------------
SUBROUTINE B.SCB.STMP.DTY.EXEP
*-----------------------------------------------------------------------------
* Modification History :
*
* [8220461] - [18th Sep 2026] - [15990649] - Worker for the Stamp Duty exemption extract batch.
*
* Called From:  BATCH>SNG/B.SCB.STMP.DTY.EXEMPT
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SECURITY.MASTER
    
*
    GOSUB OPEN.FILES
    GOSUB PROCESS
RETURN
*===========
OPEN.FILES:
*===========

    FN.SECURITY.MASTER = 'F.SECURITY.MASTER'
    F.SECURITY.MASTER = ''
    CALL OPF(FN.SECURITY.MASTER,F.SECURITY.MASTER)
	
	Y.LOC.REF.APP = 'SECURITY.MASTER'
    Y.LOC.REF.FLD = 'LWM.GSD'
    Y.LOC.REF.POS = ''
    CALL MULTI.GET.LOC.REF(Y.LOC.REF.APP,Y.LOC.REF.FLD,Y.LOC.REF.POS)
    Y.LWM.GSD.POS = Y.LOC.REF.POS<1,1>
   
RETURN


*===========
PROCESS:
*===========


	SEL.CMD = 'SELECT ':FN.SECURITY.MASTER:' WITH STOCK.EXCHANGE EQ 104 AND SUB.ASSET.TYPE EQ 118 AND LWM.GSD NE 0'
	GOSUB SELECT.STMT
	

	SEL.CMD = 'SELECT ':FN.SECURITY.MASTER:' WITH STOCK.EXCHANGE EQ 361 AND COMPANY.DOMICILE EQ IE AND LWM.GSD NE 0'
    GOSUB SELECT.STMT
	

	RETURN
*==========
SELECT.STMT:
*===========
 
  CALL EB.READLIST(SEL.CMD,Y.SEL.LIST,'',NO.OF.RECS,SEL.ERR)
	LOOP
        REMOVE Y.SECURITY.CODE FROM Y.SEL.LIST SETTING SEC.POS
		WHILE SEC.POS:Y.SECURITY.CODE
		CALL F.READ(FN.SECURITY.MASTER,Y.SECURITY.CODE,R.SECURITY.MASTER,F.SECURITY.MASTER,SM.ERR)
		Y.LWD.GSD = R.SECURITY.MASTER<SC.SCM.LOCAL.REF,Y.LWM.GSD.POS> 
		R.SECURITY.MASTER<SC.SCM.LOCAL.REF,Y.LWM.GSD.POS> = 0
	    CALL F.LIVE.WRITE(FN.SECURITY.MASTER,Y.SECURITY.CODE,R.SECURITY.MASTER)	
		
	REPEAT
RETURN
 **************************************************************************************