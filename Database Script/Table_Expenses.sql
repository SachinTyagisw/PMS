USE [PMS]
GO

Alter Table [PaymentType] Add Primary Key(ID)

GO

/****** Object:  Table [dbo].[Expenses]    Script Date: 10/08/2017 06:27:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Expenses](
	[ID] [int] IDENTITY(1,1) primary key NOT NULL,
	[PropertyID] [int] NULL,
	[ExpenseCategoryID] [int],
	[PaymentTypeID] [int],
	[Amount] [money],
	[Description] [nvarchar] (max) NULL,
	[IsActive] [bit] NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
	[ExpenseDate] [datetime] NULL
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Expenses]  WITH CHECK ADD FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([ID])
GO

ALTER TABLE [dbo].[Expenses]  WITH CHECK ADD FOREIGN KEY([ExpenseCategoryID])
REFERENCES [dbo].[ExpenseCategory] ([ID])
GO

ALTER TABLE [dbo].[Expenses]  WITH CHECK ADD FOREIGN KEY([PaymentTypeID])
REFERENCES [dbo].[PaymentType] ([ID])
GO

ALTER TABLE [dbo].[Expenses] ADD  DEFAULT ((1)) FOR [IsActive]
GO