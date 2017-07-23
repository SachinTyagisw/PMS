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
    public partial class PropertyFloorController : ApiController, IRestController
    {
        private readonly IPmsLogic _iPmsLogic = null;
        public PropertyFloorController()
            : this(ServiceLocator.Current.GetInstance<IPmsLogic>())
        {

        }

        public PropertyFloorController(IPmsLogic iPmsLogic)
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
            MapHttpRoutesForFloor(config);
        }
         
        private void MapHttpRoutesForFloor(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
             "AddFloor",
             "api/v1/PropertyFloor/AddFloor",
             new { controller = "PropertyFloor", action = "AddFloor" }
             );

            config.Routes.MapHttpRoute(
             "UpdateFloor",
             "api/v1/PropertyFloor/UpdateFloor",
             new { controller = "PropertyFloor", action = "UpdateFloor" }
             );

            config.Routes.MapHttpRoute(
             "DeleteFloor",
             "api/v1/PropertyFloor/DeleteFloor/{propertyFloorId}",
             new { controller = "PropertyFloor", action = "DeleteFloor" },
             constraints: new { propertyFloorId = RegExConstants.NumericRegEx }
             );

            config.Routes.MapHttpRoute(
              "GetFloorsByProperty",
              "api/v1/PropertyFloor/GetFloorsByProperty/{propertyId}",
              new { controller = "PropertyFloor", action = "GetFloorsByProperty" },
              constraints: new { propertyId = RegExConstants.NumericRegEx }
              );
        }


        [HttpPost, ActionName("AddFloor")]
        public PmsResponseDto AddFloor([FromBody] PropertyFloorRequestDto request)
        {
            if (request == null || request.PropertyFloor == null)
                throw new PmsException("Floor can not be added.");

            var response = new PmsResponseDto();
            var Id = _iPmsLogic.AddFloor(request.PropertyFloor);
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

        [HttpPut, ActionName("UpdateFloor")]
        public PmsResponseDto UpdateFloor([FromBody] PropertyFloorRequestDto request)
        {
            if (request == null || request.PropertyFloor == null || request.PropertyFloor.Id <= 0)
                throw new PmsException("Floor can not be updated.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.UpdateFloor(request.PropertyFloor))
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

        [HttpDelete, ActionName("DeleteFloor")]
        public PmsResponseDto DeleteFloor(int propertyFloorId)
        {
            if (propertyFloorId <= 0) throw new PmsException("Floor is not valid. Hence Floor can not be deleted.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.DeleteFloor(propertyFloorId))
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


        [HttpGet, ActionName("GetFloorsByProperty")]
        public GetPropertyFloorResponseDto GetFloorsByProperty(int propertyId)
        {
            if (propertyId <= 0) throw new PmsException("Property id is not valid.");

            var response = new GetPropertyFloorResponseDto();
            response.PropertyFloors = _iPmsLogic.GetFloorsByProperty(propertyId);
            return response;
        }

    }
}
