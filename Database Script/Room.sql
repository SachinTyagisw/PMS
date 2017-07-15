USE [PMS]
GO

/****** Object:  Table [dbo].[Room]    Script Date: 07/14/2017 21:25:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Room](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyID] [int] NOT NULL,
	[RoomTypeID] [int] NOT NULL,
	[Number] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
	[FloorId] [int] NULL,
 CONSTRAINT [PK__Room__3214EC278D6C9E74] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Room]  WITH CHECK ADD FOREIGN KEY([FloorId])
REFERENCES [dbo].[PropertyFloor] ([ID])
GO

ALTER TABLE [dbo].[Room]  WITH CHECK ADD  CONSTRAINT [FK__Room__PropertyID__2F10007B] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([ID])
GO

ALTER TABLE [dbo].[Room] CHECK CONSTRAINT [FK__Room__PropertyID__2F10007B]
GO

ALTER TABLE [dbo].[Room]  WITH CHECK ADD  CONSTRAINT [FK__Room__RoomTypeID__2E1BDC42] FOREIGN KEY([RoomTypeID])
REFERENCES [dbo].[RoomType] ([ID])
GO

ALTER TABLE [dbo].[Room] CHECK CONSTRAINT [FK__Room__RoomTypeID__2E1BDC42]
GO

ALTER TABLE [dbo].[Room] ADD  CONSTRAINT [DF_Room_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO


