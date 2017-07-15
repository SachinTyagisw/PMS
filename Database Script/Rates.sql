USE [PMS]
GO

/****** Object:  Table [dbo].[Rates]    Script Date: 07/14/2017 20:45:47 ******/
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
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
	[RoomId] [int] NOT NULL,
 CONSTRAINT [PK_Rates] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Rates]  WITH CHECK ADD  CONSTRAINT [FK__Rates__PropertyI__24285DB4] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([ID])
GO

ALTER TABLE [dbo].[Rates] CHECK CONSTRAINT [FK__Rates__PropertyI__24285DB4]
GO

ALTER TABLE [dbo].[Rates]  WITH CHECK ADD  CONSTRAINT [FK__Rates__RateTypeI__251C81ED] FOREIGN KEY([RateTypeID])
REFERENCES [dbo].[RateType] ([ID])
GO

ALTER TABLE [dbo].[Rates] CHECK CONSTRAINT [FK__Rates__RateTypeI__251C81ED]
GO

ALTER TABLE [dbo].[Rates]  WITH CHECK ADD FOREIGN KEY([RoomId])
REFERENCES [dbo].[Room] ([ID])
GO

ALTER TABLE [dbo].[Rates]  WITH CHECK ADD  CONSTRAINT [FK__Rates__RoomTypeI__2610A626] FOREIGN KEY([RoomTypeID])
REFERENCES [dbo].[RoomType] ([ID])
GO

ALTER TABLE [dbo].[Rates] CHECK CONSTRAINT [FK__Rates__RoomTypeI__2610A626]
GO

ALTER TABLE [dbo].[Rates] ADD  CONSTRAINT [DF_Rates_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO


