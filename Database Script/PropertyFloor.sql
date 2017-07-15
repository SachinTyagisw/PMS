USE [PMS]
GO

/****** Object:  Table [dbo].[PropertyFloor]    Script Date: 07/14/2017 21:24:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PropertyFloor](
	[propertyId] [int] NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FloorNumber] [int] NULL,
	[isActive] [bit] NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[PropertyFloor] ADD  DEFAULT ((1)) FOR [isActive]
GO


