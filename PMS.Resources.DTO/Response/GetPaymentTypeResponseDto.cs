using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;
using PMS.Resources.Entities;

namespace PMS.Resources.DTO.Response
{
    [DataContract]
    [Serializable]
    public class GetPaymentTypeResponseDto
    {
        public PaymentType PaymentType {get;set;}
    }
}
