using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public class AdditionalGuest
    {
        public int Id { get; set; }
        public Nullable<int> BookingId { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string GUESTIDPath { get; set; }
        public bool IsActive { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string LastUpdatedBy { get; set; }
        public Nullable<System.DateTime> LastUpdatedOn { get; set; }
        public string Gender { get; set; }

        public Booking Booking { get; set; }
    }
}
