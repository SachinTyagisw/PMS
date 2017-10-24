USE [PMS]
GO

/****** Object:  UserDefinedFunction [dbo].[getRooms]    Script Date: 10/23/2017 17:26:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[getRooms]
(
@Date datetime
)
Returns int
as begin
  return (select sum(itemValue) from InvoiceItems where ItemName = 'Total Room Charge' and (Createdon >= @Date + '00:00:00' and createdon <= @Date + '23:59:59') OR (lastupdatedon >= @Date + '00:00:00' and lastupdatedon <= @Date + '23:59:59'))
end 


GO


