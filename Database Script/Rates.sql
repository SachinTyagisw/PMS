USE [PMS]
GO

/****** Object:  Table [dbo].[Rates]    Script Date: 6/8/2017 12:00:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Rates](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Type] [nvarchar](20) NULL,
	[PropertyID] [int] NULL,
	[RateTypeID] [int] NULL,
	[RoomTypeID] [int] NULL,
	[InputKeyHours] [int] NULL,
	[Value] [money] NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
 CONSTRAINT [PK_Rates] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Rates]  WITH CHECK ADD FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([ID])
GO

ALTER TABLE [dbo].[Rates]  WITH CHECK ADD  CONSTRAINT [FK__Rates__RateTypeI__251C81ED] FOREIGN KEY([RateTypeID])
REFERENCES [dbo].[RateType] ([ID])
GO

ALTER TABLE [dbo].[Rates] CHECK CONSTRAINT [FK__Rates__RateTypeI__251C81ED]
GO

ALTER TABLE [dbo].[Rates]  WITH CHECK ADD  CONSTRAINT [FK__Rates__RoomTypeI__2610A626] FOREIGN KEY([RoomTypeID])
REFERENCES [dbo].[RoomType] ([ID])
GO

ALTER TABLE [dbo].[Rates] CHECK CONSTRAINT [FK__Rates__RoomTypeI__2610A626]
GO


