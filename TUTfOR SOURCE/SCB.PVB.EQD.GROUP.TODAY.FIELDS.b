* @ValidationCode : MjoxNzUxMTM0NzQ3OklTTy04ODU5LTE6MTc1ODE5MTIxODY2MTo4MjI2NjA1Oi0xOi0xOjA6MDp0cnVlOk4vQTpSMjBfU1AxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 18 Sep 2025 15:56:58
* @ValidationInfo : Encoding          : ISO-8859-1
* @ValidationInfo : User Name         : 8226605
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : R20_SP10.0
*-----------------------------------------------------------------------------
* <Rating>-15</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE SCB.PVB.EQD.GROUP.TODAY.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine YOURAPPLICATION.FIELDS
*
* @author tcoleman@temenos.com
* @stereotype fields template
* @uses Table
* @public Table Creation
* @package infra.eb
* </doc>
*-----------------------------------------------------------------------------
* Modification History :
** 18/06/2026   12127880        8220461      Trade Grouping Logic in T24
*
* ----------------------------------------------------------------------------
*** <region name= Header>
*** <desc>Inserts and control logic</desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DataTypes
*** </region>
*-----------------------------------------------------------------------------
    CALL Table.defineId("@ID", T24_String)        ;* Define Table id
*-----------------------------------------------------------------------------
    ID.F = '@ID' ; ID.N = '90' ; ID.T = 'ANY'
 
    fieldName = 'XX<SEC.TRADE.ID'
    fieldLength = '20'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'XX-QUANTITY'
    fieldLength = '18'
    fieldType = 'AMT'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'XX-PRICE'
    fieldLength = '18'
    fieldType = 'AMT'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
	fieldName = 'XX-TRADE.DATE'
    fieldLength = '8'
    fieldType = 'D'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
	fieldName = 'XX-VALUE.DATE'
    fieldLength = '8'
    fieldType = 'D'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
	fieldName = 'XX-CUS.TRANS.CODE'
    fieldLength = '6'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
	fieldName = 'XX-BR.GROSS.AMT.TRD'
    fieldLength = '18'
    fieldType = 'AMT'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
	fieldName = 'XX-STOCK.EXCHANGE'
    fieldLength = '18'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
	fieldName = 'XX-DEPO'
    fieldLength = '18'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field


    fieldName = 'XX>BR.MISC.FEE'
    fieldLength = '18'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field


    fieldName = 'AGGREGATED.QTY'
    fieldLength = '18'
    fieldType = 'AMT'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
	fieldName = 'AVG.PRICE'
    fieldLength = '18'
    fieldType = 'AMT'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
	fieldName = 'AGGREGATED.STAMP.DUTY'
    fieldLength = '18'
    fieldType = 'AMT'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
	fieldName = 'AGGREGATED.TRANSFER.ID'
    fieldLength = '16'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
	fieldName = 'AUTH.DATE'
    fieldLength = '8'
    fieldType = 'D'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'AGGREGATED.STATUS'
    fieldLength = '10'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
	fieldName = 'ERROR'
    fieldLength = '100'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
		
    fieldName = 'XX<SEC.TRADE.ID.NOT.INCLUDED'
    fieldLength = '20'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'XX-QUANTITY.NOT.INCLUDED'
    fieldLength = '18'
    fieldType = 'AMT'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    fieldName = 'XX-PRICE.NOT.INCLUDED'
    fieldLength = '18'
    fieldType = 'AMT'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
	fieldName = 'XX-TRADE.DATE.NOT.INCLUDED'
    fieldLength = '8'
    fieldType = 'D'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
	fieldName = 'XX-VALUE.DATE.NOT.INCLUDED'
    fieldLength = '8'
    fieldType = 'D'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
	fieldName = 'XX-CUST.TRANS.CODE.NOT.INCLUDED'
    fieldLength = '6'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
	fieldName = 'XX-BR.GROSS.AMT.TRD.NOT.INCLUDED'
    fieldLength = '18'
    fieldType = 'AMT'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field


    fieldName = 'XX-BR.MISC.FEE1.NOT.INCLUDED'
    fieldLength = '18'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
	fieldName = 'XX-STOCK.EXCHANGE.NOT.INCLUDED'
    fieldLength = '18'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
	
	fieldName = 'XX>DEPO.NOT.INCLUDED'
    fieldLength = '18'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

*
*
    CALL Table.addField("RESERVED.10",T24_String,Field_NoInput,"") ;
    CALL Table.addField("RESERVED.9",T24_String,Field_NoInput,"") ;
    CALL Table.addField("RESERVED.8",T24_String,Field_NoInput,"") ;
    CALL Table.addField("RESERVED.7",T24_String,Field_NoInput,"") ;
    CALL Table.addField("RESERVED.6",T24_String,Field_NoInput,"") ;
    CALL Table.addField("RESERVED.5",T24_String,Field_NoInput,"") ;
    CALL Table.addField("RESERVED.4",T24_String,Field_NoInput,"") ;
    CALL Table.addField("RESERVED.3",T24_String,Field_NoInput,"") ;
    CALL Table.addField("RESERVED.2",T24_String,Field_NoInput,"") ;
    CALL Table.addField("RESERVED.1",T24_String,Field_NoInput,"") ;
*
RETURN
*-----------------------------------------------------------------------------
END