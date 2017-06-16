using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public class RoomBooking
    {
        public int Id { get; set; }
        public Nullable<bool> IsExtra { get; set; }
        public Nullable<decimal> Discount { get; set; }
        public Nullable<decimal> RoomCharges { get; set; }
        public bool IsActive { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string LastUpdatedBy { get; set; }
        public Nullable<System.DateTime> LastUpdatedOn { get; set; }
        public Room Room { get; set; }
        public Guest Guest { get; set; }
        public int GuestID { get; set; }
        public int RoomId { get; set; }
        public int BookingId { get; set; }
        public bool ShouldSerializeDiscount()
        {
            return Discount != null;
        }
        public bool ShouldSerializeRoomCharges()
        {
            return RoomCharges != null;
        }
    }
}
