using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public class Tax
    {
        public int Id { get; set; }
        public Nullable<int> PropertyId { get; set; }
        public Nullable<decimal> Value { get; set; }
        public bool IsActive { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string LastUpdatedBy { get; set; }
        public Nullable<System.DateTime> LastUpdatedOn { get; set; }
        public string TaxName { get; set; }
        public bool IsDefaultCharges { get; set; }
        public bool IsTaxIncluded { get; set; }
        public Nullable<decimal> Amount { get; set; }
    }
}
