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
              "api/v1/Room/{propertyId}/GetRoomTypeById/{typeId}",
              new { controller = "Room", action = "GetRoomTypeById" },
              constraints: new { propertyId = RegExConstants.NumericRegEx, typeId = RegExConstants.NumericRegEx }
              );
        }

        [HttpPost, ActionName("AddRoomType")]
        public PmsResponseDto AddRoomType([FromBody] AddRoomTypeRequestDto request)
        {
            if (request == null || request.RoomType == null) throw new PmsException("Room type can not be added.");

            var response = new PmsResponseDto();
            if (_iPMSLogic.AddRoomType(request.RoomType))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "New Room Type Added successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "New Room Type Addition failed.Contact administrator.";
            }
            return response;
        }

        [HttpPut, ActionName("UpdateRoomType")]
        public PmsResponseDto UpdateRoomType([FromBody] UpdateRoomTypeRequestDto request)
        {
            if (request == null || request.RoomType == null || request.RoomType.Id <= 0) throw new PmsException("Room type can not be updated.");

            var response = new PmsResponseDto();
            if (_iPMSLogic.UpdateRoomType(request.RoomType))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Room Type Updated successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Room Type Updation failed.Contact administrator.";
            }
            return response;
        }

        [HttpDelete, ActionName("DeleteRoomType")]
        public PmsResponseDto DeleteRoomType(int typeId)
        {
            if (typeId <= 0) throw new PmsException("RoomType id is not valid. Hence Roomtype can not be deleted.");

            var response = new PmsResponseDto();
            if (_iPMSLogic.DeleteRoomType(typeId))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Room Type Deleted successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Room Type Deletion failed.Contact administrator.";
            }
            return response;
        }

        [HttpGet, ActionName("GetRoomTypeByProperty")]
        public GetRoomTypeResponseDto GetRoomTypeByProperty(int propertyId)
        {
            if (propertyId <= 0) throw new PmsException("Property id is not valid.");

            var response = new GetRoomTypeResponseDto();
            if (!AppConfigReaderHelper.AppConfigToBool(AppSettingKeys.MockEnabled))
            {
                response.RoomTypes = _iPMSLogic.GetRoomTypeByProperty(propertyId);
            }
            else
            {
                //mock data
            }
            return response;
        }

        [HttpGet, ActionName("GetRoomTypeById")]
        public GetRoomTypeResponseDto GetRoomTypeById(int propertyId, int typeId)
        {
            if (propertyId <= 0) throw new PmsException("Property id is not valid.");

            var response = new GetRoomTypeResponseDto();
            if (typeId <= 0)
            {
                return response;
            }
            var roomTypeResponseDto = GetRoomTypeByProperty(propertyId);
            if (roomTypeResponseDto == null || roomTypeResponseDto.RoomTypes == null || roomTypeResponseDto.RoomTypes.Count <= 0) return response;

            response.RoomTypes = roomTypeResponseDto.RoomTypes.Where(x => x.Id.Equals(typeId)).ToList();
            return response;
        }       
	}
}