using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public class InvoicePaymentDetail
    {
        public int ID { get; set; }
        public int InvoiceID { get; set; }
        public string PaymentMode { get; set; }
        public Nullable<decimal> PaymentValue { get; set; }
        public string PaymentDetails { get; set; }
        public bool IsActive { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string LastUpdatedBy { get; set; }
        public Nullable<System.DateTime> LastUpdatedOn { get; set; }
    }
}
