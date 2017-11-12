using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public class GuestSummary
    {
        public int Id { get; set; }
        public int PropertyId { get; set; }
        public Nullable<System.DateTime> CheckinTime { get; set; }
        public Nullable<System.DateTime> CheckoutTime { get; set; }
        public string Status { get; set; }
        public string ModeOFPayment { get; set; }
        public Nullable<decimal> Rate { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public int GuestId { get; set; }
        public int RoomBookingId { get; set; }
        public int RoomId { get; set; }
        public string RoomNumber { get; set; }
        public int RoomTypeID { get; set; }
        public string RoomTypeName { get; set; }
        public string RoomTypeShortName { get; set; }
        public string RoomStatus { get; set; }
        public Nullable<decimal> TotalAmount { get; set; }
        public System.DateTime NextReservation { get; set; }
    }
}
