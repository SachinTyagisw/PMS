Declare @propertyID int
Declare @RateXml xml
set @propertyID =1 
Declare @RateId int
set @RateXml = '<Rates xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Id>-1</Id>
<Type>Daily</Type>
<PropertyID>1</PropertyID>
<RateTypeID>1</RateTypeID>
<RoomTypeID>1</RoomTypeID>
<InputKeyHours>2</InputKeyHours>
<Value>2000</Value>
<RoomId>1</RoomId>
<IsActive>true</IsActive>
<CreatedBy>vipul</CreatedBy>
<CreatedOn>2017-06-11T19:46:54</CreatedOn>
<LastUpdatedOn xsi:nil="true" />
</Rates>'

exec InsertRoomRates @propertyID,@RateXml, @RateId out


