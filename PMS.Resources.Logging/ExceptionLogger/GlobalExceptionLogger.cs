using PMS.Resources.Entities;
using PMS.Resources.Logging.Logger;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http.ExceptionHandling;
using Microsoft.AspNet.Identity;

namespace PMS.Resources.Logging.ExceptionLogger
{
    public class GlobalExceptionLogger : System.Web.Http.ExceptionHandling.ExceptionLogger
    {
        public override void Log(ExceptionLoggerContext context)
        {
            string bodyText;
            using (var sr = new StreamReader(HttpContext.Current.Request.InputStream))
            {
                sr.BaseStream.Seek(0, SeekOrigin.Begin);
                bodyText = sr.ReadToEnd();
            }

            //Do whatever logging you need to do here.
            var requestUri = HttpContext.Current.Request.Url.AbsoluteUri;
            var logService = LoggingManager.GetLogInstance();
            logService.LogException(context.Exception.Message + " , With request : " + bodyText + " , Request URI : " + requestUri, context.Exception);
            
            var additionalExData = new ExceptionLog()
            {
                ExceptionLogTypeId = 1,
                SessionId = "mobile", //Session.SessionID
                UserId = HttpContext.Current.User.Identity.GetUserId<int>(),
                //IsAjax = isAjaxRequest,
                Source = HttpContext.Current.Request.RawUrl + " RAW: " + HttpContext.Current.Request.Url,
                StatusCode = 500,
                Message = context.Exception.Message + " , With request : " + bodyText + " , Request URI : " + requestUri,
                InnerException = context.Exception.InnerException != null ? context.Exception.InnerException.ToString() : null,
                StackTrace = context.Exception.StackTrace,
                Referer = HttpContext.Current.Request.ServerVariables["http_referer"],
                RemoteIP = HttpContext.Current.Request.ServerVariables["HTTP_X_FORWARDED_FOR"] ?? HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"],
                Browser = HttpContext.Current.Request.UserAgent,
                DateTime = DateTime.UtcNow
            };

            //log exception to db
            logService.LogExceptionDataToDb(additionalExData);
        }
    }
}
