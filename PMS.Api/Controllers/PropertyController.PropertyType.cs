using PMS.Resources.Common.Constants;
using PMS.Resources.Common.Helper;
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
            if (_iPMSLogic.AddPropertyType(request.PropertyType))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "New Property Type Added successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "New Property Type Addition failed.Contact administrator.";
            }
            return response;
        }

        [HttpPut, ActionName("UpdatePropertyType")]
        public PmsResponseDto UpdatePropertyType([FromBody] UpdatePropertyTypeRequestDto request)
        {
            if (request == null || request.PropertyType == null || request.PropertyType.Id <= 0) throw new PmsException("Property type can not be updated.");

            var response = new PmsResponseDto();
            if (_iPMSLogic.UpdatePropertyType(request.PropertyType))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Property Type Updated successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Property Type Updation failed.Contact administrator.";
            }
            return response;
        }

        [HttpDelete, ActionName("DeletePropertyType")]
        public PmsResponseDto DeletePropertyType(int typeId)
        {
            if (typeId <= 0) throw new PmsException("PropertyType id is not valid. Hence PropertyType can not be deleted.");

            var response = new PmsResponseDto();
            if (_iPMSLogic.DeletePropertyType(typeId))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Property Type Deleted successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Property Type Deletion failed.Contact administrator.";
            }
            return response;
        }

        [HttpGet, ActionName("GetAllPropertyType")]
        public GetPropertyTypeResponseDto GetAllPropertyType()
        {
            var response = new GetPropertyTypeResponseDto();
            if (!AppConfigReaderHelper.AppConfigToBool(AppSettingKeys.MockEnabled))
            {
                response.PropertyTypes = _iPMSLogic.GetAllPropertyType();
            }
            else
            {
                //mock data
            }
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
            var propertyTypeResponseDto = GetAllPropertyType();
            if (propertyTypeResponseDto == null || propertyTypeResponseDto.PropertyTypes == null || propertyTypeResponseDto.PropertyTypes.Count <= 0) return response;

            response.PropertyTypes = propertyTypeResponseDto.PropertyTypes.Where(x => x.Id.Equals(typeId)).ToList();
            return response;
        }
    }
}