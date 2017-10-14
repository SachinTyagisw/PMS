SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
            
CREATE PROC [dbo].[GetExpenseData]           
@StartDate Datetime = NULL,
@EndDate DateTime = NULL,
@PaymentTypeID int = NULL,
@ExpenseCategoryID int = NULL,
@AmountPaidMin money = NULL,
@AmountPaidMax nvarchar(max) = NULL,
@PropertyId nvarchar(max) = NULL    
AS BEGIN

select
ID,
PropertyID,
ExpenseCategoryID,
PaymentTypeID,
Amount,
Description,
IsActive,
CreatedOn,
LastUpdatedBy,
LastUpdatedOn
from
Expenses ex
where (ex.PropertyID = cast(@PropertyId as int) or @PropertyId is null)
AND (ex.ExpenseDate > @StartDate or @StartDate is null)
AND (ex.ExpenseDate < @EndDate or @EndDate is null) 
AND (ex.Amount > @AmountPaidMin or @AmountPaidMin is null)
AND (ex.Amount < @AmountPaidMax or @AmountPaidMax is null)
AND (ex.PaymentTypeID = CAST(@PaymentTypeID as int) or @PaymentTypeID is null)
AND (ex.ExpenseCategoryID = CAST(@ExpenseCategoryID as int) or @ExpenseCategoryID is null)
END

GO


