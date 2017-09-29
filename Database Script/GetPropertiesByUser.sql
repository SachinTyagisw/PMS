CREATE PROC [dbo].[GetPropertiesByUser]    
@UserName nvarchar(max)    
AS BEGIN    
SELECT 
ID,
PropertyDetails,
PropertyName,
SecondaryName,
PropertyCode,
FullAddress,
Phone,
Fax,
LogoPath,
WebSiteAddress,
TimeZone,
CurrencyID,
CheckinTime,
CheckoutTime,
CloseOfDayTime,
State,
Country,
City
from  Property where ID in (Select [UsersPropertyMapping].PropertyID from [UsersPropertyMapping], [Users] where [Users].id = [UsersPropertyMapping].userid and [Users].username = @UserName)

    
END  

  
GO


