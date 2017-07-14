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
      XMLTable.LastUpdatedOn                        
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
      LastUpdatedOn DateTime                        
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
  WHEN NOT MATCHED THEN                        
  INSERT (   
   PropertyId,                         
      RoomTypeId,  
      Number,                          
      IsActive,                          
      CreatedBy,                          
      CreatedOn,                       
      LastUpdatedBy,                          
      LastUpdatedOn)             
   VALUES                         
    (    
  @PropertyID,                      
     [SourceRoom].RoomTypeId,                          
     [SourceRoom].Number,                          
     [SourceRoom].IsActive,                          
     [SourceRoom].CreatedBy,                          
     [SourceRoom].CreatedOn,                          
     [SourceRoom].LastUpdatedBy,                          
     [SourceRoom].LastUpdatedOn                        
    ) ;                       
 END   
                      
 COMMIT TRAN                        
 END TRY                        
                        
    BEGIN CATCH                        
  ROLLBACK TRAN;                        
 END CATCH                        
                            
    SET NOCOUNT OFF                        
END 