-- =============================================
-- Author:  Sachin Tyagi
-- Create date: April 29, 2017
-- Description: This stored procedure shall get the details of booking based on the checkin and checkoutdate
-- =============================================
--Exec GetBookingDetails 1, '2017-01-01', '2017-07-07'

CREATE PROCEDURE [DBO].GETALLBOOKINGS
	@PROPERTYID INT,
	@CHECKINTIME DATETIME = NULL,
	@CHECKOUTDATE DATETIME = NULL
AS
BEGIN
SELECT 
	 BK.ID
	,BK.PROPERTYID
	,BK.CHECKINTIME
	,BK.CHECKOUTTIME
	,GUEST.FIRSTNAME
	,GUEST.LASTNAME
	FROM BOOKING BK INNER JOIN ROOMBOOKING RB 
	ON BK.ID = RB.BOOKINGID
	INNER JOIN GUEST
	ON RB.GUESTID = GUEST.ID
	WHERE BK.CHECKINTIME >= ISNULL(@CHECKINTIME,'1900-01-01')
	AND BK.CHECKOUTTIME <= ISNULL(@CHECKOUTDATE, GETDATE()) AND BK.ISACTIVE=1
END