using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace PMS.Web
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            routes.MapRoute(
                name: "Default",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional },
                namespaces: new[] { "PMS.Web.Controllers" }
            );

            MapRoutesForBooking(routes);
        }

        private static void MapRoutesForBooking(RouteCollection routes)
        {
            routes.MapRoute(
               name: "RoomBook",
               url: "{controller}/{action}/{id}",
               defaults: new { controller = "Booking", action = "RoomBook", id = UrlParameter.Optional },
               namespaces: new[] { "PMS.Web.Controllers" }
           );

        }
    }
}
