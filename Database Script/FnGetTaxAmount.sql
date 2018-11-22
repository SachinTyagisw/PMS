
Alter function fnGetTaxAmount
(
@invoiceId int
)
Returns money
as begin
  return (select sum(TaxValue) from  InvoiceTaxDetail where invoiceId = @invoiceId)
end