
CREATE TABLE PropertyFloor(PropertyId int,ID int identity(1,1),FloorNumber int, isActive bit default(1), CreatedBy nvarchar(200), CreatedOn datetime, LastUpdatedBy nvarchar(200), LastUpdatedOn datetime)

