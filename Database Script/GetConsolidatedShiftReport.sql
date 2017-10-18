Create PROC [dbo].[GetConsolidatedShiftReport]             
@StartDate Datetime = NULL,  
@EndDate DateTime = NULL,  
@PropertyId nvarchar(max) = NULL      
AS BEGIN  

If(OBJECT_ID('tempdb..#tmpData') Is Not Null)
Begin
    Drop Table #tmpData
End

create table #tmpData
(
 DataType nvarchar(max),
 ADR money,
 RevPAR money,
 RoomCharges money,
 ConsolidatedTax money
 )
 
 --Dummy Data
 insert into #tmpData values('Today',44.44,13.33,400.00,56.5)
 insert into #tmpData values('Monthly',144.44,113.33,800.00,90.5)
 insert into #tmpData values('Yearly',1444.44,1013.33,1200.00,9889.5)
 
 select
 DataType,
 ADR,
 RevPAR,
 RoomCharges,
 ConsolidatedTax from #tmpData
    
END    