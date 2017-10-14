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
@AmountPaidMax money = NULL,
@PropertyId int = NULL    
AS BEGIN

select
ex.ID,
ex.PropertyID,
ex.ExpenseCategoryID,
ex.PaymentTypeID,
ex.Amount,
ex.Description,
ex.IsActive,
ex.ExpenseDate,
ex.CreatedOn,
ex.CreatedBy,
ex.LastUpdatedBy,
ex.LastUpdatedOn,
pt.ShortName as [PaymentShortName],
pt.Description as [PaymentDesc],
exc.ShortName as [CategoryShortName],
exc.Description as [CategoryDesc]
from
Expenses ex
inner join PaymentType pt on pt.PropertyID= ex.PaymentTypeID
inner join ExpenseCategory exc on exc.ID= ex.ExpenseCategoryID
where (ex.PropertyID = cast(@PropertyId as int) or @PropertyId is null)
AND (ex.ExpenseDate > @StartDate or @StartDate is null)
AND (ex.ExpenseDate < @EndDate or @EndDate is null) 
AND (ex.Amount > @AmountPaidMin or @AmountPaidMin is null)
AND (ex.Amount < @AmountPaidMax or @AmountPaidMax is null)
AND (ex.PaymentTypeID = CAST(@PaymentTypeID as int) or @PaymentTypeID is null)
AND (ex.ExpenseCategoryID = CAST(@ExpenseCategoryID as int) or @ExpenseCategoryID is null)
and ex.isActive =1
END

GO


