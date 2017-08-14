-- =============================================            
-- Author:  Sachin Tyagi            
-- Create date: June 04, 2017            
-- Description: This stored procedure shall return the amount of booking          
-- =============================================    
  
--Exec [GETBOOKINGAMOUNT]  20,30,38,null,0,0,67  
  
--select * from rates where roomid=67   
           
ALTER PROC [dbo].[GETBOOKINGAMOUNT]            
@PROPERTYID INT,            
@ROOMTYPEID INT,            
@RATETYPEID INT,            
@NOOFHOURS INT = NULL,            
@NOOFDAYS INT,            
@ISHOURLY BIT,    
@RoomID int           
AS BEGIN            
--CREATE TEMP TABLE TO HOLD THE KEY VALUE PAIR TO RETURN THE DETAIL OF THE INVOICE            
            
declare @TMPINVOICEDETAILS TABLE(        
ITEM NVARCHAR(100),            
ITEMAMOUNT MONEY,        
OrderBy int identity(1,1))         
                                   
CREATE TABLE #TMPINVOICEDETAILS(            
ITEM NVARCHAR(100),            
ITEMAMOUNT MONEY)            
            
-- ROOM BOOKING AMOUNT            
INSERT INTO @TMPINVOICEDETAILS(ITEM, ITEMAMOUNT)            
SELECT TOP 1 'ROOM CHARGES'        
  ,Value          
  --,CASE WHEN (@ISHOURLY = 1) THEN  VALUE ELSE VALUE * @NOOFDAYS END              
  FROM RATES WHERE             
  PROPERTYID =@PROPERTYID AND             
  ROOMTYPEID = @ROOMTYPEID AND  RateTypeID=@RATETYPEID AND       
  --(INPUTKEYHOURS IS NULL OR INPUTKEYHOURS = @NOOFHOURS) AND    
  RoomId = @RoomID          
        
-- TAX DETAILS            
--INSERT INTO @TMPINVOICEDETAILS(ITEM, ITEMAMOUNT)            
--SELECT ALLTAXES.TAXSHORTNAME, TAXES.VALUE FROM TAXES INNER JOIN ALLTAXES ON            
--TAXES.TAXID = ALLTAXES.ID AND TAXES.PROPERTYID = @PROPERTYID            
      
INSERT INTO @TMPINVOICEDETAILS(ITEM, ITEMAMOUNT)            
SELECT TAXES.TaxName, TAXES.VALUE FROM TAXES WHERE PROPERTYID = @PROPERTYID      
            
SELECT ITEM,ITEMAMOUNT, OrderBy FROM @TMPINVOICEDETAILS            
            
END 