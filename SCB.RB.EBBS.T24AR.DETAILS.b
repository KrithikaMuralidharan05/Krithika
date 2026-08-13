SUBROUTINE SCB.RB.EBBS.T24AR.DETAILS
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
* 03/10/2025 - ADO-10450834 - Anitha Rani S
*              New Template changes
* ----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_Table
*-----------------------------------------------------------------------------
    Table.name = 'SCB.RB.EBBS.T24AR.DETAILS' ;* Full application name including product prefix
    Table.title ='To store the eBBS response status'       ;* Screen title
    Table.stereotype = 'L'    ;* H, U, L, W or T
    Table.product = 'SC'      ;* Must be on EB.PRODUCT
    Table.subProduct = ''     ;* Must be on EB.SUB.PRODUCT
    Table.classification = 'INT'        ;* As per FILE.CONTROL
    Table.systemClearFile = 'Y'         ;* As per FILE.CONTROL
    Table.relatedFiles = ''   ;* As per FILE.CONTROL
    Table.isPostClosingFile = ''        ;* As per FILE.CONTROL
    Table.equatePrefix = 'SCB.EBBS.T24AR'    ;* Use to create I_F.SCB.RB.EBBS.T24AR.DETAILS
*-----------------------------------------------------------------------------
    Table.idPrefix = ''       ;* Used by EB.FORMAT.ID if set
    Table.blockedFunctions = ''         ;* Space delimeted list of blocked functions
    Table.trigger = ''        ;* Trigger field used for OPERATION style fields
*-----------------------------------------------------------------------------
RETURN
END