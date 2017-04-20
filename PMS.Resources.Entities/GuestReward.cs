using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public class GuestReward
    {
        public int Id { get; set; }
        public Nullable<bool> IsCredit { get; set; }
        public Nullable<System.DateTime> ExpirationDate { get; set; }
        public Nullable<int> NoOfPoints { get; set; }
        public string Decription { get; set; }
        public Nullable<bool> IsActive { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string LastUpdatedBy { get; set; }
        public Nullable<System.DateTime> LastUpdatedOn { get; set; }
        public int GuestId { get; set; }
        public int BookingId { get; set; }
    }
}
