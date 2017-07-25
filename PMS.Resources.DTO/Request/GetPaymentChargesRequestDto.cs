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
    public class GetPaymentChargesRequestDto
    {
        [DataMember]
        public int? PropertyId { get; set; }
        [DataMember]
        public int? RoomTypeId { get; set; }
        [DataMember]
        public int? RateTypeId { get; set; }
        [DataMember]
        public int? NoOfHours { get; set; }
        [DataMember]
        public Nullable<bool> IsHourly { get; set; }
        [DataMember]
        public int? roomId { get; set; }
        
    }
}
