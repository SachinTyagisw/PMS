using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Web.Http;
using Microsoft.Owin.Security.OAuth;
using Newtonsoft.Json.Serialization;
using System.Web.Http.Cors;
using System.Web.Http.ExceptionHandling;
using PMS.Resources.Logging.ExceptionLogger;
using PMS.Resources.Logging.ExceptionHandler;
using PMS.Resources.Common.Helper;
using PMS.Resources.Common.Constants;

namespace PMS.Api
{
    public static class WebApiConfig
    {
        public static void Register(HttpConfiguration config)
        {
            // Web API configuration and services
            // Configure Web API to use only bearer token authentication.
            config.SuppressDefaultHostAuthentication();
            config.Filters.Add(new HostAuthenticationFilter(OAuthDefaults.AuthenticationType));

            // Web API routes
            config.MapHttpAttributeRoutes();

            //config.Routes.MapHttpRoute(
            //    name: "DefaultApi",
            //    routeTemplate: "api/{controller}/{id}",
            //    defaults: new { id = RouteParameter.Optional }
            //);

            //resolve CORS issue : i.e. response for preflight has invalid http status code 405 web api
            if (AppConfigReaderHelper.AppConfigToBool(AppSettingKeys.CorsEnabled))
            {
                var cors = new EnableCorsAttribute("*", "*", "*", "*");
                config.EnableCors(cors);
            }

            config.Services.Replace(typeof(IExceptionLogger), new GlobalExceptionLogger());
            config.Services.Replace(typeof(IExceptionHandler), new GlobalExceptionHandler());
        }
    }
}
