using PMS.Resources.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.DTO.Request
{
    [DataContract]
    [Serializable]
    public class GetRoomByDateRequestDto
    {
        [DataMember]
        public int RoomTypeId { get; set; }
        [DataMember]
        public DateTime CheckinDate { get; set; }
        [DataMember]
        public DateTime CheckoutDate { get; set; }
        [DataMember]
        public int PropertyId { get; set; }
    }
}
