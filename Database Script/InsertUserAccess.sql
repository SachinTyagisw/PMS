USE [PMS]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 ALTER PROCEDURE [dbo].[InsertUserAccess]                          
 @UserID INT,                          
 @Functionalities nvarchar(max),
 @Properties nvarchar(max),
 @CreatedBy nvarchar(200)
AS                          
BEGIN                          
 SET NOCOUNT ON                          
 BEGIN TRAN                           
 BEGIN TRY 
 
 Delete from UsersPropertyMapping where UserID=@UserID
 Delete from UsersFunctionalityMapping where UserID=@UserID
 
 insert into UsersFunctionalityMapping
 SELECT @UserID,Item,1,@CreatedBy,GETDATE(),@CreatedBy,GETDATE() FROM dbo.SplitString(@Functionalities, ',')
 
 insert into UsersPropertyMapping
 SELECT @UserID,Item,1,@CreatedBy,GETDATE(),@CreatedBy,GETDATE() FROM dbo.SplitString(@Properties, ',')
                        
 COMMIT TRAN                          
 END TRY                          
                          
    BEGIN CATCH                          
  ROLLBACK TRAN;                          
 END CATCH                          
                              
    SET NOCOUNT OFF            
END 
GO


