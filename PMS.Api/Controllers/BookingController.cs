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
    public partial class BookingController : ApiController, IRestController
    {
        private readonly IPmsLogic _iPMSLogic = null;
        public BookingController()
            : this(ServiceLocator.Current.GetInstance<IPmsLogic>())
        {
            
        }

        public BookingController(IPmsLogic iPMSLogic)
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
            MapHttpRoutesForBooking(config);
        }

        private void MapHttpRoutesForBooking(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
             "AddBooking",
             "api/v1/Booking/AddBooking",
             new { controller = "Booking", action = "AddBooking" }
             );
        }

        [HttpPost, ActionName("AddBooking")]
        public PmsResponseDto AddBooking([FromBody] AddBookingRequestDto request)
        {
            if (request == null || request.Booking == null) throw new PmsException("Room Booking can not be done.");
            
            var response = new PmsResponseDto();
            if(_iPMSLogic.AddBooking(request.Booking))
            {
                response.ResponseStatus = PmsApiStatus.Success;
                response.StatusDescription = "Booking is done successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure;
                response.StatusDescription = "Booking is failed.Contact administrator.";
            }

            return response;
        }
    }
}
