-- =============================================                
-- Author:  Sachin Tyagi                
-- Create date: Aug 21, 2017                
-- Description: This stored procedure shall return the complete transaction information based on search criteria
-- =============================================                

--exec GetTransactionData    
            
ALTER PROC GetTransactionData           
@StartDate Datetime = NULL,
@EndDate DateTime = NULL,
@CustomerName nvarchar(max) = NULL,
@RoomType nvarchar(max) = NULL,
@AmountPaid money = NULL,
@paymentmode nvarchar(max) = NULL,
@TransactionStatus bit = NULL           
AS BEGIN

select distinct 
bk.CheckinTime as TransactionDate,
Guest.FirstName + ' ' + Guest.LastName as GuestName,
inv.TotalAmount as AmountPaid,
rt.NAME as RoomType,
[dbo].fnGetPaymentOption(inv.ID) as ModeOfPayment,
[dbo].fnGetRoomRates(inv.ID) as RoomRate,
bk.ID as TransactionNumber,
[dbo].fnGetTaxAmount(inv.ID) as TaxCollected,
Status = case when (bk.IsActive = 1) then  'Active' else 'InActive' end                    
from
Booking bk 
inner join 
Invoice inv on
inv.BookingID = bk.ID
inner join
InvoicePaymentDetails payment on
payment.invoiceid = inv.ID
inner join 
InvoiceItems on
InvoiceItems.InvoiceID = inv.ID
inner join
InvoiceTaxDetail on
InvoiceTaxDetail.InvoiceID = inv.ID
inner join
RoomBooking rbk on
rbk.BookingID = bk.ID
inner join
Room on
rbk.RoomID = Room.ID
inner join
RoomType rt on
rt.ID = Room.RoomTypeID
LEFT OUTER JOIN             
Guest             
ON rbk.GuestID = Guest.ID          
END







