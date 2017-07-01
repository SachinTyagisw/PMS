USE [PMS]
GO

/****** Object:  Table [dbo].[Property]    Script Date: 06/30/2017 23:13:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Property](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyDetails] [nvarchar](max) NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
	[PropertyName] [nvarchar](100) NULL,
	[SecondaryName] [nvarchar](100) NULL,
	[PropertyCode] [nvarchar](50) NULL,
	[FullAddress] [nvarchar](max) NULL,
	[Phone] [nvarchar](100) NULL,
	[Fax] [nvarchar](100) NULL,
	[LogoPath] [nvarchar](max) NULL,
	[WebSiteAddress] [nvarchar](100) NULL,
	[TimeZone] [nvarchar](100) NULL,
	[CurrencyID] [int] NULL,
	[CheckinTime] [time](7) NULL,
	[CheckoutTime] [time](7) NULL,
	[CloseOfDayTime] [time](7) NULL,
	[State] [int] NULL,
	[Country] [int] NULL,
	[City] [int] NULL,
 CONSTRAINT [PK__Property__3214EC27AD6BF945] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Property]  WITH CHECK ADD FOREIGN KEY([City])
REFERENCES [dbo].[City] ([ID])
GO

ALTER TABLE [dbo].[Property]  WITH CHECK ADD FOREIGN KEY([Country])
REFERENCES [dbo].[Country] ([ID])
GO

ALTER TABLE [dbo].[Property]  WITH CHECK ADD FOREIGN KEY([State])
REFERENCES [dbo].[State] ([ID])
GO

ALTER TABLE [dbo].[Property] ADD  CONSTRAINT [DF_Property_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO


