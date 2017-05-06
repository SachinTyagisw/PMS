using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public class GuestMapping
    {
        public int Id { get; set; }
        public int IdTypeId { get; set; }
        public int GuestId { get; set; }
        public string IdDetails { get; set; }
        public bool IsActive { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string LastUpdatedBy { get; set; }
        public Nullable<System.DateTime> LastUpdatedOn { get; set; }
        public IDType IdType { get; set; }
        public string IdIssueState { get; set; }
        public string IdIssueCountry { get; set; }
        public System.DateTime IdExpiryDate { get; set; }
    }
}
