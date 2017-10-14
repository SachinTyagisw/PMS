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
    public class SearchExpenseRequestDto
    {
        [DataMember]
        public DateTime? StartDate { set; get; }
        [DataMember]
        public DateTime? EndDate { set; get; }
        [DataMember]
        public int? PaymentId { set; get; }
        [DataMember]
        public int? ExpenseCategoryId { set; get; }
        [DataMember]
        public decimal? AmountPaidMin { set; get; }
        [DataMember]
        public decimal? AmountPaidMax { set; get; }
        [DataMember]
        public int? PropertyId { set; get; }
    }
}
