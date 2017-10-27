CREATE TABLE [dbo].[UsersFunctionalityMapping](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [int] NULL,
	[FunctionalityID] [int],
	[IsActive] [bit] NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
	Primary Key(ID),
	Foreign Key([FunctionalityID]) References Functionality(ID)
)

GO




