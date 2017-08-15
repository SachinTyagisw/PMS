ALTER PROCEDURE [dbo].[InsertInvoice]                          
 @propertyID INT,                          
 @InvoiceXML XML = NULL,       
 @INVOICEID INT OUTPUT                          
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
      XMLTable.DiscountAmount,                           
      XMLTable.IsActive,    
      XMLTable.CreditCardDetail,                            
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
      DiscountAmount decimal,                   
      IsActive bit,    
      CreditCardDetail nvarchar(200),                           
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
      ,[TargetInvoice].DiscountAmount = [SourceInvoice].DiscountAmount
      ,[TargetInvoice].IsActive = [SourceInvoice].IsActive      
      ,[TargetInvoice].CreditCardDetail = [SourceInvoice].CreditCardDetail                          
      ,[TargetInvoice].CreatedBy = [SourceInvoice].CreatedBy                          
      ,[TargetInvoice].CreatedOn = [SourceInvoice].CreatedOn                           
      ,[TargetInvoice].LastUpdatedBy = [SourceInvoice].LastUpdatedBy                           
      ,[TargetInvoice].LastUpdatedOn = [SourceInvoice].LastUpdatedOn                          
   ,@INVOICEID = [SourceInvoice].ID      
  WHEN NOT MATCHED THEN                          
  INSERT (                            
      GuestID,                 
      BookingID,                            
      IsPaid,                            
      TotalAmount,                            
      FolioNumber,                            
      Discount,                
      DiscountAmount,
      IsActive,     
      CreditCardDetail,                           
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
     [SourceInvoice].DiscountAmount,
     [SourceInvoice].IsActive,                            
     [SourceInvoice].CreditCardDetail,    
     [SourceInvoice].CreatedBy,                            
     [SourceInvoice].CreatedOn,                            
     [SourceInvoice].LastUpdatedBy,                            
     [SourceInvoice].LastUpdatedOn                          
    )                          
   OUTPUT [SourceInvoice].ID, inserted.ID INTO @SavedInvoiceIDTable(OldInvoiceID,NewInvoiceID);                          
       
   IF(@INVOICEID is null)      
   BEGIN      
    SELECT @INVOICEID = NewInvoiceID FROM @SavedInvoiceIDTable            
   END       
               
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
              
    --select * from [SourceInvoiceItems]          
    --select * from invoiceitems          
                
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
      XMLTable.LastUpdatedOn,  
      XMLTable.TaxValue,  
      XMLTable.IsConsidered                          
    FROM                           
     OPENXML(@hDoc, 'Invoice/InvoiceTaxDetails/InvoiceTaxDetail',2)                          
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
      LastUpdatedOn DateTime,  
      TaxValue decimal,  
      IsConsidered bit                          
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
      ,[TargetInvoiceTaxDetail].TaxValue = [SourceInvoiceTaxDetail].TaxValue                           
      ,[TargetInvoiceTaxDetail].IsConsidered = [SourceInvoiceTaxDetail].IsConsidered                          
  WHEN NOT MATCHED THEN                          
  INSERT (                              
      InvoiceId,                         
      TaxShortName,                            
      TaxAmount,                            
      IsActive,                            
      CreatedBy,                            
      CreatedOn,                            
      LastUpdatedBy,                            
      LastUpdatedOn,  
      TaxValue,  
      IsConsidered                          
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
      [SourceInvoiceTaxDetail].LastUpdatedOn,  
      [SourceInvoiceTaxDetail].TaxValue,   
      [SourceInvoiceTaxDetail].IsConsidered                          
    );            
              
    --select * from [SourceInvoiceTaxDetail]          
    --select * from [InvoiceTaxDetail]          
                    
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
     OPENXML(@hDoc, 'Invoice/InvoicePaymentDetails/InvoicePaymentDetail',2)                          
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
          
    SELECT @INVOICEID          
 END                          
 COMMIT TRAN                          
 END TRY                          
                          
    BEGIN CATCH                          
  ROLLBACK TRAN;                          
 END CATCH                          
                              
    SET NOCOUNT OFF                          
END 