using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;

namespace PMS.Api
{
    public interface IRestController
    {
        /// <summary>
        /// Map REST Routes
        /// </summary>
        /// <param name="config">Config object to map the REST routes to</param>
        void MapHttpRoutes(HttpConfiguration config);
    }
}