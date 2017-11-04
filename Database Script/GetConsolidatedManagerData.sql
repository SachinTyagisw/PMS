USE [PMS]
    
ALter Proc [dbo].[GetConsolidatedManagerData]    
 @PropertyID INT,                        
 @StartDate DATE,                        
 @EndDate DATE,
 @option int = 1     
 AS Begin   
 
 --Declare  @PropertyID int
 --Declare @StartDate date
 --Declare @EndDate date
 --set @PropertyID =1
 --set @StartDate= '2017-06-01' 
 --set @EndDate = '2017-06-30'
 
 
IF OBJECT_ID('tempdb.dbo.#PreviousMonthManagerData', 'U') IS NOT NULL    
drop table #PreviousMonthManagerData    
    
IF OBJECT_ID('tempdb.dbo.#TaxdataPM', 'U') IS NOT NULL    
drop table #TaxdataPM    
    
IF OBJECT_ID('tempdb.dbo.#PaymentDataPM', 'U') IS NOT NULL    
drop table #PaymentDataPM 

CREATE TABLE #PreviousMonthManagerData (    
  d DATETime,    
  TotalRooms int default(0),    
  Rooms money default(0),    
  TotalTax money default(0),    
  MiscIncome money default(0),    
  Total money default(0),    
  ADR money default(0),    
  RevPAR money default(0),        
  PRIMARY KEY (d)    
)    

select distinct TaxShortName, IDENTITY(int,1,1) as ID into #TaxdataPM from InvoiceTaxDetail  where COALESCE(PATINDEX('%[^ ]%', [TaxShortName]), 0) > 0  
select distinct PaymentMode, IDENTITY(int,1,1) as ID into #PaymentDataPM from invoicepaymentdetails where COALESCE(PATINDEX('%[^ ]%', [PaymentMode]), 0) > 0  

Declare @Script as Varchar(8000);    
Declare @Script_prepare as Varchar(8000); 

Set @Script_prepare = 'Alter table #PreviousMonthManagerData Add [?] money;'    
Set @Script = ''    
     
Select    
            @Script = @Script + Replace(@Script_prepare, '?', Replace([TaxShortName], ' ',''))    
From    
            #TaxdataPM    
Exec (@Script) 

Set @Script_prepare = 'Alter table #PreviousMonthManagerData Add [?] money;'    
Set @Script = ''    
     
Select @Script = @Script + Replace(@Script_prepare, '?', [dbo].RemoveAllSpaces([PaymentMode]))    
From #PaymentDataPM   
    
Exec (@Script) 

Insert into #PreviousMonthManagerData  
Exec [GetManagerData] @PropertyId,@StartDate,@EndDate 

Set @Script = 'Select 
Sum(Rooms) as Rooms
,Sum(Rooms) as TotalTax
,Sum(MiscIncome) as MiscIncome
,Sum(Total) as Total
,Sum(ADR) as ADR
,Sum(RevPAR) as RevPAR'

DECLARE @LoopCounter INT    
DECLARE @MaxTaxID INT    
Declare @TaxName nvarchar(max)
Declare @PaymentMode nvarchar(max)    
    
Select @LoopCounter = MIN(ID), @MaxTaxID = MAX(ID) from #TaxdataPM   
    
WHILE(@LoopCounter <= @MaxTaxID)    
BEGIN    
Select @TaxName=[dbo].RemoveAllSpaces([TaxShortName]) from #TaxdataPM where ID = @LoopCounter     
Set @Script = @Script + ' ,Sum(' + @TaxName + ') as ' +  @TaxName 
SET @LoopCounter=@LoopCounter+1    
END 


Select @LoopCounter = MIN(ID), @MaxTaxID = MAX(ID) from #PaymentDataPM    
    
WHILE(@LoopCounter <= @MaxTaxID)    
BEGIN    
Select @PaymentMode=[dbo].RemoveAllSpaces([PaymentMode]) from #PaymentDataPM where ID = @LoopCounter         
Set @Script = @Script + ' ,Sum(' + @PaymentMode + ') as ' +  @PaymentMode 
SET @LoopCounter=@LoopCounter+1    
END 

Set @Script = @Script + ' from #PreviousMonthManagerData'
--set nocount on
--print @Script
exec(@Script)
--EXECUTE sp_executesql @Script
					     
End    
    
    
GO


