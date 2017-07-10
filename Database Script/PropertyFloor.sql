USE [PMS]
GO

/****** Object:  Table [dbo].[PropertyFloor]    Script Date: 7/10/2017 9:27:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PropertyFloor](
	[PropertyId] [int] NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[FloorNumber] [int] NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF__PropertyF__isAct__0EF836A4]  DEFAULT ((1)),
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
 CONSTRAINT [PK_PropertyFloor] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

