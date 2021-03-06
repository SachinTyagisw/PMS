//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace PMS.Resources.DAL
{
    using System;
    using System.Collections.Generic;
    
    public partial class Invoice
    {
        public Invoice()
        {
            this.InvoiceTaxDetails = new HashSet<InvoiceTaxDetail>();
        }
    
        public int ID { get; set; }
        public int GuestID { get; set; }
        public int BookingID { get; set; }
        public Nullable<bool> IsPaid { get; set; }
        public Nullable<decimal> TotalAmount { get; set; }
        public string FolioNumber { get; set; }
        public bool IsActive { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string LastUpdatedBy { get; set; }
        public Nullable<System.DateTime> LastUpdatedOn { get; set; }
        public Nullable<decimal> DISCOUNT { get; set; }
        public string CreditCardDetail { get; set; }
        public Nullable<decimal> DiscountAmount { get; set; }
    
        public virtual Booking Booking { get; set; }
        public virtual Guest Guest { get; set; }
        public virtual ICollection<InvoiceTaxDetail> InvoiceTaxDetails { get; set; }
    }
}
