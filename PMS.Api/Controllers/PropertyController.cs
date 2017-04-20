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
    public partial class PropertyController : ApiController, IRestController
    {
       private readonly IPmsLogic _iPMSLogic = null;

        public PropertyController()
            : this(ServiceLocator.Current.GetInstance<IPmsLogic>())
        {
            
        }

        public PropertyController(IPmsLogic iPMSLogic)
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
            return response;
        }

        [HttpPut, ActionName("UpdateProperty")]
        public PmsResponseDto UpdateProperty([FromBody] UpdatePropertyRequestDto request)
        {
            if (request == null || request.Property == null || request.Property.Id <= 0) throw new PmsException("Property can not be updated.");

            var response = new PmsResponseDto();
            return response;
        }

        [HttpDelete, ActionName("DeleteProperty")]
        public PmsResponseDto DeleteProperty(int propertyId)
        {
            if (propertyId <= 0) throw new PmsException("Propertyid is not valid. Hence Property can not be deleted.");

            var response = new PmsResponseDto();
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
            return response;
        }

        [HttpGet, ActionName("GetAllProperty")]
        public GetPropertyResponseDto GetAllProperty()
        {
            var response = new GetPropertyResponseDto();
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
            return response;
        }
    }
}
