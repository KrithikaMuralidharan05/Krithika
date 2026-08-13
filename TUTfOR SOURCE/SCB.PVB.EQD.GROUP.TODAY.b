* @ValidationCode : MjotMTA3OTk5ODg0ODpJU08tODg1OS0xOjE3NTgxOTEwMjAyNjQ6ODIyNjYwNTotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMF9TUDEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 18 Sep 2025 15:53:40
* @ValidationInfo : Encoding          : ISO-8859-1
* @ValidationInfo : User Name         : 8226605
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R20_SP10.0
*-----------------------------------------------------------------------------
* <Rating>-13</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE SCB.PVB.EQD.GROUP.TODAY
*-----------------------------------------------------------------------------
*<doc>
* TODO add a description of the application here.
* @author youremail@temenos.com
* @stereotype Application
* @package TODO define the product group and product, e.g. infra.eb
* </doc>
*-----------------------------------------------------------------------------
* TODO - You MUST write a .FIELDS routine for the field definitions
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
*** 18/06/2026   12127880        8220461      Trade Grouping Logic in T24
* ----------------------------------------------------------------------------
* <region name= Inserts>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_Table
* </region>
*-----------------------------------------------------------------------------
    Table.name = 'SCB.PVB.EQD.GROUP.TODAY'        ;* Full application name including product prefix
    Table.title = 'SCB EQD SEC TRADE GROUPING'       ;* Screen title
    Table.stereotype = 'L'    ;* H, U, L, W or T
    Table.product = 'SC'      ;* Must be on EB.PRODUCT
    Table.subProduct = ''     ;* Must be on EB.SUB.PRODUCT
    Table.classification = 'FIN'        ;* As per FILE.CONTROL
    Table.systemClearFile = 'Y'         ;* As per FILE.CONTROL
    Table.relatedFiles = ''   ;* As per FILE.CONTROL
    Table.isPostClosingFile = ''        ;* As per FILE.CONTROL
    Table.equatePrefix = 'SCB.EQD.ST'        ;* Use to create I_F.EB.LOG.PARAMETER
*-----------------------------------------------------------------------------
    Table.idPrefix = ''       ;* Used by EB.FORMAT.ID if set
    Table.blockedFunctions = ''         ;* Space delimeted list of blocked functions
    Table.trigger = ''        ;* Trigger field used for OPERATION style fields
*-----------------------------------------------------------------------------

RETURN
END