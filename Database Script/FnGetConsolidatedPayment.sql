USE [PMS]
GO

/****** Object:  UserDefinedFunction [dbo].[fnGetConsolidatedPayment]    Script Date: 10/23/2017 17:25:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[fnGetConsolidatedPayment]
(
@PaymentMode nvarchar(max),
@Date datetime
)
Returns money
as begin
  return (select sum(PaymentValue) from InvoicePaymentDetails where PaymentMode = @PaymentMode and Createdon > @Date + '00:00:00' and createdon <= @Date + '23:59:59')
end 


GO


