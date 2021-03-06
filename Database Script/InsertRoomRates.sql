    
ALTER PROCEDURE [dbo].[InsertRoomRates]                                
 @propertyID INT,                                
 @RateXML XML = NULL,             
 @Status Bit OUTPUT                                     
AS                                
BEGIN                                
 SET NOCOUNT ON                                
 BEGIN TRAN                                 
 BEGIN TRY                                
 Set @Status = 1                             
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
     OPENXML(@hDoc, 'Rates/Rate',2)                                
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
             
   --IF(@RateID is null)            
   --BEGIN            
   -- SELECT @RateID = NewRateID FROM @SavedRateIDTable                  
   --END             
   -- SELECT @RateID                
 END        
 SELECT @STATUS                        
 COMMIT TRAN                                
 END TRY                                
                                
    BEGIN CATCH                        
    Set @STATUS = 0
    Select @STATUS                            
  ROLLBACK TRAN;                                
 END CATCH                                
                                    
    SET NOCOUNT OFF                                
END 