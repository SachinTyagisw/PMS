using PMS.Resources.Entities;
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
    public class GetRateTypeResponseDto
    {
        [DataMember]
        public List<RateType> RateTypes { get; set; }
    }
}
