using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public class Functionality
    {
        public int Id { get; set; }

        public string Functionality1 { get; set; }

        public string Description { get; set; }

        public bool IsActive { get; set; }

        public string CreatedBy { get; set; }

        public Nullable<System.DateTime> CreatedOn { get; set; }

        public string LastUpdatedBy { get; set; }

        public Nullable<System.DateTime> LastUpdatedOn { get; set; }

    }
}
