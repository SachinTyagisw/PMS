USE [PMS]
GO

/****** Object:  Table [dbo].[PaymentType]    Script Date: 07/04/2017 19:53:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PaymentType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyID] [int] NULL,
	[ShortName] [nvarchar](50) NULL,
	[Description] [nvarchar](max) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[PaymentType]  WITH CHECK ADD FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([ID])
GO

ALTER TABLE [dbo].[PaymentType] ADD  DEFAULT ((1)) FOR [IsActive]
GO


