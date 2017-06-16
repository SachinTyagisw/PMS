using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public class Invoice
    {
        public int Id { get; set; }
        public int GuestId { get; set; }
        public int PropertyId { get; set; }
        public int BookingId { get; set; }
        public Nullable<bool> IsPaid { get; set; }
        public Nullable<decimal> TotalAmount { get; set; }
        public string FolioNumber { get; set; }
        public bool IsActive { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string LastUpdatedBy { get; set; }
        public Nullable<System.DateTime> LastUpdatedOn { get; set; }
        public Nullable<decimal> Discount { get; set; }
        public List<InvoiceTaxDetail> InvoiceTaxDetails { get; set; }
        public List<InvoiceItem> InvoiceItems { get; set; }
        public List<InvoicePaymentDetail> InvoicePaymentDetails { get; set; }    
    }
}
