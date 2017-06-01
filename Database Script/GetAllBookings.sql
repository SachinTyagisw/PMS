USE [PMS]
GO
/****** Object:  StoredProcedure [dbo].[GETALLBOOKINGS]    Script Date: 6/1/2017 2:49:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  Sachin Tyagi  
-- Create date: April 29, 2017  
-- Description: This stored procedure shall get the details of booking based on the checkin and checkoutdate  
-- =============================================  
--Exec GETALLBOOKINGS 1, '2017-06-01', '2017-06-02'  
 
ALTER PROCEDURE [dbo].[GETALLBOOKINGS]  
 @PROPERTYID INT,  
 @CHECKINTIME DATETIME = NULL,  
 @CHECKOUTDATE DATETIME = NULL  
AS  
BEGIN  

IF(CONVERT(TIME,@CHECKOUTDATE)= '00:00:00.0000000')
 set @CHECKOUTDATE = @CHECKOUTDATE + '23:59:59'

SELECT   
  distinct BK.ID  
 ,BK.PROPERTYID  
 ,BK.CHECKINTIME  
 ,BK.CHECKOUTTIME  
 ,GUEST.FIRSTNAME  
 ,GUEST.LASTNAME
 ,GUEST.ID AS GUESTID
 ,RB.ID AS ROOMBOOKINGID
 ,ROOM.ID AS ROOMID
 ,ROOM.Number AS ROOMNUMBER
 
 FROM BOOKING BK INNER JOIN ROOMBOOKING RB   
 ON BK.ID = RB.BOOKINGID  
 INNER JOIN Room
 ON RB.RoomID = Room.ID
 INNER JOIN GUEST  
 ON RB.GUESTID = GUEST.ID  
 WHERE BK.CHECKINTIME >= ISNULL(@CHECKINTIME,'1900-01-01')  
 AND BK.CHECKOUTTIME <= ISNULL(stuff(convert(varchar(19), @CHECKOUTDATE, 126),11,1,' '), GETDATE()) AND BK.ISACTIVE=1  
END