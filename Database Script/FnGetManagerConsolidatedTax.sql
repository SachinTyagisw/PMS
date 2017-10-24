USE [PMS]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetManagerConsolidatedTax]    Script Date: 10/23/2017 17:25:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[fnGetManagerConsolidatedTax]
(
@TaxName nvarchar(max),
@Date datetime
)
Returns money
as begin
  return (select sum(TaxAmount) from InvoiceTaxDetail where TaxShortName = @TaxName and Createdon > @Date + '00:00:00' and createdon <= @Date + '23:59:59')
end 


GO


