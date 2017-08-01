using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public class Room
    {
        public int Id { get; set; }
        public string Number { get; set; }
        public bool IsActive { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string LastUpdatedBy { get; set; }
        public Nullable<System.DateTime> LastUpdatedOn { get; set; }
        public int PropertyId { get; set; }
        public int RoomTypeId { get; set; }
        public int FloorId { get; set; }
        public Property Property { get; set; }
        public RoomType RoomType { get; set; }
        public RoomStatus RoomStatus { get; set; }
        public PropertyFloor Floor { get; set; }
        public RateType RateType { get; set; }
    }
}
