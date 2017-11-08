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
    public class ConsolidatedManagerReportDto
    {
        [DataMember]
        public DateTime StartDate{ get; set; }

        [DataMember]
        public DateTime EndDate { get; set; }

        [DataMember]
        public int PropertyId { get; set; }

        [DataMember]
        public int Option { get; set; }
    }
}
