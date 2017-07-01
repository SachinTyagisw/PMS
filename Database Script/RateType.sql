USE [PMS]
GO

/****** Object:  Table [dbo].[RateType]    Script Date: 7/1/2017 2:32:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RateType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyID] [int] NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_RateType_IsActive]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
	[NAME] [nvarchar](max) NULL,
	[RoomTypeID] [int] NULL,
	[ShortName] [nvarchar](50) NULL,
 CONSTRAINT [PK__RateType__3214EC2725FEB820] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

ALTER TABLE [dbo].[RateType]  WITH CHECK ADD  CONSTRAINT [FK__RateType__Proper__267ABA7A] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([ID])
GO

ALTER TABLE [dbo].[RateType] CHECK CONSTRAINT [FK__RateType__Proper__267ABA7A]
GO

ALTER TABLE [dbo].[RateType]  WITH CHECK ADD  CONSTRAINT [FK__RateType__Proper__27F8EE98] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([ID])
GO

ALTER TABLE [dbo].[RateType] CHECK CONSTRAINT [FK__RateType__Proper__27F8EE98]
GO


