create function fnGetRoomRates
(
@invoiceId int
)
Returns money
as begin
  return (select itemValue from  InvoiceItems where invoiceId = @invoiceId and ItemName='ROOM CHARGES')
end
