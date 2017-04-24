using System;
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
    public class PmsResponseDto
    {
        [DataMember]
        public string ResponseStatus { get; set; }

        [DataMember]
        public object ResponseObject { get; set; }

        [DataMember]
        public string StatusDescription { get; set; }
    }

    public enum PmsApiStatus
    {
        Success,
        Failure
    }
}


