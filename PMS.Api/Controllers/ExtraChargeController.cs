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
    public partial class ExtraChargeController : ApiController, IRestController
    {
        private readonly IPmsLogic _iPmsLogic = null;
        public ExtraChargeController()
            : this(ServiceLocator.Current.GetInstance<IPmsLogic>())
        {

        }

        public ExtraChargeController(IPmsLogic iPmsLogic)
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
            MapHttpRoutesForExtraCharge(config);
        }

        private void MapHttpRoutesForExtraCharge(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
             "AddExtraCharge",
             "api/v1/Payment/AddExtraCharge",
             new { controller = "ExtraCharge", action = "AddExtraCharge" }
             );

            config.Routes.MapHttpRoute(
             "UpdateExtraCharge",
             "api/v1/ExtraCharge/UpdateExtraCharge",
             new { controller = "ExtraCharge", action = "UpdateExtraCharge" }
             );

            config.Routes.MapHttpRoute(
             "DeleteExtraCharge",
             "api/v1/ExtraCharge/DeleteExtraCharge/{Id}",
             new { controller = "Payment", action = "DeleteExtraCharge" },
             constraints: new { typeId = RegExConstants.NumericRegEx }
             );

            config.Routes.MapHttpRoute(
              "GetExtraChargesByProperty",
              "api/v1/ExtraCharge/GetExtraChargesByProperty",
              new { controller = "ExtraCharge", action = "GetExtraChargesByProperty" }
              );
        }


        [HttpPost, ActionName("AddExtraCharge")]
        public PmsResponseDto AddExtraCharge([FromBody] ExtraChargeRequestDto request)
        {
            if (request == null || request.ExtraCharge == null)
                throw new PmsException("Extra Charge can not be added.");

            var response = new PmsResponseDto();
            var Id = _iPmsLogic.AddExtraCharge(request.ExtraCharge);
            if (Id > 0)
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "New Extra Charge Added successfully.";
                response.ResponseObject = Id;
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "New Extra charge failed.Contact administrator.";
            }
            return response;
        }

        [HttpPut, ActionName("UpdateExtraCharge")]
        public PmsResponseDto UpdateExtraCharge([FromBody] ExtraChargeRequestDto request)
        {
            if (request == null || request.ExtraCharge == null)
                throw new PmsException("ExtraCharge can not be updated.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.UpdateExtraCharge(request.ExtraCharge))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "ExtraCharge Updated successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "ExtraCharge Updation failed.Contact administrator.";
            }
            return response;
        }

        [HttpDelete, ActionName("DeleteExtraCharge")]
        public PmsResponseDto DeleteExtraCharge(int extraChargeId)
        {
            if (extraChargeId <= 0) throw new PmsException("ExtraCharge is not valid. Hence ExtraCharge can not be deleted.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.DeleteExtraCharge(extraChargeId))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "ExtraCharge Deleted successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Payment Type Deletion failed.Contact administrator.";
            }
            return response;
        }


        [HttpGet, ActionName("GetExtraChargesByProperty")]
        public GetExtraChargeResponseDto GetExtraChargesByProperty(int propertyId)
        {
            if (propertyId <= 0) throw new PmsException("Property id is not valid.");

            var response = new GetExtraChargeResponseDto();
            response.ExtraCharges = _iPmsLogic.GetExtraCharges(propertyId);

            return response;
        }

    }
}


