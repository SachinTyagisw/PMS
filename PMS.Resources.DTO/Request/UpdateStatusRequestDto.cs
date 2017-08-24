using PMS.Resources.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.DTO.Request
{
    public class UpdateStatusRequestDto
    {
        [DataMember]
        public int BookingId { get; set; }
        [DataMember]
        public bool Status { get; set; }
        [DataMember]
        public int PropertyId { get; set; }
    }
}
