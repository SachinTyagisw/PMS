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
    public class ExtraChargeRequestDto
    {
        [DataMember]
        public ExtraCharge ExtraCharge { get; set; }
    }
}
