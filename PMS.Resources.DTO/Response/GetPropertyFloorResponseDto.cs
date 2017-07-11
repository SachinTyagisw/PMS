using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;
using PMS.Resources.Entities;
using System;

namespace PMS.Resources.DTO.Response
{

    [DataContract]
    [Serializable]
    public class GetPropertyFloorResponseDto
    {
        [DataMember]
        public List<PropertyFloor> PropertyFloors { get; set; }
    }
}
