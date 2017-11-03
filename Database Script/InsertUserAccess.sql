USE [PMS]
GO

/****** Object:  StoredProcedure [dbo].[InsertUserAccess]    Script Date: 11/03/2017 09:55:48 ******/
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
 
 if LEN(ISNULL(@Functionalities,'')) <> 0
 Begin
 insert into UsersFunctionalityMapping
 SELECT @UserID,Item,1,@CreatedBy,GETDATE(),@CreatedBy,GETDATE() FROM dbo.SplitString(@Functionalities, ',')
 End
 
 if LEN(ISNULL(@Properties,'')) <> 0
 Begin
 insert into UsersPropertyMapping
 SELECT @UserID,Item,1,@CreatedBy,GETDATE(),@CreatedBy,GETDATE() FROM dbo.SplitString(@Properties, ',')
 end
                        
 COMMIT TRAN                          
 END TRY                          
                          
    BEGIN CATCH                          
  ROLLBACK TRAN;                          
 END CATCH                          
                              
    SET NOCOUNT OFF            
END 

GO


