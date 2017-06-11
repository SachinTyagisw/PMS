
ALTER PROCEDURE [dbo].[InsertInvoice]              
 @propertyID INT,              
 @InvoiceXML XML = NULL              
AS              
BEGIN              
 SET NOCOUNT ON              
 BEGIN TRAN               
 BEGIN TRY              
                
 DECLARE @hDoc INT              
  IF @InvoiceXML IS NOT NULL              
  BEGIN              
   DECLARE @SavedInvoiceIDTable Table (OldInvoiceID INT, NewInvoiceID INT)              
   --DECLARE @SavedGuestIDTable Table (OldGuestID INT, NewGuestID INT)              
   --DECLARE @SavedGuestMappingIDTable Table(OldGuestMappingID INT, NewGuestMappingID INT)            
              
   EXEC sp_xml_preparedocument @hDoc OUTPUT,@InvoiceXML               
              
   -- Start - Merge INTO Invoice              
  MERGE INTO               
  [Invoice] AS [TargetInvoice]              
  USING               
   (              
    SELECT               
      XMLTable.Id,                
      XMLTable.BookingId,
      XMLTable.GuestId,                
      XMLTable.IsPaid,                
      XMLTable.TotalAmount,                
      XMLTable.FolioNumber,                
      XMLTable.Discount,                
      XMLTable.IsActive,                
      XMLTable.CreatedBy,                
      XMLTable.CreatedOn,                
      XMLTable.LastUpdatedBy,                
      XMLTable.LastUpdatedOn              
    FROM               
     OPENXML(@hDoc, 'Invoice',2)              
     WITH              
     (              
      Id int,                
      BookingId int,                
      GuestId int,                
      IsPaid bit,                
      TotalAmount money,                
      FolioNumber nvarchar(200),                
      Discount money,                
      IsActive bit,                
      CreatedBy nvarchar(200),                
      CreatedOn Datetime,                
      LastUpdatedBy nvarchar(200),                
      LastUpdatedOn DateTime              
     ) XMLTable                
   ) AS [SourceInvoice]              
  ON [TargetInvoice].ID = [SourceInvoice].ID              
  WHEN MATCHED THEN              
  UPDATE               
   SET               
      [TargetInvoice].GuestID = [SourceInvoice].GuestID                
      ,[TargetInvoice].BookingID = [SourceInvoice].BookingID                
      ,[TargetInvoice].IsPaid = [SourceInvoice].IsPaid              
      ,[TargetInvoice].TotalAmount = [SourceInvoice].TotalAmount                
      ,[TargetInvoice].FolioNumber = [SourceInvoice].FolioNumber 
      ,[TargetInvoice].Discount = [SourceInvoice].Discount              
      ,[TargetInvoice].IsActive = [SourceInvoice].IsActive                
      ,[TargetInvoice].CreatedBy = [SourceInvoice].CreatedBy              
      ,[TargetInvoice].CreatedOn = [SourceInvoice].CreatedOn               
      ,[TargetInvoice].LastUpdatedBy = [SourceInvoice].LastUpdatedBy               
      ,[TargetInvoice].LastUpdatedOn = [SourceInvoice].LastUpdatedOn              
  WHEN NOT MATCHED THEN              
  INSERT (                
      GuestID,                
      BookingID,                
      IsPaid,                
      TotalAmount,                
      FolioNumber,                
      Discount,    
      IsActive,                
      CreatedBy,                
      CreatedOn,                
      LastUpdatedBy,                
      LastUpdatedOn)   
   VALUES               
    (              
     [SourceInvoice].GuestID,                
     [SourceInvoice].BookingID,                
     [SourceInvoice].IsPaid,                
     [SourceInvoice].TotalAmount,                
     [SourceInvoice].FolioNumber,                
     [SourceInvoice].Discount,                
     [SourceInvoice].IsActive,                
     [SourceInvoice].CreatedBy,                
     [SourceInvoice].CreatedOn,                
     [SourceInvoice].LastUpdatedBy,                
     [SourceInvoice].LastUpdatedOn              
    )              
              
   OUTPUT [SourceInvoice].ID, inserted.ID INTO @SavedInvoiceIDTable(OldInvoiceID,NewInvoiceID);              
   
   DECLARE @INVOICEID int
   SELECT @INVOICEID = NewInvoiceID FROM @SavedInvoiceIDTable
   
   DELETE FROM INVOICEITEMS WHERE INVOICEID=@INVOICEID
   DELETE FROM INVOICETAXDETAIL WHERE INVOICEID=@INVOICEID
   DELETE FROM INVOICEPAYMENTDETAILS WHERE INVOICEID=@INVOICEID
                 
  MERGE INTO              
  [InvoiceItems] AS [TargetInvoiceItems]              
  USING               
   (              
    SELECT               
      XMLTable.Id,                
      InvoiceId = case when (XMLTable.InvoiceId < 0) then  InvoiceIDTable.NewInvoiceID else XMLTable.InvoiceID end,            
      XMLTable.ItemName,                
      XMLTable.ItemValue,                
      XMLTable.IsActive,                
      XMLTable.CreatedBy,                
      XMLTable.CreatedOn,                
      XMLTable.LastUpdatedBy,                
      XMLTable.LastUpdatedOn              
    FROM               
     OPENXML(@hDoc, 'Invoice/InvoiceItems/InvoiceItem',2)              
     WITH              
     (              
      Id int,
      InvoiceId int,                
      ItemName nvarchar(200),                
      ItemValue nvarchar(200),                
      IsActive bit,                
      CreatedBy nvarchar(200),                
      CreatedOn Datetime,                
      LastUpdatedBy nvarchar(200),                
      LastUpdatedOn DateTime              
     ) XMLTable
      LEFT OUTER JOIN              
     @SavedInvoiceIDTable AS InvoiceIDTable              
     ON InvoiceIDTable.OldInvoiceID = XMLTable.InvoiceID                 
   ) AS [SourceInvoiceItems]              
  ON [TargetInvoiceItems].ID = [SourceInvoiceItems].ID              
  WHEN MATCHED THEN              
  UPDATE               
   SET               
       [TargetInvoiceItems].ItemName = [SourceInvoiceItems].ItemName              
      ,[TargetInvoiceItems].ItemValue = [SourceInvoiceItems].ItemValue                
      ,[TargetInvoiceItems].IsActive = [SourceInvoiceItems].IsActive                
      ,[TargetInvoiceItems].CreatedBy = [SourceInvoiceItems].CreatedBy              
      ,[TargetInvoiceItems].CreatedOn = [SourceInvoiceItems].CreatedOn               
      ,[TargetInvoiceItems].LastUpdatedBy = [SourceInvoiceItems].LastUpdatedBy               
      ,[TargetInvoiceItems].LastUpdatedOn = [SourceInvoiceItems].LastUpdatedOn              
  WHEN NOT MATCHED THEN              
  INSERT (                  
      InvoiceId,                
      ItemName,                
      ItemValue,                
      IsActive,                
      CreatedBy,                
      CreatedOn,                
      LastUpdatedBy,                
      LastUpdatedOn              
      )              
   VALUES               
    (              
      [SourceInvoiceItems].InvoiceId,                
      [SourceInvoiceItems].ItemName,                
      [SourceInvoiceItems].ItemValue,                
      [SourceInvoiceItems].IsActive,                
      [SourceInvoiceItems].CreatedBy,                
      [SourceInvoiceItems].CreatedOn,                
      [SourceInvoiceItems].LastUpdatedBy,                
      [SourceInvoiceItems].LastUpdatedOn              
    );
    
  MERGE INTO              
  [InvoiceTaxDetail] AS [TargetInvoiceTaxDetail]              
  USING               
   (              
    SELECT               
      XMLTable.Id,                
      InvoiceId = case when (XMLTable.InvoiceId < 0) then  InvoiceIDTable.NewInvoiceID else XMLTable.InvoiceID end,            
      XMLTable.TaxShortName,                
      XMLTable.TaxAmount,                
      XMLTable.IsActive,                
      XMLTable.CreatedBy,                
      XMLTable.CreatedOn,                
      XMLTable.LastUpdatedBy,                
      XMLTable.LastUpdatedOn              
    FROM               
     OPENXML(@hDoc, 'Invoice/InvoiceTaxDetails/TaxDetail',2)              
     WITH              
     (              
      Id int,
      InvoiceId int,                
      TaxShortName nvarchar(max),                
      TaxAmount money,                
      IsActive bit,                
      CreatedBy nvarchar(200),                
      CreatedOn Datetime,                
      LastUpdatedBy nvarchar(200),                
      LastUpdatedOn DateTime              
     ) XMLTable
      LEFT OUTER JOIN              
     @SavedInvoiceIDTable AS InvoiceIDTable              
     ON InvoiceIDTable.OldInvoiceID = XMLTable.InvoiceID                 
   ) AS [SourceInvoiceTaxDetail]              
  ON [TargetInvoiceTaxDetail].ID = [SourceInvoiceTaxDetail].ID              
  WHEN MATCHED THEN              
  UPDATE               
   SET               
       [TargetInvoiceTaxDetail].TaxShortName = [SourceInvoiceTaxDetail].TaxShortName              
      ,[TargetInvoiceTaxDetail].TaxAmount = [SourceInvoiceTaxDetail].TaxAmount                
      ,[TargetInvoiceTaxDetail].IsActive = [SourceInvoiceTaxDetail].IsActive                
      ,[TargetInvoiceTaxDetail].CreatedBy = [SourceInvoiceTaxDetail].CreatedBy              
      ,[TargetInvoiceTaxDetail].CreatedOn = [SourceInvoiceTaxDetail].CreatedOn               
      ,[TargetInvoiceTaxDetail].LastUpdatedBy = [SourceInvoiceTaxDetail].LastUpdatedBy               
      ,[TargetInvoiceTaxDetail].LastUpdatedOn = [SourceInvoiceTaxDetail].LastUpdatedOn              
  WHEN NOT MATCHED THEN              
  INSERT (                  
      InvoiceId,                
      TaxShortName,                
      TaxAmount,                
      IsActive,                
      CreatedBy,                
      CreatedOn,                
      LastUpdatedBy,                
      LastUpdatedOn              
      )              
   VALUES               
    (              
      [SourceInvoiceTaxDetail].InvoiceId,                
      [SourceInvoiceTaxDetail].TaxShortName,                
      [SourceInvoiceTaxDetail].TaxAmount,                
      [SourceInvoiceTaxDetail].IsActive,                
      [SourceInvoiceTaxDetail].CreatedBy,                
      [SourceInvoiceTaxDetail].CreatedOn,                
      [SourceInvoiceTaxDetail].LastUpdatedBy,                
      [SourceInvoiceTaxDetail].LastUpdatedOn              
    );
    
  MERGE INTO              
  [InvoicePaymentDetails] AS [TargetInvoicePaymentDetails]              
  USING               
   (              
    SELECT               
      XMLTable.Id,                
      InvoiceId = case when (XMLTable.InvoiceId < 0) then  InvoiceIDTable.NewInvoiceID else XMLTable.InvoiceID end,            
      XMLTable.PaymentMode,
      XMLTable.PaymentValue,
      XMLTable.PaymentDetails,                
      XMLTable.IsActive,                
      XMLTable.CreatedBy,                
      XMLTable.CreatedOn,                
      XMLTable.LastUpdatedBy,                
      XMLTable.LastUpdatedOn              
    FROM               
     OPENXML(@hDoc, 'Invoice/InvoicePaymentDetails/InvoicePayment',2)              
     WITH              
     (              
      Id int,
      InvoiceId int,                
      PaymentMode nvarchar(max),                
      PaymentValue money,                
      PaymentDetails nvarchar(max),
      IsActive bit,                
      CreatedBy nvarchar(200),                
      CreatedOn Datetime,                
      LastUpdatedBy nvarchar(200),                
      LastUpdatedOn DateTime              
     ) XMLTable
      LEFT OUTER JOIN              
     @SavedInvoiceIDTable AS InvoiceIDTable              
     ON InvoiceIDTable.OldInvoiceID = XMLTable.InvoiceID                 
   ) AS [SourceInvoicePaymentDetails]              
  ON [TargetInvoicePaymentDetails].ID = [SourceInvoicePaymentDetails].ID              
  WHEN MATCHED THEN              
  UPDATE               
   SET               
       [TargetInvoicePaymentDetails].PaymentMode = [SourceInvoicePaymentDetails].PaymentMode              
      ,[TargetInvoicePaymentDetails].PaymentValue = [SourceInvoicePaymentDetails].PaymentValue
      ,[TargetInvoicePaymentDetails].PaymentDetails = [SourceInvoicePaymentDetails].PaymentDetails                
      ,[TargetInvoicePaymentDetails].IsActive = [SourceInvoicePaymentDetails].IsActive                
      ,[TargetInvoicePaymentDetails].CreatedBy = [SourceInvoicePaymentDetails].CreatedBy              
      ,[TargetInvoicePaymentDetails].CreatedOn = [SourceInvoicePaymentDetails].CreatedOn               
      ,[TargetInvoicePaymentDetails].LastUpdatedBy = [SourceInvoicePaymentDetails].LastUpdatedBy               
      ,[TargetInvoicePaymentDetails].LastUpdatedOn = [SourceInvoicePaymentDetails].LastUpdatedOn              
  WHEN NOT MATCHED THEN              
  INSERT (                  
      InvoiceId, 
      PaymentMode, 
      PaymentValue,
      PaymentDetails,              
      IsActive,                
      CreatedBy,                
      CreatedOn,                
      LastUpdatedBy,                
      LastUpdatedOn              
      )              
   VALUES               
    (              
      [SourceInvoicePaymentDetails].InvoiceId,                
      [SourceInvoicePaymentDetails].PaymentMode,                
      [SourceInvoicePaymentDetails].PaymentValue,
      [SourceInvoicePaymentDetails].PaymentDetails,                
      [SourceInvoicePaymentDetails].IsActive,                
      [SourceInvoicePaymentDetails].CreatedBy,                
      [SourceInvoicePaymentDetails].CreatedOn,                
      [SourceInvoicePaymentDetails].LastUpdatedBy,                
      [SourceInvoicePaymentDetails].LastUpdatedOn              
    ) ;             
                  
        
                  
 END              
 COMMIT TRAN              
 END TRY              
              
    BEGIN CATCH              
  ROLLBACK TRAN;              
 END CATCH              
                  
    SET NOCOUNT OFF              
END                
              