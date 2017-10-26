--Exec GetManagerData 1, '2017-06-01', '2017-06-30'    
    
ALTER Proc GetManagerData    
 @PropertyID INT,                        
 @StartDate DATE,                        
 @EndDate DATE     
 AS Begin    
    
IF OBJECT_ID('tempdb.dbo.#ManagerData', 'U') IS NOT NULL    
drop table #ManagerData    
    
IF OBJECT_ID('tempdb.dbo.#Taxdata', 'U') IS NOT NULL    
drop table #Taxdata    
    
IF OBJECT_ID('tempdb.dbo.#PaymentData', 'U') IS NOT NULL    
drop table #PaymentData    
  
    
CREATE TABLE #ManagerData (    
  d DATE,    
  TotalRooms int default(0),    
  Rooms money default(0),    
  TotalTax money default(0),    
  MiscIncome money default(0),    
  Total money default(0),    
  ADR money default(0),    
  RevPAR money default(0),        
  PRIMARY KEY (d)    
)    
     
WHILE ( @StartDate < @EndDate )    
BEGIN    
  INSERT INTO #ManagerData (d) VALUES( @StartDate )    
  SELECT @StartDate = DATEADD(DAY, 1, @StartDate )      
END    
    
--Get Distict Tax    
select distinct [dbo].fnRemoveSpecialCharacter(TaxShortName) as 'TaxShortName', IDENTITY(int,1,1) as ID into #Taxdata from InvoiceTaxDetail  where COALESCE(PATINDEX('%[^ ]%', [TaxShortName]), 0) > 0   
    
Declare @Script as Varchar(8000);    
Declare @Script_prepare as Varchar(8000);    
    
Set @Script_prepare = 'Alter table #ManagerData Add [?] money;'    
Set @Script = ''    
     
Select    
            @Script = @Script + Replace(@Script_prepare, '?', Replace([TaxShortName], ' ',''))    
From    
            #Taxdata    
Exec (@Script)    
    
--Get Distict PaymentMode    
select distinct [dbo].fnRemoveSpecialCharacter(PaymentMode) as 'PaymentMode', IDENTITY(int,1,1) as ID into #PaymentData from invoicepaymentdetails where COALESCE(PATINDEX('%[^ ]%', [PaymentMode]), 0) > 0   
    
Set @Script_prepare = 'Alter table #ManagerData Add [?] money;'    
Set @Script = ''    
     
Select @Script = @Script + Replace(@Script_prepare, '?', [dbo].RemoveAllSpaces([PaymentMode]))    
From #PaymentData    
    
Exec (@Script)    
    
DECLARE @LoopCounter INT    
DECLARE @MaxTaxID INT    
Declare @TaxName nvarchar(max)    
    
Select @LoopCounter = MIN(ID), @MaxTaxID = MAX(ID) from #Taxdata    
    
WHILE(@LoopCounter <= @MaxTaxID)    
BEGIN    
Select @TaxName=[dbo].RemoveAllSpaces([TaxShortName]) from #Taxdata where ID = @LoopCounter     
Set @Script = 'update #ManagerData set ' + @TaxName + '= [dbo].[fnGetManagerConsolidatedTax](''' + @TaxName + '''' + ', d )'    
print @Script    
Exec (@Script)    
SET @LoopCounter=@LoopCounter+1    
END    
    
    
Select @LoopCounter = MIN(ID), @MaxTaxID = MAX(ID) from #PaymentData    
Declare @PaymentMode nvarchar(max)    
    
WHILE(@LoopCounter <= @MaxTaxID)    
BEGIN    
Select @PaymentMode=[dbo].RemoveAllSpaces([PaymentMode]) from #PaymentData where ID = @LoopCounter     
Set @Script = 'update #ManagerData set ' + @PaymentMode + '= [dbo].[fnGetConsolidatedPayment](''' + @PaymentMode + '''' + ', d )'    
print @Script    
Exec (@Script)    
SET @LoopCounter=@LoopCounter+1    
END    
    
declare @TotalNoOfRooms int    
select @TotalNoOfRooms = COUNT(1) from Room where PropertyID = @PropertyID    
Update #ManagerData set    
TotalRooms = [dbo].getTotalRooms(d),    
Rooms = [dbo].getRooms(d),    
TotalTax = [dbo].getTotalTax(d),    
Total = [dbo].getTotalPayment(d),    
ADR = case when TotalRooms != 0 then Rooms / TotalRooms else 0 end,    
RevPAR = case when @TotalNoOfRooms !=0 then Rooms /@TotalNoOfRooms else 0 end    
    
select * from  #ManagerData    
    
End    
    