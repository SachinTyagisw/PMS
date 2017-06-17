USE [PMS]
GO
/****** Object:  StoredProcedure [dbo].[GETINVOICEDETAILS]    Script Date: 6/17/2017 9:47:03 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================    
-- Author:  Sachin Tyagi    
-- Create date: June 13, 2017    
-- Description: This stored procedure shall return the complete information of invoice.
-- =============================================    
--Exec GETINVOICEDETAILS 21 

ALTER PROC [dbo].[GETINVOICEDETAILS]
@INVOICEID INT
AS BEGIN
SELECT INVOICE.ID as InvoiceId
, Invoice.GuestID
, Invoice.BookingID
, Invoice.IsPaid
, Invoice.TotalAmount
, Invoice.FolioNumber
, Invoice.IsActive as InvoiceActive
, Invoice.CreatedBy
, Invoice.CreatedOn
, Invoice.LastUpdatedBy
, Invoice.LastUpdatedOn
, Invoice.DISCOUNT
, InvoiceItems.ItemName
, InvoiceItems.ItemValue
, INVOICEPAYMENTDETAILS.PaymentMode
, INVOICEPAYMENTDETAILS.PaymentValue
, INVOICEPAYMENTDETAILS.PaymentDetails
, INVOICETAXDETAIL.TaxShortName
, INVOICETAXDETAIL.TaxAmount
FROM 
INVOICE 
LEFT OUTER JOIN 
INVOICEITEMS 
ON INVOICE.ID = INVOICEITEMS.INVOICEID
LEFT OUTER JOIN
INVOICETAXDETAIL
ON INVOICE.ID = INVOICETAXDETAIL.INVOICEID 
LEFT OUTER JOIN
INVOICEPAYMENTDETAILS
ON INVOICE.ID = INVOICEPAYMENTDETAILS.INVOICEID
WHERE INVOICE.ID= @INVOICEID
END