	CREATE TABLE AdditionalGuests
	(	
		Id int identity, 
		BookingId int, 
		FirstName nvarchar(100), 
		LastName nvarchar(100), 
		GUESTIDPath nvarchar(max),
		IsActive bit,
		CreatedBy nvarchar(200),
		CreatedOn datetime,
		LastUpdatedBy nvarchar(200),
		LastUpdatedOn datetime,
		Foreign key(BookingID) References Booking(ID)
	)