-- =============================================    
-- Author:  Sachin Tyagi    
-- Create date: MAY 06, 2017    
-- Description: This stored procedure shall get the status of the room based on the checkin and checkout date  
-- =============================================    
--Exec GETROOMSTATUS 1, '2017-05-15 21:24:34.000', '2017-06-18 21:24:34.000','1'  
    
ALTER PROCEDURE [DBO].GETROOMSTATUS    
 @PROPERTYID INT,    
 @CHECKINTIME DATETIME = NULL,    
 @CHECKOUTDATE DATETIME = NULL  
AS    
BEGIN    
  
WITH ROOMBOOKING_CTE(ROOMBOOKINGID, ROOMID)  
AS  
(  
SELECT   
 ROOMBOOKING.ID,   
 ROOMID   
FROM ROOMBOOKING  
  
INNER JOIN   
BOOKING ON  
BOOKING.ID = ROOMBOOKING.BOOKINGID   
WHERE BOOKING.CHECKINTIME >=@CHECKINTIME AND BOOKING.CHECKOUTTIME <=@CHECKOUTDATE  
) 
 
SELECT DISTINCT  
ROOM.ID,  
ROOM.ROOMTypeID,  
NUMBER,  
ROOMSTATUS = CASE WHEN ISNULL(ROOMBOOKING_CTE.ROOMID,'') = '' THEN 'AVAILABLE' ELSE 'BOOKED' END  
FROM ROOM  
LEFT OUTER JOIN  
ROOMBOOKING_CTE ON  
ROOMBOOKING_CTE.ROOMID = ROOM.ID   
where ROOM.PROPERTYID=@PROPERTYID 
  
--SELECT DISTINCT  
--ROOM.ID,  
--ROOM.ROOMTypeID,  
--NUMBER,  
--ROOMSTATUS = CASE WHEN ISNULL(ROOMBOOKING.ROOMID,'') = '' THEN 'AVAILABLE' ELSE 'BOOKED' END  
--FROM ROOM   
--LEFT OUTER JOIN   
  
  
--ROOMBOOKING   
--ON ROOM.ID = ROOMBOOKING.ROOMID  
--LEFT OUTER JOIN  
--BOOKING  
--ON BOOKING.ID = ROOMBOOKING.BOOKINGID  
--WHERE ROOM.ROOMTYPEID = @ROOMTYPEID   
----AND BOOKING.CHECKINTIME >=@CHECKINTIME AND BOOKING.CHECKOUTTIME <=@CHECKOUTDATE  
END  