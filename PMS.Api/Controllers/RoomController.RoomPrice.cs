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
              "api/v1/Room/{propertyId}/GetRoomPriceByRoomType/{roomTypeId}",
              new { controller = "Room", action = "GetRoomPriceByRoomType" },
              constraints: new { propertyId = RegExConstants.NumericRegEx, roomTypeId = RegExConstants.NumericRegEx }
              );

            config.Routes.MapHttpRoute(
              "GetRoomPriceByRateType",
              "api/v1/Room/{propertyId}/GetRoomPriceByRateType/{rateTypeId}",
              new { controller = "Room", action = "GetRoomPriceByRateType" },
              constraints: new { propertyId = RegExConstants.NumericRegEx, rateTypeId = RegExConstants.NumericRegEx }
              );
        }

        [HttpPost, ActionName("AddRoomPrice")]
        public PmsResponseDto AddRoomPrice([FromBody] AddRoomPriceRequestDto request)
        {
            if (request == null || request.RoomPricing == null) throw new PmsException("Room price can not be added.");

            var response = new PmsResponseDto();
            var Id = _iPmsLogic.AddRoomPrice(request.RoomPricing);
            if (Id > 0)
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "New Room Price Added successfully.";
                response.ResponseObject = Id;
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "New Room Price Addition failed.Contact administrator.";
            }
            return response;
        }

        [HttpPut, ActionName("UpdateRoomPrice")]
        public PmsResponseDto UpdateRoomPrice([FromBody] UpdateRoomPriceRequestDto request)
        {
            if (request == null || request.RoomPricing == null || request.RoomPricing.Id <= 0) throw new PmsException("Room price can not be updated.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.UpdateRoomPrice(request.RoomPricing))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Room Price Updated successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Room Price Updation failed.Contact administrator.";
            }
            return response;
        }

        [HttpDelete, ActionName("DeleteRoomPrice")]
        public PmsResponseDto DeleteRoomPrice(int priceId)
        {
            if (priceId <= 0) throw new PmsException("Room price id is not valid. Hence Room price can not be deleted.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.DeleteRoomPrice(priceId))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Room Price Deleted successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Room Price Deletion failed.Contact administrator.";
            }
            return response;
        }

        [HttpGet, ActionName("GetRoomPriceByProperty")]
        public GetRoomPriceResponseDto GetRoomPriceByProperty(int propertyId)
        {
            if (propertyId <= 0) throw new PmsException("Property id is not valid.");

            var response = new GetRoomPriceResponseDto();
            if (!AppConfigReaderHelper.AppConfigToBool(AppSettingKeys.MockEnabled))
            {
                response.RoomPricing = _iPmsLogic.GetRoomPriceByProperty(propertyId);
            }
            else
            {
                //mock data
            }
            return response;
        }

        [HttpGet, ActionName("GetRoomPriceByRoomType")]
        public GetRoomPriceResponseDto GetRoomPriceByRoomType(int propertyId, int roomTypeId)
        {
            if (propertyId <= 0) throw new PmsException("Property id is not valid.");

            var response = new GetRoomPriceResponseDto();
            if (roomTypeId <= 0)
            {
                return response;
            }
            var roomPricingResponseDto = GetRoomPriceByProperty(propertyId);
            if (roomPricingResponseDto == null || roomPricingResponseDto.RoomPricing == null || roomPricingResponseDto.RoomPricing.Count <= 0) return response;

            response.RoomPricing = roomPricingResponseDto.RoomPricing.Where(x => x.RoomType.Id.Equals(roomTypeId)).ToList();
            return response;
        }

        [HttpGet, ActionName("GetRoomPriceByRateType")]
        public GetRoomPriceResponseDto GetRoomPriceByRateType(int propertyId, int rateTypeId)
        {
            if (propertyId <= 0) throw new PmsException("Property id is not valid.");

            var response = new GetRoomPriceResponseDto();
            if (rateTypeId <= 0)
            {
                return response;
            }
            var roomPricingResponseDto = GetRoomPriceByProperty(propertyId);
            if (roomPricingResponseDto == null || roomPricingResponseDto.RoomPricing == null || roomPricingResponseDto.RoomPricing.Count <= 0) return response;

            response.RoomPricing = roomPricingResponseDto.RoomPricing.Where(x => x.RateType.Id.Equals(rateTypeId)).ToList();
            return response;
        }   
	}
}