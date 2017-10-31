
ALTER PROC [dbo].[GetConsolidatedShiftReport]               
@StartDate Datetime,    
@EndDate DateTime,    
@PropertyId nvarchar(max)        
AS BEGIN    
  
  
If(OBJECT_ID('tempdb..#tmpData') Is Not Null)  
Begin  
    Drop Table #tmpData  
End  
  
If(OBJECT_ID('tempdb..#tmp_Table') Is Not Null)  
Begin  
    Drop Table #tmp_Table  
End  
  
If(OBJECT_ID('tempdb..#Taxdata') Is Not Null)  
Begin  
    Drop Table #Taxdata  
End  
  
If(OBJECT_ID('tempdb..#PaymentData') Is Not Null)  
Begin  
    Drop Table #PaymentData  
End  
  
  
create table #tmpData  
(  
 DataType nvarchar(max),  
 ADR money,  
 RevPAR money,  
 RoomCharges money,  
 ConsolidatedTax money  
 )  
   
   
create table #tmp_Table  
(  
 CheckinTime Datetime,  
 CheckoutTime Datetime,  
 TransactionNumber int,  
 RoomNumber nvarchar(200),  
 RoomCharges money,  
 GuestName nvarchar(max),  
 GuestRemarks nvarchar(max),  
 TotalAmount money  
 )  
   
IF OBJECT_ID('tempdb.dbo.#Taxdata', 'U') IS NOT NULL      
drop table #Taxdata   
   
select distinct TaxShortName, IDENTITY(int,1,1) as ID into #Taxdata from InvoiceTaxDetail  where COALESCE(PATINDEX('%[^ ]%', [TaxShortName]), 0) > 0    
   
Declare @Script as NVarchar(max);      
Declare @Script_prepare as NVarchar(max);      
      
Set @Script_prepare = 'Alter table #tmp_Table Add [?] money;'      
Set @Script = ''      
       
Select @Script = @Script + Replace(@Script_prepare, '?', Replace([TaxShortName], ' ',''))      
From #Taxdata      
  
Exec (@Script)   
  
select distinct PaymentMode, IDENTITY(int,1,1) as ID into #PaymentData from invoicepaymentdetails where COALESCE(PATINDEX('%[^ ]%', [PaymentMode]), 0) > 0    
      
Set @Script_prepare = 'Alter table #tmp_Table Add [?] money;'      
Set @Script = ''      
       
Select @Script = @Script + Replace(@Script_prepare, '?', [dbo].RemoveAllSpaces([PaymentMode]))      
From #PaymentData      
      
Exec (@Script)         
  
 --Fetch data from Stored-Procedure for Today  
 Insert into #tmp_Table  
 Exec GetShiftReport @StartDate,@EndDate,@PropertyId  
   
 Declare @RoomCharges money  
 Declare @TotalRentedRooms int  
 Declare @TotalRentableRooms int  
   
 set @RoomCharges = (select SUM(ISNULL(RoomCharges,0)) from #tmp_Table)  
 set @TotalRentedRooms = (select COUNT(1) from #tmp_Table)   
 set @TotalRentableRooms = (select COUNT(1) from Room)  
   
 Declare @ADR money  
 Declare @RevPAR money  
 Declare @consolidatedTax money  
   
 set @ADR = @RoomCharges /@TotalRentedRooms  
 set @RevPAR = @RoomCharges / @TotalRentableRooms  
   
 Declare @LoopCounter int, @MaxTaxId int,@MinTaxId int, @TaxName nvarchar(200)  
 Select @LoopCounter = MIN(ID),@MinTaxId = MIN(ID), @MaxTaxId = MAX(ID) from #Taxdata  
   
 set @Script = 'Select @consolidatedTax1= '  
   
 while(@LoopCounter is not null and @LoopCounter <=@MaxTaxId)  
 Begin  
  select @TaxName = TaxShortName from #Taxdata where ID = @LoopCounter  
  if(COALESCE(PATINDEX('%[^ ]%', @TaxName), 0) > 0)  
  Begin  
  if(@MinTaxId = @LoopCounter)  
  Set @Script = @Script + ' SUM(' + @TaxName +')'  
  else  
   Set @Script = @Script + '+ SUM(' + @TaxName +')'  
  End  
  set @LoopCounter = @LoopCounter +1  
 End  
   
 set @Script = @Script + ' from #tmp_Table'  
 --Print(@Script)   
   
 exec sp_executesql @Script, N'@consolidatedTax1 money out', @consolidatedTax out  
 --print @consolidatedTax  
   
 insert into #tmpData values('Today',@ADR,@RevPAR,@RoomCharges,@consolidatedTax)  
   
 --Fetch data from Stored-Procedure for Month  
   
 If(OBJECT_ID('tempdb..#tmp_Table') Is Not Null)  
Begin  
    Truncate Table #tmp_Table  
End  
  
SELECT @StartDate = DATEADD(month, DATEDIFF(month, 0, @EndDate), 0)  
  
Insert into #tmp_Table  
 Exec GetShiftReport @StartDate,@EndDate,@PropertyId  
   
set @RoomCharges = (select SUM(ISNULL(RoomCharges,0)) from #tmp_Table)  
set @TotalRentedRooms = (select COUNT(1) from #tmp_Table)   
set @TotalRentableRooms = (select COUNT(1) from Room)  
   
 set @ADR = @RoomCharges /@TotalRentedRooms  
 set @RevPAR = @RoomCharges / @TotalRentableRooms  
   
 Select @LoopCounter = MIN(ID),@MinTaxId = MIN(ID), @MaxTaxId = MAX(ID) from #Taxdata  
  
 set @Script = 'Select @consolidatedTax1= '  
   
 while(@LoopCounter is not null and @LoopCounter <=@MaxTaxId)  
 Begin  
  select @TaxName = TaxShortName from #Taxdata where ID = @LoopCounter  
  if(COALESCE(PATINDEX('%[^ ]%', @TaxName), 0) > 0)  
  Begin  
  if(@MinTaxId = @LoopCounter)  
  Set @Script = @Script + ' SUM(' + @TaxName +')'  
  else  
   Set @Script = @Script + '+ SUM(' + @TaxName +')'  
  End  
  set @LoopCounter = @LoopCounter +1  
 End  
   
 set @Script = @Script + ' from #tmp_Table'  
 --Print(@Script)   
   
 exec sp_executesql @Script, N'@consolidatedTax1 money out', @consolidatedTax out  
 --print @consolidatedTax  
   
 insert into #tmpData values('Monthly',@ADR,@RevPAR,@RoomCharges,@consolidatedTax)  
   
--Fetch data from Stored-Procedure for Yearly  
   
 If(OBJECT_ID('tempdb..#tmp_Table') Is Not Null)  
Begin  
    Truncate Table #tmp_Table  
End  
  
SELECT @StartDate = DATEADD(yy, DATEDIFF(yy, 0, @EndDate), 0)  
  
Insert into #tmp_Table  
 Exec GetShiftReport @StartDate,@EndDate,@PropertyId  
   
set @RoomCharges = (select SUM(ISNULL(RoomCharges,0)) from #tmp_Table)  
set @TotalRentedRooms = (select COUNT(1) from #tmp_Table)   
set @TotalRentableRooms = (select COUNT(1) from Room)  
   
 set @ADR = @RoomCharges /@TotalRentedRooms  
 set @RevPAR = @RoomCharges / @TotalRentableRooms  
   
 Select @LoopCounter = MIN(ID),@MinTaxId = MIN(ID), @MaxTaxId = MAX(ID) from #Taxdata  

 set @Script = 'Select @consolidatedTax1= '  
   
 while(@LoopCounter is not null and @LoopCounter <=@MaxTaxId)  
 Begin  
  select @TaxName = TaxShortName from #Taxdata where ID = @LoopCounter  
  if(COALESCE(PATINDEX('%[^ ]%', @TaxName), 0) > 0)  
  Begin  
  if(@MinTaxId = @LoopCounter)  
  Set @Script = @Script + ' SUM(' + @TaxName +')'  
  else  
   Set @Script = @Script + '+ SUM(' + @TaxName +')'  
  End  
  set @LoopCounter = @LoopCounter +1  
 End  
   
 set @Script = @Script + ' from #tmp_Table'  
 --Print(@Script)   
   
 exec sp_executesql @Script, N'@consolidatedTax1 money out', @consolidatedTax out  
 --print @consolidatedTax  
   
 insert into #tmpData values('Yearly',@ADR,@RevPAR,@RoomCharges,@consolidatedTax)  
  
   
 select  
 DataType,  
 ADR,  
 RevPAR,  
 RoomCharges,  
 ConsolidatedTax from #tmpData  
END      
  