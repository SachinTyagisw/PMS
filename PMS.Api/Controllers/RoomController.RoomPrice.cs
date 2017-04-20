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
        private void MapHttpRoutesForRoomPricing(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
            "AddRoomPrice",
            "api/v1/Room/AddRoomPrice",
            new { controller = "Room", action = "AddRoomPrice" }
            );

            config.Routes.MapHttpRoute(
            "UpdateRoomPrice",
            "api/v1/Room/UpdateRoomPrice",
            new { controller = "Room", action = "UpdateRoomPrice" }
            );

            config.Routes.MapHttpRoute(
             "DeleteRoomPrice",
             "api/v1/Room/DeleteRoomPrice/{priceId}",
             new { controller = "Room", action = "DeleteRoomPrice" },
             constraints: new { priceId = RegExConstants.NumericRegEx }
             );

            config.Routes.MapHttpRoute(
              "GetRoomPriceByProperty",
              "api/v1/Room/GetRoomPriceByProperty/{propertyId}",
              new { controller = "Room", action = "GetRoomPriceByProperty" },
              constraints: new { propertyId = RegExConstants.NumericRegEx }
              );

            config.Routes.MapHttpRoute(
              "GetRoomPriceByRoomType",
              "api/v1/Room/GetRoomPriceByRoomType/{roomTypeId}",
              new { controller = "Room", action = "GetRoomPriceByRoomType" },
              constraints: new { roomTypeId = RegExConstants.NumericRegEx }
              );

            config.Routes.MapHttpRoute(
              "GetRoomPriceByRateType",
              "api/v1/Room/GetRoomPriceByRateType/{rateTypeId}",
              new { controller = "Room", action = "GetRoomPriceByRateType" },
              constraints: new { rateTypeId = RegExConstants.NumericRegEx }
              );
        }

        [HttpPost, ActionName("AddRoomPrice")]
        public PmsResponseDto AddRoomPrice([FromBody] AddRoomPriceRequestDto request)
        {
            if (request == null || request.RoomPricing == null) throw new PmsException("Room price can not be added.");

            var response = new PmsResponseDto();
            return response;
        }

        [HttpPut, ActionName("UpdateRoomPrice")]
        public PmsResponseDto UpdateRoomPrice([FromBody] UpdateRoomPriceRequestDto request)
        {
            if (request == null || request.RoomPricing == null || request.RoomPricing.Id <= 0) throw new PmsException("Room price can not be updated.");

            var response = new PmsResponseDto();
            return response;
        }

        [HttpDelete, ActionName("DeleteRoomPrice")]
        public PmsResponseDto DeleteRoomPrice(int priceId)
        {
            if (priceId <= 0) throw new PmsException("Room price id is not valid. Hence Room price can not be deleted.");

            var response = new PmsResponseDto();
            return response;
        }

        [HttpGet, ActionName("GetRoomPriceByProperty")]
        public GetRateTypeResponseDto GetRoomPriceByProperty(int propertyId)
        {
            if (propertyId <= 0) throw new PmsException("Property id is not valid.");

            var response = new GetRateTypeResponseDto();
            return response;
        }

        [HttpGet, ActionName("GetRoomPriceByRoomType")]
        public GetRateTypeResponseDto GetRoomPriceByRoomType(int roomTypeId)
        {
            var response = new GetRateTypeResponseDto();
            if (roomTypeId <= 0)
            {
                return response;
            }
            return response;
        }

        [HttpGet, ActionName("GetRoomPriceByRateType")]
        public GetRateTypeResponseDto GetRoomPriceByRateType(int rateTypeId)
        {
            var response = new GetRateTypeResponseDto();
            if (rateTypeId <= 0)
            {
                return response;
            }
            return response;
        }   
	}
}