Create PROC [dbo].[GetRoomRates]
@PropertyId INT
AS BEGIN

Select 
Rates.ID
,Rates.Type
,Rates.PropertyID
,Rates.RateTypeID
,Rates.RoomTypeID
,Rates.InputKeyHours
,Rates.Value
,Rates.IsActive
,Rates.CreatedBy
,Rates.CreatedOn
,Rates.LastUpdatedBy
,Rates.LastUpdatedOn
,RoomType.NAME as RoomTypeName
,RateType.NAME as RateTypeName
from Rates 
inner join
RoomType on
Rates.RoomTypeID  = RoomType.ID
inner join
RateType on
Rates.RateTypeID = RateType.ID
where Rates.IsActive = 1 and Rates.PropertyID = @PropertyId
End
