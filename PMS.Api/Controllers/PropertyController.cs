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
    [Export(typeof(IRestController))]
    [PartCreationPolicy(CreationPolicy.NonShared)]
    public partial class PropertyController : ApiController, IRestController
    {
       private readonly IPmsLogic _iPmsLogic = null;

        public PropertyController()
            : this(ServiceLocator.Current.GetInstance<IPmsLogic>())
        {
            
        }

        public PropertyController(IPmsLogic iPmsLogic)
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
            MapHttpRoutesForProperty(config);
            MapHttpRoutesForPropertyType(config);
        }

        private void MapHttpRoutesForProperty(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
             "AddProperty",
             "api/v1/Property/AddProperty",
             new { controller = "Property", action = "AddProperty" }
             );

            config.Routes.MapHttpRoute(
             "UpdateProperty",
             "api/v1/Property/UpdateProperty",
             new { controller = "Property", action = "UpdateProperty" }
             );

            config.Routes.MapHttpRoute(
             "DeleteProperty",
             "api/v1/Property/DeleteProperty/{propertyId}",
             new { controller = "Property", action = "DeleteProperty" },
             constraints: new { propertyId = RegExConstants.NumericRegEx }
             );

            config.Routes.MapHttpRoute(
             "GetPropertyById",
             "api/v1/Property/GetPropertyById/{propertyId}",
             new { controller = "Property", action = "GetPropertyById" },
             constraints: new { propertyId = RegExConstants.NumericRegEx }
             );

            config.Routes.MapHttpRoute(
              "GetAllProperty",
              "api/v1/Property/GetAllProperty",
              new { controller = "Property", action = "GetAllProperty" }
              );

            config.Routes.MapHttpRoute(
             "GetPropertyByUserId",
             "api/v1/Property/GetPropertyByUserId/{userId}",
             new { controller = "Property", action = "GetPropertyByUserId" },
             constraints: new { userId = RegExConstants.NumericRegEx }
             );
        }

        [HttpPost, ActionName("AddProperty")]
        public PmsResponseDto AddProperty([FromBody] AddPropertyRequestDto request)
        {
            if (request == null || request.Property == null) throw new PmsException("Property can not be added.");

            var response = new PmsResponseDto();
            var Id = _iPmsLogic.AddProperty(request.Property);
            if (Id > 0)
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "New Property Added successfully.";
                response.ResponseObject = Id;
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "New Property Addition failed.Contact administrator.";
            }
            return response;
        }

        [HttpPut, ActionName("UpdateProperty")]
        public PmsResponseDto UpdateProperty([FromBody] UpdatePropertyRequestDto request)
        {
            if (request == null || request.Property == null || request.Property.Id <= 0) throw new PmsException("Property can not be updated.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.UpdateProperty(request.Property))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Property Updated successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Property Updation failed.Contact administrator.";
            }
            return response;
        }

        [HttpDelete, ActionName("DeleteProperty")]
        public PmsResponseDto DeleteProperty(int propertyId)
        {
            if (propertyId <= 0) throw new PmsException("PropertyId is not valid. Hence Property can not be deleted.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.DeleteProperty(propertyId))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Property Deleted successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Property Deletion failed.Contact administrator.";
            }
            return response;
        }

        [HttpGet, ActionName("GetAllProperty")]
        public GetPropertyResponseDto GetAllProperty()
        {
            var response = new GetPropertyResponseDto();
            if (!AppConfigReaderHelper.AppConfigToBool(AppSettingKeys.MockEnabled))
            {
                response.Properties = _iPmsLogic.GetAllProperty();
            }
            else
            {
                //mock data
            }
            return response;
        }

        [HttpGet, ActionName("GetPropertyById")]
        public GetPropertyResponseDto GetPropertyById(int propertyId)
        {
            var response = new GetPropertyResponseDto();
            if (propertyId <= 0)
            {
                return response;
            }
            var propertyResponseDto = GetAllProperty();
            if (propertyResponseDto == null || propertyResponseDto.Properties == null || propertyResponseDto.Properties.Count <= 0) return response;

            response.Properties = propertyResponseDto.Properties.Where(x => x.Id.Equals(propertyId)).ToList();
            return response;
        }
       
        [HttpGet, ActionName("GetPropertyByUserId")]
        public GetPropertyResponseDto GetPropertyByUserId(int userId)
        {
            var response = new GetPropertyResponseDto();
            if (userId <= 0)
            {
                return response;
            }

            var propertyResponseDto = GetAllProperty();
            if (propertyResponseDto == null || propertyResponseDto.Properties == null || propertyResponseDto.Properties.Count <= 0) return response;

            response.Properties = propertyResponseDto.Properties.Where(x => x.UserId.Equals(userId)).ToList();
            return response;
        }
    }
}
