﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public class State
    {
        public int Id { get; set; }
        public int CountryId { get; set; }
        public string Name { get; set; }
        public bool IsActive { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string LastUpdatedBy { get; set; }
        public Nullable<System.DateTime> LastUpdatedOn { get; set; }        
    }
}
