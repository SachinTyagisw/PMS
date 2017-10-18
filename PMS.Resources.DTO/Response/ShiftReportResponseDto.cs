using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.DTO.Response
{
    [DataContract]
    [Serializable]
    public class ShiftReportResponseDto
    {
        [DataMember]
        public DataTable ShiftRecords { get; set; }
    }
}
