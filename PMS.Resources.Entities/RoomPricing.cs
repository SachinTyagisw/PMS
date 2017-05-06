using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public class RoomPricing
    {
        public int Id { get; set; }
        public decimal BasePrice { get; set; }
        public Nullable<decimal> ExtraPersonPrice { get; set; }
        public bool IsActive { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string LastUpdatedBy { get; set; }
        public Nullable<System.DateTime> LastUpdatedOn { get; set; }
        public Property Property { get; set; }
        public RateType RateType { get; set; }
        public RoomType RoomType { get; set; }
    }
}
