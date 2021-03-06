USE [master]
GO
/****** Object:  Database [PMS]    Script Date: 7/19/2017 2:40:12 PM ******/
CREATE DATABASE [PMS]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'PMS', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\PMS.mdf' , SIZE = 4096KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'PMS_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\PMS_log.ldf' , SIZE = 13632KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [PMS] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [PMS].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [PMS] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [PMS] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [PMS] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [PMS] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [PMS] SET ARITHABORT OFF 
GO
ALTER DATABASE [PMS] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [PMS] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [PMS] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [PMS] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [PMS] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [PMS] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [PMS] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [PMS] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [PMS] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [PMS] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [PMS] SET  DISABLE_BROKER 
GO
ALTER DATABASE [PMS] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [PMS] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [PMS] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [PMS] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [PMS] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [PMS] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [PMS] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [PMS] SET RECOVERY FULL 
GO
ALTER DATABASE [PMS] SET  MULTI_USER 
GO
ALTER DATABASE [PMS] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [PMS] SET DB_CHAINING OFF 
GO
ALTER DATABASE [PMS] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [PMS] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [PMS]
GO
/****** Object:  User [pmsadmin]    Script Date: 7/19/2017 2:40:12 PM ******/
CREATE USER [pmsadmin] FOR LOGIN [pmsadmin] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [pmsadmin]
GO
ALTER ROLE [db_accessadmin] ADD MEMBER [pmsadmin]
GO
ALTER ROLE [db_securityadmin] ADD MEMBER [pmsadmin]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [pmsadmin]
GO
ALTER ROLE [db_backupoperator] ADD MEMBER [pmsadmin]
GO
ALTER ROLE [db_datareader] ADD MEMBER [pmsadmin]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [pmsadmin]
GO
ALTER ROLE [db_denydatareader] ADD MEMBER [pmsadmin]
GO
ALTER ROLE [db_denydatawriter] ADD MEMBER [pmsadmin]
GO
/****** Object:  StoredProcedure [dbo].[GETALLBOOKINGS]    Script Date: 7/19/2017 2:40:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================        
-- Author:  Sachin Tyagi        
-- Create date: April 29, 2017        
-- Description: This stored procedure shall get the details of booking based on the checkin and checkoutdate        
-- =============================================        
--Exec GETALLBOOKINGS 1, '2017-05-26', '2017-06-13'
 
CREATE PROCEDURE [dbo].[GETALLBOOKINGS]        
 @PROPERTYID INT,        
 @CHECKINTIME DATETIME = NULL,        
 @CHECKOUTDATE DATETIME = NULL        
AS        
BEGIN        
      
IF(CONVERT(TIME,@CHECKOUTDATE)= '00:00:00.0000000')      
 set @CHECKOUTDATE = @CHECKOUTDATE + '23:59:59'      
      
SELECT         
  distinct BK.ID        
 ,BK.PROPERTYID        
 ,BK.CHECKINTIME        
 ,BK.CHECKOUTTIME        
 ,GUEST.FIRSTNAME        
 ,GUEST.LASTNAME      
 ,GUEST.ID AS GUESTID      
 ,RB.ID AS ROOMBOOKINGID      
 ,ROOM.ID AS ROOMID      
 ,ROOM.Number AS ROOMNUMBER      
       
 FROM BOOKING BK INNER JOIN ROOMBOOKING RB         
 ON BK.ID = RB.BOOKINGID        
 INNER JOIN Room      
 ON RB.RoomID = Room.ID      
 INNER JOIN GUEST        
 ON RB.GUESTID = GUEST.ID        
 WHERE (BK.CHECKINTIME >= ISNULL(@CHECKINTIME,'1900-01-01') AND BK.CHECKOUTTIME <= ISNULL(stuff(convert(varchar(19), @CHECKOUTDATE, 126),11,1,' '), GETDATE())) 
 OR  
  ((BK.CHECKINTIME <= ISNULL(@CHECKINTIME,'1900-01-01') and BK.CheckoutTime >= ISNULL(stuff(convert(varchar(19), @CHECKOUTDATE, 126),11,1,' '), GETDATE())))  
 OR  
 ((BK.CHECKINTIME <= ISNULL(@CHECKINTIME,'1900-01-01') and ((BK.CheckoutTime <= ISNULL(stuff(convert(varchar(19), @CHECKOUTDATE, 126),11,1,' '), GETDATE())) and BK.CheckoutTime >= ISNULL(@CHECKINTIME,'1900-01-01'))))
 OR  
 ((BK.CHECKINTIME <= ISNULL(@CHECKOUTDATE,'1900-01-01') and BK.CheckoutTime >= ISNULL(stuff(convert(varchar(19), @CHECKOUTDATE, 126),11,1,' '), GETDATE())))  
   
 AND BK.ISACTIVE=1        
END 
GO
/****** Object:  StoredProcedure [dbo].[GETALLGUESTS]    Script Date: 7/19/2017 2:40:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  Sachin Tyagi  
-- Create date: May 26, 2017  
-- Description: This stored procedure shall return all the guest details 
-- =============================================  
--Exec GETALLGUESTS
 
CREATE PROCEDURE [dbo].[GETALLGUESTS] 
AS  
BEGIN  


SELECT   
  ID  
 ,FIRSTNAME
 ,LASTNAME
 ,MOBILENUMBER
 ,EMAILADDRESS  
 ,DOB
 ,GENDER
 ,PHOTOPATH
 FROM GUEST
END
GO
/****** Object:  StoredProcedure [dbo].[GETBOOKINGAMOUNT]    Script Date: 7/19/2017 2:40:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================      
-- Author:  Sachin Tyagi      
-- Create date: June 04, 2017      
-- Description: This stored procedure shall return the amount of booking    
-- =============================================      
--Exec GETBOOKINGAMOUNT 1,1,1,2,0,1
     
CREATE PROC [dbo].[GETBOOKINGAMOUNT]      
@PROPERTYID INT,      
@ROOMTYPEID INT,      
@RATETYPEID INT,      
@NOOFHOURS INT = NULL,      
@NOOFDAYS INT,      
@ISHOURLY BIT      
AS BEGIN      
--CREATE TEMP TABLE TO HOLD THE KEY VALUE PAIR TO RETURN THE DETAIL OF THE INVOICE      
      
declare @TMPINVOICEDETAILS TABLE(  
ITEM NVARCHAR(100),      
ITEMAMOUNT MONEY,  
OrderBy int identity(1,1))   
                             
CREATE TABLE #TMPINVOICEDETAILS(      
ITEM NVARCHAR(100),      
ITEMAMOUNT MONEY)      
      
-- ROOM BOOKING AMOUNT      
INSERT INTO @TMPINVOICEDETAILS(ITEM, ITEMAMOUNT)      
SELECT TOP 1 'ROOM CHARGES'  
  ,Value    
  --,CASE WHEN (@ISHOURLY = 1) THEN  VALUE ELSE VALUE * @NOOFDAYS END        
  FROM RATES WHERE       
  PROPERTYID =@PROPERTYID AND       
  ROOMTYPEID = @ROOMTYPEID AND   
  (INPUTKEYHOURS IS NULL OR INPUTKEYHOURS = @NOOFHOURS)      
  
-- TAX DETAILS      
--INSERT INTO @TMPINVOICEDETAILS(ITEM, ITEMAMOUNT)      
--SELECT ALLTAXES.TAXSHORTNAME, TAXES.VALUE FROM TAXES INNER JOIN ALLTAXES ON      
--TAXES.TAXID = ALLTAXES.ID AND TAXES.PROPERTYID = @PROPERTYID      

INSERT INTO @TMPINVOICEDETAILS(ITEM, ITEMAMOUNT)      
SELECT TAXES.TaxName, TAXES.VALUE FROM TAXES WHERE PROPERTYID = @PROPERTYID AND IsActive = 1
      
SELECT ITEM,ITEMAMOUNT, OrderBy FROM @TMPINVOICEDETAILS      
      
END 
GO
/****** Object:  StoredProcedure [dbo].[GetBookingDetails]    Script Date: 7/19/2017 2:40:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================          
-- Author:  Sachin Tyagi          
-- Create date: June 13, 2017          
-- Description: This stored procedure shall return the complete information of booking based on the booking id.      
-- =============================================          
--Exec GetBokingDetails  50  
      
CREATE PROC [dbo].[GetBookingDetails]      
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
,Invoice.ID as InvoiceId  
,RoomType.ID as RoomTypeID  
,RoomType.NAME as RoomTypeName  
,RoomType.ShortName as RoomTypeShortName  
,Room.ID as RoomID  
,Room.Number as RoomNumber  
,Address.ID as AddressID  
,Address.AddressTypeID as AddressTypeID  
,Address.Address1 as Address1  
,Address.Address2 as Address2  
,Address.City as AddressCity  
,Address.State as AddressState  
,Address.ZipCode as AddressZipCode  
,Address.Country as AddressCountry  
FROM Booking       
LEFT OUTER JOIN      
AdditionalGuests      
ON Booking.ID = AdditionalGuests.BookingId       
LEFT OUTER JOIN      
RoomBooking      
ON Booking.ID = RoomBooking.BookingId  
LEFT OUTER JOIN      
Room   
ON RoomBooking.RoomID = Room.ID   
LEFT OUTER JOIN      
RoomType   
ON Room.RoomTypeID = RoomType.ID       
LEFT OUTER JOIN       
Guest       
ON RoomBooking.GuestID = Guest.ID    
LEFT OUTER JOIN       
Address       
ON Address.GuestID = Guest.ID    
LEFT OUTER JOIN    
GuestMapping    
on Guest.ID = GuestMapping.GuestID    
Left Outer Join  
Invoice  
on Invoice.BookingID = Booking.ID  
WHERE Booking.ID= @BookingID  
      
END    
  
GO
/****** Object:  StoredProcedure [dbo].[GETGUESTTRANSACTIONS]    Script Date: 7/19/2017 2:40:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================    
-- Author:  Sachin Tyagi    
-- Create date: MAY 13, 2017    
-- Description: This stored procedure shall return the histroy of guest transaction
-- Exec [GETGUESTTRANSACTIONS] 44
-- =============================================    
CREATE PROCEDURE [dbo].[GETGUESTTRANSACTIONS]
	@GUESTID INT    
 AS    
BEGIN    
  
WITH ROOMBOOKING_CTE(ROOMBOOKINGID, BOOKINGID, ROOMID, PropertyID)  
AS  
(  
SELECT   
 ROOMBOOKING.ID,   
 BOOKING.ID,
 ROOMID,
 BOOKING.PROPERTYID
FROM ROOMBOOKING  
  
INNER JOIN   
BOOKING ON  
BOOKING.ID = ROOMBOOKING.BOOKINGID   
WHERE  ROOMBOOKING.GUESTID = @GUESTID 
) 
 
SELECT DISTINCT  
PROPERTY.PROPERTYDETAILS AS PROPERTY,
Booking.CheckinTime,
Booking.CheckoutTime,  
RoomType.Name AS ROOMTYPE,
Room.Number AS ROOMNUMBER
FROM PROPERTY  
Inner join 
ROOMBOOKING_CTE ON  
ROOMBOOKING_CTE.PropertyID = PROPERTY.ID
INNER JOIN
BOOKING ON 
ROOMBOOKING_CTE.BOOKINGID = BOOKING.ID
INNER JOIN
ROOM ON
ROOM.ID = ROOMBOOKING_CTE.ROOMID
INNER JOIN
RoomType ON
ROOM.ROOMTYPEID = RoomType.ID
END  
GO
/****** Object:  StoredProcedure [dbo].[GETINVOICEDETAILS]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================    
-- Author:  Sachin Tyagi    
-- Create date: June 13, 2017    
-- Description: This stored procedure shall return the complete information of invoice.
-- =============================================    
--Exec GETINVOICEDETAILS 20 

CREATE PROC [dbo].[GETINVOICEDETAILS]
@INVOICEID INT
AS BEGIN
SELECT INVOICE.ID as InvoiceId
, Invoice.GuestID
, Invoice.BookingID
, Invoice.IsPaid
, Invoice.TotalAmount
, Invoice.FolioNumber
, Invoice.IsActive as InvoiceActive
, Invoice.CreatedBy
, Invoice.CreatedOn
, Invoice.LastUpdatedBy
, Invoice.LastUpdatedOn
, Invoice.DISCOUNT
, InvoiceItems.ItemName
, InvoiceItems.ItemValue
, INVOICEPAYMENTDETAILS.PaymentMode
, INVOICEPAYMENTDETAILS.PaymentValue
, INVOICEPAYMENTDETAILS.PaymentDetails
, INVOICETAXDETAIL.TaxShortName
, INVOICETAXDETAIL.TaxAmount
FROM 
INVOICE 
LEFT OUTER JOIN 
INVOICEITEMS 
ON INVOICE.ID = INVOICEITEMS.INVOICEID
LEFT OUTER JOIN
INVOICETAXDETAIL
ON INVOICE.ID = INVOICETAXDETAIL.INVOICEID 
LEFT OUTER JOIN
INVOICEPAYMENTDETAILS
ON INVOICE.ID = INVOICEPAYMENTDETAILS.INVOICEID
WHERE INVOICE.ID= @INVOICEID
END
GO
/****** Object:  StoredProcedure [dbo].[GetRoomRates]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetRoomRates]
@PropertyId INT
AS BEGIN

Select 
Rates.ID
,Rates.Type
,Rates.PropertyID
,Rates.RateTypeID
,Rates.RoomTypeID
,Rates.RoomId
,Rates.InputKeyHours
,Rates.Value
,Rates.IsActive
,Rates.CreatedBy
,Rates.CreatedOn
,Rates.LastUpdatedBy
,Rates.LastUpdatedOn
,RoomType.NAME as RoomTypeName
,RateType.NAME as RateTypeName
,RateType.ID as MasterRateTypeID
,RateType.IsActive as RateTypeIsActive
,RateType.Units
,Room.Number as RoomNumber
,PropertyFloor.FloorNumber as FloorNumber
,PropertyFloor.ID as FloorId
,RateType.Hours as Hours
from RateType 
left outer join
Rates on
RateType.ID = Rates.RateTypeID
left outer join
RoomType on
Rates.RoomTypeID = RoomType.ID
left outer join
Room on
Room.ID = Rates.RoomId
left outer join
PropertyFloor on
Room.FloorId = PropertyFloor.ID
where RateType.PropertyID = @PropertyId
and (RateType.IsActive = 1 or RateType.IsActive is null)
End



GO
/****** Object:  StoredProcedure [dbo].[GETROOMSTATUS]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================    
-- Author:  Sachin Tyagi    
-- Create date: MAY 06, 2017    
-- Description: This stored procedure shall get the status of the room based on the checkin and checkout date  
-- =============================================    
--Exec GETROOMSTATUS 1, '2017-05-15 21:24:34.000', '2017-06-18 21:24:34.000','1'  
    
CREATE PROCEDURE [dbo].[GETROOMSTATUS]    
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
GO
/****** Object:  StoredProcedure [dbo].[InsertBooking]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertBooking]                
 @propertyID INT,                
 @bookingXML XML = NULL,     
 @BOOKINGID INT OUTPUT,  
 @GUESTID INT OUTPUT               
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
   DECLARE @SavedGuestMappingIDTable Table(OldGuestMappingID INT, NewGuestMappingID INT)              
                
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
      XMLTable.ISHOURLYCHECKIN,      
      XMLTable.HOURSTOSTAY,                 
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
      ISHOURLYCHECKIN bit,      
      HOURSTOSTAY int,      
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
      ,[TargetBooking].ISHOURLYCHECKIN = [SourceBooking].ISHOURLYCHECKIN                
      ,[TargetBooking].HOURSTOSTAY = [SourceBooking].HOURSTOSTAY                
      ,[TargetBooking].IsActive = [SourceBooking].IsActive                  
      ,[TargetBooking].CreatedBy = [SourceBooking].CreatedBy                
      ,[TargetBooking].CreatedOn = [SourceBooking].CreatedOn                 
      ,[TargetBooking].LastUpdatedBy = [SourceBooking].LastUpdatedBy                 
      ,[TargetBooking].LastUpdatedOn = [SourceBooking].LastUpdatedOn                
      ,@BOOKINGID = [SourceBooking].ID  
  WHEN NOT MATCHED THEN                
  INSERT (  PropertyID,                  
      CheckinTime,                  
      CheckoutTime,                  
      NoOfAdult,                  
      NoOfChild,                  
      GuestRemarks,                  
      TransactionRemarks,      
      ISHOURLYCHECKIN,                  
      HOURSTOSTAY,      
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
     [SourceBooking].ISHOURLYCHECKIN,      
     [SourceBooking].HOURSTOSTAY,      
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
      XMLTable.Gender,                  
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
      Gender nvarchar(10),                  
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
      ,[TargetGuest].Gender = [SourceGuest].Gender                  
      ,[TargetGuest].PhotoPath = [SourceGuest].PhotoPath                
      ,[TargetGuest].IsActive = [SourceGuest].IsActive                  
      ,[TargetGuest].CreatedBy = [SourceGuest].CreatedBy                
      ,[TargetGuest].CreatedOn = [SourceGuest].CreatedOn                 
      ,[TargetGuest].LastUpdatedBy = [SourceGuest].LastUpdatedBy                 
      ,[TargetGuest].LastUpdatedOn = [SourceGuest].LastUpdatedOn                
      ,@GUESTID = [SourceGuest].Id  
  WHEN NOT MATCHED THEN                
  INSERT (                    
      FirstName,                  
      LastName,                  
      MobileNumber,                  
      EmailAddress,                  
      DOB,        
      Gender,                  
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
      [SourceGuest].Gender,                  
      [SourceGuest].PhotoPath,                    
      [SourceGuest].IsActive,                  
      [SourceGuest].CreatedBy,                
      [SourceGuest].CreatedOn,                  
      [SourceGuest].LastUpdatedBy,                  
      [SourceGuest].LastUpdatedOn                
    )                
   OUTPUT [SourceGuest].ID, inserted.ID INTO @SavedGuestIDTable(OldGuestID,NewGuestID);                
                 
                    
  MERGE INTO                
  [GuestMapping] AS [TargetGuestMapping]                
  USING                 
   (        
    SELECT                 
      XMLTable.Id,                  
      XMLTable.IDTYPEID,                  
      GuestID = case when (XMLTable.GuestID < 0) then  GuestIDTable.NewGuestID else XMLTable.GuestID end,              
      XMLTable.IDDETAILS,              
      XMLTable.IdExpiryDate,              
      XMLTable.IdIssueState,              
      XMLTable.IdIssueCountry,                  
      XMLTable.IsActive,                  
      XMLTable.CreatedBy,                  
      XMLTable.CreatedOn,                  
      XMLTable.LastUpdatedBy,                  
      XMLTable.LastUpdatedOn                
    FROM                 
     OPENXML(@hDoc, 'Booking/GuestMappings/GuestMapping',2)                
     WITH                
     (                
      Id int,                  
      IDTYPEID int,                  
      GUESTID int,               
      IDDETAILS nvarchar(max),                 
      IdExpiryDate DateTime,              
      IdIssueState nvarchar(100),              
      IdIssueCountry nvarchar(100),              
      IsActive bit,                  
      CreatedBy nvarchar(200),                  
      CreatedOn Datetime,                  
      LastUpdatedBy nvarchar(200),                  
      LastUpdatedOn DateTime                
     ) XMLTable                
     LEFT OUTER JOIN                
     @SavedGuestIDTable AS GuestIDTable                
     ON GuestIDTable.OldGuestID = XMLTable.GuestID              
   ) AS [SourceGuestMapping]                
  ON [TargetGuestMapping].ID = [SourceGuestMapping].ID                
  WHEN MATCHED THEN                
  UPDATE                 
   SET                 
       [TargetGuestMapping].IDTYPEID = [SourceGuestMapping].IDTYPEID                
      ,[TargetGuestMapping].GUESTID = [SourceGuestMapping].GUESTID                  
      ,[TargetGuestMapping].IDDETAILS = [SourceGuestMapping].IDDETAILS               
      ,[TargetGuestMapping].IdExpiryDate = [SourceGuestMapping].IdExpiryDate               
      ,[TargetGuestMapping].IdIssueState = [SourceGuestMapping].IdIssueState               
      ,[TargetGuestMapping].IdIssueCountry = [SourceGuestMapping].IdIssueCountry                  
      ,[TargetGuestMapping].IsActive = [SourceGuestMapping].IsActive                  
      ,[TargetGuestMapping].CreatedBy = [SourceGuestMapping].CreatedBy                
      ,[TargetGuestMapping].CreatedOn = [SourceGuestMapping].CreatedOn                 
      ,[TargetGuestMapping].LastUpdatedBy = [SourceGuestMapping].LastUpdatedBy                 
      ,[TargetGuestMapping].LastUpdatedOn = [SourceGuestMapping].LastUpdatedOn                
  WHEN NOT MATCHED THEN                
  INSERT (                    
      IDTYPEID,                  
      GUESTID,                  
      IDDETAILS,               
      IdExpiryDate,              
      IdIssueState,              
      IdIssueCountry,                 
      IsActive,                  
      CreatedBy,                  
      CreatedOn,                  
      LastUpdatedBy,                  
      LastUpdatedOn                
      )     
   VALUES                 
    (                
      [SourceGuestMapping].IDTYPEID,                  
      [SourceGuestMapping].GUESTID,                  
      [SourceGuestMapping].IDDETAILS,              
      [SourceGuestMapping].IdExpiryDate,              
      [SourceGuestMapping].IdIssueState,              
      [SourceGuestMapping].IdIssueCountry,                  
      [SourceGuestMapping].IsActive,                  
      [SourceGuestMapping].CreatedBy,                  
      [SourceGuestMapping].CreatedOn,                  
      [SourceGuestMapping].LastUpdatedBy,                  
      [SourceGuestMapping].LastUpdatedOn                
    )                
   OUTPUT [SourceGuestMapping].ID, inserted.ID INTO @SavedGuestMappingIDTable(OldGuestMappingID,NewGuestMappingID);                
   
   
               
   MERGE INTO                
  [AdditionalGuests] AS [TargetAdditionalGuests]                
  USING                 
   (                
    SELECT                 
      XMLTable.Id, 
      BookingId = case when (XMLTable.BookingId < 0) then  BookingIDTable.NewBookingID else XMLTable.BookingId end,           
      XMLTable.FirstName,              
      XMLTable.LastName,              
      XMLTable.GUESTIDPath,              
      XMLTable.IsActive,                  
      XMLTable.CreatedBy,                  
      XMLTable.CreatedOn,                  
      XMLTable.LastUpdatedBy,                  
      XMLTable.LastUpdatedOn                
    FROM                 
     OPENXML(@hDoc, 'Booking/AdditionalGuests/AdditionalGuest',2)                
     WITH                
     (                
      Id int,                  
      BookingId int,                  
      FirstName nvarchar(100),                 
      LastName nvarchar(100),              
      GUESTIDPath nvarchar(max),              
      IsActive bit,                  
      CreatedBy nvarchar(200),                  
      CreatedOn Datetime,                  
      LastUpdatedBy nvarchar(200),                  
      LastUpdatedOn DateTime                
     ) XMLTable                
     LEFT OUTER JOIN                
     @SavedBookingIDTable AS BookingIDTable                
     ON BookingIDTable.OldBookingID = XMLTable.BookingId           
   ) AS [SourceAdditionalGuests]                
  ON [TargetAdditionalGuests].ID = [SourceAdditionalGuests].ID                
  WHEN MATCHED THEN                
  UPDATE                 
   SET                 
       [TargetAdditionalGuests].FirstName = [SourceAdditionalGuests].FirstName                
      ,[TargetAdditionalGuests].LastName = [SourceAdditionalGuests].LastName                  
      ,[TargetAdditionalGuests].GUESTIDPath = [SourceAdditionalGuests].GUESTIDPath               
      ,[TargetAdditionalGuests].IsActive = [SourceAdditionalGuests].IsActive                  
      ,[TargetAdditionalGuests].CreatedBy = [SourceAdditionalGuests].CreatedBy                
      ,[TargetAdditionalGuests].CreatedOn = [SourceAdditionalGuests].CreatedOn                 
      ,[TargetAdditionalGuests].LastUpdatedBy = [SourceAdditionalGuests].LastUpdatedBy                 
      ,[TargetAdditionalGuests].LastUpdatedOn = [SourceAdditionalGuests].LastUpdatedOn                
  WHEN NOT MATCHED THEN                
  INSERT (                    
      BookingID,                  
      FirstName,                  
      LastName,               
      GUESTIDPath,              
      IsActive,                  
      CreatedBy,                  
      CreatedOn,                  
      LastUpdatedBy,                  
      LastUpdatedOn                
      )                
   VALUES                 
    (                
      [SourceAdditionalGuests].BookingID,                  
      [SourceAdditionalGuests].FirstName,                  
      [SourceAdditionalGuests].LastName,              
      [SourceAdditionalGuests].GUESTIDPath,              
      [SourceAdditionalGuests].IsActive,                  
      [SourceAdditionalGuests].CreatedBy,                  
      [SourceAdditionalGuests].CreatedOn,                  
      [SourceAdditionalGuests].LastUpdatedBy,                  
      [SourceAdditionalGuests].LastUpdatedOn                
    ) ;              
   --OUTPUT [SourceGuestMapping].ID, inserted.ID INTO @SavedGuestMappingIDTable(OldGuestMappingID,NewGuestMappingID);                
                    
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
     @SavedGuestIDTable AS GuestIDTable                
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
      CreatedBy nvarchar(200),                  
      CreatedOn Datetime,                  
      LastUpdatedBy nvarchar(200),                  
      LastUpdatedOn DateTime                
     ) XMLTable                
     LEFT Outer JOIN                
     @SavedGuestIDTable AS GuestIDTable                
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
      
    IF(@BOOKINGID IS NULL)    
    Begin  
     SELECT TOP 1 @BOOKINGID = NEWBOOKINGID FROM @SAVEDBOOKINGIDTABLE  
    End  
      
    IF(@GUESTID IS NULL)    
    Begin  
     SELECT TOP 1 @GUESTID = NewGuestID FROM @SavedGuestIDTable  
    End  
      
      
    Select @BOOKINGID, @GUESTID  
    --Print @GUESTID  
    --SELECT TOP 1 @BOOKINGID = NEWBOOKINGID FROM @SAVEDBOOKINGIDTABLE    
                    
 END                
 COMMIT TRAN                
 END TRY                
                
    BEGIN CATCH                
  ROLLBACK TRAN;                
 END CATCH                
                    
    SET NOCOUNT OFF                
END                  
GO
/****** Object:  StoredProcedure [dbo].[InsertInvoice]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
CREATE PROCEDURE [dbo].[InsertInvoice]                    
 @propertyID INT,                    
 @InvoiceXML XML = NULL, 
 @INVOICEID INT OUTPUT                    
AS                    
BEGIN                    
 SET NOCOUNT ON                    
 BEGIN TRAN                     
 BEGIN TRY                    
                      
 DECLARE @hDoc INT                    
  IF @InvoiceXML IS NOT NULL                    
  BEGIN                    
   DECLARE @SavedInvoiceIDTable Table (OldInvoiceID INT, NewInvoiceID INT)                    
   --DECLARE @SavedGuestIDTable Table (OldGuestID INT, NewGuestID INT)                    
   --DECLARE @SavedGuestMappingIDTable Table(OldGuestMappingID INT, NewGuestMappingID INT)                  
                    
   EXEC sp_xml_preparedocument @hDoc OUTPUT,@InvoiceXML                     
                    
   -- Start - Merge INTO Invoice                    
  MERGE INTO                     
  [Invoice] AS [TargetInvoice]                    
  USING                     
   (                    
    SELECT                     
      XMLTable.Id,                      
      XMLTable.BookingId,      
      XMLTable.GuestId,                      
      XMLTable.IsPaid,                      
      XMLTable.TotalAmount,                      
      XMLTable.FolioNumber,                      
      XMLTable.Discount,                      
      XMLTable.IsActive,                      
      XMLTable.CreatedBy,                      
      XMLTable.CreatedOn,                      
      XMLTable.LastUpdatedBy,                      
      XMLTable.LastUpdatedOn                    
    FROM                     
     OPENXML(@hDoc, 'Invoice',2)                    
     WITH                    
     (                    
      Id int,                      
      BookingId int,                      
      GuestId int,                      
      IsPaid bit,                      
      TotalAmount money,                      
      FolioNumber nvarchar(200),                      
      Discount money,                      
      IsActive bit,                      
      CreatedBy nvarchar(200),                      
      CreatedOn Datetime,                      
      LastUpdatedBy nvarchar(200),                      
      LastUpdatedOn DateTime                    
     ) XMLTable                      
   ) AS [SourceInvoice]                    
  ON [TargetInvoice].ID = [SourceInvoice].ID                    
  WHEN MATCHED THEN                    
  UPDATE                     
   SET                     
      [TargetInvoice].GuestID = [SourceInvoice].GuestID                      
      ,[TargetInvoice].BookingID = [SourceInvoice].BookingID                      
      ,[TargetInvoice].IsPaid = [SourceInvoice].IsPaid                    
      ,[TargetInvoice].TotalAmount = [SourceInvoice].TotalAmount                      
      ,[TargetInvoice].FolioNumber = [SourceInvoice].FolioNumber       
      ,[TargetInvoice].Discount = [SourceInvoice].Discount                    
      ,[TargetInvoice].IsActive = [SourceInvoice].IsActive                      
      ,[TargetInvoice].CreatedBy = [SourceInvoice].CreatedBy                    
      ,[TargetInvoice].CreatedOn = [SourceInvoice].CreatedOn                     
      ,[TargetInvoice].LastUpdatedBy = [SourceInvoice].LastUpdatedBy                     
      ,[TargetInvoice].LastUpdatedOn = [SourceInvoice].LastUpdatedOn                    
      ,@INVOICEID = [SourceInvoice].ID
  WHEN NOT MATCHED THEN                    
  INSERT (                      
      GuestID,                      
      BookingID,                      
      IsPaid,                      
      TotalAmount,                      
      FolioNumber,                      
      Discount,          
      IsActive,                      
      CreatedBy,                      
      CreatedOn,                      
      LastUpdatedBy,                      
      LastUpdatedOn)         
   VALUES                     
    (                    
     [SourceInvoice].GuestID,                      
     [SourceInvoice].BookingID,                      
     [SourceInvoice].IsPaid,                      
     [SourceInvoice].TotalAmount,                      
     [SourceInvoice].FolioNumber,           
     [SourceInvoice].Discount,                      
     [SourceInvoice].IsActive,                      
     [SourceInvoice].CreatedBy,                      
     [SourceInvoice].CreatedOn,                      
     [SourceInvoice].LastUpdatedBy,                      
     [SourceInvoice].LastUpdatedOn                    
    )                    
   OUTPUT [SourceInvoice].ID, inserted.ID INTO @SavedInvoiceIDTable(OldInvoiceID,NewInvoiceID);                    
 
   IF(@INVOICEID is null)
   BEGIN
    SELECT @INVOICEID = NewInvoiceID FROM @SavedInvoiceIDTable      
   END 
         
   DELETE FROM INVOICEITEMS WHERE INVOICEID=@INVOICEID      
   DELETE FROM INVOICETAXDETAIL WHERE INVOICEID=@INVOICEID      
   DELETE FROM INVOICEPAYMENTDETAILS WHERE INVOICEID=@INVOICEID      
                       
  MERGE INTO                    
  [InvoiceItems] AS [TargetInvoiceItems]                    
  USING                     
   (                    
    SELECT                     
      XMLTable.Id,                      
      InvoiceId = case when (XMLTable.InvoiceId < 0) then  InvoiceIDTable.NewInvoiceID else XMLTable.InvoiceID end,                  
      XMLTable.ItemName,                      
      XMLTable.ItemValue,                      
      XMLTable.IsActive,                      
      XMLTable.CreatedBy,                      
      XMLTable.CreatedOn,                      
      XMLTable.LastUpdatedBy,                      
      XMLTable.LastUpdatedOn                    
    FROM                     
     OPENXML(@hDoc, 'Invoice/InvoiceItems/InvoiceItem',2)                    
     WITH                    
     (                    
      Id int,      
      InvoiceId int,                      
      ItemName nvarchar(200),                      
      ItemValue nvarchar(200),                      
      IsActive bit,                      
      CreatedBy nvarchar(200),                      
      CreatedOn Datetime,                      
      LastUpdatedBy nvarchar(200),                      
      LastUpdatedOn DateTime                    
     ) XMLTable      
      LEFT OUTER JOIN                    
     @SavedInvoiceIDTable AS InvoiceIDTable                    
     ON InvoiceIDTable.OldInvoiceID = XMLTable.InvoiceID                       
   ) AS [SourceInvoiceItems]                    
  ON [TargetInvoiceItems].ID = [SourceInvoiceItems].ID                    
  WHEN MATCHED THEN                    
  UPDATE                     
   SET                     
       [TargetInvoiceItems].ItemName = [SourceInvoiceItems].ItemName                    
      ,[TargetInvoiceItems].ItemValue = [SourceInvoiceItems].ItemValue                      
      ,[TargetInvoiceItems].IsActive = [SourceInvoiceItems].IsActive                      
      ,[TargetInvoiceItems].CreatedBy = [SourceInvoiceItems].CreatedBy                    
      ,[TargetInvoiceItems].CreatedOn = [SourceInvoiceItems].CreatedOn                     
      ,[TargetInvoiceItems].LastUpdatedBy = [SourceInvoiceItems].LastUpdatedBy                     
      ,[TargetInvoiceItems].LastUpdatedOn = [SourceInvoiceItems].LastUpdatedOn                    
  WHEN NOT MATCHED THEN                    
  INSERT (                        
      InvoiceId,                      
      ItemName,                      
      ItemValue,                      
      IsActive,                      
      CreatedBy,                      
      CreatedOn,                      
      LastUpdatedBy,                      
      LastUpdatedOn                    
      )                    
   VALUES                     
    (                    
      [SourceInvoiceItems].InvoiceId,                      
      [SourceInvoiceItems].ItemName,                      
      [SourceInvoiceItems].ItemValue,                
      [SourceInvoiceItems].IsActive,                      
      [SourceInvoiceItems].CreatedBy,                      
      [SourceInvoiceItems].CreatedOn,                      
      [SourceInvoiceItems].LastUpdatedBy,                      
      [SourceInvoiceItems].LastUpdatedOn                    
    );      
        
    --select * from [SourceInvoiceItems]    
    --select * from invoiceitems    
          
  MERGE INTO                    
  [InvoiceTaxDetail] AS [TargetInvoiceTaxDetail]                    
  USING                     
   (                    
    SELECT                     
      XMLTable.Id,                      
      InvoiceId = case when (XMLTable.InvoiceId < 0) then  InvoiceIDTable.NewInvoiceID else XMLTable.InvoiceID end,                  
      XMLTable.TaxShortName,                      
      XMLTable.TaxAmount,            
      XMLTable.IsActive,                      
      XMLTable.CreatedBy,                      
      XMLTable.CreatedOn,                      
      XMLTable.LastUpdatedBy,                      
      XMLTable.LastUpdatedOn                    
    FROM                     
     OPENXML(@hDoc, 'Invoice/InvoiceTaxDetails/InvoiceTaxDetail',2)                    
     WITH                    
     (                    
      Id int,      
      InvoiceId int,                      
      TaxShortName nvarchar(max),                      
      TaxAmount money,                      
      IsActive bit,                      
      CreatedBy nvarchar(200),                      
      CreatedOn Datetime,                      
      LastUpdatedBy nvarchar(200),                      
      LastUpdatedOn DateTime                    
     ) XMLTable      
      LEFT OUTER JOIN                    
     @SavedInvoiceIDTable AS InvoiceIDTable                    
     ON InvoiceIDTable.OldInvoiceID = XMLTable.InvoiceID                       
   ) AS [SourceInvoiceTaxDetail]                    
  ON [TargetInvoiceTaxDetail].ID = [SourceInvoiceTaxDetail].ID                    
  WHEN MATCHED THEN                    
  UPDATE                     
   SET                     
       [TargetInvoiceTaxDetail].TaxShortName = [SourceInvoiceTaxDetail].TaxShortName                    
      ,[TargetInvoiceTaxDetail].TaxAmount = [SourceInvoiceTaxDetail].TaxAmount                      
      ,[TargetInvoiceTaxDetail].IsActive = [SourceInvoiceTaxDetail].IsActive                      
      ,[TargetInvoiceTaxDetail].CreatedBy = [SourceInvoiceTaxDetail].CreatedBy                    
      ,[TargetInvoiceTaxDetail].CreatedOn = [SourceInvoiceTaxDetail].CreatedOn                     
      ,[TargetInvoiceTaxDetail].LastUpdatedBy = [SourceInvoiceTaxDetail].LastUpdatedBy                     
      ,[TargetInvoiceTaxDetail].LastUpdatedOn = [SourceInvoiceTaxDetail].LastUpdatedOn                    
  WHEN NOT MATCHED THEN                    
  INSERT (                        
      InvoiceId,                      
      TaxShortName,                      
      TaxAmount,                      
      IsActive,                      
      CreatedBy,                      
      CreatedOn,                      
      LastUpdatedBy,                      
      LastUpdatedOn                    
      )                    
   VALUES                     
    (                    
      [SourceInvoiceTaxDetail].InvoiceId,                      
      [SourceInvoiceTaxDetail].TaxShortName,                      
      [SourceInvoiceTaxDetail].TaxAmount,                      
      [SourceInvoiceTaxDetail].IsActive,                      
      [SourceInvoiceTaxDetail].CreatedBy,                      
      [SourceInvoiceTaxDetail].CreatedOn,                      
      [SourceInvoiceTaxDetail].LastUpdatedBy,                      
      [SourceInvoiceTaxDetail].LastUpdatedOn                    
    );      
        
    --select * from [SourceInvoiceTaxDetail]    
    --select * from [InvoiceTaxDetail]    
              
  MERGE INTO                    
  [InvoicePaymentDetails] AS [TargetInvoicePaymentDetails]                    
  USING                     
   (                    
    SELECT                     
      XMLTable.Id,                      
      InvoiceId = case when (XMLTable.InvoiceId < 0) then  InvoiceIDTable.NewInvoiceID else XMLTable.InvoiceID end,                  
      XMLTable.PaymentMode,      
      XMLTable.PaymentValue,      
      XMLTable.PaymentDetails,                      
      XMLTable.IsActive,                      
      XMLTable.CreatedBy,                      
      XMLTable.CreatedOn,                      
      XMLTable.LastUpdatedBy,                      
      XMLTable.LastUpdatedOn                    
    FROM                     
     OPENXML(@hDoc, 'Invoice/InvoicePaymentDetails/InvoicePaymentDetail',2)                    
     WITH                    
     (                    
      Id int,      
      InvoiceId int,                      
      PaymentMode nvarchar(max),                      
      PaymentValue money,                      
      PaymentDetails nvarchar(max),      
      IsActive bit,                      
      CreatedBy nvarchar(200),                      
      CreatedOn Datetime,                      
      LastUpdatedBy nvarchar(200),                      
      LastUpdatedOn DateTime                    
     ) XMLTable      
      LEFT OUTER JOIN                    
     @SavedInvoiceIDTable AS InvoiceIDTable                    
     ON InvoiceIDTable.OldInvoiceID = XMLTable.InvoiceID                       
   ) AS [SourceInvoicePaymentDetails]                    
  ON [TargetInvoicePaymentDetails].ID = [SourceInvoicePaymentDetails].ID                    
  WHEN MATCHED THEN                    
  UPDATE                     
   SET                     
       [TargetInvoicePaymentDetails].PaymentMode = [SourceInvoicePaymentDetails].PaymentMode                    
      ,[TargetInvoicePaymentDetails].PaymentValue = [SourceInvoicePaymentDetails].PaymentValue      
      ,[TargetInvoicePaymentDetails].PaymentDetails = [SourceInvoicePaymentDetails].PaymentDetails                      
      ,[TargetInvoicePaymentDetails].IsActive = [SourceInvoicePaymentDetails].IsActive                      
      ,[TargetInvoicePaymentDetails].CreatedBy = [SourceInvoicePaymentDetails].CreatedBy                    
      ,[TargetInvoicePaymentDetails].CreatedOn = [SourceInvoicePaymentDetails].CreatedOn                     
      ,[TargetInvoicePaymentDetails].LastUpdatedBy = [SourceInvoicePaymentDetails].LastUpdatedBy                     
      ,[TargetInvoicePaymentDetails].LastUpdatedOn = [SourceInvoicePaymentDetails].LastUpdatedOn                    
  WHEN NOT MATCHED THEN                    
  INSERT (                        
      InvoiceId,       
      PaymentMode,       
      PaymentValue,      
      PaymentDetails,                    
      IsActive,                      
      CreatedBy,                      
      CreatedOn,                      
      LastUpdatedBy,                      
      LastUpdatedOn                    
      )                    
   VALUES                     
    (                    
      [SourceInvoicePaymentDetails].InvoiceId,                      
      [SourceInvoicePaymentDetails].PaymentMode,                      
      [SourceInvoicePaymentDetails].PaymentValue,      
      [SourceInvoicePaymentDetails].PaymentDetails,                      
      [SourceInvoicePaymentDetails].IsActive,                      
      [SourceInvoicePaymentDetails].CreatedBy,                      
      [SourceInvoicePaymentDetails].CreatedOn,                      
      [SourceInvoicePaymentDetails].LastUpdatedBy,                      
      [SourceInvoicePaymentDetails].LastUpdatedOn                    
    ) ;  
    
    SELECT @INVOICEID    
 END                    
 COMMIT TRAN                    
 END TRY                    
                    
    BEGIN CATCH                    
  ROLLBACK TRAN;                    
 END CATCH                    
                        
    SET NOCOUNT OFF                    
END  
GO
/****** Object:  StoredProcedure [dbo].[InsertRoom]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[InsertRoom]                        
 @propertyID INT,                        
 @RoomXML XML = NULL  
             
AS                        
BEGIN                        
 SET NOCOUNT ON                        
 BEGIN TRAN                         
 BEGIN TRY                        
                          
 DECLARE @hDoc INT                        
  IF @RoomXML IS NOT NULL                        
  BEGIN                        
   DECLARE @SavedRoomIDTable Table (OldRoomID INT, NewRoomID INT)                        
   EXEC sp_xml_preparedocument @hDoc OUTPUT,@RoomXML    
     
  MERGE INTO                         
  [Room] AS [TargetRoom]                        
  USING                         
   (                        
    SELECT                         
      XMLTable.Id,                          
      XMLTable.RoomTypeId,          
      XMLTable.Number,                          
      XMLTable.IsActive,                          
      XMLTable.CreatedBy,                          
      XMLTable.CreatedOn,                          
      XMLTable.LastUpdatedBy,                          
      XMLTable.LastUpdatedOn,
	  XMLTable.FloorId                       
    FROM                         
     OPENXML(@hDoc, 'Rooms/Room',2)                        
     WITH                        
     (                        
      Id int,                          
      RoomTypeId int,                          
      Number nvarchar(200),                          
      IsActive bit,                          
      CreatedBy nvarchar(200),                          
      CreatedOn Datetime,                          
      LastUpdatedBy nvarchar(200),                          
      LastUpdatedOn DateTime,
	  FloorId int                            
     ) XMLTable                          
   ) AS [SourceRoom]                        
  ON [TargetRoom].Id = [SourceRoom].Id        
                    
  WHEN MATCHED THEN                        
  UPDATE                         
   SET                         
       [TargetRoom].RoomTypeId = [SourceRoom].RoomTypeId                          
      ,[TargetRoom].Number = [SourceRoom].Number                          
      ,[TargetRoom].IsActive = [SourceRoom].IsActive                          
      ,[TargetRoom].CreatedBy = [SourceRoom].CreatedBy                        
      ,[TargetRoom].CreatedOn = [SourceRoom].CreatedOn                         
      ,[TargetRoom].LastUpdatedBy = [SourceRoom].LastUpdatedBy                         
      ,[TargetRoom].LastUpdatedOn = [SourceRoom].LastUpdatedOn                        
	  ,[TargetRoom].FloorId = [SourceRoom].FloorId
  WHEN NOT MATCHED THEN                        
  INSERT (   
   PropertyId,                         
      RoomTypeId,  
      Number,                          
      IsActive,                          
      CreatedBy,                          
      CreatedOn,                       
      LastUpdatedBy,                          
      LastUpdatedOn,
	  FloorId)             
   VALUES                         
    (    
  @PropertyID,                      
     [SourceRoom].RoomTypeId,                          
     [SourceRoom].Number,                          
     [SourceRoom].IsActive,                          
     [SourceRoom].CreatedBy,                          
     [SourceRoom].CreatedOn,                          
     [SourceRoom].LastUpdatedBy,                          
     [SourceRoom].LastUpdatedOn,
	 [SourceRoom].FloorId                        
    ) ;                       
 END   
                      
 COMMIT TRAN                        
 END TRY                        
                        
    BEGIN CATCH                        
  ROLLBACK TRAN;                        
 END CATCH                        
                            
    SET NOCOUNT OFF                        
END 
GO
/****** Object:  StoredProcedure [dbo].[InsertRoomRates]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[InsertRoomRates]                                
 @propertyID INT,                                
 @RateXML XML = NULL,             
 @RateID INT OUTPUT                                
AS                                
BEGIN                                
 SET NOCOUNT ON                                
 BEGIN TRAN                                 
 BEGIN TRY                                
                                  
 DECLARE @hDoc INT                                
  IF @RateXML IS NOT NULL                                
  BEGIN                                
   DECLARE @SavedRateIDTable Table (OldRateID INT, NewRateID INT)                                
   EXEC sp_xml_preparedocument @hDoc OUTPUT,@RateXML    
  
   -- Start - Merge INTO Invoice                                
  MERGE INTO                                 
  [Rates] AS [TargetRates]                                
  USING                                 
   (                                
    SELECT                                 
      XMLTable.Id,                                  
      XMLTable.Type,          
      XMLTable.PropertyId,                  
      XMLTable.RateTypeId,                                  
      XMLTable.RoomTypeId,                                  
      XMLTable.InputKeyHours,                                  
      XMLTable.Value,                                  
      XMLTable.RoomId,                                  
      XMLTable.IsActive,                                  
      XMLTable.CreatedBy,                                  
      XMLTable.CreatedOn,                                  
      XMLTable.LastUpdatedBy,                                  
      XMLTable.LastUpdatedOn                                
    FROM                                 
     OPENXML(@hDoc, 'Rate',2)                                
     WITH                                
     (                                
      Id int,                                  
      Type nvarchar(20),                                  
      PropertyId int,                                  
      RateTypeId int,            
      RoomTypeId int,                                
      InputKeyHours int,                                  
      Value money,                                  
      RoomId int,                                  
      IsActive bit,                                  
      CreatedBy nvarchar(200),                                  
      CreatedOn Datetime,                                  
      LastUpdatedBy nvarchar(200),                                  
      LastUpdatedOn DateTime                                
     ) XMLTable                                  
   ) AS [SourceRates]                                
  ON [TargetRates].ID = [SourceRates].ID                                
  WHEN MATCHED THEN                                
  UPDATE                                 
   SET                                 
      [TargetRates].Type = [SourceRates].Type                                  
      ,[TargetRates].PropertyID = [SourceRates].PropertyID                                  
      ,[TargetRates].RateTypeID = [SourceRates].RateTypeID                                
      ,[TargetRates].RoomTypeID = [SourceRates].RoomTypeID                                
      ,[TargetRates].InputKeyHours = [SourceRates].InputKeyHours                                  
      ,[TargetRates].Value = [SourceRates].Value                   
      ,[TargetRates].RoomId = [SourceRates].RoomId                                
      ,[TargetRates].IsActive = [SourceRates].IsActive                                  
      ,[TargetRates].CreatedBy = [SourceRates].CreatedBy                                
      ,[TargetRates].CreatedOn = [SourceRates].CreatedOn                                 
      ,[TargetRates].LastUpdatedBy = [SourceRates].LastUpdatedBy                                 
      ,[TargetRates].LastUpdatedOn = [SourceRates].LastUpdatedOn        
      ,@RateID = [SourceRates].ID            
  WHEN NOT MATCHED THEN                                
  INSERT (                                  
      Type,                                  
      PropertyID,                                  
      RateTypeID,        
      RoomTypeID,                                  
      InputKeyHours,                                  
      Value,                                  
      RoomId,                                
      IsActive,                                  
      CreatedBy,                                  
      CreatedOn,                                  
      LastUpdatedBy,           
      LastUpdatedOn          
      )                     
   VALUES                                 
    (                                
      [SourceRates].Type                                  
      ,[SourceRates].PropertyID                                  
      ,[SourceRates].RateTypeID        
      ,[SourceRates].RoomTypeID                                
      ,[SourceRates].InputKeyHours                                  
      ,[SourceRates].Value                   
      ,[SourceRates].RoomId                                
      ,[SourceRates].IsActive                                  
      ,[SourceRates].CreatedBy                                
      ,[SourceRates].CreatedOn                                 
      ,[SourceRates].LastUpdatedBy                                 
      ,[SourceRates].LastUpdatedOn                                 
    )                                
   OUTPUT [SourceRates].ID, inserted.ID INTO @SavedRateIDTable(OldRateID,NewRateID);                                
             
   IF(@RateID is null)            
   BEGIN            
    SELECT @RateID = NewRateID FROM @SavedRateIDTable                  
   END             
    SELECT @RateID                
 END                                
 COMMIT TRAN                                
 END TRY                                
                                
    BEGIN CATCH                                
  ROLLBACK TRAN;                                
 END CATCH                                
                                    
    SET NOCOUNT OFF                                
END 
GO
/****** Object:  StoredProcedure [dbo].[UpdateBooking]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================      
-- Author:  Sachin Tyagi      
-- Create date: MAY 16, 2017      
-- Description: This stored procedure shall update the booking checkin/checkout and room information in case of drag/drop feature.
-- =============================================      
      
CREATE PROCEDURE [dbo].[UpdateBooking]      
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
GO
/****** Object:  Table [dbo].[AdditionalGuests]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AdditionalGuests](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[BookingId] [int] NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[GUESTIDPath] [nvarchar](max) NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_AdditionalGuests_IsActive]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
	[Gender] [nvarchar](10) NULL,
 CONSTRAINT [PK_AdditionalGuests] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Address]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Address](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[AddressTypeID] [int] NOT NULL,
	[GuestID] [int] NOT NULL,
	[Address1] [nvarchar](200) NULL,
	[Address2] [nvarchar](200) NULL,
	[City] [nvarchar](200) NULL,
	[State] [nvarchar](200) NULL,
	[ZipCode] [nvarchar](40) NULL,
	[Country] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF__Address__IsActiv__797309D9]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
 CONSTRAINT [PK__Address__3214EC27EE6E9CCB] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AddressType]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AddressType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_AddressType_IsActive]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
	[Name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK__AddressT__3214EC279E125A55] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Booking]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Booking](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyID] [int] NOT NULL,
	[CheckinTime] [datetime] NULL,
	[CheckoutTime] [datetime] NULL,
	[NoOfAdult] [int] NULL,
	[NoOfChild] [int] NULL,
	[GuestRemarks] [nvarchar](200) NULL,
	[TransactionRemarks] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF__Booking__IsActiv__7A672E12]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
	[Status] [nvarchar](50) NULL,
	[ISHOURLYCHECKIN] [bit] NULL,
	[HOURSTOSTAY] [int] NULL,
 CONSTRAINT [PK__Booking__3214EC27D183E29A] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ChargableFacility]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChargableFacility](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FacilityShortName] [nvarchar](100) NULL,
	[Description] [nvarchar](max) NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
 CONSTRAINT [PK__Chargabl__3214EC27DD965004] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[City]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[City](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[StateID] [int] NULL,
	[CountryID] [int] NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF__City__IsActive__7B5B524B]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
 CONSTRAINT [PK__City__3214EC278D337EBF] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Country]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Country](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF__Country__IsActiv__7C4F7684]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
 CONSTRAINT [PK__Country__3214EC27881DE460] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Currency]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Currency](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](100) NULL,
	[Description] [nvarchar](max) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ExtraCharges]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExtraCharges](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyID] [int] NULL,
	[FacilityName] [nvarchar](400) NOT NULL,
	[Value] [money] NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_ExtraCharges_IsActive]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
 CONSTRAINT [PK_ExtraCharges] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Guest]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Guest](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](200) NULL,
	[LastName] [nvarchar](200) NULL,
	[MobileNumber] [bigint] NULL,
	[EmailAddress] [nvarchar](500) NULL,
	[DOB] [date] NULL,
	[Gender] [nvarchar](10) NULL,
	[PhotoPath] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF__Guest__IsActive__7D439ABD]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
 CONSTRAINT [PK__Guest__3214EC27B26A2F31] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[GuestMapping]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GuestMapping](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDTYPEID] [int] NOT NULL,
	[GUESTID] [int] NOT NULL,
	[IDDETAILS] [nvarchar](max) NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF__GuestMapp__IsAct__7E37BEF6]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
	[IdExpiryDate] [datetime] NOT NULL,
	[IdIssueState] [nvarchar](50) NOT NULL,
	[IdIssueCountry] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK__GuestMap__3214EC27EE38DB4B] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[GuestReward]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GuestReward](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[GuestID] [int] NOT NULL,
	[BookingID] [int] NOT NULL,
	[IsCredit] [bit] NULL,
	[ExpirationDate] [datetime] NULL,
	[NoOfPoints] [int] NULL,
	[Decription] [nvarchar](max) NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
 CONSTRAINT [PK__GuestRew__3214EC27BE9BAFD4] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[IDType]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IDType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF__IDType__IsActive__00200768]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
 CONSTRAINT [PK__IDType__3214EC2788EBEA0B] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Invoice]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Invoice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[GuestID] [int] NOT NULL,
	[BookingID] [int] NOT NULL,
	[IsPaid] [bit] NULL,
	[TotalAmount] [money] NULL,
	[FolioNumber] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF__Invoice__IsActiv__01142BA1]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
	[DISCOUNT] [money] NULL,
 CONSTRAINT [PK__Invoice__3214EC2766CAD2C9] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[InvoiceItems]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceItems](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InvoiceID] [int] NOT NULL,
	[ItemName] [nvarchar](max) NULL,
	[ItemValue] [money] NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_InvoiceItems_IsActive]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
 CONSTRAINT [PK_InvoiceItems] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[InvoicePaymentDetails]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoicePaymentDetails](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InvoiceID] [int] NOT NULL,
	[PaymentMode] [nvarchar](max) NULL,
	[PaymentValue] [money] NULL,
	[PaymentDetails] [nvarchar](max) NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_InvoicePaymentDetails_IsActive]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
 CONSTRAINT [PK_InvoicePaymentDetails] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[InvoiceTaxDetail]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InvoiceTaxDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InvoiceID] [int] NOT NULL,
	[TaxShortName] [nvarchar](max) NULL,
	[TaxAmount] [decimal](7, 2) NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF__InvoiceTa__IsAct__02084FDA]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
 CONSTRAINT [PK__InvoiceT__3214EC27D12730CC] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PaymentType]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PaymentType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyID] [int] NULL,
	[ShortName] [nvarchar](50) NULL,
	[Description] [nvarchar](max) NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF__PaymentTy__IsAct__0D0FEE32]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
 CONSTRAINT [PK_PaymentType] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Property]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Property](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyDetails] [nvarchar](max) NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_Property_IsActive]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
	[PropertyName] [nvarchar](100) NULL,
	[SecondaryName] [nvarchar](100) NULL,
	[PropertyCode] [nvarchar](50) NULL,
	[FullAddress] [nvarchar](max) NULL,
	[Phone] [nvarchar](100) NULL,
	[Fax] [nvarchar](100) NULL,
	[LogoPath] [nvarchar](max) NULL,
	[WebSiteAddress] [nvarchar](100) NULL,
	[TimeZone] [nvarchar](100) NULL,
	[CurrencyId] [int] NULL,
	[CheckinTime] [time](7) NULL,
	[CheckoutTime] [time](7) NULL,
	[CloseOfDayTime] [time](7) NULL,
	[State] [int] NULL,
	[Country] [int] NULL,
	[City] [int] NULL,
	[Zipcode] [nvarchar](50) NULL,
 CONSTRAINT [PK__Property__3214EC27AD6BF945] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[PropertyFloor]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PropertyFloor](
	[PropertyId] [int] NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FloorNumber] [int] NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF__PropertyF__isAct__0EF836A4]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
 CONSTRAINT [PK_PropertyFloor] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Rates]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Rates](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Type] [nvarchar](20) NULL,
	[PropertyID] [int] NULL,
	[RateTypeID] [int] NULL,
	[RoomTypeID] [int] NULL,
	[InputKeyHours] [int] NULL,
	[Value] [money] NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_Rates_IsActive]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
	[RoomId] [int] NULL,
 CONSTRAINT [PK_Rates] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RateType]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RateType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyID] [int] NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_RateType_IsActive]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
	[NAME] [nvarchar](max) NULL,
	[Units] [nvarchar](50) NULL,
	[Hours] [int] NULL,
 CONSTRAINT [PK__RateType__3214EC2725FEB820] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RewardCategory]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RewardCategory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RewardCategory] [nvarchar](200) NOT NULL,
	[NoOfPoints] [int] NULL,
	[Benefits] [nvarchar](max) NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
 CONSTRAINT [PK__RewardCa__3214EC27122A8426] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Room]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Room](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyID] [int] NOT NULL,
	[RoomTypeID] [int] NOT NULL,
	[Number] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_Room_IsActive]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
	[FloorId] [int] NULL,
 CONSTRAINT [PK__Room__3214EC278D6C9E74] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RoomBooking]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoomBooking](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[GuestID] [int] NOT NULL,
	[BookingID] [int] NOT NULL,
	[RoomID] [int] NOT NULL,
	[IsExtra] [bit] NULL,
	[Discount] [decimal](7, 2) NULL,
	[RoomCharges] [decimal](7, 2) NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF__RoomBooki__IsAct__03F0984C]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
 CONSTRAINT [PK__RoomBook__3214EC2709EFCFF0] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RoomPricing]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoomPricing](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyID] [int] NOT NULL,
	[RoomTypeID] [int] NOT NULL,
	[RateTypeID] [int] NOT NULL,
	[BasePrice] [decimal](8, 2) NOT NULL,
	[ExtraPersonPrice] [decimal](8, 2) NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
 CONSTRAINT [PK__RoomPric__3214EC271DE61C1F] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[RoomType]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoomType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyID] [int] NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_RoomType_IsActive]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
	[NAME] [nvarchar](max) NULL,
	[ShortName] [nvarchar](50) NULL,
 CONSTRAINT [PK__RoomType__3214EC2783760BB1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[State]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[State](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NULL,
	[CountryID] [int] NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF__State__IsActive__05D8E0BE]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
 CONSTRAINT [PK__State__3214EC27E166B7A6] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Taxes]    Script Date: 7/19/2017 2:40:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Taxes](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyID] [int] NULL,
	[TaxId] [int] NULL,
	[Value] [money] NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_Taxes_IsActive]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
	[TaxName] [nvarchar](200) NULL,
 CONSTRAINT [PK__Taxes__3214EC270D4AC0D8] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[AdditionalGuests] ON 

INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (6, NULL, N'additional name', N'additional last', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (7, NULL, N'add fname', N'add lname', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-05-18 15:35:27.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (8, NULL, N'add 1', N'add last', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-05-23 21:37:12.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (9, NULL, N'add1', N'add2', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-05-25 09:33:19.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (10, NULL, N'add1', N'add last1', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-05-25 10:05:09.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (11, NULL, N'add1', N'add2', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-05-25 11:14:42.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (12, NULL, N'add1', N'add2', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-05-25 11:20:02.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1002, NULL, N'f1', N'l1', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-06 10:07:09.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1003, NULL, N'ad1', N'ad2', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-07 09:33:59.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1004, NULL, N'adf1', N'adf2', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-07 09:39:37.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1005, NULL, N'adf1', N'adl1', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-07 10:08:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1006, NULL, N'adf2', N'adl2', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-07 10:52:56.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1007, NULL, N'ad1', N'ad2', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-07 23:00:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1008, NULL, N'', N'', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-08 12:59:45.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1009, NULL, N'sfsffsfsfdsfdsf', N'dsfsfsf', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-11 19:14:29.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1015, NULL, N'dgsf', N'sfsf', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-11 19:46:54.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1017, NULL, N'adw', N'ls', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1019, NULL, N'adw', N'ls', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1020, NULL, N'adw', N'ls', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1021, NULL, N'adw', N'ls', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1023, NULL, N'adw', N'ls', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1024, NULL, N'adw', N'ls', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1032, NULL, N'ads1', N'ads2', N'D:\PMSHosted\PMSApi\UploadedFiles\DSC_0836850.JPG', 1, N'vipul', CAST(N'2017-06-16 07:40:51.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1033, NULL, N'ads1', N'ads2', N'D:\PMSHosted\PMSApi\UploadedFiles\DSC_0836850.JPG', 1, N'vipul', CAST(N'2017-06-16 07:40:51.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1034, NULL, N'ads1', N'ads2', N'D:\PMSHosted\PMSApi\UploadedFiles\DSC_0836850.JPG', 1, N'vipul', CAST(N'2017-06-16 07:40:51.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1035, NULL, N'', N'', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-16 09:03:02.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1036, NULL, N'adr1', N'adr2', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-18 21:12:57.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1037, NULL, N'adf1', N'adf2', N'No Image Available', 1, N'vipul', CAST(N'2017-06-21 22:54:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1038, NULL, N'qadd', N'q1add', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-21 23:10:18.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1039, 1094, N'q2', N'q3', N'No Image Available', 1, N'vipul', CAST(N'2017-06-22 13:03:11.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (1040, 1095, N'adfg', N'adft', N'No Image Available', 1, N'vipul', CAST(N'2017-06-23 00:15:13.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (2036, 2086, N'drf', N'drm', N'No Image Available', 1, N'test', CAST(N'2017-06-30 21:03:55.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (2037, 2087, N'rt', N'gh', N'No Image Available', 1, N'test', CAST(N'2017-06-30 21:25:14.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (2038, 2087, N'rt', N'gh', N'No Image Available', 1, N'test', CAST(N'2017-06-30 21:29:59.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (2039, 2088, N'nf', N'nl', N'No Image Available', 1, N'agoenka', CAST(N'2017-06-30 21:40:31.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[AdditionalGuests] ([Id], [BookingId], [FirstName], [LastName], [GUESTIDPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Gender]) VALUES (2040, 2089, N'adg', N'gj', N'No Image Available', 1, N'test', CAST(N'2017-07-14 10:52:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
SET IDENTITY_INSERT [dbo].[AdditionalGuests] OFF
SET IDENTITY_INSERT [dbo].[Address] ON 

INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (45, 1, 49, N'', N'', N'4', N'2', N'201301', N'3', 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (46, 1, 50, N'noida', N'noida', N'3', N'3', N'201301', N'2', 1, N'vipul', CAST(N'2017-05-18 15:35:27.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (47, 1, 51, N'noida', N'noida', N'1', N'1', N'201301', N'3', 1, N'vipul', CAST(N'2017-05-23 21:37:12.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (48, 1, 52, N'test address', N'test address', N'1', N'6', N'201301', N'3', 1, N'vipul', CAST(N'2017-05-25 09:33:19.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (49, 1, 53, N'test address', N'test address', N'1', N'6', N'201301', N'3', 1, N'vipul', CAST(N'2017-05-25 10:05:09.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (50, 1, 54, N'noida', N'noida', N'1', N'6', N'201301', N'3', 1, N'vipul', CAST(N'2017-05-25 11:14:42.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (51, 1, 55, N'jlkjlkjlkjlkjlkjlk', N'jlkjlkjlkjlkjlkjlk', N'1', N'6', N'201301', N'3', 1, N'vipul', CAST(N'2017-05-25 11:20:02.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1041, 1, 48, N'noida', N'noida', N'1', N'6', N'201301', N'3', 1, N'vipul', CAST(N'2017-06-06 10:07:09.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1042, 1, 51, N'noida', N'noida', N'1', N'6', N'201301', N'3', 1, N'vipul', CAST(N'2017-06-07 09:33:59.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1043, 1, 51, N'noida', N'noida', N'1', N'6', N'201301', N'3', 1, N'vipul', CAST(N'2017-06-07 09:39:37.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1044, 1, 51, N'noida', N'noida', N'1', N'6', N'201301', N'3', 1, N'vipul', CAST(N'2017-06-07 10:08:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1045, 1, 51, N'', N'', N'1', N'6', N'201301', N'3', 1, N'vipul', CAST(N'2017-06-07 10:52:56.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1046, 1, 1045, N'noida', N'noida', N'1', N'6', N'201301', N'3', 1, N'vipul', CAST(N'2017-06-07 23:00:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1047, 1, 48, N'noida', N'noida', N'1', N'6', N'201301', N'3', 1, N'vipul', CAST(N'2017-06-08 12:59:45.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1048, 1, 1045, N'fddfdsfsdf', N'fddfdsfsdf', N'7', N'6', N'232131', N'3', 1, N'vipul', CAST(N'2017-06-11 19:14:29.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1051, 1, 1047, N'noida', N'noida', N'3', N'1', N'201', N'2', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1052, 1, 1048, N'noida', N'noida', N'3', N'1', N'201', N'2', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1056, 1, 54, N'dsdad', N'dsdad', N'7', N'6', N'424321', N'3', 1, N'vipul', CAST(N'2017-06-11 19:46:54.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1058, 1, 1053, N'noida', N'noida', N'3', N'6', N'465465', N'3', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1060, 1, 1055, N'noida', N'noida', N'3', N'6', N'465465', N'3', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1061, 1, 1056, N'noida', N'noida', N'3', N'6', N'465465', N'3', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1062, 1, 1057, N'noida', N'noida', N'3', N'6', N'465465', N'3', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1064, 1, 1059, N'noida', N'noida', N'3', N'6', N'465465', N'3', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1065, 1, 1060, N'noida', N'noida', N'3', N'6', N'465465', N'3', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1073, 1, 1068, N'hjlj', N'hjlj', N'7', N'6', N'201301', N'3', 1, N'vipul', CAST(N'2017-06-16 07:40:51.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1074, 1, 1069, N'hjlj', N'hjlj', N'7', N'6', N'201301', N'3', 1, N'vipul', CAST(N'2017-06-16 07:40:51.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1075, 1, 1070, N'hjlj', N'hjlj', N'7', N'6', N'201301', N'3', 1, N'vipul', CAST(N'2017-06-16 07:40:51.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1077, 1, 1072, N'noida', N'noida', N'3', N'1', N'201', N'2', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1078, 1, 1073, N'noida', N'noida', N'3', N'1', N'201', N'2', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1079, 1, 1074, N'noida', N'noida', N'3', N'1', N'201', N'2', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1080, 1, 1075, N'nnoida', N'nnoida', N'7', N'6', N'111111', N'3', 1, N'vipul', CAST(N'2017-06-16 09:03:02.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1081, 1, 1076, N'noida', N'noida', N'3', N'1', N'201', N'2', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1082, 1, 1077, N'noida', N'noida', N'3', N'1', N'201', N'2', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1083, 1, 1078, N'noida', N'noida', N'3', N'1', N'201', N'2', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1084, 1, 1079, N'noida', N'noida', N'3', N'1', N'201', N'2', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1085, 1, 54, N'noidaa', N'noidaa', N'3', N'6', N'201301', N'3', 1, N'vipul', CAST(N'2017-06-18 21:12:57.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1086, 1, 1080, N'new add', N'new add', N'7', N'6', N'999999', N'3', 1, N'vipul', CAST(N'2017-06-21 22:54:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1087, 1, 1081, N'noida', N'noida', N'3', N'1', N'201', N'2', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1088, 1, 1082, N'new ad', N'new ad', N'3', N'6', N'777777', N'3', 1, N'vipul', CAST(N'2017-06-21 23:10:18.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1089, 1, 1083, N'add new', N'add new', N'7', N'6', N'111111', N'3', 1, N'vipul', CAST(N'2017-06-22 13:03:11.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1090, 1, 1084, N'demoadd', N'demoadd', N'Test33', N'California', N'333333', N'U.S.A', 1, N'vipul', CAST(N'2017-06-23 00:15:13.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2081, 1, 2076, N'noida', N'noida', N'Test3', N'California', N'200000', N'U.S.A', 1, N'test', CAST(N'2017-06-30 21:03:55.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2082, 1, 2077, N'lll', N'lll', N'Test3', N'California', N'808098', N'U.S.A', 1, N'test', CAST(N'2017-06-30 21:25:14.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2083, 1, 2077, N'lllast name', N'lllast name', N'Test3', N'California', N'808098', N'U.S.A', 1, N'test', CAST(N'2017-06-30 21:29:59.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2084, 1, 2078, N'delhi', N'delhi', N'Test4', N'California', N'435345', N'U.S.A', 1, N'agoenka', CAST(N'2017-06-30 21:40:31.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Address] ([ID], [AddressTypeID], [GuestID], [Address1], [Address2], [City], [State], [ZipCode], [Country], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2085, 1, 2079, N'delhi', N'delhi', N'Test33', N'California', N'111111', N'U.S.A', 1, N'test', CAST(N'2017-07-14 10:52:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
SET IDENTITY_INSERT [dbo].[Address] OFF
SET IDENTITY_INSERT [dbo].[AddressType] ON 

INSERT [dbo].[AddressType] ([ID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Name]) VALUES (1, 1, N'sachin', CAST(N'2017-05-01 11:33:50.973' AS DateTime), N'tyagi', CAST(N'2017-05-01 11:33:50.973' AS DateTime), N'Official Address')
INSERT [dbo].[AddressType] ([ID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Name]) VALUES (2, 1, N'sachin', CAST(N'2017-05-01 11:33:50.973' AS DateTime), N'tyagi', CAST(N'2017-05-01 11:33:50.973' AS DateTime), N'Correspondence Address')
INSERT [dbo].[AddressType] ([ID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Name]) VALUES (3, 1, N'sachin', CAST(N'2017-05-01 11:33:50.997' AS DateTime), N'tyagi', CAST(N'2017-05-01 11:33:50.997' AS DateTime), N'Permanenent Address')
INSERT [dbo].[AddressType] ([ID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Name]) VALUES (4, 1, N'sachin', CAST(N'2017-05-01 11:33:50.997' AS DateTime), N'tyagi', CAST(N'2017-05-01 11:33:50.997' AS DateTime), N'Temporary Address')
SET IDENTITY_INSERT [dbo].[AddressType] OFF
SET IDENTITY_INSERT [dbo].[Booking] ON 

INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (50, 1, CAST(N'2017-06-07 01:00:00.000' AS DateTime), CAST(N'2017-06-07 03:00:00.000' AS DateTime), 1, 0, N'test comments', N'test remark', 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (51, 1, CAST(N'2017-06-08 00:00:00.000' AS DateTime), CAST(N'2017-06-08 01:00:00.000' AS DateTime), 1, 0, N'comments', N'trans remarks', 1, N'vipul', CAST(N'2017-05-18 15:35:27.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (52, 1, CAST(N'2017-06-08 05:00:00.000' AS DateTime), CAST(N'2017-06-08 06:00:00.000' AS DateTime), 1, 1, N'comments1', N'trans1', 1, N'vipul', CAST(N'2017-05-23 21:37:12.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (53, 1, CAST(N'2017-05-25 09:00:00.000' AS DateTime), CAST(N'2017-05-25 10:00:00.000' AS DateTime), 1, 0, N'guest commnets test', N'trans remarks', 1, N'vipul', CAST(N'2017-05-25 09:33:19.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (54, 1, CAST(N'2017-05-25 15:00:00.000' AS DateTime), CAST(N'2017-05-25 16:00:00.000' AS DateTime), 1, 0, N'guest coments', N'trans remark', 1, N'vipul', CAST(N'2017-05-25 10:05:09.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (55, 1, CAST(N'2017-05-25 17:00:00.000' AS DateTime), CAST(N'2017-05-25 18:00:00.000' AS DateTime), 1, 0, N'guest comments', N'trans  remarks', 1, N'vipul', CAST(N'2017-05-25 11:14:42.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (56, 1, CAST(N'2017-05-26 00:00:00.000' AS DateTime), CAST(N'2017-05-27 00:00:00.000' AS DateTime), 1, 0, N'test comments', N'remarks test', 1, N'vipul', CAST(N'2017-05-25 11:20:02.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1046, 1, CAST(N'2017-06-09 00:00:00.000' AS DateTime), CAST(N'2017-06-09 06:00:00.000' AS DateTime), 1, 0, N'comments', N'trans remark', 1, N'vipul', CAST(N'2017-06-06 10:07:09.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1047, 1, CAST(N'2017-06-01 00:00:00.000' AS DateTime), CAST(N'2017-06-01 01:00:00.000' AS DateTime), 1, 0, N'testguestcom', N'testremark', 1, N'vipul', CAST(N'2017-06-07 09:33:59.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1048, 1, CAST(N'2017-06-10 00:00:00.000' AS DateTime), CAST(N'2017-06-10 02:00:00.000' AS DateTime), 1, 0, N'comment test', N'transtest', 1, N'vipul', CAST(N'2017-06-07 09:39:37.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1049, 1, CAST(N'2017-06-11 00:00:00.000' AS DateTime), CAST(N'2017-06-11 02:00:00.000' AS DateTime), 1, 0, N'sdfdsfsf', N'fgdgsdfsf', 1, N'vipul', CAST(N'2017-06-07 10:08:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1050, 1, CAST(N'2017-06-12 00:00:00.000' AS DateTime), CAST(N'2017-06-12 02:00:00.000' AS DateTime), 1, 0, N'test comment', N'test remark', 1, N'vipul', CAST(N'2017-06-07 10:52:56.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, NULL, NULL)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1051, 1, CAST(N'2017-06-30 00:00:00.000' AS DateTime), CAST(N'2017-06-30 02:00:00.000' AS DateTime), 1, 0, N'sdsfsf', N'sfsf', 1, N'vipul', CAST(N'2017-06-07 23:00:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 1, 2)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1052, 1, CAST(N'2017-07-01 00:00:00.000' AS DateTime), CAST(N'2017-07-01 02:00:00.000' AS DateTime), 1, 0, N'dsfsfsafasf', N'sfdsfdsf', 1, N'vipul', CAST(N'2017-06-08 12:59:45.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 1, 2)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1053, 1, CAST(N'2017-07-29 00:00:00.000' AS DateTime), CAST(N'2017-07-29 02:00:00.000' AS DateTime), 2, 0, N'fsfsfsfsf', N'sdff', 1, N'vipul', CAST(N'2017-06-11 19:14:29.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 1, 2)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1056, 1, CAST(N'2017-05-05 10:16:00.000' AS DateTime), CAST(N'2017-05-06 00:00:00.000' AS DateTime), 3, 1, N'gues', N'transaction', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 0, 0)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1057, 1, CAST(N'2017-05-05 10:16:00.000' AS DateTime), CAST(N'2017-05-06 00:00:00.000' AS DateTime), 3, 1, N'gues', N'transaction', 1, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 0, 0)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1061, 1, CAST(N'2017-08-25 00:00:00.000' AS DateTime), CAST(N'2017-08-25 04:00:00.000' AS DateTime), 2, 0, N'f', N'vfdsdf', 1, N'vipul', CAST(N'2017-06-11 19:46:54.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'booked', 1, 4)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1063, 1, CAST(N'2017-06-01 00:00:00.000' AS DateTime), CAST(N'2017-06-01 06:00:00.000' AS DateTime), 1, 0, N'', N'tttttttt', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'booked', 1, 6)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1065, 1, CAST(N'2017-06-01 00:00:00.000' AS DateTime), CAST(N'2017-06-01 06:00:00.000' AS DateTime), 1, 0, N'', N'tttttttt', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'booked', 1, 6)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1066, 1, CAST(N'2017-06-01 00:00:00.000' AS DateTime), CAST(N'2017-06-01 06:00:00.000' AS DateTime), 1, 0, N'', N'tttttttt', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'booked', 1, 6)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1067, 1, CAST(N'2017-06-01 00:00:00.000' AS DateTime), CAST(N'2017-06-01 06:00:00.000' AS DateTime), 1, 0, N'', N'tttttttt', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'booked', 1, 6)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1069, 1, CAST(N'2017-06-01 00:00:00.000' AS DateTime), CAST(N'2017-06-01 06:00:00.000' AS DateTime), 1, 0, N'', N'tttttttt', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'booked', 1, 6)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1070, 1, CAST(N'2017-06-01 00:00:00.000' AS DateTime), CAST(N'2017-06-01 06:00:00.000' AS DateTime), 1, 0, N'', N'tttttttt', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'booked', 1, 6)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1078, 1, CAST(N'2017-06-30 00:00:00.000' AS DateTime), CAST(N'2017-06-30 06:00:00.000' AS DateTime), 1, 1, N'my guest', N'ddad', 1, N'vipul', CAST(N'2017-06-16 07:40:51.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'booked', 1, 6)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1079, 1, CAST(N'2017-06-30 00:00:00.000' AS DateTime), CAST(N'2017-06-30 06:00:00.000' AS DateTime), 1, 1, N'my guest', N'ddad', 1, N'vipul', CAST(N'2017-06-16 07:40:51.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'booked', 1, 6)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1080, 1, CAST(N'2017-06-30 00:00:00.000' AS DateTime), CAST(N'2017-06-30 06:00:00.000' AS DateTime), 1, 1, N'my guest', N'ddad', 1, N'vipul', CAST(N'2017-06-16 07:40:51.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'booked', 1, 6)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1082, 1, CAST(N'2017-05-05 10:16:00.000' AS DateTime), CAST(N'2017-05-06 00:00:00.000' AS DateTime), 3, 1, N'gues', N'transaction', 1, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 0, 0)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1083, 1, CAST(N'2017-05-05 10:16:00.000' AS DateTime), CAST(N'2017-05-06 00:00:00.000' AS DateTime), 3, 1, N'gues', N'transaction', 1, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 0, 0)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1084, 1, CAST(N'2017-05-05 10:16:00.000' AS DateTime), CAST(N'2017-05-06 00:00:00.000' AS DateTime), 3, 1, N'gues123', N'transaction', 1, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 0, 0)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1085, 1, CAST(N'2017-06-28 00:00:00.000' AS DateTime), CAST(N'2017-06-28 01:00:00.000' AS DateTime), 1, 0, N'remark1222', N'remark', 1, N'vipul', CAST(N'2017-06-16 09:03:02.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'booked', 1, 1)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1086, 1, CAST(N'2017-05-05 10:16:00.000' AS DateTime), CAST(N'2017-05-06 00:00:00.000' AS DateTime), 3, 1, N'gues123', N'transaction', 1, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 0, 0)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1087, 1, CAST(N'2017-05-05 10:16:00.000' AS DateTime), CAST(N'2017-05-06 00:00:00.000' AS DateTime), 3, 1, N'gues123', N'transaction', 1, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 0, 0)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1088, 1, CAST(N'2017-05-05 10:16:00.000' AS DateTime), CAST(N'2017-05-06 00:00:00.000' AS DateTime), 3, 1, N'gues123', N'transaction', 1, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 0, 0)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1089, 1, CAST(N'2017-05-05 10:16:00.000' AS DateTime), CAST(N'2017-05-06 00:00:00.000' AS DateTime), 3, 1, N'gues123', N'transaction', 1, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 0, 0)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1090, 1, CAST(N'2017-06-22 00:00:00.000' AS DateTime), CAST(N'2017-06-22 04:00:00.000' AS DateTime), 1, 0, N'ffffffff', N'eeeee', 1, N'vipul', CAST(N'2017-06-18 21:12:57.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 1, 4)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1091, 1, CAST(N'2017-06-23 00:00:00.000' AS DateTime), CAST(N'2017-06-23 06:00:00.000' AS DateTime), 1, 2, N'new com', N'new trans', 1, N'vipul', CAST(N'2017-06-21 22:54:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 1, 6)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1092, 1, CAST(N'2017-06-23 10:16:00.000' AS DateTime), CAST(N'2017-06-23 00:00:00.000' AS DateTime), 3, 1, N'gues123', N'transaction', 1, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 0, 0)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1093, 1, CAST(N'2017-06-24 00:00:00.000' AS DateTime), CAST(N'2017-06-25 06:00:00.000' AS DateTime), 3, 1, N'new guest', N'new tran', 1, N'vipul', CAST(N'2017-06-21 23:10:18.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 1, 6)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1094, 1, CAST(N'2017-06-25 07:00:00.000' AS DateTime), CAST(N'2017-06-27 00:00:00.000' AS DateTime), 1, 2, N'gyue', N'tra', 1, N'vipul', CAST(N'2017-06-22 13:03:11.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 0, 0)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (1095, 1, CAST(N'2017-06-27 00:00:00.000' AS DateTime), CAST(N'2017-06-27 06:00:00.000' AS DateTime), 1, 1, N'comm', N'rema', 1, N'vipul', CAST(N'2017-06-23 00:15:13.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 1, 6)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (2086, 1, CAST(N'2017-07-01 00:00:00.000' AS DateTime), CAST(N'2017-07-01 01:00:00.000' AS DateTime), 1, 0, N'ment', N'ark', 1, N'test', CAST(N'2017-06-30 21:03:55.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (2087, 1, CAST(N'2017-07-03 00:00:00.000' AS DateTime), CAST(N'2017-07-03 02:00:00.000' AS DateTime), 1, 1, N'from india', N'delhi', 1, N'test', CAST(N'2017-06-30 21:29:59.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 1, 2)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (2088, 1, CAST(N'2017-07-06 00:00:00.000' AS DateTime), CAST(N'2017-07-06 02:00:00.000' AS DateTime), 1, 0, N'uest', N'sac', 1, N'agoenka', CAST(N'2017-06-30 21:40:31.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 1, 2)
INSERT [dbo].[Booking] ([ID], [PropertyID], [CheckinTime], [CheckoutTime], [NoOfAdult], [NoOfChild], [GuestRemarks], [TransactionRemarks], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [Status], [ISHOURLYCHECKIN], [HOURSTOSTAY]) VALUES (2089, 1, CAST(N'2017-07-20 10:49:00.000' AS DateTime), CAST(N'2017-07-20 12:49:00.000' AS DateTime), 1, 0, N'comm', N'tttt rem', 1, N'test', CAST(N'2017-07-14 10:52:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL, 1, 2)
SET IDENTITY_INSERT [dbo].[Booking] OFF
SET IDENTITY_INSERT [dbo].[City] ON 

INSERT [dbo].[City] ([ID], [Name], [StateID], [CountryID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1, N'Test1', 2, 3, 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, NULL)
INSERT [dbo].[City] ([ID], [Name], [StateID], [CountryID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2, N'Test2', 2, 3, 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, NULL)
INSERT [dbo].[City] ([ID], [Name], [StateID], [CountryID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (3, N'Test3', 6, 3, 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, NULL)
INSERT [dbo].[City] ([ID], [Name], [StateID], [CountryID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (4, N'Test4', 6, 3, 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, NULL)
INSERT [dbo].[City] ([ID], [Name], [StateID], [CountryID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (5, N'Test11', 5, 3, 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, NULL)
INSERT [dbo].[City] ([ID], [Name], [StateID], [CountryID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (6, N'Test22', 5, 3, 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, NULL)
INSERT [dbo].[City] ([ID], [Name], [StateID], [CountryID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (7, N'Test33', 6, 3, 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, NULL)
INSERT [dbo].[City] ([ID], [Name], [StateID], [CountryID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (8, N'Test44', 4, 3, 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, NULL)
INSERT [dbo].[City] ([ID], [Name], [StateID], [CountryID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1002, N'ind1', 7, 1, 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, NULL)
INSERT [dbo].[City] ([ID], [Name], [StateID], [CountryID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1003, N'ind2', 8, 1, 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, NULL)
INSERT [dbo].[City] ([ID], [Name], [StateID], [CountryID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1004, N'ind3', 9, 1, 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[City] OFF
SET IDENTITY_INSERT [dbo].[Country] ON 

INSERT [dbo].[Country] ([ID], [Name], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1, N'India', 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, NULL)
INSERT [dbo].[Country] ([ID], [Name], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (3, N'U.S.A', 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[Country] OFF
SET IDENTITY_INSERT [dbo].[Currency] ON 

INSERT [dbo].[Currency] ([ID], [Code], [Description], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1, N'$', N'Dollar', NULL, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Currency] OFF
SET IDENTITY_INSERT [dbo].[ExtraCharges] ON 

INSERT [dbo].[ExtraCharges] ([ID], [PropertyID], [FacilityName], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1, 1, N'room charge', 5.0000, 0, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', CAST(N'2017-07-13 15:30:22.000' AS DateTime))
INSERT [dbo].[ExtraCharges] ([ID], [PropertyID], [FacilityName], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2, 1, N'gymcharges', 2.5000, 0, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', NULL)
INSERT [dbo].[ExtraCharges] ([ID], [PropertyID], [FacilityName], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (3, 1, N'poolcharges', 4.5000, 1, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', NULL)
INSERT [dbo].[ExtraCharges] ([ID], [PropertyID], [FacilityName], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (4, 2, N'roomaccharge', 2.5000, 0, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime))
INSERT [dbo].[ExtraCharges] ([ID], [PropertyID], [FacilityName], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (5, 1, N'gym ', 6.0000, 1, N'test', CAST(N'2017-07-13 15:31:26.000' AS DateTime), N'test', NULL)
INSERT [dbo].[ExtraCharges] ([ID], [PropertyID], [FacilityName], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (6, 1, N'water bottle', 50.0000, 1, N'test', CAST(N'2017-07-13 15:35:36.000' AS DateTime), N'test', NULL)
INSERT [dbo].[ExtraCharges] ([ID], [PropertyID], [FacilityName], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (7, 4, N'new charge', 6.0000, 1, N'test', CAST(N'2017-07-13 15:36:00.000' AS DateTime), N'test', NULL)
INSERT [dbo].[ExtraCharges] ([ID], [PropertyID], [FacilityName], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (8, 1, N'mocktails', 60.0000, 1, N'test', CAST(N'2017-07-15 14:43:00.000' AS DateTime), N'test', CAST(N'2017-07-17 16:09:29.000' AS DateTime))
SET IDENTITY_INSERT [dbo].[ExtraCharges] OFF
SET IDENTITY_INSERT [dbo].[Guest] ON 

INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (48, N'qqqqas', N'Test Last', 8098098098, N'v@v.com', CAST(N'2017-06-04' AS Date), N'M', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-08 12:59:45.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (49, N'Test First', N'test last', 8098098098, N'v@v.com', CAST(N'2017-05-01' AS Date), N'F', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (50, N'FNAME', N'lname', 7987987987, N'v@v.com', CAST(N'2017-05-01' AS Date), N'F', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-05-18 15:35:27.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (51, N'demo test', N'demo last', 8098098098, N'v@v.com', CAST(N'2017-06-01' AS Date), N'M', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-07 10:52:56.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (52, N'new demo', N'new name', 201301, N'v@v.com', CAST(N'2017-05-01' AS Date), N'M', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-05-25 09:33:19.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (53, N'demo test', N'last name', 8709870987, N'v@v.com', CAST(N'2017-05-01' AS Date), N'F', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-05-25 10:05:09.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (54, N'demodemo', N'checkin', 7098099880, N'demo@demo.com', CAST(N'2017-06-04' AS Date), N'F', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-18 21:12:57.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (55, N'demo checkin', N'last', 7097988089, N'demo@demo.com', CAST(N'2017-05-08' AS Date), N'F', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-05-25 11:20:02.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1045, N'fpms', N'lpms', 6876986987, N'v@v.com', CAST(N'2017-06-01' AS Date), N'M', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-11 19:14:29.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1047, N'vs', N'sh', 999, N'v@v.com', CAST(N'2017-05-23' AS Date), N'M', N'UploadedImage\nursery 006.jpg', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1048, N'vs', N'sh', 999, N'v@v.com', CAST(N'2017-05-23' AS Date), N'M', N'UploadedImage\nursery 006.jpg', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1053, N'yyuyu', N'uiouoi', 3244444444, N'q@q.com', CAST(N'2017-06-01' AS Date), N'M', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1055, N'yyuyu', N'uiouoi', 3244444444, N'q@q.com', CAST(N'2017-06-01' AS Date), N'M', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1056, N'yyuyu', N'uiouoi', 3244444444, N'q@q.com', CAST(N'2017-06-01' AS Date), N'M', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1057, N'yyuyu', N'uiouoi', 3244444444, N'q@q.com', CAST(N'2017-06-01' AS Date), N'M', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1059, N'yyuyu', N'uiouoi', 3244444444, N'q@q.com', CAST(N'2017-06-01' AS Date), N'M', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1060, N'yyuyu', N'uiouoi', 3244444444, N'q@q.com', CAST(N'2017-06-01' AS Date), N'M', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1068, N'hello', N'hi', 8080980980, N'p@p.com', CAST(N'2017-06-06' AS Date), N'M', N'D:\PMSHosted\PMSApi\UploadedFiles\DSC_0836850.JPG', 1, N'vipul', CAST(N'2017-06-16 07:40:51.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1069, N'hello', N'hi', 8080980980, N'p@p.com', CAST(N'2017-06-06' AS Date), N'M', N'D:\PMSHosted\PMSApi\UploadedFiles\DSC_0836850.JPG', 1, N'vipul', CAST(N'2017-06-16 07:40:51.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1070, N'hello', N'hi', 8080980980, N'p@p.com', CAST(N'2017-06-06' AS Date), N'M', N'D:\PMSHosted\PMSApi\UploadedFiles\DSC_0836850.JPG', 1, N'vipul', CAST(N'2017-06-16 07:40:51.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1072, N'vs', N'sh', 999, N'v@v.com', CAST(N'2017-05-23' AS Date), N'M', N'UploadedImage\nursery 006.jpg', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1073, N'vs', N'sh', 999, N'v@v.com', CAST(N'2017-05-23' AS Date), N'M', N'UploadedImage\nursery 006.jpg', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1074, N'vs', N'sh', 999, N'v@v.com', CAST(N'2017-05-23' AS Date), N'M', N'UploadedImage\nursery 006.jpg', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1075, N'hello', N'hiiii', 1111111111, N'q@q.com', CAST(N'2017-06-12' AS Date), N'M', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-16 09:03:02.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1076, N'vs', N'sh', 999, N'v@v.com', CAST(N'2017-05-23' AS Date), N'M', N'UploadedImage\nursery 006.jpg', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1077, N'vs', N'sh', 999, N'v@v.com', CAST(N'2017-05-23' AS Date), N'M', N'UploadedImage\nursery 006.jpg', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1078, N'vs', N'sh', 999, N'v@v.com', CAST(N'2017-05-23' AS Date), N'M', N'UploadedImage\nursery 006.jpg', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1079, N'vs', N'sh', 999, N'v@v.com', CAST(N'2017-05-23' AS Date), N'M', N'UploadedImage\nursery 006.jpg', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1080, N'new fname', N'new lnam', 9777777777, N'w@w.com', CAST(N'2017-06-01' AS Date), N'M', N'No Image Available', 1, N'vipul', CAST(N'2017-06-21 22:54:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1081, N'new vs', N'new sh', 999999999, N'v@v.com', CAST(N'2017-05-23' AS Date), N'M', N'UploadedImage\nursery 006.jpg', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1082, N'new r', N'new n', 6666666666, N't@t.com', CAST(N'2017-06-04' AS Date), N'M', N'D:\PMSHosted\PMSApi\UploadedFiles\Untitled.png', 1, N'vipul', CAST(N'2017-06-21 23:10:18.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1083, N'newpmsnew', N'newnew', 9999999999, N'1@1.com', CAST(N'2017-06-05' AS Date), N'M', N'No Image Available', 1, N'vipul', CAST(N'2017-06-22 13:03:11.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1084, N'demodemo', N'deml', 2222222222, N'e@e.com', CAST(N'2017-06-29' AS Date), N'M', N'No Image Available', 1, N'vipul', CAST(N'2017-06-23 00:15:13.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2076, N'new ch', N'new las', 3333333333, N'e@e.com', CAST(N'2017-06-05' AS Date), N'M', N'No Image Available', 1, N'test', CAST(N'2017-06-30 21:03:55.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2077, N'gg', N'll', 8098098098, N'v@y.com', CAST(N'2017-06-05' AS Date), N'M', N'No Image Available', 1, N'test', CAST(N'2017-06-30 21:29:59.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2078, N'fnln', N'lnfn', 7777777777, N't@t.com', CAST(N'2017-06-05' AS Date), N'M', N'No Image Available', 1, N'agoenka', CAST(N'2017-06-30 21:40:31.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[Guest] ([ID], [FirstName], [LastName], [MobileNumber], [EmailAddress], [DOB], [Gender], [PhotoPath], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2079, N'my first booking', N'tyagi', 1111111111, N'w@w.com', CAST(N'2017-07-20' AS Date), N'M', N'No Image Available', 1, N'test', CAST(N'2017-07-14 10:52:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
SET IDENTITY_INSERT [dbo].[Guest] OFF
SET IDENTITY_INSERT [dbo].[GuestMapping] ON 

INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (12, 2, 49, N'abctest', 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-05-31 00:00:00.000' AS DateTime), N'Select State', N'Select Country')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (13, 1, 50, N'abc', 1, N'vipul', CAST(N'2017-05-18 15:35:27.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-05-25 00:00:00.000' AS DateTime), N'3', N'1')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (14, 1, 51, N'jlkjlkjlkjlkjlkjl', 1, N'vipul', CAST(N'2017-05-23 21:37:12.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-05-31 00:00:00.000' AS DateTime), N'1', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (15, 1, 52, N'abc', 1, N'vipul', CAST(N'2017-05-25 09:33:19.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-05-31 00:00:00.000' AS DateTime), N'1', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (16, 1, 53, N'abc', 1, N'vipul', CAST(N'2017-05-25 10:05:09.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-05-30 00:00:00.000' AS DateTime), N'1', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (17, 1, 54, N'abccccc', 1, N'vipul', CAST(N'2017-05-25 11:14:42.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-05-31 00:00:00.000' AS DateTime), N'1', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (18, 1, 55, N'esdfsdf', 1, N'vipul', CAST(N'2017-05-25 11:20:02.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-05-31 00:00:00.000' AS DateTime), N'1', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1008, 1, 48, N'xyx', 1, N'vipul', CAST(N'2017-06-06 10:07:09.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-30 00:00:00.000' AS DateTime), N'7', N'1')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1009, 1, 51, N'abc', 1, N'vipul', CAST(N'2017-06-07 09:33:59.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-01 00:00:00.000' AS DateTime), N'6', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1010, 2, 51, N'axbbb', 1, N'vipul', CAST(N'2017-06-07 09:39:37.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-30 00:00:00.000' AS DateTime), N'6', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1011, 1, 51, N'bcdf', 1, N'vipul', CAST(N'2017-06-07 10:08:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-30 00:00:00.000' AS DateTime), N'6', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1012, 1, 51, N'fdgfdg', 1, N'vipul', CAST(N'2017-06-07 10:52:56.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-30 00:00:00.000' AS DateTime), N'6', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1013, 1, 1045, N'qqqqq', 1, N'vipul', CAST(N'2017-06-07 23:00:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-30 00:00:00.000' AS DateTime), N'6', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1014, 1, 48, N'xyx', 1, N'vipul', CAST(N'2017-06-08 12:59:45.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-18 00:00:00.000' AS DateTime), N'6', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1015, 1, 1045, N'qqqqq', 1, N'vipul', CAST(N'2017-06-11 19:14:29.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-27 00:00:00.000' AS DateTime), N'6', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1021, 1, 54, N'abccccc', 1, N'vipul', CAST(N'2017-06-11 19:46:54.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-21 00:00:00.000' AS DateTime), N'6', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1023, 1, 1053, N'gjgjhgjhkjjkhkjh', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-26 00:00:00.000' AS DateTime), N'6', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1025, 1, 1055, N'gjgjhgjhkjjkhkjh', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-26 00:00:00.000' AS DateTime), N'6', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1026, 1, 1056, N'gjgjhgjhkjjkhkjh', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-26 00:00:00.000' AS DateTime), N'6', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1027, 1, 1057, N'gjgjhgjhkjjkhkjh', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-26 00:00:00.000' AS DateTime), N'6', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1029, 1, 1059, N'gjgjhgjhkjjkhkjh', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-26 00:00:00.000' AS DateTime), N'6', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1030, 1, 1060, N'gjgjhgjhkjjkhkjh', 1, N'vipul', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-26 00:00:00.000' AS DateTime), N'6', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1038, 3, 1068, N'hhhkhkh', 1, N'vipul', CAST(N'2017-06-16 07:40:51.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-30 00:00:00.000' AS DateTime), N'6', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1039, 3, 1069, N'hhhkhkh', 1, N'vipul', CAST(N'2017-06-16 07:40:51.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-30 00:00:00.000' AS DateTime), N'6', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1040, 3, 1070, N'hhhkhkh', 1, N'vipul', CAST(N'2017-06-16 07:40:51.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-30 00:00:00.000' AS DateTime), N'6', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1041, 1, 1075, N'aaaaaaaaaaa', 1, N'vipul', CAST(N'2017-06-16 09:03:02.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-28 00:00:00.000' AS DateTime), N'6', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1042, 1, 54, N'abccccc', 1, N'vipul', CAST(N'2017-06-18 21:12:57.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-30 00:00:00.000' AS DateTime), N'7', N'1')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1043, 1, 1080, N'ababababababbabab', 1, N'vipul', CAST(N'2017-06-21 22:54:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-30 00:00:00.000' AS DateTime), N'7', N'1')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1044, 1, 1082, N'abcuuuuuuu', 1, N'vipul', CAST(N'2017-06-21 23:10:18.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-30 00:00:00.000' AS DateTime), N'6', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1045, 1, 1083, N'12dddd', 1, N'vipul', CAST(N'2017-06-22 13:03:11.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-30 00:00:00.000' AS DateTime), N'6', N'3')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (1046, 3, 1084, N'abvc', 1, N'vipul', CAST(N'2017-06-23 00:15:13.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-30 00:00:00.000' AS DateTime), N'Punjab', N'India')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (2042, 1, 2076, N'rrrrrrrrrrrrrrrr', 1, N'test', CAST(N'2017-06-30 21:03:55.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-30 00:00:00.000' AS DateTime), N'Alabama', N'U.S.A')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (2043, 1, 2077, N'444', 1, N'test', CAST(N'2017-06-30 21:25:14.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-29 00:00:00.000' AS DateTime), N'Alabama', N'U.S.A')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (2044, 1, 2077, N'444', 1, N'test', CAST(N'2017-06-30 21:29:59.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-29 00:00:00.000' AS DateTime), N'Alabama', N'U.S.A')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (2045, 2, 2078, N'number1', 1, N'agoenka', CAST(N'2017-06-30 21:40:31.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-06-29 00:00:00.000' AS DateTime), N'Arizona', N'U.S.A')
INSERT [dbo].[GuestMapping] ([ID], [IDTYPEID], [GUESTID], [IDDETAILS], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [IdExpiryDate], [IdIssueState], [IdIssueCountry]) VALUES (2046, 1, 2079, N'122234344444444', 1, N'test', CAST(N'2017-07-14 10:52:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), CAST(N'2017-07-20 10:49:00.000' AS DateTime), N'UP', N'India')
SET IDENTITY_INSERT [dbo].[GuestMapping] OFF
SET IDENTITY_INSERT [dbo].[IDType] ON 

INSERT [dbo].[IDType] ([ID], [Name], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1, N'Passport', 1, N'admin', NULL, NULL, NULL)
INSERT [dbo].[IDType] ([ID], [Name], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2, N'SSN', 1, N'admin', NULL, NULL, NULL)
INSERT [dbo].[IDType] ([ID], [Name], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (3, N'PAN', 1, N'admin', NULL, NULL, NULL)
INSERT [dbo].[IDType] ([ID], [Name], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (4, N'Driving License', 1, N'admin', NULL, NULL, NULL)
INSERT [dbo].[IDType] ([ID], [Name], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (5, N'Govt Id Prood', 1, N'admin', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[IDType] OFF
SET IDENTITY_INSERT [dbo].[Invoice] ON 

INSERT [dbo].[Invoice] ([ID], [GuestID], [BookingID], [IsPaid], [TotalAmount], [FolioNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [DISCOUNT]) VALUES (3, 48, 50, 1, 400.1500, N'folio', 1, N'sachin', CAST(N'2017-06-07 23:00:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 150.0000)
INSERT [dbo].[Invoice] ([ID], [GuestID], [BookingID], [IsPaid], [TotalAmount], [FolioNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [DISCOUNT]) VALUES (16, 1055, 1065, 1, 500.0000, NULL, 1, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), NULL)
INSERT [dbo].[Invoice] ([ID], [GuestID], [BookingID], [IsPaid], [TotalAmount], [FolioNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [DISCOUNT]) VALUES (18, 1055, 1065, 1, 500.0000, NULL, 1, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 10.0000)
INSERT [dbo].[Invoice] ([ID], [GuestID], [BookingID], [IsPaid], [TotalAmount], [FolioNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [DISCOUNT]) VALUES (19, 1055, 1065, 1, 153.8900, NULL, 1, N'vipul', CAST(N'2017-06-16 11:06:26.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 2.4500)
INSERT [dbo].[Invoice] ([ID], [GuestID], [BookingID], [IsPaid], [TotalAmount], [FolioNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [DISCOUNT]) VALUES (20, 1055, 1065, 1, 156.1100, NULL, 1, N'vipul', CAST(N'2017-06-16 11:15:43.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 3.5600)
INSERT [dbo].[Invoice] ([ID], [GuestID], [BookingID], [IsPaid], [TotalAmount], [FolioNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [DISCOUNT]) VALUES (21, 1055, 1065, 0, 198.4500, NULL, 1, N'vipul', CAST(N'2017-06-17 13:18:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 10.0000)
INSERT [dbo].[Invoice] ([ID], [GuestID], [BookingID], [IsPaid], [TotalAmount], [FolioNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [DISCOUNT]) VALUES (22, 1055, 1065, 0, 151.0000, NULL, 1, N'vipul', CAST(N'2017-06-17 16:26:50.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 3.0000)
INSERT [dbo].[Invoice] ([ID], [GuestID], [BookingID], [IsPaid], [TotalAmount], [FolioNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [DISCOUNT]) VALUES (23, 1055, 1065, 0, 47.0000, NULL, 1, N'vipul', CAST(N'2017-06-18 12:07:57.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 3.0000)
INSERT [dbo].[Invoice] ([ID], [GuestID], [BookingID], [IsPaid], [TotalAmount], [FolioNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [DISCOUNT]) VALUES (24, 1055, 1065, 0, 47.0000, NULL, 1, N'vipul', CAST(N'2017-06-18 12:09:50.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 3.0000)
INSERT [dbo].[Invoice] ([ID], [GuestID], [BookingID], [IsPaid], [TotalAmount], [FolioNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [DISCOUNT]) VALUES (25, 1055, 1065, 1, 500.0000, NULL, 1, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 10.0000)
INSERT [dbo].[Invoice] ([ID], [GuestID], [BookingID], [IsPaid], [TotalAmount], [FolioNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [DISCOUNT]) VALUES (26, 1055, 1065, 1, 500.0000, NULL, 1, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 10.0000)
INSERT [dbo].[Invoice] ([ID], [GuestID], [BookingID], [IsPaid], [TotalAmount], [FolioNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [DISCOUNT]) VALUES (27, 1055, 1065, 0, 170.0000, NULL, 1, N'vipul', CAST(N'2017-06-18 19:53:47.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 0.0000)
INSERT [dbo].[Invoice] ([ID], [GuestID], [BookingID], [IsPaid], [TotalAmount], [FolioNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [DISCOUNT]) VALUES (28, 1055, 1065, 0, 92.4500, NULL, 1, N'vipul', CAST(N'2017-06-19 08:34:00.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 20.0000)
INSERT [dbo].[Invoice] ([ID], [GuestID], [BookingID], [IsPaid], [TotalAmount], [FolioNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [DISCOUNT]) VALUES (29, 1082, 1093, 0, 72.0500, NULL, 1, N'vipul', CAST(N'2017-06-22 00:04:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 10.4500)
INSERT [dbo].[Invoice] ([ID], [GuestID], [BookingID], [IsPaid], [TotalAmount], [FolioNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [DISCOUNT]) VALUES (30, 1083, 1094, 0, 105.0000, NULL, 1, N'vipul', CAST(N'2017-06-22 11:29:44.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 0.0000)
INSERT [dbo].[Invoice] ([ID], [GuestID], [BookingID], [IsPaid], [TotalAmount], [FolioNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [DISCOUNT]) VALUES (31, 1084, 1095, 0, 94.0000, NULL, 1, N'vipul', CAST(N'2017-06-23 13:29:24.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 0.0000)
INSERT [dbo].[Invoice] ([ID], [GuestID], [BookingID], [IsPaid], [TotalAmount], [FolioNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [DISCOUNT]) VALUES (1024, 2077, 2087, 0, 60.0000, NULL, 1, N'test', CAST(N'2017-06-30 21:30:26.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 0.0000)
INSERT [dbo].[Invoice] ([ID], [GuestID], [BookingID], [IsPaid], [TotalAmount], [FolioNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [DISCOUNT]) VALUES (1025, 2078, 2088, 0, 50.0000, NULL, 1, N'agoenka', CAST(N'2017-06-30 21:41:19.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 0.0000)
INSERT [dbo].[Invoice] ([ID], [GuestID], [BookingID], [IsPaid], [TotalAmount], [FolioNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [DISCOUNT]) VALUES (1026, 2079, 2089, 0, 81.5000, NULL, 1, N'test', CAST(N'2017-07-14 10:53:54.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 6.0000)
SET IDENTITY_INSERT [dbo].[Invoice] OFF
SET IDENTITY_INSERT [dbo].[InvoiceItems] ON 

INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1, 3, N'item1', 500.0000, 0, N'vipul', CAST(N'2017-06-07 23:00:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2, 3, N'item2', 600.0000, 0, N'vipul', CAST(N'2017-06-07 23:00:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (3, 18, N'testtax1', 2.3400, 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (4, 18, N'testtax2', 0.3400, 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (5, 18, N'baseRoomCharge', 2500.0000, 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (6, 18, N'totalRoomCharge', 4500.0000, 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (7, 19, N'othertax', 1.3400, 1, N'vipul', CAST(N'2017-06-16 11:06:26.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (8, 19, N'ROOM CHARGES', 35.0000, 1, N'vipul', CAST(N'2017-06-16 11:06:26.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (9, 19, N'Total Room Charge', 140.0000, 1, N'vipul', CAST(N'2017-06-16 11:06:26.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (10, 20, N'entertaintax', 4.6700, 1, N'vipul', CAST(N'2017-06-16 11:15:43.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (11, 20, N'ROOM CHARGES', 35.0000, 1, N'vipul', CAST(N'2017-06-16 11:15:43.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (12, 20, N'Total Room Charge', 140.0000, 1, N'vipul', CAST(N'2017-06-16 11:15:43.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (13, 21, N'othrtx', 3.4500, 1, N'vipul', CAST(N'2017-06-17 13:18:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (14, 21, N'othrtx2', 40.0000, 1, N'vipul', CAST(N'2017-06-17 13:18:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (15, 21, N'ROOM CHARGES', 35.0000, 1, N'vipul', CAST(N'2017-06-17 13:18:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (16, 21, N'Total Room Charge', 140.0000, 1, N'vipul', CAST(N'2017-06-17 13:18:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (17, 22, N'ROOM CHARGES', 35.0000, 1, N'vipul', CAST(N'2017-06-17 16:26:50.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (18, 22, N'Total Room Charge', 140.0000, 1, N'vipul', CAST(N'2017-06-17 16:26:50.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (19, 23, N'ROOM CHARGES', 35.0000, 1, N'vipul', CAST(N'2017-06-18 12:07:57.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (20, 23, N'Total Room Charge', 35.0000, 1, N'vipul', CAST(N'2017-06-18 12:07:57.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (21, 24, N'ROOM CHARGES', 35.0000, 1, N'vipul', CAST(N'2017-06-18 12:09:50.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (22, 24, N'Total Room Charge', 35.0000, 1, N'vipul', CAST(N'2017-06-18 12:09:50.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (27, 25, N'testtax1', 2.3400, 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (28, 25, N'testtax2', 0.3400, 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (29, 25, N'baseRoomCharge', 2500.0000, 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (30, 25, N'totalRoomCharge', 4500.0000, 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (31, 26, N'testtax1', 2.3400, 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (32, 26, N'testtax2', 0.3400, 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (33, 26, N'baseRoomCharge', 2500.0000, 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (34, 26, N'totalRoomCharge', 4500.0000, 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (35, 27, N'othr', 5.0000, 1, N'vipul', CAST(N'2017-06-18 19:54:01.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (36, 27, N'VAT2', 10.0000, 1, N'vipul', CAST(N'2017-06-18 19:54:01.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (37, 27, N'ROOM CHARGES', 35.0000, 1, N'vipul', CAST(N'2017-06-18 19:54:01.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (38, 27, N'Total Room Charge', 140.0000, 1, N'vipul', CAST(N'2017-06-18 19:54:01.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (43, 28, N'VAT2', 50.0000, 1, N'vipul', CAST(N'2017-06-19 08:34:00.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (44, 28, N'VAT3', 2.4500, 1, N'vipul', CAST(N'2017-06-19 08:34:00.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (45, 28, N'ROOM CHARGES', 45.0000, 1, N'vipul', CAST(N'2017-06-19 08:34:00.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (46, 28, N'Total Room Charge', 45.0000, 1, N'vipul', CAST(N'2017-06-19 08:34:00.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (49, 29, N'othertax', 2.5000, 1, N'vipul', CAST(N'2017-06-22 00:04:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (50, 29, N'ROOM CHARGES', 65.0000, 1, N'vipul', CAST(N'2017-06-22 00:04:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (51, 29, N'Total Room Charge', 65.0000, 1, N'vipul', CAST(N'2017-06-22 00:04:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (52, 30, N'otax1', 20.0000, 1, N'vipul', CAST(N'2017-06-22 11:29:44.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (53, 30, N'ROOM CHARGES', 35.0000, 1, N'vipul', CAST(N'2017-06-22 11:29:44.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (54, 30, N'Total Room Charge', 70.0000, 1, N'vipul', CAST(N'2017-06-22 11:29:44.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (58, 31, N'o2', 10.0000, 1, N'vipul', CAST(N'2017-06-23 13:29:24.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (59, 31, N'o3', 4.0000, 1, N'vipul', CAST(N'2017-06-23 13:29:24.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (60, 31, N'ROOM CHARGES', 65.0000, 1, N'vipul', CAST(N'2017-06-23 13:29:24.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (61, 31, N'Total Room Charge', 65.0000, 1, N'vipul', CAST(N'2017-06-23 13:29:24.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1021, 1024, N'gst1', 10.0000, 1, N'test', CAST(N'2017-06-30 21:30:26.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1022, 1024, N'ROOM CHARGES', 35.0000, 1, N'test', CAST(N'2017-06-30 21:30:26.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1023, 1024, N'Total Room Charge', 35.0000, 1, N'test', CAST(N'2017-06-30 21:30:26.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1024, 1025, N'ROOM CHARGES', 35.0000, 1, N'agoenka', CAST(N'2017-06-30 21:41:19.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1025, 1025, N'Total Room Charge', 35.0000, 1, N'agoenka', CAST(N'2017-06-30 21:41:19.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1026, 1026, N'new vat', 35.0000, 1, N'test', CAST(N'2017-07-14 10:53:54.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1027, 1026, N'ROOM CHARGES', 35.0000, 1, N'test', CAST(N'2017-07-14 10:53:54.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceItems] ([ID], [InvoiceID], [ItemName], [ItemValue], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1028, 1026, N'Total Room Charge', 35.0000, 1, N'test', CAST(N'2017-07-14 10:53:54.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
SET IDENTITY_INSERT [dbo].[InvoiceItems] OFF
SET IDENTITY_INSERT [dbo].[InvoicePaymentDetails] ON 

INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1, 3, N'cash', 1234.0000, N'case by sachin', 1, N'sachin', CAST(N'2017-06-07 23:00:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2, 3, N'credit', 1234.0000, N'case by sachin', 1, N'sachin', CAST(N'2017-06-07 23:00:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (3, 18, N'CASH', 545.8900, N'50% payment is done.', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (4, 19, N'Credit card', 2000.0000, N'50% payment is done.', 1, N'vipul', CAST(N'2017-06-16 11:06:26.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (5, 20, N'Credit card', 2000.0000, N'50% payment is done.', 1, N'vipul', CAST(N'2017-06-16 11:15:43.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (6, 20, N'Cash', 1000.0000, N'50% payment is done.', 1, N'vipul', CAST(N'2017-06-16 11:15:43.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (7, 21, N'Coupons', 52.0000, N'50% payment is done.', 1, N'vipul', CAST(N'2017-06-17 13:18:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (8, 22, N'', 0.0000, N'50% payment is done.', 1, N'vipul', CAST(N'2017-06-17 16:26:50.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (9, 21, N'Cash', 12.0000, N'50% payment is done.', 1, N'vipul', CAST(N'2017-06-17 13:18:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (10, 23, N'Cash', 2.0000, N'50% payment is done.', 1, N'vipul', CAST(N'2017-06-18 12:07:57.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (11, 23, N'Coupons', 4.0000, N'50% payment is done.', 1, N'vipul', CAST(N'2017-06-18 12:07:57.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (12, 23, N'Credit Card', 1.0000, N'50% payment is done.', 1, N'vipul', CAST(N'2017-06-18 12:07:57.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (13, 24, N'Cash', 10.0000, N'50% payment is done.', 1, N'vipul', CAST(N'2017-06-18 12:09:50.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (14, 24, N'Coupons', 10.0000, N'50% payment is done.', 1, N'vipul', CAST(N'2017-06-18 12:09:50.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (15, 24, N'Credit Card', 20.0000, N'50% payment is done.', 1, N'vipul', CAST(N'2017-06-18 12:09:50.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (16, 25, N'CASH', 545.8900, N'50% payment is done.', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (17, 25, N'CASH', 22.8900, N'50% payment is done.', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (18, 26, N'CASH', 545.8900, N'50% payment is done.', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (19, 26, N'CASH', 22.8900, N'50% payment is done.', 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (20, 27, N'Credit Card', 6.0000, N'50% payment is done.', 1, N'vipul', CAST(N'2017-06-18 19:54:04.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (21, 27, N'Cash', 5.0000, N'50% payment is done.', 1, N'vipul', CAST(N'2017-06-18 19:54:04.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (24, 28, N'Credit Card', 7.0000, N'50% payment is done.', 1, N'vipul', CAST(N'2017-06-19 08:34:00.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (25, 28, N'Coupons', 10.0000, N'50% payment is done.', 1, N'vipul', CAST(N'2017-06-19 08:34:00.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (28, 29, N'Credit Card', 10.0000, N'50% payment is done.', 1, N'vipul', CAST(N'2017-06-22 00:04:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (29, 29, N'Cash', 20.0000, N'50% payment is done.', 1, N'vipul', CAST(N'2017-06-22 00:04:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (30, 30, N'Credit Card', 2.5000, N'50% payment is done.', 1, N'vipul', CAST(N'2017-06-22 11:29:44.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (31, 30, N'Cash', 50.0000, N'50% payment is done.', 1, N'vipul', CAST(N'2017-06-22 11:29:44.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (33, 31, N'Credit Card', 5.0000, N'50% payment is done.', 1, N'vipul', CAST(N'2017-06-23 13:29:24.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1009, 1024, N'Credit Card', 30.0000, N'50% payment is done.', 1, N'test', CAST(N'2017-06-30 21:30:26.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoicePaymentDetails] ([ID], [InvoiceID], [PaymentMode], [PaymentValue], [PaymentDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1010, 1026, N'Credit Card', 4.0000, N'50% payment is done.', 1, N'test', CAST(N'2017-07-14 10:53:54.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
SET IDENTITY_INSERT [dbo].[InvoicePaymentDetails] OFF
SET IDENTITY_INSERT [dbo].[InvoiceTaxDetail] ON 

INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1, 3, N'gst', CAST(200.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-07 23:00:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2, 3, N'vat', CAST(100.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-07 23:00:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (3, 18, N'VAT', CAST(5.00 AS Decimal(7, 2)), 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (4, 18, N'GST', CAST(8.00 AS Decimal(7, 2)), 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (5, 19, N'GST', CAST(5.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-16 11:06:26.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (6, 19, N'VAT', CAST(7.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-16 11:06:26.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (7, 19, N'Tax3', CAST(3.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-16 11:06:26.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (8, 20, N'GST', CAST(5.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-16 11:15:43.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (9, 20, N'VAT', CAST(7.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-16 11:15:43.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (10, 20, N'Tax3', CAST(3.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-16 11:15:43.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (11, 21, N'GST', CAST(5.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-17 13:18:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (12, 21, N'VAT', CAST(7.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-17 13:18:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (13, 21, N'Tax3', CAST(3.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-17 13:18:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (14, 22, N'GST', CAST(5.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-17 16:26:50.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (15, 22, N'VAT', CAST(7.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-17 16:26:50.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (16, 22, N'Tax3', CAST(2.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-17 16:26:50.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (17, 23, N'GST', CAST(5.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-18 12:07:57.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (18, 23, N'VAT', CAST(7.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-18 12:07:57.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (19, 23, N'Tax3', CAST(3.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-18 12:07:57.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (20, 24, N'GST', CAST(5.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-18 12:09:50.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (21, 24, N'VAT', CAST(7.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-18 12:09:50.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (22, 24, N'Tax3', CAST(3.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-18 12:09:50.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (23, 25, N'VAT', CAST(5.00 AS Decimal(7, 2)), 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (24, 25, N'GST', CAST(8.00 AS Decimal(7, 2)), 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (25, 26, N'VAT', CAST(5.00 AS Decimal(7, 2)), 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (26, 26, N'GST', CAST(8.00 AS Decimal(7, 2)), 0, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (27, 27, N'GST', CAST(5.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-18 19:53:47.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (28, 27, N'VAT', CAST(7.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-18 19:53:47.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (29, 27, N'Tax3', CAST(3.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-18 19:53:47.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (33, 28, N'GST', CAST(5.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-19 08:34:00.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (34, 28, N'VAT', CAST(7.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-19 08:34:00.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (35, 28, N'Tax3', CAST(3.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-19 08:34:00.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (39, 29, N'GST', CAST(5.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-22 00:04:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (40, 29, N'VAT', CAST(7.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-22 00:04:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (41, 29, N'Tax3', CAST(3.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-22 00:04:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (42, 30, N'GST', CAST(5.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-22 11:29:44.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (43, 30, N'VAT', CAST(7.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-22 11:29:44.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (44, 30, N'Tax3', CAST(3.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-22 11:29:44.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (48, 31, N'GST', CAST(5.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-23 13:29:24.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (49, 31, N'VAT', CAST(7.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-23 13:29:24.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (50, 31, N'Tax3', CAST(3.00 AS Decimal(7, 2)), 1, N'vipul', CAST(N'2017-06-23 13:29:24.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1020, 1024, N'GST', CAST(5.00 AS Decimal(7, 2)), 1, N'test', CAST(N'2017-06-30 21:30:26.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1021, 1024, N'VAT', CAST(7.00 AS Decimal(7, 2)), 1, N'test', CAST(N'2017-06-30 21:30:26.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1022, 1024, N'Tax3', CAST(3.00 AS Decimal(7, 2)), 1, N'test', CAST(N'2017-06-30 21:30:26.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1023, 1025, N'GST', CAST(5.00 AS Decimal(7, 2)), 1, N'agoenka', CAST(N'2017-06-30 21:41:19.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1024, 1025, N'VAT', CAST(7.00 AS Decimal(7, 2)), 1, N'agoenka', CAST(N'2017-06-30 21:41:19.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1025, 1025, N'Tax3', CAST(3.00 AS Decimal(7, 2)), 1, N'agoenka', CAST(N'2017-06-30 21:41:19.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1026, 1026, N'gst', CAST(2.50 AS Decimal(7, 2)), 1, N'test', CAST(N'2017-07-14 10:53:54.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1027, 1026, N'vat', CAST(5.00 AS Decimal(7, 2)), 1, N'test', CAST(N'2017-07-14 10:53:54.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[InvoiceTaxDetail] ([ID], [InvoiceID], [TaxShortName], [TaxAmount], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1028, 1026, N'cgst', CAST(10.00 AS Decimal(7, 2)), 1, N'test', CAST(N'2017-07-14 10:53:54.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
SET IDENTITY_INSERT [dbo].[InvoiceTaxDetail] OFF
SET IDENTITY_INSERT [dbo].[PaymentType] ON 

INSERT [dbo].[PaymentType] ([ID], [PropertyID], [ShortName], [Description], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1, 1, N'CC23', N'Credit Card3456', 0, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime))
INSERT [dbo].[PaymentType] ([ID], [PropertyID], [ShortName], [Description], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2, 1, N'CC', NULL, 0, N'test', CAST(N'2017-07-13 11:35:08.000' AS DateTime), NULL, NULL)
INSERT [dbo].[PaymentType] ([ID], [PropertyID], [ShortName], [Description], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (3, 1, N'CC', N'Credit card', 0, N'test', CAST(N'2017-07-13 11:45:39.000' AS DateTime), NULL, NULL)
INSERT [dbo].[PaymentType] ([ID], [PropertyID], [ShortName], [Description], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (4, 1, N'cc23', N'Credit card', 0, N'test', CAST(N'2017-07-13 11:47:56.000' AS DateTime), N'test', CAST(N'2017-07-13 11:48:15.000' AS DateTime))
INSERT [dbo].[PaymentType] ([ID], [PropertyID], [ShortName], [Description], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (5, 1, N'db', N'Debit card', 1, N'test', CAST(N'2017-07-13 11:48:39.000' AS DateTime), NULL, NULL)
INSERT [dbo].[PaymentType] ([ID], [PropertyID], [ShortName], [Description], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (6, 1, N'PAYTM', N'PayTM', 1, N'test', CAST(N'2017-07-15 15:02:59.000' AS DateTime), N'test', CAST(N'2017-07-17 16:10:33.000' AS DateTime))
SET IDENTITY_INSERT [dbo].[PaymentType] OFF
SET IDENTITY_INSERT [dbo].[Property] ON 

INSERT [dbo].[Property] ([ID], [PropertyDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [PropertyName], [SecondaryName], [PropertyCode], [FullAddress], [Phone], [Fax], [LogoPath], [WebSiteAddress], [TimeZone], [CurrencyId], [CheckinTime], [CheckoutTime], [CloseOfDayTime], [State], [Country], [City], [Zipcode]) VALUES (1, N'vsharma', 1, N'sachin', CAST(N'2017-05-01 11:20:30.000' AS DateTime), N'sachin', CAST(N'2017-05-01 11:20:30.000' AS DateTime), N'Vipul Resort', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, 2, 3, 2, N'898987')
INSERT [dbo].[Property] ([ID], [PropertyDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [PropertyName], [SecondaryName], [PropertyCode], [FullAddress], [Phone], [Fax], [LogoPath], [WebSiteAddress], [TimeZone], [CurrencyId], [CheckinTime], [CheckoutTime], [CloseOfDayTime], [State], [Country], [City], [Zipcode]) VALUES (2, N'vsharma', 0, NULL, NULL, NULL, NULL, N'new prop2', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, NULL, NULL, 2, 3, 2, N'898987')
INSERT [dbo].[Property] ([ID], [PropertyDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [PropertyName], [SecondaryName], [PropertyCode], [FullAddress], [Phone], [Fax], [LogoPath], [WebSiteAddress], [TimeZone], [CurrencyId], [CheckinTime], [CheckoutTime], [CloseOfDayTime], [State], [Country], [City], [Zipcode]) VALUES (3, N'vsharma', 0, N'sachin', CAST(N'2017-05-01 11:25:02.610' AS DateTime), N'test', CAST(N'2017-07-10 11:43:35.000' AS DateTime), N'new prop3', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2, 3, 2, N'898987')
INSERT [dbo].[Property] ([ID], [PropertyDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [PropertyName], [SecondaryName], [PropertyCode], [FullAddress], [Phone], [Fax], [LogoPath], [WebSiteAddress], [TimeZone], [CurrencyId], [CheckinTime], [CheckoutTime], [CloseOfDayTime], [State], [Country], [City], [Zipcode]) VALUES (4, N'styagi', 0, NULL, CAST(N'2017-05-01 11:20:30.000' AS DateTime), N'test', CAST(N'2017-07-07 23:14:27.000' AS DateTime), N'Hotel Plaza76', NULL, N'PROP001', N'No11ida', NULL, NULL, NULL, N'www.prop1.com', NULL, NULL, CAST(N'01:00:00' AS Time), CAST(N'03:00:00' AS Time), NULL, 5, 3, 2, N'898987')
INSERT [dbo].[Property] ([ID], [PropertyDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [PropertyName], [SecondaryName], [PropertyCode], [FullAddress], [Phone], [Fax], [LogoPath], [WebSiteAddress], [TimeZone], [CurrencyId], [CheckinTime], [CheckoutTime], [CloseOfDayTime], [State], [Country], [City], [Zipcode]) VALUES (5, N'agoenka1', 0, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', CAST(N'2017-07-08 23:52:34.000' AS DateTime), N'Hotel Plaza4555', NULL, N'PROP001', N'Noida', NULL, NULL, NULL, N'www.prop.com', NULL, NULL, CAST(N'12:00:00' AS Time), CAST(N'23:00:00' AS Time), NULL, 5, 3, 6, N'898987')
INSERT [dbo].[Property] ([ID], [PropertyDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [PropertyName], [SecondaryName], [PropertyCode], [FullAddress], [Phone], [Fax], [LogoPath], [WebSiteAddress], [TimeZone], [CurrencyId], [CheckinTime], [CheckoutTime], [CloseOfDayTime], [State], [Country], [City], [Zipcode]) VALUES (6, N'vsharma', 0, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, NULL, N'Hotel Plaza3', NULL, N'PROP001', N'Noida', NULL, NULL, NULL, N'www.prop.com', NULL, 1, CAST(N'12:00:00' AS Time), CAST(N'23:00:00' AS Time), NULL, 2, 3, 1, N'898987')
INSERT [dbo].[Property] ([ID], [PropertyDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [PropertyName], [SecondaryName], [PropertyCode], [FullAddress], [Phone], [Fax], [LogoPath], [WebSiteAddress], [TimeZone], [CurrencyId], [CheckinTime], [CheckoutTime], [CloseOfDayTime], [State], [Country], [City], [Zipcode]) VALUES (7, N'agoenka', 0, N'vsharma', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', CAST(N'2017-07-08 16:45:59.000' AS DateTime), N'Hotel Plaza3797', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5, 3, 2, N'898987')
INSERT [dbo].[Property] ([ID], [PropertyDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [PropertyName], [SecondaryName], [PropertyCode], [FullAddress], [Phone], [Fax], [LogoPath], [WebSiteAddress], [TimeZone], [CurrencyId], [CheckinTime], [CheckoutTime], [CloseOfDayTime], [State], [Country], [City], [Zipcode]) VALUES (8, N'test', 0, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', CAST(N'2017-07-09 14:14:47.000' AS DateTime), N'Hotel Plaza3', NULL, N'PROP001', N'Noida', NULL, NULL, NULL, N'www.prop.com', NULL, NULL, CAST(N'12:00:00' AS Time), CAST(N'23:00:00' AS Time), NULL, 5, 3, 6, N'898987')
INSERT [dbo].[Property] ([ID], [PropertyDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [PropertyName], [SecondaryName], [PropertyCode], [FullAddress], [Phone], [Fax], [LogoPath], [WebSiteAddress], [TimeZone], [CurrencyId], [CheckinTime], [CheckoutTime], [CloseOfDayTime], [State], [Country], [City], [Zipcode]) VALUES (9, N'tst5', 0, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, NULL, N'Hotel Plaza3', NULL, N'PROP001', N'Noida', NULL, NULL, NULL, N'www.prop.com', NULL, NULL, CAST(N'12:00:00' AS Time), CAST(N'23:00:00' AS Time), NULL, 6, 3, 3, N'809809')
INSERT [dbo].[Property] ([ID], [PropertyDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [PropertyName], [SecondaryName], [PropertyCode], [FullAddress], [Phone], [Fax], [LogoPath], [WebSiteAddress], [TimeZone], [CurrencyId], [CheckinTime], [CheckoutTime], [CloseOfDayTime], [State], [Country], [City], [Zipcode]) VALUES (10, N'atest3', 0, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, NULL, N'Hotel Plaza3', NULL, N'PROP001', N'Noida', NULL, NULL, NULL, N'www.prop.com', NULL, NULL, CAST(N'12:00:00' AS Time), CAST(N'23:00:00' AS Time), NULL, 6, 3, 7, N'576576')
INSERT [dbo].[Property] ([ID], [PropertyDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [PropertyName], [SecondaryName], [PropertyCode], [FullAddress], [Phone], [Fax], [LogoPath], [WebSiteAddress], [TimeZone], [CurrencyId], [CheckinTime], [CheckoutTime], [CloseOfDayTime], [State], [Country], [City], [Zipcode]) VALUES (11, N'vsharma', 0, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', CAST(N'2017-07-09 13:11:04.000' AS DateTime), N'Hotel Plaza3', NULL, N'PROP001', N'Noida', NULL, NULL, NULL, N'www.prop.com', NULL, NULL, CAST(N'12:00:00' AS Time), CAST(N'23:00:00' AS Time), NULL, 5, 3, 6, N'797980')
INSERT [dbo].[Property] ([ID], [PropertyDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [PropertyName], [SecondaryName], [PropertyCode], [FullAddress], [Phone], [Fax], [LogoPath], [WebSiteAddress], [TimeZone], [CurrencyId], [CheckinTime], [CheckoutTime], [CloseOfDayTime], [State], [Country], [City], [Zipcode]) VALUES (12, N'me', 0, N'test', CAST(N'2017-07-07 11:27:42.000' AS DateTime), NULL, NULL, N'propindi', N'sec', N'p007', N'hlkhkhjlk', N'9899999999', N'8080980980', NULL, N'www.web.com', N'EST', 1, CAST(N'10:00:00' AS Time), CAST(N'23:00:00' AS Time), CAST(N'12:00:00' AS Time), 6, 3, 7, N'324243')
INSERT [dbo].[Property] ([ID], [PropertyDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [PropertyName], [SecondaryName], [PropertyCode], [FullAddress], [Phone], [Fax], [LogoPath], [WebSiteAddress], [TimeZone], [CurrencyId], [CheckinTime], [CheckoutTime], [CloseOfDayTime], [State], [Country], [City], [Zipcode]) VALUES (13, N'me1', 0, N'test', CAST(N'2017-07-07 11:42:52.000' AS DateTime), N'test', CAST(N'2017-07-09 14:16:28.000' AS DateTime), N'prop india07', N'secree', N'p009', N'delhi', N'9080808080', N'1111111111', NULL, N'www.pop.co', N'IST', NULL, CAST(N'12:00:00' AS Time), CAST(N'23:00:00' AS Time), CAST(N'03:00:00' AS Time), 6, 3, 3, N'212121')
INSERT [dbo].[Property] ([ID], [PropertyDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [PropertyName], [SecondaryName], [PropertyCode], [FullAddress], [Phone], [Fax], [LogoPath], [WebSiteAddress], [TimeZone], [CurrencyId], [CheckinTime], [CheckoutTime], [CloseOfDayTime], [State], [Country], [City], [Zipcode]) VALUES (14, N'kkkkkkkkkkkkk', 0, N'test', CAST(N'2017-07-07 16:37:36.000' AS DateTime), NULL, NULL, N'propmart', N'sef', N'm001', N'BSR', N'9999999999', N'3435355353', NULL, N'www.a.com', N'IST', 1, CAST(N'02:00:00' AS Time), CAST(N'07:00:00' AS Time), CAST(N'08:00:00' AS Time), 6, 3, 7, N'898987')
INSERT [dbo].[Property] ([ID], [PropertyDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [PropertyName], [SecondaryName], [PropertyCode], [FullAddress], [Phone], [Fax], [LogoPath], [WebSiteAddress], [TimeZone], [CurrencyId], [CheckinTime], [CheckoutTime], [CloseOfDayTime], [State], [Country], [City], [Zipcode]) VALUES (15, N'onwer1', 0, N'test', CAST(N'2017-07-07 16:53:49.000' AS DateTime), NULL, NULL, N'prop india', N'scv', N'p005', N'bsr5755', N'7777777777', N'3333333333', NULL, N'www.kl.com', N'EST', 1, CAST(N'12:00:00' AS Time), CAST(N'02:00:00' AS Time), CAST(N'08:00:00' AS Time), 6, 3, 7, N'222222')
INSERT [dbo].[Property] ([ID], [PropertyDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [PropertyName], [SecondaryName], [PropertyCode], [FullAddress], [Phone], [Fax], [LogoPath], [WebSiteAddress], [TimeZone], [CurrencyId], [CheckinTime], [CheckoutTime], [CloseOfDayTime], [State], [Country], [City], [Zipcode]) VALUES (16, N'11111111111111111111111111111111', 0, N'test', CAST(N'2017-07-08 10:13:04.000' AS DateTime), N'test', CAST(N'2017-07-08 10:13:43.000' AS DateTime), N'my prop', N'12', N'123', N'new add', N'9999999999', N'1111111111', NULL, N'www.23.com', N'IST', NULL, CAST(N'12:00:00' AS Time), CAST(N'02:00:00' AS Time), CAST(N'01:00:00' AS Time), 5, 3, 2, N'333333')
INSERT [dbo].[Property] ([ID], [PropertyDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [PropertyName], [SecondaryName], [PropertyCode], [FullAddress], [Phone], [Fax], [LogoPath], [WebSiteAddress], [TimeZone], [CurrencyId], [CheckinTime], [CheckoutTime], [CloseOfDayTime], [State], [Country], [City], [Zipcode]) VALUES (17, N'jlkjlkjlkjlkj', 0, N'test', CAST(N'2017-07-11 14:10:03.000' AS DateTime), NULL, NULL, N'VIPTESt', N'UUUU', N'TEST', N'hkhkjhhk', N'8098080980', N'8098098098', NULL, N'www.tt.com', N'EST', 1, CAST(N'12:45:00' AS Time), CAST(N'03:00:00' AS Time), CAST(N'02:00:00' AS Time), 6, 3, 4, N'809890')
INSERT [dbo].[Property] ([ID], [PropertyDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [PropertyName], [SecondaryName], [PropertyCode], [FullAddress], [Phone], [Fax], [LogoPath], [WebSiteAddress], [TimeZone], [CurrencyId], [CheckinTime], [CheckoutTime], [CloseOfDayTime], [State], [Country], [City], [Zipcode]) VALUES (18, N'me', 0, N'test', CAST(N'2017-07-11 14:26:58.000' AS DateTime), NULL, NULL, N'VIP', N'SEC001', N'V001', N'ddfdgfgf', N'8098098098', N'4324432432', NULL, N'www.dd.com', N'IST', 1, CAST(N'12:00:00' AS Time), CAST(N'02:00:00' AS Time), CAST(N'01:00:00' AS Time), 6, 3, 7, N'243243')
INSERT [dbo].[Property] ([ID], [PropertyDetails], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [PropertyName], [SecondaryName], [PropertyCode], [FullAddress], [Phone], [Fax], [LogoPath], [WebSiteAddress], [TimeZone], [CurrencyId], [CheckinTime], [CheckoutTime], [CloseOfDayTime], [State], [Country], [City], [Zipcode]) VALUES (19, N'styagi', 1, N'test', CAST(N'2017-07-11 15:10:11.000' AS DateTime), N'test', CAST(N'2017-07-11 15:11:53.000' AS DateTime), N'Sachin Hotel', N'uouoiuo', N'00723', N'dsffdsf', N'3432432432', N'7329749324', NULL, N'hjkjhkjhkj', N'EST', 1, CAST(N'12:00:00' AS Time), CAST(N'05:00:00' AS Time), CAST(N'06:00:00' AS Time), 5, 3, 6, N'434353')
SET IDENTITY_INSERT [dbo].[Property] OFF
SET IDENTITY_INSERT [dbo].[PropertyFloor] ON 

INSERT [dbo].[PropertyFloor] ([PropertyId], [ID], [FloorNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (3, 1, 2, 0, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime))
INSERT [dbo].[PropertyFloor] ([PropertyId], [ID], [FloorNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2, 2, 2, 1, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', NULL)
INSERT [dbo].[PropertyFloor] ([PropertyId], [ID], [FloorNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2, 3, 5, 1, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', NULL)
INSERT [dbo].[PropertyFloor] ([PropertyId], [ID], [FloorNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2, 4, 4, 1, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', NULL)
INSERT [dbo].[PropertyFloor] ([PropertyId], [ID], [FloorNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1, 5, 1, 1, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', CAST(N'2017-07-17 16:08:20.000' AS DateTime))
INSERT [dbo].[PropertyFloor] ([PropertyId], [ID], [FloorNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1, 6, 7, 1, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', CAST(N'2017-07-17 16:08:41.000' AS DateTime))
INSERT [dbo].[PropertyFloor] ([PropertyId], [ID], [FloorNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1, 7, 3, 1, N'test', CAST(N'2017-07-11 11:20:39.000' AS DateTime), N'test', CAST(N'2017-07-17 16:08:51.000' AS DateTime))
INSERT [dbo].[PropertyFloor] ([PropertyId], [ID], [FloorNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1, 8, 66, 1, N'test', CAST(N'2017-07-11 11:22:25.000' AS DateTime), N'test', NULL)
INSERT [dbo].[PropertyFloor] ([PropertyId], [ID], [FloorNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (6, 9, 55555, 0, N'test', CAST(N'2017-07-11 11:39:17.000' AS DateTime), N'test', CAST(N'2017-07-11 11:39:47.000' AS DateTime))
INSERT [dbo].[PropertyFloor] ([PropertyId], [ID], [FloorNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (6, 10, 89808, 0, N'test', CAST(N'2017-07-11 11:40:31.000' AS DateTime), N'test', CAST(N'2017-07-11 11:41:32.000' AS DateTime))
INSERT [dbo].[PropertyFloor] ([PropertyId], [ID], [FloorNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (6, 11, 9078, 0, N'test', CAST(N'2017-07-11 11:54:08.000' AS DateTime), N'test', CAST(N'2017-07-11 11:54:37.000' AS DateTime))
INSERT [dbo].[PropertyFloor] ([PropertyId], [ID], [FloorNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (12, 12, 34, 0, N'test', CAST(N'2017-07-11 11:58:43.000' AS DateTime), N'test', NULL)
INSERT [dbo].[PropertyFloor] ([PropertyId], [ID], [FloorNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (14, 13, 567, 1, N'test', CAST(N'2017-07-11 11:59:16.000' AS DateTime), N'test', NULL)
INSERT [dbo].[PropertyFloor] ([PropertyId], [ID], [FloorNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1, 14, 67, 1, N'test', CAST(N'2017-07-15 15:02:04.000' AS DateTime), N'test', NULL)
INSERT [dbo].[PropertyFloor] ([PropertyId], [ID], [FloorNumber], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1, 15, 5, 1, N'test', CAST(N'2017-07-18 22:14:23.000' AS DateTime), N'test', NULL)
SET IDENTITY_INSERT [dbo].[PropertyFloor] OFF
SET IDENTITY_INSERT [dbo].[Rates] ON 

INSERT [dbo].[Rates] ([ID], [Type], [PropertyID], [RateTypeID], [RoomTypeID], [InputKeyHours], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [RoomId]) VALUES (1, N'Hourly', 1, 1, 1, 2, 35.0000, 0, N'vipul', NULL, NULL, NULL, NULL)
INSERT [dbo].[Rates] ([ID], [Type], [PropertyID], [RateTypeID], [RoomTypeID], [InputKeyHours], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [RoomId]) VALUES (2, N'Hourly', 1, 1, 1, 1, 15.0000, 0, N'vipul', NULL, NULL, NULL, NULL)
INSERT [dbo].[Rates] ([ID], [Type], [PropertyID], [RateTypeID], [RoomTypeID], [InputKeyHours], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [RoomId]) VALUES (3, N'Hourly', 1, 1, 1, 4, 45.0000, 0, N'vipul', NULL, NULL, NULL, NULL)
INSERT [dbo].[Rates] ([ID], [Type], [PropertyID], [RateTypeID], [RoomTypeID], [InputKeyHours], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [RoomId]) VALUES (4, N'Hourly', 1, 1, 1, 6, 65.0000, 0, N'vipul', NULL, NULL, NULL, NULL)
INSERT [dbo].[Rates] ([ID], [Type], [PropertyID], [RateTypeID], [RoomTypeID], [InputKeyHours], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [RoomId]) VALUES (5, N'Hourly', 2, 1, 1, 2, 35.0000, 0, N'vipul', NULL, NULL, NULL, NULL)
INSERT [dbo].[Rates] ([ID], [Type], [PropertyID], [RateTypeID], [RoomTypeID], [InputKeyHours], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [RoomId]) VALUES (6, N'Hourly', 2, 1, 1, 1, 15.0000, 0, N'vipul', NULL, NULL, NULL, NULL)
INSERT [dbo].[Rates] ([ID], [Type], [PropertyID], [RateTypeID], [RoomTypeID], [InputKeyHours], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [RoomId]) VALUES (7, N'Hourly', 2, 1, 1, 4, 45.0000, 0, N'vipul', NULL, NULL, NULL, NULL)
INSERT [dbo].[Rates] ([ID], [Type], [PropertyID], [RateTypeID], [RoomTypeID], [InputKeyHours], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [RoomId]) VALUES (8, N'Hourly', 2, 1, 1, 6, 65.0000, 0, N'vipul', NULL, NULL, NULL, NULL)
INSERT [dbo].[Rates] ([ID], [Type], [PropertyID], [RateTypeID], [RoomTypeID], [InputKeyHours], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [RoomId]) VALUES (9, N'Hourly', 1, 2, 1, 2, 15.0000, 0, N'vipul', NULL, NULL, NULL, NULL)
INSERT [dbo].[Rates] ([ID], [Type], [PropertyID], [RateTypeID], [RoomTypeID], [InputKeyHours], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [RoomId]) VALUES (10, N'Daily', 1, 21, 2, 0, 78.9800, 1, N'vipul', CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'test', CAST(N'2017-07-19 13:57:28.000' AS DateTime), 7)
INSERT [dbo].[Rates] ([ID], [Type], [PropertyID], [RateTypeID], [RoomTypeID], [InputKeyHours], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [RoomId]) VALUES (11, N'Hourly', 1, 20, 1, 4, 25.0000, 1, N'vipul', NULL, NULL, NULL, 14)
INSERT [dbo].[Rates] ([ID], [Type], [PropertyID], [RateTypeID], [RoomTypeID], [InputKeyHours], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [RoomId]) VALUES (12, N'Hourly', 1, 19, 1, 6, 45.0000, 1, N'vipul', NULL, NULL, NULL, 15)
INSERT [dbo].[Rates] ([ID], [Type], [PropertyID], [RateTypeID], [RoomTypeID], [InputKeyHours], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [RoomId]) VALUES (13, N'Daily', 1, 18, 2, 0, 6.0000, 1, N'vipul', CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'test', CAST(N'2017-07-19 14:32:20.000' AS DateTime), 6)
INSERT [dbo].[Rates] ([ID], [Type], [PropertyID], [RateTypeID], [RoomTypeID], [InputKeyHours], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [RoomId]) VALUES (14, N'Daily', 1, 21, 2, 0, 7676.0000, 1, N'vipul', CAST(N'1900-01-01 00:00:00.000' AS DateTime), N'test', CAST(N'2017-07-19 14:38:32.000' AS DateTime), 5)
INSERT [dbo].[Rates] ([ID], [Type], [PropertyID], [RateTypeID], [RoomTypeID], [InputKeyHours], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [RoomId]) VALUES (16, N'Hourly', NULL, NULL, NULL, 4, 2.5000, 0, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 3)
INSERT [dbo].[Rates] ([ID], [Type], [PropertyID], [RateTypeID], [RoomTypeID], [InputKeyHours], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [RoomId]) VALUES (17, N'Hourly', 1, 2, 1, 4, 2.5000, 1, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), 3)
INSERT [dbo].[Rates] ([ID], [Type], [PropertyID], [RateTypeID], [RoomTypeID], [InputKeyHours], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [RoomId]) VALUES (18, N'Hourly', 2, 2, 1, 4, 2.5000, 1, N'vipul', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 3)
INSERT [dbo].[Rates] ([ID], [Type], [PropertyID], [RateTypeID], [RoomTypeID], [InputKeyHours], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [RoomId]) VALUES (22, N'Hourly', 2, 2, 1, 4, 2.5000, 1, N'vipul123', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 3)
INSERT [dbo].[Rates] ([ID], [Type], [PropertyID], [RateTypeID], [RoomTypeID], [InputKeyHours], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [RoomId]) VALUES (23, N'Daily', 2, 2, 1, 0, 2.5000, 1, N'vipul123', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 3)
INSERT [dbo].[Rates] ([ID], [Type], [PropertyID], [RateTypeID], [RoomTypeID], [InputKeyHours], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [RoomId]) VALUES (24, N'Daily', 1, 21, 2, 0, 6.0000, 1, N'test', CAST(N'2017-07-19 10:14:23.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 5)
INSERT [dbo].[Rates] ([ID], [Type], [PropertyID], [RateTypeID], [RoomTypeID], [InputKeyHours], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [RoomId]) VALUES (25, N'Daily', 1, 18, 3, 0, 90.0000, 0, N'test', CAST(N'2017-07-19 12:45:19.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime), 18)
SET IDENTITY_INSERT [dbo].[Rates] OFF
SET IDENTITY_INSERT [dbo].[RateType] ON 

INSERT [dbo].[RateType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [Units], [Hours]) VALUES (1, 1, 0, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', CAST(N'2017-07-15 18:19:08.000' AS DateTime), N'new ratetype daily1', N'Daily', NULL)
INSERT [dbo].[RateType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [Units], [Hours]) VALUES (2, 1, 0, N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), N'Apartment Standard', N'Hourly', 3)
INSERT [dbo].[RateType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [Units], [Hours]) VALUES (3, 1, 0, N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), N'Queen Standard', N'Hourly', 4)
INSERT [dbo].[RateType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [Units], [Hours]) VALUES (4, 1, 0, N'sachin', CAST(N'2017-05-01 11:31:06.573' AS DateTime), N'sachin', CAST(N'2017-07-15 17:37:30.000' AS DateTime), N'Holiday Standard Daily', N'Daily', NULL)
INSERT [dbo].[RateType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [Units], [Hours]) VALUES (5, 1, 0, N'sachin', CAST(N'2017-05-01 11:31:06.573' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.573' AS DateTime), N'My Weekend Standard', N'Hourly', 4)
INSERT [dbo].[RateType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [Units], [Hours]) VALUES (6, 2, 0, N'sachin', CAST(N'2017-05-01 11:31:06.573' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.573' AS DateTime), N'2Apartment Standard Test', N'Hourly', 5)
INSERT [dbo].[RateType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [Units], [Hours]) VALUES (7, 2, 0, N'sachin', CAST(N'2017-05-01 11:31:06.573' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.573' AS DateTime), N'2Apartment Standard', N'Daily', 0)
INSERT [dbo].[RateType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [Units], [Hours]) VALUES (8, 2, 0, N'sachin', CAST(N'2017-05-01 11:31:06.573' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.573' AS DateTime), N'2Queen Standard', N'Daily', 0)
INSERT [dbo].[RateType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [Units], [Hours]) VALUES (9, 1, 0, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'ratetype23', N'Daily', 0)
INSERT [dbo].[RateType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [Units], [Hours]) VALUES (10, 1, 0, N'test', CAST(N'2017-07-15 08:47:43.000' AS DateTime), N'test', CAST(N'2017-07-15 17:37:11.000' AS DateTime), N'Delux rate type', N'Daily', NULL)
INSERT [dbo].[RateType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [Units], [Hours]) VALUES (11, 1, 0, N'test', CAST(N'2017-07-15 15:35:08.000' AS DateTime), NULL, NULL, N'Super Queen', N'Hourly', 3)
INSERT [dbo].[RateType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [Units], [Hours]) VALUES (12, 1, 0, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'ratetype23', N'Daily', NULL)
INSERT [dbo].[RateType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [Units], [Hours]) VALUES (13, 1, 0, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, NULL, N'Hourly4', N'Daily', NULL)
INSERT [dbo].[RateType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [Units], [Hours]) VALUES (14, 1, 0, N'test', CAST(N'2017-07-15 19:08:30.000' AS DateTime), N'test', CAST(N'2017-07-15 19:08:57.000' AS DateTime), N'daily1', N'Hourly', 5)
INSERT [dbo].[RateType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [Units], [Hours]) VALUES (15, 1, 0, N'test', CAST(N'2017-07-15 19:15:05.000' AS DateTime), NULL, NULL, N'fddgdg', N'Daily', NULL)
INSERT [dbo].[RateType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [Units], [Hours]) VALUES (16, 1, 0, N'test', CAST(N'2017-07-16 15:59:00.000' AS DateTime), NULL, NULL, N'Weekday', N'Daily', NULL)
INSERT [dbo].[RateType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [Units], [Hours]) VALUES (17, 1, 0, N'test', CAST(N'2017-07-16 15:59:38.000' AS DateTime), NULL, NULL, N'Weekend', N'Daily', NULL)
INSERT [dbo].[RateType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [Units], [Hours]) VALUES (18, 1, 1, N'test', CAST(N'2017-07-16 16:02:41.000' AS DateTime), NULL, NULL, N'Weekday', N'Daily', NULL)
INSERT [dbo].[RateType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [Units], [Hours]) VALUES (19, 1, 1, N'test', CAST(N'2017-07-16 16:03:06.000' AS DateTime), NULL, NULL, N'Hourly1', N'Hourly', 2)
INSERT [dbo].[RateType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [Units], [Hours]) VALUES (20, 1, 1, N'test', CAST(N'2017-07-16 16:03:25.000' AS DateTime), N'test', CAST(N'2017-07-17 16:12:41.000' AS DateTime), N'Hourly3', N'Hourly', 5)
INSERT [dbo].[RateType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [Units], [Hours]) VALUES (21, 1, 1, N'test', CAST(N'2017-07-16 16:03:46.000' AS DateTime), NULL, NULL, N'Weekend', N'Daily', NULL)
SET IDENTITY_INSERT [dbo].[RateType] OFF
SET IDENTITY_INSERT [dbo].[Room] ON 

INSERT [dbo].[Room] ([ID], [PropertyID], [RoomTypeID], [Number], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [FloorId]) VALUES (1, 1, 1, N'R1-101', 1, N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), 1)
INSERT [dbo].[Room] ([ID], [PropertyID], [RoomTypeID], [Number], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [FloorId]) VALUES (2, 1, 1, N'R1-102', 1, N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), 2)
INSERT [dbo].[Room] ([ID], [PropertyID], [RoomTypeID], [Number], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [FloorId]) VALUES (3, 1, 1, N'R1-103', 1, N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), 3)
INSERT [dbo].[Room] ([ID], [PropertyID], [RoomTypeID], [Number], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [FloorId]) VALUES (4, 1, 1, N'R1-104', 1, N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), 4)
INSERT [dbo].[Room] ([ID], [PropertyID], [RoomTypeID], [Number], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [FloorId]) VALUES (5, 1, 2, N'R1-105', 1, N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), 3)
INSERT [dbo].[Room] ([ID], [PropertyID], [RoomTypeID], [Number], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [FloorId]) VALUES (6, 1, 2, N'R1-106', 1, N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), 4)
INSERT [dbo].[Room] ([ID], [PropertyID], [RoomTypeID], [Number], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [FloorId]) VALUES (7, 1, 2, N'R1-107', 1, N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), 2)
INSERT [dbo].[Room] ([ID], [PropertyID], [RoomTypeID], [Number], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [FloorId]) VALUES (8, 1, 3, N'R1-108', 1, N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), 1)
INSERT [dbo].[Room] ([ID], [PropertyID], [RoomTypeID], [Number], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [FloorId]) VALUES (9, 2, 1, N'R2-101', 1, N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), 3)
INSERT [dbo].[Room] ([ID], [PropertyID], [RoomTypeID], [Number], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [FloorId]) VALUES (10, 2, 1, N'R2-102', 1, N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), 2)
INSERT [dbo].[Room] ([ID], [PropertyID], [RoomTypeID], [Number], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [FloorId]) VALUES (11, 2, 1, N'RN007', 0, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test123', CAST(N'2017-05-05 10:20:07.000' AS DateTime), 4)
INSERT [dbo].[Room] ([ID], [PropertyID], [RoomTypeID], [Number], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [FloorId]) VALUES (12, 2, 1, N'R2-104', 1, N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), 1)
INSERT [dbo].[Room] ([ID], [PropertyID], [RoomTypeID], [Number], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [FloorId]) VALUES (13, 2, 2, N'R2-105', 1, N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), 3)
INSERT [dbo].[Room] ([ID], [PropertyID], [RoomTypeID], [Number], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [FloorId]) VALUES (14, 2, 2, N'R2-106', 1, N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), 1)
INSERT [dbo].[Room] ([ID], [PropertyID], [RoomTypeID], [Number], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [FloorId]) VALUES (15, 2, 2, N'R2-107', 1, N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), 1)
INSERT [dbo].[Room] ([ID], [PropertyID], [RoomTypeID], [Number], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [FloorId]) VALUES (16, 2, 3, N'R2-108', 1, N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), 2)
INSERT [dbo].[Room] ([ID], [PropertyID], [RoomTypeID], [Number], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [FloorId]) VALUES (17, 2, 1, N'RN107', 0, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test123', CAST(N'2017-05-05 10:20:07.000' AS DateTime), 3)
INSERT [dbo].[Room] ([ID], [PropertyID], [RoomTypeID], [Number], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [FloorId]) VALUES (18, 1, 3, N'RN001', 1, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, NULL, 2)
INSERT [dbo].[Room] ([ID], [PropertyID], [RoomTypeID], [Number], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [FloorId]) VALUES (19, 19, 5, N'R2-108', 1, N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), N'sachin', CAST(N'2017-05-01 11:31:06.570' AS DateTime), 2)
INSERT [dbo].[Room] ([ID], [PropertyID], [RoomTypeID], [Number], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [FloorId]) VALUES (20, 19, 6, N'RN107', 0, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test123', CAST(N'2017-05-05 10:20:07.000' AS DateTime), 3)
INSERT [dbo].[Room] ([ID], [PropertyID], [RoomTypeID], [Number], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [FloorId]) VALUES (21, 19, 7, N'RN001', 1, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, NULL, 2)
SET IDENTITY_INSERT [dbo].[Room] OFF
SET IDENTITY_INSERT [dbo].[RoomBooking] ON 

INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (24, 49, 50, 6, 0, CAST(2.00 AS Decimal(7, 2)), CAST(12.00 AS Decimal(7, 2)), 1, N'v', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (25, 50, 51, 1, 0, CAST(2.00 AS Decimal(7, 2)), CAST(12.00 AS Decimal(7, 2)), 1, N'v', CAST(N'2017-05-18 15:35:27.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (26, 51, 52, 3, 0, CAST(2.00 AS Decimal(7, 2)), CAST(12.00 AS Decimal(7, 2)), 1, N'v', CAST(N'2017-05-23 21:37:12.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (27, 52, 53, 1, 0, CAST(2.00 AS Decimal(7, 2)), CAST(12.00 AS Decimal(7, 2)), 1, N'v', CAST(N'2017-05-25 09:33:19.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (28, 53, 54, 2, 0, CAST(2.00 AS Decimal(7, 2)), CAST(12.00 AS Decimal(7, 2)), 1, N'v', CAST(N'2017-05-25 10:05:09.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (29, 54, 55, 4, 0, CAST(2.00 AS Decimal(7, 2)), CAST(12.00 AS Decimal(7, 2)), 1, N'v', CAST(N'2017-05-25 11:14:42.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (30, 55, 56, 4, 0, CAST(2.00 AS Decimal(7, 2)), CAST(12.00 AS Decimal(7, 2)), 1, N'v', CAST(N'2017-05-25 11:20:02.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1020, 48, 1046, 5, 0, CAST(2.00 AS Decimal(7, 2)), CAST(12.00 AS Decimal(7, 2)), 1, N'v', CAST(N'2017-06-06 10:07:09.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1021, 51, 1047, 1, 0, CAST(2.00 AS Decimal(7, 2)), CAST(12.00 AS Decimal(7, 2)), 1, N'v', CAST(N'2017-06-07 09:33:59.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1022, 51, 1048, 1, 0, CAST(2.00 AS Decimal(7, 2)), CAST(12.00 AS Decimal(7, 2)), 1, N'v', CAST(N'2017-06-07 09:39:37.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1023, 51, 1049, 2, 0, CAST(2.00 AS Decimal(7, 2)), CAST(12.00 AS Decimal(7, 2)), 1, N'v', CAST(N'2017-06-07 10:08:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1024, 51, 1050, 1, 0, CAST(2.00 AS Decimal(7, 2)), CAST(12.00 AS Decimal(7, 2)), 1, N'v', CAST(N'2017-06-07 10:52:56.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1025, 1045, 1051, 1, 0, CAST(2.00 AS Decimal(7, 2)), CAST(12.00 AS Decimal(7, 2)), 1, N'v', CAST(N'2017-06-07 23:00:41.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1026, 48, 1052, 1, 0, CAST(2.00 AS Decimal(7, 2)), CAST(12.00 AS Decimal(7, 2)), 1, N'v', CAST(N'2017-06-08 12:59:45.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1027, 1045, 1053, 1, 0, CAST(2.00 AS Decimal(7, 2)), CAST(12.00 AS Decimal(7, 2)), 1, N'v', CAST(N'2017-06-11 19:14:29.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1028, 1047, 1056, 3, 0, CAST(2.00 AS Decimal(7, 2)), CAST(45.00 AS Decimal(7, 2)), 0, N'v', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1029, 1048, 1057, 3, 0, CAST(2.00 AS Decimal(7, 2)), CAST(45.00 AS Decimal(7, 2)), 0, N'v', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1030, 54, 1061, 1, 0, CAST(2.00 AS Decimal(7, 2)), CAST(12.00 AS Decimal(7, 2)), 1, N'v', CAST(N'2017-06-11 19:46:54.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1031, 1053, 1063, 2, 0, CAST(2.00 AS Decimal(7, 2)), CAST(12.00 AS Decimal(7, 2)), 1, N'v', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1032, 1055, 1065, 2, 0, CAST(2.00 AS Decimal(7, 2)), CAST(12.00 AS Decimal(7, 2)), 1, N'v', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1033, 1056, 1066, 2, 0, NULL, NULL, 1, N'v', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1034, 1057, 1067, 2, 0, NULL, NULL, 1, N'v', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1035, 1059, 1069, 2, 0, NULL, NULL, 1, N'v', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1036, 1060, 1070, 2, 0, NULL, NULL, 1, N'v', CAST(N'2017-06-15 15:50:36.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1037, 1068, 1078, 2, 0, NULL, NULL, 1, N'v', CAST(N'2017-06-16 07:40:51.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1038, 1069, 1079, 2, 0, NULL, NULL, 1, N'v', CAST(N'2017-06-16 07:40:51.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1039, 1070, 1080, 2, 0, NULL, NULL, 1, N'v', CAST(N'2017-06-16 07:40:51.000' AS DateTime), NULL, NULL)
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1040, 1072, 1082, 3, 0, NULL, NULL, 0, N'v', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1041, 1073, 1083, 3, 0, NULL, NULL, 0, N'v', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1042, 1074, 1084, 3, 0, NULL, NULL, 0, N'v', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1043, 1075, 1085, 3, 0, NULL, NULL, 1, N'v', CAST(N'2017-06-16 09:03:02.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1044, 1076, 1086, 3, 0, NULL, NULL, 0, N'v', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1045, 1077, 1087, 3, 0, NULL, NULL, 0, N'v', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1046, 1078, 1088, 3, 0, NULL, NULL, 0, N'v', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1047, 1079, 1089, 3, 0, NULL, NULL, 0, N'v', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1048, 54, 1090, 1, 0, NULL, NULL, 1, N'v', CAST(N'2017-06-18 21:12:57.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1049, 1080, 1091, 1, 0, NULL, NULL, 1, N'v', CAST(N'2017-06-21 22:54:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1050, 1081, 1092, 3, 0, NULL, NULL, 0, N'v', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1051, 1082, 1093, 2, 0, NULL, NULL, 1, N'v', CAST(N'2017-06-21 23:10:18.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1052, 1083, 1094, 3, 0, NULL, NULL, 1, N'vipul', CAST(N'2017-06-22 13:03:11.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (1053, 1084, 1095, 1, 0, NULL, NULL, 1, N'vipul', CAST(N'2017-06-23 00:15:13.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2044, 2076, 2086, 1, 0, NULL, NULL, 1, N'test', CAST(N'2017-06-30 21:03:55.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2045, 2077, 2087, 1, 0, NULL, NULL, 1, N'test', CAST(N'2017-06-30 21:25:14.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2046, 2077, 2087, 1, 0, NULL, NULL, 1, N'test', CAST(N'2017-06-30 21:29:59.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2047, 2078, 2088, 2, 0, NULL, NULL, 1, N'agoenka', CAST(N'2017-06-30 21:40:31.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
INSERT [dbo].[RoomBooking] ([ID], [GuestID], [BookingID], [RoomID], [IsExtra], [Discount], [RoomCharges], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2048, 2079, 2089, 1, 0, NULL, NULL, 1, N'test', CAST(N'2017-07-14 10:52:08.000' AS DateTime), NULL, CAST(N'1900-01-01 00:00:00.000' AS DateTime))
SET IDENTITY_INSERT [dbo].[RoomBooking] OFF
SET IDENTITY_INSERT [dbo].[RoomType] ON 

INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (1, NULL, 1, N'sachin', CAST(N'2017-05-01 11:20:30.000' AS DateTime), N'test', CAST(N'2017-07-17 15:29:23.000' AS DateTime), N'King-Smoking1', N'SUPER')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (2, 1, 1, N'sachin', CAST(N'2017-05-01 11:26:47.573' AS DateTime), N'sachin', CAST(N'2017-05-01 11:26:47.573' AS DateTime), N'King-NonSmoking', N'sfd')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (3, 1, 1, N'sachin', CAST(N'2017-05-01 11:26:47.573' AS DateTime), N'sachin', CAST(N'2017-05-01 11:26:47.573' AS DateTime), N'Queen-Smoking', N'fds')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (4, 1, 0, N'sachin', CAST(N'2017-05-01 11:26:47.593' AS DateTime), N'sachin', CAST(N'2017-05-01 11:26:47.593' AS DateTime), N'Test King-Smoking', N'fd')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (5, 19, 1, N'sachin', CAST(N'2017-05-01 11:27:30.580' AS DateTime), N'sachin', CAST(N'2017-05-01 11:27:30.580' AS DateTime), N'2King-Smoking', N'fds')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (6, 19, 1, N'sachin', CAST(N'2017-05-01 11:27:30.580' AS DateTime), N'sachin', CAST(N'2017-05-01 11:27:30.580' AS DateTime), N'2King-NonSmoking', N'ada')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (7, 19, 1, N'sachin', CAST(N'2017-05-01 11:27:30.583' AS DateTime), N'sachin', CAST(N'2017-05-01 11:27:30.583' AS DateTime), N'2Queen-Smoking', N'fgg')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (8, 2, 1, N'sachin', CAST(N'2017-05-01 11:27:30.603' AS DateTime), N'sachin', CAST(N'2017-05-01 11:27:30.603' AS DateTime), N'2Test King-Smoking', N'eqe')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (9, 2, 1, NULL, NULL, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'Super Delux', N'SUP')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (10, 1, 1, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, NULL, N'Delux', N'Del')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (11, 2, 0, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'Super Exlux', N'SUP')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (12, 1, 1, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), NULL, NULL, N'Executive Delux', N'EXE')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (13, 12, 0, N'test', CAST(N'2017-07-10 16:10:09.000' AS DateTime), N'test', CAST(N'2017-07-10 16:11:13.000' AS DateTime), N'myroomtype', N'CODE001')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (14, 14, 0, N'test', CAST(N'2017-07-10 16:22:02.000' AS DateTime), NULL, NULL, N'testtyp', N'800')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (15, 15, 0, N'test', CAST(N'2017-07-10 16:27:38.000' AS DateTime), NULL, NULL, N'myroo123', N'1234')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (16, 16, 0, N'test', CAST(N'2017-07-10 16:31:02.000' AS DateTime), NULL, NULL, N'hiroomtype', N'hifi')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (17, 16, 1, N'test', CAST(N'2017-07-10 16:31:50.000' AS DateTime), NULL, NULL, N'romt', N'456')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (18, 1, 1, N'test', CAST(N'2017-07-10 16:59:47.000' AS DateTime), NULL, NULL, N'hello123', N'EXECU')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (19, 1, 1, N'test', CAST(N'2017-07-10 17:06:01.000' AS DateTime), NULL, NULL, N'superdelux', N'QUEEN')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (20, 12, 0, N'test', CAST(N'2017-07-10 17:06:32.000' AS DateTime), NULL, NULL, N'ProperRoomTYpe', N'TYP1')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (21, 15, 0, N'test', CAST(N'2017-07-11 11:59:54.000' AS DateTime), NULL, NULL, N'rttt', N'wer')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (22, 15, 0, N'test', CAST(N'2017-07-11 12:00:20.000' AS DateTime), NULL, NULL, N'hhh', N'gdgf')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (23, 1, 1, N'test', CAST(N'2017-07-15 15:01:13.000' AS DateTime), N'test', CAST(N'2017-07-17 16:11:56.000' AS DateTime), N'TYPE2', N'TEST')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (24, 1, 1, N'test', CAST(N'2017-07-18 21:52:41.000' AS DateTime), NULL, NULL, N'New King Room', N'NKR')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (25, 1, 1, N'test', CAST(N'2017-07-18 21:59:06.000' AS DateTime), NULL, NULL, N'NewSmokingRoom', N'NSR')
INSERT [dbo].[RoomType] ([ID], [PropertyID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [NAME], [ShortName]) VALUES (26, 1, 1, N'test', CAST(N'2017-07-18 22:00:05.000' AS DateTime), NULL, NULL, N'Test', N'TEST1')
SET IDENTITY_INSERT [dbo].[RoomType] OFF
SET IDENTITY_INSERT [dbo].[State] ON 

INSERT [dbo].[State] ([ID], [Name], [CountryID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (2, N'Alabama ', 3, 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, NULL)
INSERT [dbo].[State] ([ID], [Name], [CountryID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (3, N'Alaska', 3, 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, NULL)
INSERT [dbo].[State] ([ID], [Name], [CountryID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (4, N'Arizona', 3, 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, NULL)
INSERT [dbo].[State] ([ID], [Name], [CountryID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (5, N'Arkansas', 3, 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, NULL)
INSERT [dbo].[State] ([ID], [Name], [CountryID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (6, N'California', 3, 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, NULL)
INSERT [dbo].[State] ([ID], [Name], [CountryID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (7, N'UP', 1, 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, NULL)
INSERT [dbo].[State] ([ID], [Name], [CountryID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (8, N'Punjab', 1, 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, NULL)
INSERT [dbo].[State] ([ID], [Name], [CountryID], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn]) VALUES (9, N'Gujarat', 1, 1, N'vipul', CAST(N'2017-05-17 16:01:08.000' AS DateTime), NULL, NULL)
SET IDENTITY_INSERT [dbo].[State] OFF
SET IDENTITY_INSERT [dbo].[Taxes] ON 

INSERT [dbo].[Taxes] ([ID], [PropertyID], [TaxId], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [TaxName]) VALUES (1, 1, NULL, 1.2000, 1, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', CAST(N'2017-07-15 13:29:49.000' AS DateTime), N'gst')
INSERT [dbo].[Taxes] ([ID], [PropertyID], [TaxId], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [TaxName]) VALUES (2, 1, NULL, 10.0000, 1, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', CAST(N'2017-07-17 16:11:05.000' AS DateTime), N'VAT')
INSERT [dbo].[Taxes] ([ID], [PropertyID], [TaxId], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [TaxName]) VALUES (3, 2, NULL, 4.5000, 1, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', NULL, N'vat23')
INSERT [dbo].[Taxes] ([ID], [PropertyID], [TaxId], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [TaxName]) VALUES (4, 2, NULL, 4.5000, 1, N'test', CAST(N'2017-05-05 10:20:07.000' AS DateTime), N'test', NULL, N'cgst122')
INSERT [dbo].[Taxes] ([ID], [PropertyID], [TaxId], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [TaxName]) VALUES (5, 1, NULL, 10.0000, 1, N'test', CAST(N'2017-07-14 10:29:12.000' AS DateTime), NULL, NULL, N'cgst')
INSERT [dbo].[Taxes] ([ID], [PropertyID], [TaxId], [Value], [IsActive], [CreatedBy], [CreatedOn], [LastUpdatedBy], [LastUpdatedOn], [TaxName]) VALUES (6, 1, NULL, 3.0000, 1, N'test', CAST(N'2017-07-15 15:03:33.000' AS DateTime), NULL, NULL, N'SGST')
SET IDENTITY_INSERT [dbo].[Taxes] OFF
SET ANSI_PADDING ON

GO
/****** Object:  Index [DF_ExtraCharges_Unique]    Script Date: 7/19/2017 2:40:13 PM ******/
ALTER TABLE [dbo].[ExtraCharges] ADD  CONSTRAINT [DF_ExtraCharges_Unique] UNIQUE NONCLUSTERED 
(
	[PropertyID] ASC,
	[FacilityName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ChargableFacility] ADD  CONSTRAINT [DF_ChargableFacility_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[GuestReward] ADD  CONSTRAINT [DF__GuestRewa__IsAct__7F2BE32F]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[RewardCategory] ADD  CONSTRAINT [DF__RewardCat__IsAct__02FC7413]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[RoomPricing] ADD  CONSTRAINT [DF__RoomPrici__IsAct__04E4BC85]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[AdditionalGuests]  WITH CHECK ADD  CONSTRAINT [FK__Additiona__Booki__6442E2C9] FOREIGN KEY([BookingId])
REFERENCES [dbo].[Booking] ([ID])
GO
ALTER TABLE [dbo].[AdditionalGuests] CHECK CONSTRAINT [FK__Additiona__Booki__6442E2C9]
GO
ALTER TABLE [dbo].[Address]  WITH CHECK ADD  CONSTRAINT [FK__Address__Address__1920BF5C] FOREIGN KEY([AddressTypeID])
REFERENCES [dbo].[AddressType] ([ID])
GO
ALTER TABLE [dbo].[Address] CHECK CONSTRAINT [FK__Address__Address__1920BF5C]
GO
ALTER TABLE [dbo].[Address]  WITH CHECK ADD  CONSTRAINT [FK__Address__GuestID__1A14E395] FOREIGN KEY([GuestID])
REFERENCES [dbo].[Guest] ([ID])
GO
ALTER TABLE [dbo].[Address] CHECK CONSTRAINT [FK__Address__GuestID__1A14E395]
GO
ALTER TABLE [dbo].[Booking]  WITH CHECK ADD  CONSTRAINT [FK__Booking__Propert__1273C1CD] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([ID])
GO
ALTER TABLE [dbo].[Booking] CHECK CONSTRAINT [FK__Booking__Propert__1273C1CD]
GO
ALTER TABLE [dbo].[City]  WITH CHECK ADD  CONSTRAINT [FK__City__CountryID__48CFD27E] FOREIGN KEY([CountryID])
REFERENCES [dbo].[Country] ([ID])
GO
ALTER TABLE [dbo].[City] CHECK CONSTRAINT [FK__City__CountryID__48CFD27E]
GO
ALTER TABLE [dbo].[City]  WITH CHECK ADD  CONSTRAINT [FK__City__StateID__47DBAE45] FOREIGN KEY([StateID])
REFERENCES [dbo].[State] ([ID])
GO
ALTER TABLE [dbo].[City] CHECK CONSTRAINT [FK__City__StateID__47DBAE45]
GO
ALTER TABLE [dbo].[ExtraCharges]  WITH CHECK ADD  CONSTRAINT [FK__ExtraChar__Prope__214BF109] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([ID])
GO
ALTER TABLE [dbo].[ExtraCharges] CHECK CONSTRAINT [FK__ExtraChar__Prope__214BF109]
GO
ALTER TABLE [dbo].[GuestMapping]  WITH CHECK ADD  CONSTRAINT [FK__GuestMapp__GUEST__1FCDBCEB] FOREIGN KEY([GUESTID])
REFERENCES [dbo].[Guest] ([ID])
GO
ALTER TABLE [dbo].[GuestMapping] CHECK CONSTRAINT [FK__GuestMapp__GUEST__1FCDBCEB]
GO
ALTER TABLE [dbo].[GuestMapping]  WITH CHECK ADD  CONSTRAINT [FK__GuestMapp__IDTYP__1ED998B2] FOREIGN KEY([IDTYPEID])
REFERENCES [dbo].[IDType] ([ID])
GO
ALTER TABLE [dbo].[GuestMapping] CHECK CONSTRAINT [FK__GuestMapp__IDTYP__1ED998B2]
GO
ALTER TABLE [dbo].[GuestReward]  WITH CHECK ADD  CONSTRAINT [FK__GuestRewa__Booki__38996AB5] FOREIGN KEY([BookingID])
REFERENCES [dbo].[Booking] ([ID])
GO
ALTER TABLE [dbo].[GuestReward] CHECK CONSTRAINT [FK__GuestRewa__Booki__38996AB5]
GO
ALTER TABLE [dbo].[GuestReward]  WITH CHECK ADD  CONSTRAINT [FK__GuestRewa__Guest__398D8EEE] FOREIGN KEY([GuestID])
REFERENCES [dbo].[Guest] ([ID])
GO
ALTER TABLE [dbo].[GuestReward] CHECK CONSTRAINT [FK__GuestRewa__Guest__398D8EEE]
GO
ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK__Invoice__Booking__3C69FB99] FOREIGN KEY([BookingID])
REFERENCES [dbo].[Booking] ([ID])
GO
ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [FK__Invoice__Booking__3C69FB99]
GO
ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK__Invoice__GuestID__3D5E1FD2] FOREIGN KEY([GuestID])
REFERENCES [dbo].[Guest] ([ID])
GO
ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [FK__Invoice__GuestID__3D5E1FD2]
GO
ALTER TABLE [dbo].[InvoiceTaxDetail]  WITH CHECK ADD  CONSTRAINT [FK__InvoiceTa__Invoi__403A8C7D] FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[Invoice] ([ID])
GO
ALTER TABLE [dbo].[InvoiceTaxDetail] CHECK CONSTRAINT [FK__InvoiceTa__Invoi__403A8C7D]
GO
ALTER TABLE [dbo].[PaymentType]  WITH CHECK ADD  CONSTRAINT [FK__PaymentTy__Prope__0C1BC9F9] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([ID])
GO
ALTER TABLE [dbo].[PaymentType] CHECK CONSTRAINT [FK__PaymentTy__Prope__0C1BC9F9]
GO
ALTER TABLE [dbo].[Rates]  WITH CHECK ADD  CONSTRAINT [FK__Rates__PropertyI__24285DB4] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([ID])
GO
ALTER TABLE [dbo].[Rates] CHECK CONSTRAINT [FK__Rates__PropertyI__24285DB4]
GO
ALTER TABLE [dbo].[Rates]  WITH CHECK ADD  CONSTRAINT [FK__Rates__RateTypeI__251C81ED] FOREIGN KEY([RateTypeID])
REFERENCES [dbo].[RateType] ([ID])
GO
ALTER TABLE [dbo].[Rates] CHECK CONSTRAINT [FK__Rates__RateTypeI__251C81ED]
GO
ALTER TABLE [dbo].[Rates]  WITH CHECK ADD FOREIGN KEY([RoomId])
REFERENCES [dbo].[Room] ([ID])
GO
ALTER TABLE [dbo].[Rates]  WITH CHECK ADD  CONSTRAINT [FK__Rates__RoomTypeI__2610A626] FOREIGN KEY([RoomTypeID])
REFERENCES [dbo].[RoomType] ([ID])
GO
ALTER TABLE [dbo].[Rates] CHECK CONSTRAINT [FK__Rates__RoomTypeI__2610A626]
GO
ALTER TABLE [dbo].[RateType]  WITH CHECK ADD  CONSTRAINT [FK__RateType__Proper__267ABA7A] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([ID])
GO
ALTER TABLE [dbo].[RateType] CHECK CONSTRAINT [FK__RateType__Proper__267ABA7A]
GO
ALTER TABLE [dbo].[RateType]  WITH CHECK ADD  CONSTRAINT [FK__RateType__Proper__27F8EE98] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([ID])
GO
ALTER TABLE [dbo].[RateType] CHECK CONSTRAINT [FK__RateType__Proper__27F8EE98]
GO
ALTER TABLE [dbo].[Room]  WITH CHECK ADD FOREIGN KEY([FloorId])
REFERENCES [dbo].[PropertyFloor] ([ID])
GO
ALTER TABLE [dbo].[Room]  WITH CHECK ADD  CONSTRAINT [FK__Room__PropertyID__2F10007B] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([ID])
GO
ALTER TABLE [dbo].[Room] CHECK CONSTRAINT [FK__Room__PropertyID__2F10007B]
GO
ALTER TABLE [dbo].[Room]  WITH CHECK ADD  CONSTRAINT [FK__Room__RoomTypeID__2E1BDC42] FOREIGN KEY([RoomTypeID])
REFERENCES [dbo].[RoomType] ([ID])
GO
ALTER TABLE [dbo].[Room] CHECK CONSTRAINT [FK__Room__RoomTypeID__2E1BDC42]
GO
ALTER TABLE [dbo].[RoomBooking]  WITH CHECK ADD  CONSTRAINT [FK__RoomBooki__Booki__33D4B598] FOREIGN KEY([BookingID])
REFERENCES [dbo].[Booking] ([ID])
GO
ALTER TABLE [dbo].[RoomBooking] CHECK CONSTRAINT [FK__RoomBooki__Booki__33D4B598]
GO
ALTER TABLE [dbo].[RoomBooking]  WITH CHECK ADD  CONSTRAINT [FK__RoomBooki__Guest__32E0915F] FOREIGN KEY([GuestID])
REFERENCES [dbo].[Guest] ([ID])
GO
ALTER TABLE [dbo].[RoomBooking] CHECK CONSTRAINT [FK__RoomBooki__Guest__32E0915F]
GO
ALTER TABLE [dbo].[RoomPricing]  WITH CHECK ADD  CONSTRAINT [FK__RoomPrici__Prope__2A4B4B5E] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([ID])
GO
ALTER TABLE [dbo].[RoomPricing] CHECK CONSTRAINT [FK__RoomPrici__Prope__2A4B4B5E]
GO
ALTER TABLE [dbo].[RoomPricing]  WITH CHECK ADD  CONSTRAINT [FK__RoomPrici__RateT__2B3F6F97] FOREIGN KEY([RateTypeID])
REFERENCES [dbo].[RateType] ([ID])
GO
ALTER TABLE [dbo].[RoomPricing] CHECK CONSTRAINT [FK__RoomPrici__RateT__2B3F6F97]
GO
ALTER TABLE [dbo].[RoomPricing]  WITH CHECK ADD  CONSTRAINT [FK__RoomPrici__RoomT__29572725] FOREIGN KEY([RoomTypeID])
REFERENCES [dbo].[RoomType] ([ID])
GO
ALTER TABLE [dbo].[RoomPricing] CHECK CONSTRAINT [FK__RoomPrici__RoomT__29572725]
GO
ALTER TABLE [dbo].[RoomType]  WITH CHECK ADD  CONSTRAINT [FK__RoomType__Proper__22AA2996] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([ID])
GO
ALTER TABLE [dbo].[RoomType] CHECK CONSTRAINT [FK__RoomType__Proper__22AA2996]
GO
ALTER TABLE [dbo].[State]  WITH CHECK ADD  CONSTRAINT [FK__State__CountryID__44FF419A] FOREIGN KEY([CountryID])
REFERENCES [dbo].[Country] ([ID])
GO
ALTER TABLE [dbo].[State] CHECK CONSTRAINT [FK__State__CountryID__44FF419A]
GO
ALTER TABLE [dbo].[Taxes]  WITH CHECK ADD  CONSTRAINT [FK__Taxes__PropertyI__382F5661] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([ID])
GO
ALTER TABLE [dbo].[Taxes] CHECK CONSTRAINT [FK__Taxes__PropertyI__382F5661]
GO
USE [master]
GO
ALTER DATABASE [PMS] SET  READ_WRITE 
GO
