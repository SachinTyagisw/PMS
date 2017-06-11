using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public class Booking
    {
        public int Id { get; set; }
        public double DurationOfStay { get; set; }  
        public Nullable<System.DateTime> CheckinTime { get; set; }
        public Nullable<System.DateTime> CheckoutTime { get; set; }
        public Nullable<int> NoOfAdult { get; set; }
        public Nullable<int> NoOfChild { get; set; }
        public string GuestRemarks { get; set; }
        public string TransactionRemarks { get; set; }
        public bool IsActive { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string LastUpdatedBy { get; set; }
        public Nullable<System.DateTime> LastUpdatedOn { get; set; }
        public int PropertyId { get; set; }
        public string Status { get; set; }
        public Nullable<bool> ISHOURLYCHECKIN { get; set; }
        public Nullable<int> HOURSTOSTAY { get; set; }
        public List<RoomBooking> RoomBookings { get; set; }
        public List<Guest> Guests { get; set; }
        public List<Address> Addresses { get; set; }
        public List<GuestMapping> GuestMappings { get; set; }
        public List<AdditionalGuest> AdditionalGuests { get; set; }
        public Invoice Invoice { get; set; }
    }
}
