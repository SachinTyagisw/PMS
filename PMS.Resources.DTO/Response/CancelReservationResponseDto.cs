using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.DTO.Response
{
    [DataContract]
    [Serializable]
    public class CancelReservationResponseDto
    {
        [DataMember]
        public bool IsCancelled { get; set; }

        [DataMember]
        public string  Status { get; set; }
    }
}
