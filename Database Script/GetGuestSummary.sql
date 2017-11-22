    
ALTER PROCEDURE [dbo].[GETGuestSummary]                        
 @PROPERTYID INT,                        
 @CURRENTDATE DATETIME    
AS                        
BEGIN                        
               
SELECT                         
  distinct BK.ID                        
 ,BK.PROPERTYID                        
 ,BK.CHECKINTIME                        
 ,BK.CHECKOUTTIME              
 ,BK.Status as 'Status'  
 ,[dbo].fnGetPaymentOption(Invoice.ID) as 'ModeOFPayment'    
 ,[dbo].fnGetRoomRates(Invoice.ID) as 'Rate'    
 ,GUEST.FIRSTNAME                        
 ,GUEST.LASTNAME                      
 ,GUEST.ID AS GUESTID                      
 ,RB.ID AS ROOMBOOKINGID                      
 ,ROOM.ID AS ROOMID                      
 ,ROOM.Number AS ROOMNUMBER           
 ,ROOM.RoomTypeID as RoomTypeID          
 ,RoomType.NAME as RoomTypeName                       
 ,RoomType.ShortName as RoomTypeShortName      
 ,ROOM.Status as RoomStatus    
 ,Invoice.TotalAmount as TotalAmount   
 ,getdate() as NextReservation  
 FROM BOOKING BK INNER JOIN ROOMBOOKING RB                         
 ON BK.ID = RB.BOOKINGID     
 INNER JOIN Invoice    
 ON BK.ID = Invoice.BOOKINGID    
 INNER JOIN Room                      
 ON RB.RoomID = Room.ID          
 Inner JOIN RoomType          
 On  Room.RoomTypeID = RoomType.ID                     
 INNER JOIN GUEST                        
 ON RB.GUESTID = GUEST.ID                        
 WHERE (BK.CHECKINTIME <= @CURRENTDATE AND BK.CHECKOUTTIME >=  @CURRENTDATE )                      
              
END 