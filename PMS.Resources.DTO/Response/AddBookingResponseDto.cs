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
    public class AddBookingResponseDto : PmsResponseDto
    {
        [DataMember]
        public int BookingId { get; set; }
        [DataMember]
        public int GuestId { get; set; }
    }
}
