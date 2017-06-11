USE [PMS]
GO

/****** Object:  Table [dbo].[InvoicePaymentDetails]    Script Date: 06/11/2017 10:49:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[InvoicePaymentDetails](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InvoiceID] [int] NOT NULL,
	[PaymentMode] [nvarchar](max) NULL,
	[PaymentValue] [money] NULL,
	[PaymentDetails] [nvarchar](max) NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL
) ON [PRIMARY]

GO


