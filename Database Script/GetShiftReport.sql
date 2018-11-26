USE [PMS]
GO

/****** Object:  StoredProcedure [dbo].[GetShiftReport]    Script Date: 11/05/2017 08:14:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[GetShiftReport]               
@StartDate Datetime,    
@EndDate DateTime,    
@PropertyId nvarchar(5)       
AS BEGIN  
  
set @StartDate = cast(@StartDate as DATE)  
set @EndDate= cast(convert(char(8), @EndDate, 112) + ' 23:59:59.99' as datetime)  

declare @sql varchar(8000),@col_list varchar(8000),@pivot_listTax varchar(8000),@pivot_listPayment varchar (8000), @pivot_listRoomCharge varchar(8000)    
set @pivot_listTax =stuff((select distinct  ','+quotename(TaxShortName) from InvoiceTaxDetail where TaxShortName <> ''  for xml path('')),1,1,'')    

set @pivot_listPayment = stuff((select distinct  ','+quotename(PaymentMode) from InvoicePaymentDetails where PaymentMode <> '' for xml path('')),1,1,'')    

set @sql  = 'select * from    
(    
SELECT     
CONVERT(VARCHAR, bk.CheckinTime, 120) as CheckinTime,    
bk.CheckoutTime,bk.id as TransantionNumber,    
Room.Number as RoomNumber,    
[dbo].fnGetRoomCharge(inv.ID) as RoomCharge,    
Guest.FirstName +'' ''+ Guest.LastName as GuestName,     
bk.GuestRemarks,invTax.TaxShortName,invTax.TaxValue, invPayment.PaymentMode, invPayment.PaymentValue,inv.TotalAmount    
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
ON rbk.GuestID = Guest.ID where bk.propertyID =' + @PropertyId + 
' and bk.checkinTime > ''' + CONVERT(VARCHAR(max), @StartDate, 120) + ''' and bk.checkinTime < ''' + CONVERT(VARCHAR(max), @EndDate, 120) + '''
) as p    
pivot     
(    
max(TaxValue)    
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

GO


