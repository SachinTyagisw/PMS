﻿using PMS.Resources.Common.Constants;
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
             "api/v1/Tax/DeleteTax/{TaxId}",
             new { controller = "Tax", action = "DeleteTax" },
             constraints: new { TaxId = RegExConstants.NumericRegEx }
             );

            config.Routes.MapHttpRoute(
              "GetTaxsByProperty",
              "api/v1/Tax/GetTaxesByProperty/{propertyId}",
              new { controller = "Tax", action = "GetTaxesByProperty" },
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
                response.StatusDescription = "New Tax Added successfully.";
                response.ResponseObject = Id;
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "New Tax Addition failed.Contact administrator.";
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
                response.StatusDescription = "Tax Updated successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Tax Updation failed.Contact administrator.";
            }
            return response;
        }

        [HttpDelete, ActionName("DeleteTax")]
        public PmsResponseDto DeleteTax(int TaxId)
        {
            if (TaxId <= 0) throw new PmsException("Tax is not valid. Hence Tax can not be deleted.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.DeleteTax(TaxId))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Tax Deleted successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Tax Deletion failed.Contact administrator.";
            }
            return response;
        }


        [HttpGet, ActionName("GetTaxesByProperty")]
        public GetTaxesResponseDto GetTaxesByProperty(int propertyId)
        {
            if (propertyId <= 0) throw new PmsException("Property id is not valid.");

            var response = new GetTaxesResponseDto();
            response.Taxes = _iPmsLogic.GetTaxesByProperty(propertyId);
            return response;
        }
    }
}