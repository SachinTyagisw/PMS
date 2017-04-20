using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace PMS.Resources.Logging.CustomException
{
    public class PmsException : HttpException
    {
        public PmsException(string message)
            : base(message)
        {
        }

        public PmsException(int httpCode, string message, Exception innerException)
            : base(httpCode, message, innerException)
        {

        }

    }
}
