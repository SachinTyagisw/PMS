-- =============================================      
-- Author:  Sachin Tyagi      
-- Create date: June 13, 2017      
-- Description: This stored procedure shall return the complete information of booking based on the booking id.  
-- =============================================      
--Exec GetBokingDetails  1046 

  
Create PROC GetBokingDetails  
@BookingID INT  
AS BEGIN  
SELECT 
--Booking.ID
--,Booking.PropertyID
--,Booking.CheckinTime
--,Booking.CheckoutTime
--,Booking.NoOfAdult
--,Booking.NoOfChild
--,Booking.GuestRemarks
--,Booking.TransactionRemarks
--,Booking.IsActive
--,Booking.CreatedBy
--,Booking.CreatedOn
--,Booking.LastUpdatedBy
--,Booking 
* FROM   
Booking   
LEFT OUTER JOIN  
AdditionalGuests  
ON Booking.ID = AdditionalGuests.BookingId   
LEFT OUTER JOIN  
RoomBooking  
ON Booking.ID = RoomBooking.BookingId  
LEFT OUTER JOIN   
Guest   
ON RoomBooking.GuestID = Guest.ID
LEFT OUTER JOIN
GuestMapping
on Guest.ID = GuestMapping.GuestID
WHERE Booking.ID= @BookingID  

END


