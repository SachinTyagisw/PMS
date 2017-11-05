
Alter function [dbo].[getTotalTax]
(
@Date datetime
)
Returns int
as begin
  return (select sum(TaxValue) from InvoiceTaxDetail where IsActive=1 and (Createdon >= @Date + '00:00:00' and createdon <= @Date + '23:59:59') OR (lastupdatedon >= @Date + '00:00:00' and lastupdatedon <= @Date + '23:59:59'))
end 


GO


