
create function fnGetTaxAmount
(
@invoiceId int
)
Returns money
as begin
  return (select sum(TaxAmount) from  InvoiceTaxDetail where invoiceId = @invoiceId)
end