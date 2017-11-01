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
    public class UserAccessRequestDto
    {
        [DataMember]
        public int UserId { get; set; }
        [DataMember]
        public string Functionalities { get;set;}
        [DataMember]
        public string Properties { get;set;}
        [DataMember]
        public String CreatedBy { get;set;}
    }
}
