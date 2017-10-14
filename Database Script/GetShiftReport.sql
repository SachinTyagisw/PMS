Create PROC [GetShiftReport]           
@StartDate Datetime = NULL,
@EndDate DateTime = NULL,
@PropertyId nvarchar(max) = NULL    
AS BEGIN

declare @sql varchar(8000),@col_list varchar(8000),@pivot_listTax varchar(8000),@pivot_listPayment varchar (8000), @pivot_listRoomCharge varchar(8000)
set @pivot_listTax =stuff((select distinct  ','+quotename(TaxShortName) from InvoiceTaxDetail where TaxShortName <> ''  for xml path('')),1,1,'')
print @pivot_listTax
set @pivot_listPayment = stuff((select distinct  ','+quotename(PaymentMode) from InvoicePaymentDetails where PaymentMode <> '' for xml path('')),1,1,'')
print @pivot_listPayment

set @sql  = 'select * from
(
SELECT 
bk.CheckinTime,
bk.CheckoutTime,bk.id as TransantionNumber,
Room.Number as RoomNumber,
[dbo].fnGetRoomCharge(inv.ID) as RoomCharge,
Guest.FirstName +'' ''+ Guest.LastName as GuestName, 
bk.GuestRemarks,invTax.TaxShortName,invTax.TaxAmount, invPayment.PaymentMode, invPayment.PaymentValue,inv.TotalAmount
FROM Booking bk   
inner join   
Invoice inv on  
inv.BookingID = bk.ID  
inner join  
InvoicePaymentDetails invPayment on  
invPayment.invoiceid = inv.ID  
inner join   
InvoiceItems on  
InvoiceItems.InvoiceID = inv.ID  
inner join  
InvoiceTaxDetail invTax on  
invTax.InvoiceID = inv.ID  
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
) as p
pivot 
(
max(TaxAmount)
for TaxShortName in ( '+@pivot_listTax+') 
)as pvt 
pivot
(
max(PaymentValue)
for PaymentMode in ( '+@pivot_listPayment+')
) as pvt1'

--print @sql
exec(@sql)
END