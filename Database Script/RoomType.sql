USE [PMS]
GO

/****** Object:  Table [dbo].[RoomType]    Script Date: 7/1/2017 2:33:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RoomType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyID] [int] NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_RoomType_IsActive]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
	[NAME] [nvarchar](max) NULL,
	[ShortName] [nvarchar](50) NULL,
 CONSTRAINT [PK__RoomType__3214EC2783760BB1] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[RoomType]  WITH CHECK ADD  CONSTRAINT [FK__RoomType__Proper__22AA2996] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([ID])
GO

ALTER TABLE [dbo].[RoomType] CHECK CONSTRAINT [FK__RoomType__Proper__22AA2996]
GO

