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
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string PhotoPath { get; set; }
        public string Gender { get; set; }
        public string IdDetails { get; set; }
        public int IdTypeId { get; set; }
    }
}
