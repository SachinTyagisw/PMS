-- =============================================
-- Author:  Sachin Tyagi
-- Create date: April 29, 2017
-- Description: This stored procedure shall insert/update the booking details in PMS. This is inswerting the required
				--information in following tables (Booking, RoomBooking, Guest and Address)
-- =============================================

Create PROCEDURE [dbo].InsertBooking
	@propertyID INT,
	@bookingXML XML = NULL
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRAN 
	BEGIN TRY
		
	DECLARE @hDoc INT
		IF @bookingXML IS NOT NULL
		BEGIN
			DECLARE @SavedBookingIDTable Table (OldBookingID INT, NewBookingID INT)
			DECLARE @SavedGuestIDTable Table (OldGuestID INT, NewGuestID INT)

			EXEC sp_xml_preparedocument @hDoc OUTPUT,@bookingXML	

			-- Start - Merge INTO Booking
		MERGE INTO 
		[Booking] AS [TargetBooking]
		USING 
			(
				SELECT 
						XMLTable.Id,  
						XMLTable.CheckinTime,  
						XMLTable.CheckoutTime,  
						XMLTable.NoOfAdult,  
						XMLTable.NoOfChild,  
						XMLTable.GuestRemarks,  
						XMLTable.TransactionRemarks,  
						XMLTable.IsActive,  
						XMLTable.CreatedBy,  
						XMLTable.CreatedOn,  
						XMLTable.LastUpdatedBy,  
						XMLTable.LastUpdatedOn
				FROM 
					OPENXML(@hDoc, 'Booking',2)
					WITH
					(
						Id int,  
						CheckinTime DateTime,  
						CheckoutTime DateTime,  
						NoOfAdult int,  
						NoOfChild int,  
						GuestRemarks nvarchar(200),  
						TransactionRemarks nvarchar(200),  
						IsActive bit,  
						CreatedBy nvarchar(200),  
						CreatedOn Datetime,  
						LastUpdatedBy nvarchar(200),  
						LastUpdatedOn DateTime
					) XMLTable		
			) AS [SourceBooking]
		ON [TargetBooking].ID = [SourceBooking].ID
		WHEN MATCHED THEN
		UPDATE 
			SET	
						
						 [TargetBooking].CheckinTime = [SourceBooking].CheckinTime
						,[TargetBooking].CheckoutTime = [SourceBooking].CheckoutTime  
						,[TargetBooking].NoOfAdult = [SourceBooking].NoOfAdult  
						,[TargetBooking].NoOfChild = [SourceBooking].NoOfChild
						,[TargetBooking].GuestRemarks = [SourceBooking].GuestRemarks  
						,[TargetBooking].TransactionRemarks = [SourceBooking].TransactionRemarks
						,[TargetBooking].IsActive = [SourceBooking].IsActive  
						,[TargetBooking].CreatedBy = [SourceBooking].CreatedBy
						,[TargetBooking].CreatedOn = [SourceBooking].CreatedOn 
						,[TargetBooking].LastUpdatedBy = [SourceBooking].LastUpdatedBy 
						,[TargetBooking].LastUpdatedOn = [SourceBooking].LastUpdatedOn
		WHEN NOT MATCHED THEN
		INSERT (		PropertyID,  
						CheckinTime,  
						CheckoutTime,  
						NoOfAdult,  
						NoOfChild,  
						GuestRemarks,  
						TransactionRemarks,  
						IsActive,  
						CreatedBy,  
						CreatedOn,  
						LastUpdatedBy,  
						LastUpdatedOn)
			VALUES 
				(
					@propertyID,
					[SourceBooking].CheckinTime,  
					[SourceBooking].CheckoutTime,  
					[SourceBooking].NoOfAdult,  
					[SourceBooking].NoOfChild,  
					[SourceBooking].GuestRemarks,  
					[SourceBooking].TransactionRemarks,  
					[SourceBooking].IsActive,  
					[SourceBooking].CreatedBy,  
					[SourceBooking].CreatedOn,  
					[SourceBooking].LastUpdatedBy,  
					[SourceBooking].LastUpdatedOn
				)

		 OUTPUT [SourceBooking].ID, inserted.ID INTO @SavedBookingIDTable(OldBookingID,NewBookingID);
		 
		MERGE INTO
		[Guest] AS [TargetGuest]
		USING 
			(
				SELECT 
						XMLTable.Id,  
						XMLTable.FirstName,  
						XMLTable.LastName,  
						XMLTable.MobileNumber,  
						XMLTable.EmailAddress,  
						XMLTable.DOB,  
						XMLTable.PhotoPath,    
						XMLTable.IsActive,  
						XMLTable.CreatedBy,  
						XMLTable.CreatedOn,  
						XMLTable.LastUpdatedBy,  
						XMLTable.LastUpdatedOn
				FROM 
					OPENXML(@hDoc, 'Booking/Guests/Guest',2)
					WITH
					(
						Id int,  
						FirstName nvarchar(200),  
						LastName nvarchar(200),  
						MobileNumber bigint,  
						EmailAddress nvarchar(500),  
						DOB Date,  
						PhotoPath nvarchar(200),  
						IsActive bit,  
						CreatedBy nvarchar(200),  
						CreatedOn Datetime,  
						LastUpdatedBy nvarchar(200),  
						LastUpdatedOn DateTime
					) XMLTable		
			) AS [SourceGuest]
		ON [TargetGuest].ID = [SourceGuest].ID
		WHEN MATCHED THEN
		UPDATE 
			SET	
						 [TargetGuest].FirstName = [SourceGuest].FirstName
						,[TargetGuest].LastName = [SourceGuest].LastName  
						,[TargetGuest].MobileNumber = [SourceGuest].MobileNumber  
						,[TargetGuest].EmailAddress = [SourceGuest].EmailAddress
						,[TargetGuest].DOB = [SourceGuest].DOB  
						,[TargetGuest].PhotoPath = [SourceGuest].PhotoPath
						,[TargetGuest].IsActive = [SourceGuest].IsActive  
						,[TargetGuest].CreatedBy = [SourceGuest].CreatedBy
						,[TargetGuest].CreatedOn = [SourceGuest].CreatedOn 
						,[TargetGuest].LastUpdatedBy = [SourceGuest].LastUpdatedBy 
						,[TargetGuest].LastUpdatedOn = [SourceGuest].LastUpdatedOn
		WHEN NOT MATCHED THEN
		INSERT (		  
						FirstName,  
						LastName,  
						MobileNumber,  
						EmailAddress,  
						DOB,  
						PhotoPath,    
						IsActive,  
						CreatedBy,  
						CreatedOn,  
						LastUpdatedBy,  
						LastUpdatedOn
						)
			VALUES 
				(
						[SourceGuest].FirstName,  
						[SourceGuest].LastName,  
						[SourceGuest].MobileNumber,  
						[SourceGuest].EmailAddress,  
						[SourceGuest].DOB,  
						[SourceGuest].PhotoPath,    
						[SourceGuest].IsActive,  
						[SourceGuest].CreatedBy,  
						[SourceGuest].CreatedOn,  
						[SourceGuest].LastUpdatedBy,  
						[SourceGuest].LastUpdatedOn
				)
		 OUTPUT [SourceGuest].ID, inserted.ID INTO @SavedGuestIDTable(OldGuestID,NewGuestID);
			 
		 MERGE INTO
		[Address] AS [TargetAddress]
		USING 
			(
				SELECT 
						XMLTable.Id,  
						XMLTable.AddressTypeID,  
						GuestID = case when (XMLTable.GuestID < 0) then  GuestIDTable.NewGuestID else XMLTable.GuestID end,
						XMLTable.Address1,  
						XMLTable.Address2,  
						XMLTable.City,  
						XMLTable.State,    
						XMLTable.ZipCode,
						XMLTable.Country,
						XMLTable.isActive,  
						XMLTable.CreatedBy,  
						XMLTable.CreatedOn,  
						XMLTable.LastUpdatedBy,  
						XMLTable.LastUpdatedOn
				FROM 
					OPENXML(@hDoc, 'Booking/Addresses/Address',2)
					WITH
					(
						Id int,  
						AddressTypeID int,  
						GuestID int,  
						Address1 nvarchar(200),
						Address2 nvarchar(200),
						City nvarchar(200), 
						State nvarchar(200),  
						ZipCode nvarchar(40),  
						Country nvarchar(200),
						IsActive bit,  
						CreatedBy nvarchar(200),  
						CreatedOn Datetime,  
						LastUpdatedBy nvarchar(200),  
						LastUpdatedOn DateTime
					) XMLTable
					LEFT OUTER JOIN
					@SavedGuestIDTable	AS GuestIDTable
					ON GuestIDTable.OldGuestID = XMLTable.GuestID		
			) AS [SourceAddress]
		ON [TargetAddress].ID = [SourceAddress].ID
		WHEN MATCHED THEN
		UPDATE 
			SET	
						 [TargetAddress].AddressTypeID =[SourceAddress].AddressTypeID   
						,[TargetAddress].GuestID = [SourceAddress].GuestID  
						,[TargetAddress].Address1 = [SourceAddress].Address1 
						,[TargetAddress].Address2 =  [SourceAddress].Address2
						,[TargetAddress].City = [SourceAddress].City 
						,[TargetAddress].State = [SourceAddress].State    
						,[TargetAddress].ZipCode = [SourceAddress].ZipCode
						,[TargetAddress].Country =[SourceAddress].Country
						,[TargetAddress].IsActive = [SourceAddress].IsActive  
						,[TargetAddress].CreatedBy = [SourceAddress].CreatedBy
						,[TargetAddress].CreatedOn = [SourceAddress].CreatedOn 
						,[TargetAddress].LastUpdatedBy = [SourceAddress].LastUpdatedBy 
						,[TargetAddress].LastUpdatedOn = [SourceAddress].LastUpdatedOn
		WHEN NOT MATCHED THEN
		INSERT (		  
						AddressTypeID,  
						GuestID,  
						Address1,
						Address2,
						City, 
						State,  
						ZipCode,  
						Country,
						IsActive,  
						CreatedBy,  
						CreatedOn,  
						LastUpdatedBy,  
						LastUpdatedOn
						)
			VALUES 
				(
						[SourceAddress].AddressTypeID,  
						[SourceAddress].GuestID,  
						[SourceAddress].Address1,
						[SourceAddress].Address2,
						[SourceAddress].City, 
						[SourceAddress].State,  
						[SourceAddress].ZipCode,  
						[SourceAddress].Country,
						[SourceAddress].IsActive,  
						[SourceAddress].CreatedBy,  
						[SourceAddress].CreatedOn,  
						[SourceAddress].LastUpdatedBy,  
						[SourceAddress].LastUpdatedOn
				);
		 
		MERGE INTO
		[RoomBooking] AS [TargetRoomBooking]
		USING 
			(
				SELECT 
						XMLTable.Id,
						GuestID = case when (XMLTable.GuestID < 0) then  GuestIDTable.NewGuestID else XMLTable.GuestID end,
						BookingId = case when (XMLTable.BookingId < 0) then  BookingIDTable.NewBookingID else XMLTable.BookingID end,
						XMLTable.RoomId, 
						XMLTable.IsExtra,  
						XMLTable.Discount,  
						XMLTable.RoomCharges,  
						XMLTable.IsActive,  
						XMLTable.CreatedBy,  
						XMLTable.CreatedOn,  
						XMLTable.LastUpdatedBy,  
						XMLTable.LastUpdatedOn
				FROM 
					OPENXML(@hDoc, 'Booking/RoomBookings/RoomBooking',2)
					WITH
					(
						Id int,  
						GuestID int,  
						BookingId int,  
						RoomId int,  
						IsExtra bit,  
						Discount decimal,  
						RoomCharges decimal,  
						IsActive bit,  
						CreatedBy nvarchar,  
						CreatedOn Datetime,  
						LastUpdatedBy nvarchar,  
						LastUpdatedOn DateTime
					) XMLTable
					LEFT Outer JOIN
					@SavedGuestIDTable	AS GuestIDTable
					ON GuestIDTable.OldGuestID = XMLTable.GuestID
					Left outer JOIN		
					@SavedBookingIDTable AS BookingIDTable
					ON BookingIDTable.OldBookingID = XMLTable.BookingId
			) AS [SourceRoomBooking]
		ON [TargetRoomBooking].ID = [SourceRoomBooking].ID
		WHEN MATCHED THEN
		UPDATE 
			SET	
			
						 [TargetRoomBooking].IsExtra = [SourceRoomBooking].IsExtra
						 ,[TargetRoomBooking].GuestID = [SourceRoomBooking].GuestID  
						 ,[TargetRoomBooking].RoomID = [SourceRoomBooking].RoomID  
						,[TargetRoomBooking].Discount = [SourceRoomBooking].Discount  
						,[TargetRoomBooking].RoomCharges = [SourceRoomBooking].RoomCharges  
						,[TargetRoomBooking].IsActive = [SourceRoomBooking].IsActive  
						,[TargetRoomBooking].CreatedBy = [SourceRoomBooking].CreatedBy
						,[TargetRoomBooking].CreatedOn = [SourceRoomBooking].CreatedOn 
						,[TargetRoomBooking].LastUpdatedBy = [SourceRoomBooking].LastUpdatedBy 
						,[TargetRoomBooking].LastUpdatedOn = [SourceRoomBooking].LastUpdatedOn
		WHEN NOT MATCHED THEN
		INSERT (		  
						GuestID ,  
						BookingID ,  
						RoomID ,  
						IsExtra ,  
						Discount ,  
						RoomCharges,    
						IsActive,  
						CreatedBy,  
						CreatedOn,  
						LastUpdatedBy,  
						LastUpdatedOn
						)
			VALUES 
				(
						[SourceRoomBooking].GuestID ,  
						[SourceRoomBooking].BookingID ,  
						[SourceRoomBooking].RoomID ,  
						[SourceRoomBooking].IsExtra ,  
						[SourceRoomBooking].Discount ,  
						[SourceRoomBooking].RoomCharges,    
						[SourceRoomBooking].IsActive,  
						[SourceRoomBooking].CreatedBy,  
						[SourceRoomBooking].CreatedOn,  
						[SourceRoomBooking].LastUpdatedBy,  
						[SourceRoomBooking].LastUpdatedOn
				);
				
	END
	COMMIT TRAN
	END TRY

    BEGIN CATCH
		ROLLBACK TRAN;
	END CATCH
    
    SET NOCOUNT OFF
END




