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
	public partial class RoomController : ApiController, IRestController
	{
        private void MapHttpRoutesForRoomType(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
            "AddRoomType",
            "api/v1/Room/AddRoomType",
            new { controller = "Room", action = "AddRoomType" }
            );

            config.Routes.MapHttpRoute(
             "UpdateRoomType",
             "api/v1/Room/UpdateRoomType",
             new { controller = "Room", action = "UpdateRoomType" }
             );

            config.Routes.MapHttpRoute(
             "DeleteRoomType",
             "api/v1/Room/DeleteRoomType/{typeId}",
             new { controller = "Room", action = "DeleteRoomType" },
             constraints: new { typeId = RegExConstants.NumericRegEx }
             );

            config.Routes.MapHttpRoute(
              "GetRoomTypeByProperty",
              "api/v1/Room/GetRoomTypeByProperty/{propertyId}",
              new { controller = "Room", action = "GetRoomTypeByProperty" },
              constraints: new { propertyId = RegExConstants.NumericRegEx }
              );

            config.Routes.MapHttpRoute(
              "GetRoomTypeById",
              "api/v1/Room/GetRoomTypeById/{typeId}",
              new { controller = "Room", action = "GetRoomTypeById" },
              constraints: new { typeId = RegExConstants.NumericRegEx }
              );
        }

        [HttpPost, ActionName("AddRoomType")]
        public PmsResponseDto AddRoomType([FromBody] AddRoomTypeRequestDto request)
        {
            if (request == null || request.RoomType == null) throw new PmsException("Room type can not be added.");

            var response = new PmsResponseDto();
            return response;
        }

        [HttpPut, ActionName("UpdateRoomType")]
        public PmsResponseDto UpdateRoomType([FromBody] UpdateRoomTypeRequestDto request)
        {
            if (request == null || request.RoomType == null || request.RoomType.Id <= 0) throw new PmsException("Room type can not be updated.");

            var response = new PmsResponseDto();
            return response;
        }

        [HttpDelete, ActionName("DeleteRoomType")]
        public PmsResponseDto DeleteRoomType(int typeId)
        {
            if (typeId <= 0) throw new PmsException("RoomType id is not valid. Hence Roomtype can not be deleted.");

            var response = new PmsResponseDto();
            return response;
        }

        [HttpGet, ActionName("GetRoomTypeByProperty")]
        public GetRoomTypeResponseDto GetRoomTypeByProperty(int propertyId)
        {
            if (propertyId <= 0) throw new PmsException("Property id is not valid.");

            var response = new GetRoomTypeResponseDto();
            return response;
        }

        [HttpGet, ActionName("GetRoomTypeById")]
        public GetRoomTypeResponseDto GetRoomTypeById(int typeId)
        {
            var response = new GetRoomTypeResponseDto();
            if (typeId <= 0)
            {
                return response;
            }
            return response;
        }       
	}
}