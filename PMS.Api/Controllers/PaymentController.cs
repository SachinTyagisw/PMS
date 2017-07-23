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
             "api/v1/Payment/DeletePaymentType/{paymentTypeId}",
             new { controller = "Payment", action = "DeletePaymentType" },
             constraints: new { paymentTypeId = RegExConstants.NumericRegEx }
             );

            config.Routes.MapHttpRoute(
              "GetPaymentTypeByProperty",
              "api/v1/Payment/GetPaymentTypeByProperty/{propertyId}",
              new { controller = "Payment", action = "GetPaymentTypeByProperty" },
              constraints: new { propertyId = RegExConstants.NumericRegEx }
              );
        }


        [HttpPost, ActionName("AddPaymentType")]
        public PmsResponseDto AddPaymentType([FromBody] PaymentTypeRequestDto request)
        {
            if (request == null || request.PaymentType == null)
                throw new PmsException("Payment Type can not be added.");

            var response = new PmsResponseDto();
            var Id = _iPmsLogic.AddPaymentType(request.PaymentType);
            if (Id > 0)
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Record(s) saved successfully.";
                response.ResponseObject = Id;
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Operation failed.Please contact administrator.";
            }
            return response;
        }

        [HttpPut, ActionName("UpdatePaymentType")]
        public PmsResponseDto UpdatePaymentType([FromBody] PaymentTypeRequestDto request)
        {
            if (request == null || request.PaymentType == null || request.PaymentType.Id <= 0)
                throw new PmsException("Payment Type can not be updated.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.UpdatePaymentType(request.PaymentType))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Record(s) saved successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Operation failed.Please contact administrator.";
            }
            return response;
        }

        [HttpDelete, ActionName("DeletePaymentType")]
        public PmsResponseDto DeletePaymentType(int paymentTypeId)
        {
            if (paymentTypeId <= 0) throw new PmsException("Payment Type is not valid. Hence Payment Type can not be deleted.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.DeletePaymentType(paymentTypeId))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Record deleted successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Operation failed.Please contact administrator.";
            }
            return response;
        }


        [HttpGet, ActionName("GetPaymentTypeByProperty")]
        public GetPaymentTypeResponseDto GetPaymentTypeByProperty(int propertyId)
        {
            if (propertyId <= 0) throw new PmsException("Property id is not valid.");

            var response = new GetPaymentTypeResponseDto();
            response.PaymentTypes = _iPmsLogic.GetPaymentTypeByProperty(propertyId);

            return response;
        }

    }
}
