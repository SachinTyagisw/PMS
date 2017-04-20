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
    public partial class PropertyController : ApiController, IRestController
    {
        private void MapHttpRoutesForPropertyType(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
            "AddPropertyType",
            "api/v1/Property/AddPropertyType",
            new { controller = "Property", action = "AddPropertyType" }
            );

            config.Routes.MapHttpRoute(
             "UpdatePropertyType",
             "api/v1/Property/UpdatePropertyType",
             new { controller = "Property", action = "UpdatePropertyType" }
             );

            config.Routes.MapHttpRoute(
             "DeletePropertyType",
             "api/v1/Property/DeletePropertyType/{typeId}",
             new { controller = "Property", action = "DeletePropertyType" },
             constraints: new { typeId = RegExConstants.NumericRegEx }
             );

            config.Routes.MapHttpRoute(
              "GetAllPropertyType",
              "api/v1/Property/GetAllPropertyType",
              new { controller = "Property", action = "GetAllPropertyType" }
              );

            config.Routes.MapHttpRoute(
              "GetPropertyTypeById",
              "api/v1/Property/GetPropertyTypeById/{typeId}",
              new { controller = "Property", action = "GetPropertyTypeById" },
              constraints: new { typeId = RegExConstants.NumericRegEx }
              );          
        }

        [HttpPost, ActionName("AddPropertyType")]
        public PmsResponseDto AddPropertyType([FromBody] AddPropertyTypeRequestDto request)
        {
            if (request == null || request.PropertyType == null) throw new PmsException("Property type can not be added.");

            var response = new PmsResponseDto();
            return response;
        }

        [HttpPut, ActionName("UpdatePropertyType")]
        public PmsResponseDto UpdatePropertyType([FromBody] UpdatePropertyTypeRequestDto request)
        {
            if (request == null || request.PropertyType == null || request.PropertyType.Id <= 0) throw new PmsException("Property type can not be updated.");

            var response = new PmsResponseDto();
            return response;
        }

        [HttpDelete, ActionName("DeletePropertyType")]
        public PmsResponseDto DeletePropertyType(int typeId)
        {
            if (typeId <= 0) throw new PmsException("PropertyType id is not valid. Hence PropertyType can not be deleted.");

            var response = new PmsResponseDto();
            return response;
        }

        [HttpGet, ActionName("GetPropertyTypeById")]
        public GetPropertyTypeResponseDto GetPropertyTypeById(int typeId)
        {
            var response = new GetPropertyTypeResponseDto();
            if (typeId <= 0)
            {
                return response;
            }
            return response;
        }

        [HttpGet, ActionName("GetAllPropertyType")]
        public GetPropertyTypeResponseDto GetAllPropertyType()
        {
            var response = new GetPropertyTypeResponseDto();
            return response;
        }
    }
}