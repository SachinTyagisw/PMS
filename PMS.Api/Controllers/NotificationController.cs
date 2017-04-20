using PMS.Resources.Common.Constants;
using PMS.Resources.Core;
using PMS.Resources.DTO.Request;
using PMS.Resources.DTO.Response;
using PMS.Resources.Logging.CustomException;
using PMS.Resources.Logic;
using System;
using System.Collections.Generic;
using System.ComponentModel.Composition;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace PMS.Api.Controllers
{
    [Export(typeof(IRestController))]
    [PartCreationPolicy(CreationPolicy.NonShared)]
    public partial class NotificationController : ApiController, IRestController
    {
        private readonly IPmsLogic _iPMSLogic = null;

        public NotificationController()
            : this(ServiceLocator.Current.GetInstance<IPmsLogic>())
        {
            
        }

        public NotificationController(IPmsLogic iPMSLogic)
        {
            _iPMSLogic = iPMSLogic;
        }

        /// <summary>
        /// Map Routes for REST
        /// </summary>
        /// <param name="config"></param>
        [System.Web.Http.NonAction]
        public void MapHttpRoutes(HttpConfiguration config)
        {
            MapHttpRoutesForNotification(config);
        }
        
        private void MapHttpRoutesForNotification(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
            "GetAllNotification",
            "api/v1/Notification/GetAllNotification",
            new { controller = "Notification", action = "GetAllNotification" }
            );
        }

        [HttpGet, ActionName("GetAllNotification")]
        public GetNotificationResponseDto GetAllNotification()
        {
            var response = new GetNotificationResponseDto();
            return response;
        }
    }
}
