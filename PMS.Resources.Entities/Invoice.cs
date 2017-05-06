using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public partial class Invoice
    {
        public int ID { get; set; }
        public Nullable<bool> IsPaid { get; set; }
        public string FolioNumber { get; set; }
        public Nullable<decimal> ExtraCharges { get; set; }
        public bool IsActive { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string LastUpdatedBy { get; set; }
        public Nullable<System.DateTime> LastUpdatedOn { get; set; }

        public Booking Booking { get; set; }
        public Guest Guest { get; set; }
        public List<InvoiceTaxDetail> InvoiceTaxDetails { get; set; }
    }
}
