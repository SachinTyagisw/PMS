
Create function [dbo].[fnGetRoomCharge]
(
@invoiceId int
)
Returns money
as begin
declare @result money
  select @result= max(ItemValue) from InvoiceItems where ItemName='Total Room Charge' and invoiceid=@invoiceId
  
  return @result
end 


GO




