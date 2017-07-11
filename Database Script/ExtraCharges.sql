USE [PMS]
GO

DROP TABLE [EXTRACHARGES]

GO

CREATE TABLE [dbo].[ExtraCharges](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyID] [int] NULL,
	[FacilityName] [nvarchar](400) NOT NULL,
	[Value] [money] NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL);
GO

ALTER TABLE [dbo].[ExtraCharges]  WITH CHECK ADD  CONSTRAINT [FK__ExtraChar__Prope__214BF109] FOREIGN KEY([PropertyID])
REFERENCES [dbo].[Property] ([ID])
GO

ALTER TABLE [dbo].[ExtraCharges] ADD  CONSTRAINT [DF_ExtraCharges_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO

ALTER TABLE [dbo].[ExtraCharges] ADD  CONSTRAINT [DF_ExtraCharges_Unique]  Unique ([PropertyID],[FacilityName])
GO

Constraint UC_FacilityName unique([PropertyID],[FacilityName])
