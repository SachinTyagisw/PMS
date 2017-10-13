using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public class Expense
    {
        public int Id { get; set; }

        public Nullable<int> PropertyID { get; set; }

        public Nullable<int> ExpenseCategoryID { get; set; }

        public Nullable<int> PaymentTypeID { get; set; }

        public Nullable<decimal> Amount { get; set; }

        public string Description { get; set; }

        public Nullable<bool> IsActive { get; set; }

        public string CreatedBy { get; set; }

        public Nullable<System.DateTime> CreatedOn { get; set; }

        public string LastUpdatedBy { get; set; }

        public Nullable<System.DateTime> LastUpdatedOn { get; set; }
        public ExpenseCategory ExpenseCategory { get; set; }

        public PaymentType PaymentType { get; set; }
    }
}
