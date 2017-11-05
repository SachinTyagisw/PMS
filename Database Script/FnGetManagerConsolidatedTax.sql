USE [PMS]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetManagerConsolidatedTax]    Script Date: 11/05/2017 08:21:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER function [dbo].[fnGetManagerConsolidatedTax]
(
@TaxName nvarchar(max),
@Date datetime
)
Returns money
as begin
  return (select sum(TaxValue) from InvoiceTaxDetail where TaxShortName = @TaxName and Createdon > @Date + '00:00:00' and createdon <= @Date + '23:59:59')
end 


GO


