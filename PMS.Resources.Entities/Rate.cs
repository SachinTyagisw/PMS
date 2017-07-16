using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public class Rate
    {
        public int Id { get; set; }
        public string Type { get; set; }
        public Nullable<int> PropertyId { get; set; }
        public Nullable<int> InputKeyHours { get; set; }
        public Nullable<decimal> Value { get; set; }
        public Nullable<bool> IsActive { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string LastUpdatedBy { get; set; }
        public Nullable<System.DateTime> LastUpdatedOn { get; set; }
        public Room Room { get; set; }
        public RoomType RoomType { get; set; }
        public RateType RateType { get; set; }

    }
}
