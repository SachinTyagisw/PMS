using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public class Payment
    {
        public int? BookingId { get; set; }
        public int? PropertyId { get; set; }
        public int? RoomTypeId { get; set; }
        public int? RateTypeId { get; set; }
        public decimal? NoOfHours { get; set; }
        public Nullable<System.DateTime> CheckinTime { get; set; }
        public Nullable<System.DateTime> CheckoutTime { get; set; }
        public Nullable<bool> IsHourly { get; set; }
        public List<Tax> Tax { get; set; }
    }
}
