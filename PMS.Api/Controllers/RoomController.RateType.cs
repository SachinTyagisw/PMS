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
        private void MapHttpRoutesForRateType(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
            "AddRateType",
            "api/v1/Room/AddRateType",
            new { controller = "Room", action = "AddRateType" }
            );

            config.Routes.MapHttpRoute(
             "UpdateRateType",
             "api/v1/Room/UpdateRateType",
             new { controller = "Room", action = "UpdateRateType" }
             );

            config.Routes.MapHttpRoute(
             "DeleteRateType",
             "api/v1/Room/DeleteRateType/{typeId}",
             new { controller = "Room", action = "DeleteRateType" },
             constraints: new { typeId = RegExConstants.NumericRegEx }
             );

            config.Routes.MapHttpRoute(
              "GetRateType",
              "api/v1/Room/GetRateType",
              new { controller = "Room", action = "GetRateType" }
              );

            config.Routes.MapHttpRoute(
              "GetRateTypeById",
              "api/v1/Room/GetRateTypeById/{typeId}",
              new { controller = "Room", action = "GetRateTypeById" },
              constraints: new { typeId = RegExConstants.NumericRegEx }
              );

            config.Routes.MapHttpRoute(
             "GetRateTypeByRoomType",
             "api/v1/Room/GetRateTypeByRoomType/{roomTypeId}",
             new { controller = "Room", action = "GetRateTypeByRoomType" },
             constraints: new { roomTypeId = RegExConstants.NumericRegEx }
             );
        }

        [HttpPost, ActionName("AddRateType")]
        public PmsResponseDto AddRateType([FromBody] AddRateTypeRequestDto request)
        {
            if (request == null || request.RateType == null) throw new PmsException("Rate type can not be added.");

            var response = new PmsResponseDto();
            return response;
        }

        [HttpPut, ActionName("UpdateRateType")]
        public PmsResponseDto UpdateRateType([FromBody] UpdateRateTypeRequestDto request)
        {
            if (request == null || request.RateType == null || request.RateType.Id <= 0) throw new PmsException("Rate type can not be updated.");

            var response = new PmsResponseDto();
            return response;
        }

        [HttpDelete, ActionName("DeleteRateType")]
        public PmsResponseDto DeleteRateType(int typeId)
        {
            if (typeId <= 0) throw new PmsException("RateType id is not valid. Hence RateType can not be deleted.");

            var response = new PmsResponseDto();
            return response;
        }

        [HttpGet, ActionName("GetRateType")]
        public GetRateTypeResponseDto GetRateType()
        {
            var response = new GetRateTypeResponseDto();
            return response;
        }

        [HttpGet, ActionName("GetRateTypeById")]
        public GetRateTypeResponseDto GetRateTypeById(int typeId)
        {
            var response = new GetRateTypeResponseDto();
            if (typeId <= 0)
            {
                return response;
            }
            return response;
        }

        [HttpGet, ActionName("GetRateTypeByRoomType")]
        public GetRateTypeResponseDto GetRateTypeByRoomType(int roomTypeId)
        {
            var response = new GetRateTypeResponseDto();
            if (roomTypeId <= 0)
            {
                return response;
            }
            return response;
        }    
    }
}