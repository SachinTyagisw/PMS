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
using PmsEntity = PMS.Resources.Entities;

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
              "GetRateTypeByProperty",
              "api/v1/Room/GetRateTypeByProperty/{propertyId}",
              new { controller = "Room", action = "GetRateTypeByProperty" },
              constraints: new { propertyId = RegExConstants.NumericRegEx }
              );

            config.Routes.MapHttpRoute(
              "GetRateTypeById",
              "api/v1/Room/{propertyId}/GetRateTypeById/{typeId}",
              new { controller = "Room", action = "GetRateTypeById" },
              constraints: new { propertyId = RegExConstants.NumericRegEx, typeId = RegExConstants.NumericRegEx }
              );

            config.Routes.MapHttpRoute(
             "GetRateTypeByRoomType",
             "api/v1/Room/{propertyId}/GetRateTypeByRoomType/{roomTypeId}",
             new { controller = "Room", action = "GetRateTypeByRoomType" },
             constraints: new { propertyId = RegExConstants.NumericRegEx, roomTypeId = RegExConstants.NumericRegEx }
             );
        }

        [HttpPost, ActionName("AddRateType")]
        public PmsResponseDto AddRateType([FromBody] AddRateTypeRequestDto request)
        {
            if (request == null || request.RateType == null) throw new PmsException("Rate type can not be added.");

            var response = new PmsResponseDto();
            if (_iPMSLogic.AddRateType(request.RateType))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "New Rate Type Added successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "New Rate Type Addition failed.Contact administrator.";
            }
            return response;
        }

        [HttpPut, ActionName("UpdateRateType")]
        public PmsResponseDto UpdateRateType([FromBody] UpdateRateTypeRequestDto request)
        {
            if (request == null || request.RateType == null || request.RateType.Id <= 0) throw new PmsException("Rate type can not be updated.");

            var response = new PmsResponseDto();
            if (_iPMSLogic.UpdateRateType(request.RateType))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Rate Type Updated successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Rate Type Updation failed.Contact administrator.";
            }
            return response;
        }

        [HttpDelete, ActionName("DeleteRateType")]
        public PmsResponseDto DeleteRateType(int typeId)
        {
            if (typeId <= 0) throw new PmsException("RateType id is not valid. Hence RateType can not be deleted.");

            var response = new PmsResponseDto();
            if (_iPMSLogic.DeleteRateType(typeId))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Rate Type Deleted successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Rate Type Deletion failed.Contact administrator.";
            }
            return response;
        }

        [HttpGet, ActionName("GetRateTypeByProperty")]
        public GetRateTypeResponseDto GetRateTypeByProperty(int propertyId)
        {
            if (propertyId <= 0) throw new PmsException("Property id is not valid.");

            var response = new GetRateTypeResponseDto();
            if (!AppConfigReaderHelper.AppConfigToBool(AppSettingKeys.MockEnabled))
            {
                response.RateTypes = _iPMSLogic.GetRateTypeByProperty(propertyId);
            }
            else
            {
                //mock data
                response.RateTypes = new List<Resources.Entities.RateType>
                {
                    new PmsEntity.RateType
                    {
                        Id = 1,
                        Name = "Apartment Standard Test",
                        RoomTypeId = 2
                    },
                    new PmsEntity.RateType
                    {
                        Id = 2,
                        Name = "Apartment Standard",
                        RoomTypeId = 1
                    },
                    new PmsEntity.RateType
                    {
                        Id = 3,
                        Name = "Queen Standard",
                        RoomTypeId = 3
                    },
                    new PmsEntity.RateType
                    {
                        Id = 4,
                        Name = "Holiday Standard",
                        RoomTypeId = 1
                    },
                    new PmsEntity.RateType
                    {
                        Id = 5,
                        Name = "My Weekend Standard",
                        RoomTypeId = 4
                    }
                };
            }
            return response;
        }

        [HttpGet, ActionName("GetRateTypeById")]
        public GetRateTypeResponseDto GetRateTypeById(int propertyId, int typeId)
        {
            if (propertyId <= 0) throw new PmsException("Property id is not valid.");

            var response = new GetRateTypeResponseDto();
            if (typeId <= 0)
            {
                return response;
            }
            var rateTypeResponseDto = GetRateTypeByProperty(propertyId);
            if (rateTypeResponseDto == null || rateTypeResponseDto.RateTypes == null || rateTypeResponseDto.RateTypes.Count <= 0) return response;

            response.RateTypes = rateTypeResponseDto.RateTypes.Where(x => x.Id.Equals(typeId)).ToList();
            return response;
        }

        [HttpGet, ActionName("GetRateTypeByRoomType")]
        public GetRateTypeResponseDto GetRateTypeByRoomType(int propertyId, int roomTypeId)
        {
            if (propertyId <= 0) throw new PmsException("Property id is not valid.");

            var response = new GetRateTypeResponseDto();
            if (roomTypeId <= 0)
            {
                return response;
            }
            var rateTypeResponseDto = GetRateTypeByProperty(propertyId);
            if (rateTypeResponseDto == null || rateTypeResponseDto.RateTypes == null || rateTypeResponseDto.RateTypes.Count <= 0) return response;

            response.RateTypes = rateTypeResponseDto.RateTypes.Where(x => x.RoomTypeId.Equals(roomTypeId)).ToList();
            return response;
        }    
    }
}