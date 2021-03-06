 -- =============================================            
-- Author:  Sachin Tyagi            
-- Create date: June 13, 2017            
-- Description: This stored procedure shall return the complete information of invoice.        
-- =============================================            
--Exec GETINVOICEDETAILS 21         
        
CREATE PROC [dbo].[GETINVOICEDETAILS]        
@INVOICEID INT,        
@PROPERTYID INT,        
@ROOMTYPEID INT,                  
@RATETYPEID INT,                  
@NOOFHOURS INT = NULL,                  
@NOOFDAYS INT,                  
@ISHOURLY BIT,          
@RoomID int        
AS BEGIN        
        
declare @RoomValue money        
SELECT @RoomValue = Value               
  --,CASE WHEN (@ISHOURLY = 1) THEN  VALUE ELSE VALUE * @NOOFDAYS END                    
  FROM RATES WHERE                   
  PROPERTYID =@PROPERTYID AND                   
  ROOMTYPEID = @ROOMTYPEID AND RATETYPEID = @RATETYPEID AND              
  --(INPUTKEYHOURS IS NULL OR INPUTKEYHOURS = @NOOFHOURS) AND          
  RoomId = @RoomID        
  
  IF(@INVOICEID < 0)
  BEGIN
  UPDATE INVOICEITEMS SET ITEMVALUE= @ROOMVALUE WHERE INVOICEID=@INVOICEID AND Upper(ITEMNAME) = 'ROOM CHARGES'        
          
  IF(@NOOFDAYS > 1)        
  BEGIN        
   UPDATE INVOICEITEMS SET ITEMVALUE= (@ROOMVALUE * @NOOFDAYS) WHERE INVOICEID=@INVOICEID AND Upper(ITEMNAME) = 'TOTAL ROOM CHARGE'        
  END        
  ELSE        
  BEGIN        
   UPDATE INVOICEITEMS SET ITEMVALUE= @ROOMVALUE WHERE INVOICEID=@INVOICEID AND Upper(ITEMNAME) = 'TOTAL ROOM CHARGE'        
  END
  
  END
          
          
          
          
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
, Invoice.DISCOUNTAmount   
,Invoice.CreditCardDetail        
, InvoiceItems.ItemName        
, InvoiceItems.ItemValue 
,InvoiceItems.CreatedOn as InvoiceItemCreatedOn
, INVOICEPAYMENTDETAILS.PaymentMode        
, INVOICEPAYMENTDETAILS.PaymentValue        
, INVOICEPAYMENTDETAILS.PaymentDetails
,INVOICEPAYMENTDETAILS.CreatedOn as InvoicePaymentCreatedOn  
, INVOICETAXDETAIL.TaxShortName        
, INVOICETAXDETAIL.TaxAmount        
,INVOICETAXDETAIL.TaxValue      
,INVOICETAXDETAIL.IsConsidered      
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
