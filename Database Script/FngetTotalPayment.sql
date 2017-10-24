USE [PMS]
GO

/****** Object:  UserDefinedFunction [dbo].[getTotalPayment]    Script Date: 10/23/2017 17:26:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[getTotalPayment]
(
@Date datetime
)
Returns int
as begin
  return (select sum(PaymentValue) from InvoicePaymentDetails where IsActive=1 and (Createdon >= @Date + '00:00:00' and createdon <= @Date + '23:59:59') OR (lastupdatedon >= @Date + '00:00:00' and lastupdatedon <= @Date + '23:59:59'))
end 


GO


