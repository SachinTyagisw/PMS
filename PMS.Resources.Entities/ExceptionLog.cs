using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public class ExceptionLog
    {
        public int ExceptionLogId { get; set; }
        public int ExceptionLogTypeId { get; set; }
        public string SessionId { get; set; }
        public long? UserId { get; set; }
        public bool? IsAjax { get; set; }
        public string Source { get; set; }
        public int? StatusCode { get; set; }
        public string Message { get; set; }
        public string InnerException { get; set; }
        public string StackTrace { get; set; }
        public string Referer { get; set; }
        public string RemoteIP { get; set; }
        public string Browser { get; set; }
        public int ErrorLevel { get; set; }
        public System.DateTime DateTime { get; set; }
    }
}
