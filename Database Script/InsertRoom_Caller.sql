Declare @propertyID int
Declare @RoomXml xml
set @propertyID =1 
set @RoomXml = '<Rooms xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<Room>
<Id>12</Id>
<RoomTypeId>1</RoomTypeId>
<FloorId>2</FloorId>
<Number>RS-Update</Number>
<IsActive>true</IsActive>
<CreatedBy>vipul</CreatedBy>
<CreatedOn>2017-06-11T19:46:54</CreatedOn>
<LastUpdatedOn xsi:nil="true" />
</Room>
<Room>
<Id>1</Id>
<RoomTypeId>2</RoomTypeId>
<FloorId>2</FloorId>
<Number>Update</Number>
<IsActive>true</IsActive>
<CreatedBy>vipul</CreatedBy>
<CreatedOn>2017-06-11T19:46:54</CreatedOn>
<LastUpdatedBy>vipul</LastUpdatedBy>
<LastUpdatedOn xsi:nil="true" />
</Room>
<Room>
<Id>-3</Id>
<RoomTypeId>1</RoomTypeId>
<FloorId>2</FloorId>
<Number>RS-003</Number>
<IsActive>true</IsActive>
<CreatedBy>vipul</CreatedBy>
<CreatedOn>2017-06-11T19:46:54</CreatedOn>
<LastUpdatedOn xsi:nil="true" />
</Room>
</Rooms>'

exec InsertRoom @propertyID,@RoomXml


