-- =============================================      
-- Author:  Sachin Tyagi      
-- Create date: MAY 16, 2017      
-- Description: This stored procedure shall update the booking checkin/checkout and room information in case of drag/drop feature.
-- =============================================      
      
CREATE PROCEDURE [DBO].UpdateBooking      
 @BOOKINGID INT,      
 @CHECKINTIME DATETIME,      
 @CHECKOUTTIME DATETIME,
 @RoomID INT     
AS      
BEGIN 

--TODO Transaction and Rollback mechanism and other contraints to avoid the updation of record with wrong value
UPDATE BOOKING SET CHECKINTIME=@CHECKINTIME, CHECKOUTTIME = @CHECKOUTTIME WHERE ID=@BOOKINGID
UPDATE ROOMBOOKING SET ROOMID=@ROOMID WHERE BOOKINGID=@BOOKINGID
END 