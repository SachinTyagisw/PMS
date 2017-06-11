USE [PMS]
GO

/****** Object:  Table [dbo].[InvoiceTaxDetail]    Script Date: 06/11/2017 10:49:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[InvoiceTaxDetail](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[InvoiceID] [int] NOT NULL,
	[TaxShortName] [nvarchar](max) NULL,
	[TaxAmount] [decimal](7, 2) NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
 CONSTRAINT [PK__InvoiceT__3214EC27D12730CC] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[InvoiceTaxDetail]  WITH CHECK ADD  CONSTRAINT [FK__InvoiceTa__Invoi__403A8C7D] FOREIGN KEY([InvoiceID])
REFERENCES [dbo].[Invoice] ([ID])
GO

ALTER TABLE [dbo].[InvoiceTaxDetail] CHECK CONSTRAINT [FK__InvoiceTa__Invoi__403A8C7D]
GO

ALTER TABLE [dbo].[InvoiceTaxDetail] ADD  CONSTRAINT [DF__InvoiceTa__IsAct__02084FDA]  DEFAULT ((1)) FOR [IsActive]
GO


