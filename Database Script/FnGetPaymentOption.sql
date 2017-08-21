create function fnGetPaymentOption
(
@invoiceId int
)
Returns nvarchar(max)
as begin
  return (select stuff((Select ',' + paymentmode from  InvoicePaymentDetails where invoiceId = @invoiceId FOR XML PATH('')),1,1,''))
end 
