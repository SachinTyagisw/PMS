using PMS.Resources.Caching;
using PMS.Resources.Core;
using PMS.Resources.DAL;
using PMS.Resources.Logging.Logger;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;

namespace PMS.Api
{
    public class WebApiApplication : System.Web.HttpApplication
    {
        private IDalFactory _iDalFactory = null;
        private ICacheProvider _iCacheProvider = null;

        protected void Application_Start()
        {
            GlobalConfiguration.Configuration.Formatters.Remove(GlobalConfiguration.Configuration.Formatters.XmlFormatter);
            var json = GlobalConfiguration.Configuration.Formatters.JsonFormatter;
            json.SerializerSettings.DefaultValueHandling = Newtonsoft.Json.DefaultValueHandling.Ignore;

            AreaRegistration.RegisterAllAreas();
            GlobalConfiguration.Configure(WebApiConfig.Register);
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);

            _iDalFactory = new DalFactory();
            if (_iDalFactory != null && HttpContext.Current.Application["DalFactory"] == null)
            {
                HttpContext.Current.Application["DalFactory"] = _iDalFactory;
            }

            _iCacheProvider = new CacheProvider();
            if (_iCacheProvider != null && HttpContext.Current.Application["CacheProvider"] == null)
            {
                HttpContext.Current.Application["CacheProvider"] = _iCacheProvider;
            }

            try
            {
                foreach (var item in ServiceLocator.Current.GetAllInstance<IRestController>())
                {
                    item.MapHttpRoutes(GlobalConfiguration.Configuration);
                }
                    
            }
            catch (ReflectionTypeLoadException ex)
            {
                string exceptionList = string.Empty;
                foreach (Exception loaderException in ex.LoaderExceptions)
                {
                    exceptionList += loaderException.Message + "\n";
                }
                throw;
            }
        }

        protected void Application_Error(object sender, EventArgs e)
        {
            //for unhandled exception
            var exception = Server.GetLastError();
            var logService = LoggingManager.GetLogInstance();
            logService.LogException("Unhandled Exception From PMS Api", exception);
        }
    }
}
