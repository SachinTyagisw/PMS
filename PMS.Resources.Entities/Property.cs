using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public class Property
    {
        public int Id { get; set; }
        public string PropertyDetails { get; set; }
        public Nullable<bool> IsActive { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string LastUpdatedBy { get; set; }
        public Nullable<System.DateTime> LastUpdatedOn { get; set; }

        public List<Booking> Bookings { get; set; }
        public List<RateType> RateTypes { get; set; }
        public List<Room> Rooms { get; set; }
        public List<RoomPricing> RoomPricings { get; set; }
        public List<RoomType> RoomTypes { get; set; }
    }
}
