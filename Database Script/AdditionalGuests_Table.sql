
	CREATE TABLE AdditionalGuests
	(	
		Id int identity, 
		BookingId int, 
		FirstName nvarchar(100), 
		LastName nvarchar(100), 
		GUESTIDPath nvarchar(max), 
		Foreign key(BookingID) References Booking(ID)
	)