using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public class BookingSummary
    {
        public int Id { get; set; }
        public string DateRange { get; set; }
        public bool Status { get; set; }
        public int TotalBooking { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal TotalTax { get; set; }
    }
}
