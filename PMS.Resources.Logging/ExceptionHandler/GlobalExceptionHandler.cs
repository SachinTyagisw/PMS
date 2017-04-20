using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web.Http;
using System.Web.Http.ExceptionHandling;
using PMS.Resources.Logging.CustomException;

namespace PMS.Resources.Logging.ExceptionHandler
{
    public class GlobalExceptionHandler : System.Web.Http.ExceptionHandling.ExceptionHandler
    {
        public override void Handle(ExceptionHandlerContext context)
        {
            var exceptionType = context.Exception.GetType();

            if (exceptionType == typeof(PmsException))
            {
                var resp = new HttpResponseMessage(HttpStatusCode.BadRequest)
                {
                    Content = new StringContent(context.Exception.Message),
                    ReasonPhrase = "PMS_Global_Error"
                };
                throw new HttpResponseException(resp);

            }
            if (exceptionType == typeof(UnauthorizedAccessException))
            {
                throw new HttpResponseException(context.Request.CreateResponse(HttpStatusCode.Unauthorized));
            }
            throw new HttpResponseException(context.Request.CreateResponse(HttpStatusCode.InternalServerError));
        }
    }
}
