USE [PMS]
GO

/****** Object:  Table [dbo].[Property]    Script Date: 7/1/2017 10:23:33 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Property](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[PropertyDetails] [nvarchar](max) NULL,
	[IsActive] [bit] NOT NULL CONSTRAINT [DF_Property_IsActive]  DEFAULT ((1)),
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
	[Currency] [nvarchar](10) NULL,
	[CheckinTime] [time](7) NULL,
	[CheckoutTime] [time](7) NULL,
	[CloseOfDayTime] [time](7) NULL,
 CONSTRAINT [PK__Property__3214EC27AD6BF945] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

