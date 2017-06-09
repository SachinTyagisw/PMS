using PMS.Resources.Common.Constants;
using PMS.Resources.Common.Helper;
using PMS.Resources.Core;
using PMS.Resources.DTO.Request;
using PMS.Resources.DTO.Response;
using PMS.Resources.Entities;
using PMS.Resources.Logging.CustomException;
using PMS.Resources.Logic;
using System;
using System.Collections.Generic;
using System.ComponentModel.Composition;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace PMS.Api.Controllers
{
    [Export(typeof(IRestController))]
    [PartCreationPolicy(CreationPolicy.NonShared)]
    public partial class PaymentController : ApiController, IRestController
    {
        private readonly IPmsLogic _iPmsLogic = null;
        public PaymentController()
            : this(ServiceLocator.Current.GetInstance<IPmsLogic>())
        {
            
        }

        public PaymentController(IPmsLogic iPmsLogic)
        {
            _iPmsLogic = iPmsLogic;
        }

        /// <summary>
        /// Map Routes for REST
        /// </summary>
        /// <param name="config"></param>
        [System.Web.Http.NonAction]
        public void MapHttpRoutes(HttpConfiguration config)
        {
            MapHttpRoutesForPayment(config);
        }

        private void MapHttpRoutesForPayment(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
             "GetPayment",
             "api/v1/Payment/GetPayment",
             new { controller = "Payment", action = "GetPayment" }
             );
        }

        [HttpPost, ActionName("GetPayment")]
        public GetPaymentResponseDto GetPayment([FromBody] GetPaymentRequestDto request )
        {
            if (request.Payment == null || request.Payment.PropertyId <=0
                || request.Payment.RateTypeId <= 0 || request.Payment.RoomTypeId <= 0 
                ) throw new PmsException("Get Payment call failed.");
            
            var response = new GetPaymentResponseDto();
            response.Tax = _iPmsLogic.GetPayment(request.Payment);
            return response;
        }   
    }
}
