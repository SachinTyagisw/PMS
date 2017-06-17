-- =============================================        
-- Author:  Sachin Tyagi        
-- Create date: June 13, 2017        
-- Description: This stored procedure shall return the complete information of booking based on the booking id.    
-- =============================================        
--Exec GetBokingDetails  1046   
    
ALTER PROC GetBokingDetails    
@BookingID INT    
AS BEGIN    
SELECT   
Booking.ID as BookingID
,Booking.PropertyID as PropertyID 
,Booking.CheckinTime  as CheckinTime
,Booking.CheckoutTime  as CheckoutTime
,Booking.NoOfAdult  
,Booking.NoOfChild  
,Booking.GuestRemarks  
,Booking.TransactionRemarks  
,Booking.IsActive  
,Booking.CreatedBy 
,Booking.CreatedOn 
,Booking.LastUpdatedBy  
,Booking.LastUpdatedOn
,Booking.Status
,Booking.ISHOURLYCHECKIN
,Booking.HOURSTOSTAY
,AdditionalGuests.Id as AdditionalGuestID
, AdditionalGuests.FirstName as AdditionalGuestFirstName
,AdditionalGuests.LastName as AdditionalGuestLastName
,AdditionalGuests.GUESTIDPath as AdditionalGuestIDPath
,AdditionalGuests.Gender as AdditionalGuestGender
,RoomBooking.RoomID as RoomBookingRoomId
,RoomBooking.ID as RoomBookingID
,RoomBooking.GuestID as RoomBookingGuestID
,GuestMapping.ID as GuestMappingId
,GuestMapping.IDTYPEID as IDTYPEID
,GuestMapping.GUESTID as GuestMappingGuestID
,GuestMapping.IDDETAILS as GuestMappingIDDETAILS
,GuestMapping.IdExpiryDate as IDExpiryDate
,GuestMapping.IdIssueState as IDIssueState
,GuestMapping.IdIssueCountry as IDIssueCountry
,Guest.ID as GuestID
,Guest.FirstName
,Guest.LastName
,Guest.MobileNumber
,Guest.EmailAddress
,Guest.DOB
,Guest.Gender
,Guest.PhotoPath

FROM Booking     
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
  
  