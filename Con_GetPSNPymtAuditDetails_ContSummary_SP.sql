SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON 
GO
IF NOT EXISTS (select 1 from dbo.sysobjects where id = object_id(N'[dbo].[Con_GetPSNPymtAuditDetails_ContSummary_SP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
	EXECUTE ('CREATE PROCEDURE Con_GetPSNPymtAuditDetails_ContSummary_SP AS SET NOCOUNT ON ')
GO

EXEC SP_SET_EXTENDED_PROPERTY 'Procedure','Con_GetPSNPymtAuditDetails_ContSummary_SP', NULL, NULL, 
'E15.0.0', ' 2024-03-26	KV	Issue MI-1151 - Integrated_Payment_Audit - Should a Rejected payment have a cash_receipt_id = 0? I think it should be NULL'
GO

/**********************************************************************
--1. File Name			Con_GetPSNPymtAuditDetails_ContSummary_SP.sql	     
--2. Description		Fetch IPM audit table details for Contract Summary Payments
--3. Modification Log                                   
--4. Ver No		 Date			Author		Modification
--   E15.0.0     2023-03-30		SR			Issue MI-559 - MI-367 Defect: Business rule-2 Violated for Café contract summary screen. Cannot see the response back from PSN in the GRID
--   E15.0.0     2023-04-07		SR			Issue MI-559 - MI-367 Defect: Business rule-2 Violated for Café contract summary screen. Cannot see the response back from PSN in the GRID
--   E15.0.0     2023-06-02		DS			Issue MI-708 - Can't create a reversal record in a posted cafe contract
--   E15.0.0     2024-03-26		KV			Issue MI-1151 - Integrated_Payment_Audit - Should a Rejected payment have a cash_receipt_id = 0? I think it should be NULL
--*********************************************************************/
ALTER PROCEDURE [dbo].[Con_GetPSNPymtAuditDetails_ContSummary_SP]
	 @pi_sSalesContractNbr	VARCHAR(20)
	,@pi_sPymtTypeCd		VARCHAR(10)
	,@pi_iCashRcptID		INT
	,@pi_dcCashRcptAmt		DECIMAL(9,2)
	,@pi_dtTransDate		DATETIME
AS

/*********************************************************************
--1. Procedure Name 	Con_GetPSNPymtAuditDetails_ContSummary_SP.sq
--2. Parameters 		
--Input :
--		NA
--	Output 		
--		NA
--3. Return Value(s)  		0 if Success                          
--		             		Error # if Failure                    
--4. Module Name			Contracts
--5. Description			Fetch IPM audit table details for Contract Summary Payments
**************************************************************************************/

--Turn off rows affected messages
SET NOCOUNT ON 

IF NOT EXISTS (SELECT 1 FROM Cash_Receipt WHERE Cash_Receipt_ID = @pi_iCashRcptID AND Cash_Receipt_Nbr IS NOT NULL and Batch_ID <> -1) 
BEGIN
	SELECT		PayType,
				BankExt,
				Status AS PSNStatus,
				TransID 
	FROM		Integrated_Payment_Audit
    WHERE		Invoke_page IN ('CONTRACTPRO','PTC') 
	AND			Sales_Contract_Nbr = @pi_sSalesContractNbr
    AND			Payment_Type_Cd = @pi_sPymtTypeCd
	AND			TransAmt = @pi_dcCashRcptAmt
	AND			CONVERT(date, TransDate) = CONVERT(date, @pi_dtTransDate)
	AND			Cash_Receipt_Nbr IS NULL
	--BEGIN - KV - 2024-03-26	- Issue MI-1151 - Integrated_Payment_Audit - Should a Rejected payment have a cash_receipt_id = 0? I think it should be NULL
	--AND			Cash_Receipt_ID = 0
	AND			Cash_Receipt_ID  IS NULL
	--END - KV - 2024-03-26	- Issue MI-1151 - Integrated_Payment_Audit - Should a Rejected payment have a cash_receipt_id = 0? I think it should be NULL
	AND			Status = 'Approved'
END
ELSE
BEGIN
	SELECT		PayType,
				BankExt,
				Status AS PSNStatus,
				TransID 
	FROM		Integrated_Payment_Audit
    WHERE		Invoke_page IN ('CONTRACTPRO','PTC')	
	AND			Sales_Contract_Nbr = @pi_sSalesContractNbr
    AND			Payment_Type_Cd = @pi_sPymtTypeCd
	AND			TransAmt = @pi_dcCashRcptAmt
	AND			CONVERT(date, TransDate) = CONVERT(date, @pi_dtTransDate)
	AND			Cash_Receipt_ID = @pi_iCashRcptID
	AND			Status = 'Approved'
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO