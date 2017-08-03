using PMS.Resources.Logging.Logger;
using PMS.Resources.Services;
using PMS.Resources.Services.Interface;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;

namespace PMS.Web
{
    public class MvcApplication : System.Web.HttpApplication
    {
        private IPmsService _iPMSService = null;
        protected void Application_Start()
        {
            var logService = LoggingManager.GetLogInstance();
            logService.LogInformationFormat("PMS web call start :" + DateTime.Now);

            BundleTable.EnableOptimizations = true;
            AreaRegistration.RegisterAllAreas();
            GlobalConfiguration.Configure(WebApiConfig.Register);
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);

            _iPMSService = new PmsService();
            if (_iPMSService != null && HttpContext.Current.Application["PMSService"] == null)
            {
                HttpContext.Current.Application["PMSService"] = _iPMSService;
            }
            logService.LogInformationFormat("PMS web call stop :" + DateTime.Now);
        }

        protected void Application_Error(object sender, EventArgs e)
        {
            //for unhandled exception
            var exception = Server.GetLastError();
            var logService = LoggingManager.GetLogInstance();
            logService.LogException("Unhandled Exception From PMS Web", exception);
        }
    }
}
