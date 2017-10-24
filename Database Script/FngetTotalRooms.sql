SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[getTotalRooms]
(
@Date datetime
)
Returns int
as begin
  return (select count(1) from RoomBooking where (Createdon >= @Date + '00:00:00' and createdon <= @Date + '23:59:59') OR (lastupdatedon >= @Date + '00:00:00' and lastupdatedon <= @Date + '23:59:59'))
end 


GO


