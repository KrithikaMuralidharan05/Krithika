*-----------------------------------------------------------------------------
SUBROUTINE SCB.STMP.DTY.EXEMPT(Y.STOCK.EXCHANGE, Y.SUB.ASSET.TYPE, Y.COMPANY.DOMICILE, Y.EXEMPT.FLAG)
*-----------------------------------------------------------------------------
* Modification History :
*
* [Author] - [Date] - [ADO Ref] - Stamp Duty exemption rule for:
*    1. HK ETF       : SEHK (104) trade AND security SUB.ASSET.TYPE (118)
*    2. LSE IE       : LSE (361) trade AND security COMPANY.DOMICILE (IE)
*
*   Values are sourced from F.SCB.WM.H.LOCAL.PARAM record 'STMP.DTY.EXEMPT.PARAM'
*   (single source of truth shared by V.CALC.MKT.CHGS.GB and the
*    B.SCB.STMP.DTY.EXEMPT batch). If the config record is absent/empty the
*    rule defaults to no exemption (fully backward compatible).
*
*   Config mapping (SCBWM.PRM pattern):
*       FIELD.NAME                          FIELD.VALUE
*       ---------------------------------    -----------
*       STMP.DTY.EXEMPT.STOCK.EXCHANGE.SEHK  104 (SM list supported)
*       STMP.DTY.EXEMPT.SUB.ASSET.TYPE.SEHK  118
*       STMP.DTY.EXEMPT.STOCK.EXCHANGE.LSE   361 (SM list supported)
*       STMP.DTY.EXEMPT.COMPANY.DOMICILE.LSE IE
*
*   Y.EXEMPT.FLAG = '1' when (SEHK terms) OR (LSE terms) hold, else '' .
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SCB.WM.H.LOCAL.PARAM
*
    GOSUB INIT
    GOSUB PROCESS
RETURN
*=========
INIT:
*=========
    FN.SCB.WM.H.LOCAL.PARAM = 'F.SCB.WM.H.LOCAL.PARAM'
    F.SCB.WM.H.LOCAL.PARAM = ''
    CALL OPF(FN.SCB.WM.H.LOCAL.PARAM,F.SCB.WM.H.LOCAL.PARAM)
RETURN
*===========
PROCESS:
*===========
    Y.EXEMPT.FLAG = ''
    IF Y.STOCK.EXCHANGE THEN
        R.SCB.WM.H.LOCAL.PARAM = ''
        CALL F.READ(FN.SCB.WM.H.LOCAL.PARAM,'STMP.DTY.EXEMPT.PARAM',R.SCB.WM.H.LOCAL.PARAM,F.SCB.WM.H.LOCAL.PARAM,PARAM.ERR)
        IF R.SCB.WM.H.LOCAL.PARAM THEN
            Y.FIELD.NAMES = R.SCB.WM.H.LOCAL.PARAM<SCBWM.PRM.FIELD.NAME>
*
*   HK ETF rule: trade on SEHK codes AND security SUB.ASSET.TYPE equals config
*
            Y.SEHK.EXCH.POS = ''
            LOCATE 'STMP.DTY.EXEMPT.STOCK.EXCHANGE.SEHK' IN Y.FIELD.NAMES<1,1> SETTING Y.SEHK.EXCH.POS THEN
                Y.SEHK.EXCHANGES = R.SCB.WM.H.LOCAL.PARAM<SCBWM.PRM.FIELD.VALUE,Y.SEHK.EXCH.POS>
                CONVERT @SM TO @VM IN Y.SEHK.EXCHANGES
                Y.SEHK.SUB.POS = ''
                LOCATE 'STMP.DTY.EXEMPT.SUB.ASSET.TYPE.SEHK' IN Y.FIELD.NAMES<1,1> SETTING Y.SEHK.SUB.POS THEN
                    Y.SEHK.SUB.ASSET.TYPE = R.SCB.WM.H.LOCAL.PARAM<SCBWM.PRM.FIELD.VALUE,Y.SEHK.SUB.POS>
                END
                IF Y.STOCK.EXCHANGE MATCHES Y.SEHK.EXCHANGES AND Y.SUB.ASSET.TYPE EQ Y.SEHK.SUB.ASSET.TYPE THEN
                    Y.EXEMPT.FLAG = '1'
                END
            END
*
*   LSE IE rule: trade on LSE codes AND security COMPANY.DOMICILE equals config
*
            Y.LSE.EXCH.POS = ''
            LOCATE 'STMP.DTY.EXEMPT.STOCK.EXCHANGE.LSE' IN Y.FIELD.NAMES<1,1> SETTING Y.LSE.EXCH.POS THEN
                Y.LSE.EXCHANGES = R.SCB.WM.H.LOCAL.PARAM<SCBWM.PRM.FIELD.VALUE,Y.LSE.EXCH.POS>
                CONVERT @SM TO @VM IN Y.LSE.EXCHANGES
                Y.LSE.DOM.POS = ''
                LOCATE 'STMP.DTY.EXEMPT.COMPANY.DOMICILE.LSE' IN Y.FIELD.NAMES<1,1> SETTING Y.LSE.DOM.POS THEN
                    Y.LSE.COMPANY.DOMICILE = R.SCB.WM.H.LOCAL.PARAM<SCBWM.PRM.FIELD.VALUE,Y.LSE.DOM.POS>
                END
                IF Y.STOCK.EXCHANGE MATCHES Y.LSE.EXCHANGES AND Y.COMPANY.DOMICILE EQ Y.LSE.COMPANY.DOMICILE THEN
                    Y.EXEMPT.FLAG = '1'
                END
            END
        END
    END
RETURN
END