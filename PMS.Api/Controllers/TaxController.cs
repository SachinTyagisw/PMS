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
    public class TaxController : ApiController, IRestController
    {
        private readonly IPmsLogic _iPmsLogic = null;
        public TaxController()
            : this(ServiceLocator.Current.GetInstance<IPmsLogic>())
        {

        }

        public TaxController(IPmsLogic iPmsLogic)
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
            MapHttpRoutesForTax(config);
        }
         
        private void MapHttpRoutesForTax(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
             "AddTax",
             "api/v1/Tax/AddTax",
             new { controller = "Tax", action = "AddTax" }
             );

            config.Routes.MapHttpRoute(
             "UpdateTax",
             "api/v1/Tax/UpdateTax",
             new { controller = "Tax", action = "UpdateTax" }
             );

            config.Routes.MapHttpRoute(
             "DeleteTax",
             "api/v1/Tax/DeleteTax/{taxId}",
             new { controller = "Tax", action = "DeleteTax" },
             constraints: new { taxId = RegExConstants.NumericRegEx }
             );

            config.Routes.MapHttpRoute(
              "GetTaxByProperty",
              "api/v1/Tax/GetTaxByProperty/{propertyId}",
              new { controller = "Tax", action = "GetTaxByProperty" },
              constraints: new { propertyId = RegExConstants.NumericRegEx }
              );
        }


        [HttpPost, ActionName("AddTax")]
        public PmsResponseDto AddTax([FromBody] TaxRequestDto request)
        {
            if (request == null || request.Tax == null)
                throw new PmsException("Tax can not be added.");

            var response = new PmsResponseDto();
            var Id = _iPmsLogic.AddTax(request.Tax);
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

        [HttpPut, ActionName("UpdateTax")]
        public PmsResponseDto UpdateTax([FromBody] TaxRequestDto request)
        {
            if (request == null || request.Tax == null || request.Tax.Id <= 0)
                throw new PmsException("Tax can not be updated.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.UpdateTax(request.Tax))
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

        [HttpDelete, ActionName("DeleteTax")]
        public PmsResponseDto DeleteTax(int taxId)
        {
            if (taxId <= 0) throw new PmsException("Tax id is not valid. Hence Tax can not be deleted.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.DeleteTax(taxId))
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


        [HttpGet, ActionName("GetTaxByProperty")]
        public GetTaxResponseDto GetTaxByProperty(int propertyId)
        {
            if (propertyId <= 0) throw new PmsException("Property id is not valid.");

            var response = new GetTaxResponseDto();
            response.Taxes = _iPmsLogic.GetTaxByProperty(propertyId);
            return response;
        }
    }
}