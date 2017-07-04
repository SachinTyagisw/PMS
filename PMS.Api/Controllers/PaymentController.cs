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
             "AddPaymentType",
             "api/v1/Payment/AddPaymentType",
             new { controller = "Payment", action = "AddPaymentType" }
             );

            config.Routes.MapHttpRoute(
             "UpdatePaymentType",
             "api/v1/Payment/UpdatePaymentType",
             new { controller = "Payment", action = "UpdatePaymentType" }
             );

            config.Routes.MapHttpRoute(
             "DeletePaymentType",
             "api/v1/Payment/DeletePaymentType/{typeId}",
             new { controller = "Payment", action = "DeletePaymentType" },
             constraints: new { typeId = RegExConstants.NumericRegEx }
             );

            config.Routes.MapHttpRoute(
              "GetPaymentType",
              "api/v1/Payment/GetPaymentType",
              new { controller = "Payment", action = "GetPaymentType" }
              );
        }

        [HttpPost, ActionName("AddPaymentType")]
        public PmsResponseDto AddPaymentType([FromBody] AddPaymentTypeRequestDto request)
        {
            throw new NotImplementedException();
        }
    }
}
