﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public class RateType
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public bool IsActive { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string LastUpdatedBy { get; set; }
        public Nullable<System.DateTime> LastUpdatedOn { get; set; }
        public Nullable<int> PropertyId { get; set; }
        public Nullable<int> RoomTypeID { get; set; }
        public string Units { get; set; }
        public Nullable<int> Hours { get; set; }
        public List<Rate> Rates { get; set; }
    }
}
