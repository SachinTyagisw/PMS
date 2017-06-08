USE [PMS]
GO

/****** Object:  Table [dbo].[ExtraCharges]    Script Date: 6/8/2017 12:00:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ExtraCharges](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyID] [int] NULL,
	[FacilityKey] [int] NULL,
	[Value] [money] NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
 CONSTRAINT [PK_ExtraCharges] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[ExtraCharges]  WITH CHECK ADD FOREIGN KEY([FacilityKey])
REFERENCES [dbo].[ChargableFacility] ([ID])
GO

ALTER TABLE [dbo].[ExtraCharges]  WITH CHECK ADD FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([ID])
GO


