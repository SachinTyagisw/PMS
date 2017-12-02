USE [PMS]
GO

/****** Object:  Table [dbo].[Invoice]    Script Date: 08/15/2017 04:53:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Invoice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[GuestID] [int] NOT NULL,
	[BookingID] [int] NOT NULL,
	[IsPaid] [bit] NULL,
	[TotalAmount] [money] NULL,
	[FolioNumber] [nvarchar](200) NULL,
	[IsActive] [bit] NOT NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedOn] [datetime] NULL,
	[LastUpdatedBy] [nvarchar](200) NULL,
	[LastUpdatedOn] [datetime] NULL,
	[DISCOUNT] [money] NULL,
	[CreditCardDetail] [nvarchar](max) NULL,
	[DiscountAmount] [decimal](18, 2) NULL,
 CONSTRAINT [PK__Invoice__3214EC2766CAD2C9] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK__Invoice__Booking__3C69FB99] FOREIGN KEY([BookingID])
REFERENCES [dbo].[Booking] ([ID])
GO

ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [FK__Invoice__Booking__3C69FB99]
GO

ALTER TABLE [dbo].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK__Invoice__GuestID__3D5E1FD2] FOREIGN KEY([GuestID])
REFERENCES [dbo].[Guest] ([ID])
GO

ALTER TABLE [dbo].[Invoice] CHECK CONSTRAINT [FK__Invoice__GuestID__3D5E1FD2]
GO

ALTER TABLE [dbo].[Invoice] ADD  CONSTRAINT [DF__Invoice__IsActiv__01142BA1]  DEFAULT ((1)) FOR [IsActive]
GO


