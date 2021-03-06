
-- =============================================      
-- Author:  Sachin Tyagi      
-- Create date: MAY 06, 2017      
-- Description: This stored procedure shall get the status of the room based on the checkin and checkout date    
-- =============================================      
--Exec GETROOMSTATUS 1, '2017-05-15 21:24:34.000', '2017-06-18 21:24:34.000','1'    
      
ALter PROCEDURE [dbo].[GETROOMSTATUS]      
 @PROPERTYID INT,      
 @CHECKINTIME DATETIME = NULL,      
 @CHECKOUTDATE DATETIME = NULL
AS      
BEGIN 

IF(CONVERT(TIME,@CHECKOUTDATE)= '00:00:00.0000000')                  
 set @CHECKOUTDATE = @CHECKOUTDATE + '23:59:59';     
    
WITH ROOMBOOKING_CTE(ROOMBOOKINGID, ROOMID)    
AS    
(    
SELECT     
 ROOMBOOKING.ID,     
 ROOMID     
FROM ROOMBOOKING    
    
INNER JOIN     
BOOKING BK ON    
BK.ID = ROOMBOOKING.BOOKINGID     
WHERE ((BK.CHECKINTIME >= ISNULL(@CHECKINTIME,'1900-01-01')                    
 AND BK.CHECKOUTTIME <= ISNULL(stuff(convert(varchar(19), @CHECKOUTDATE, 126),11,1,' '), GETDATE()))             
 OR              
  ((BK.CHECKINTIME <= ISNULL(@CHECKINTIME,'1900-01-01') and BK.CheckoutTime >= ISNULL(stuff(convert(varchar(19), @CHECKOUTDATE, 126),11,1,' '), GETDATE())))              
 OR              
 ((BK.CHECKINTIME <= ISNULL(@CHECKINTIME,'1900-01-01') and ((BK.CheckoutTime <= ISNULL(stuff(convert(varchar(19), @CHECKOUTDATE, 126),11,1,' '), GETDATE())) and BK.CheckoutTime >= ISNULL(@CHECKINTIME,'1900-01-01'))))            
 OR              
 ((BK.CHECKINTIME <= ISNULL(@CHECKOUTDATE,'1900-01-01') and BK.CheckoutTime >= ISNULL(stuff(convert(varchar(19), @CHECKOUTDATE, 126),11,1,' '), GETDATE()))))  
 AND BK.PropertyId =  @PROPERTYID     
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
AND ROOM.IsActive = 1  
    
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
