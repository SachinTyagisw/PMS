using PMS.Resources.Common.Constants;
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
    public partial class RoomController : ApiController, IRestController
    {
        private readonly IPmsLogic _iPMSLogic = null;
        public RoomController()
            : this(ServiceLocator.Current.GetInstance<IPmsLogic>())
        {
            
        }

        public RoomController(IPmsLogic iPMSLogic)
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
            MapHttpRoutesForRoom(config);
            MapHttpRoutesForRoomType(config);
            MapHttpRoutesForRoomStatus(config);
            MapHttpRoutesForRateType(config);
            MapHttpRoutesForRoomPricing(config);
        }

        private void MapHttpRoutesForRoom(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
             "AddRoom",
             "api/v1/Room/AddRoom",
             new { controller = "Room", action = "AddRoom" }
             );

            config.Routes.MapHttpRoute(
             "UpdateRoom",
             "api/v1/Room/UpdateRoom",
             new { controller = "Room", action = "UpdateRoom" }
             );

            config.Routes.MapHttpRoute(
             "DeleteRoom",
             "api/v1/Room/DeleteRoom/{roomId}",
             new { controller = "Room", action = "DeleteRoom" },
             constraints: new { roomId = RegExConstants.NumericRegEx }
             );

            config.Routes.MapHttpRoute(
              "GetRoomByProperty",
              "api/v1/Room/GetRoomByProperty/{propertyId}",
              new { controller = "Room", action = "GetRoomByProperty" },
              constraints: new { propertyId = RegExConstants.NumericRegEx }
              );

            config.Routes.MapHttpRoute(
              "GetRoomByRateType",
              "api/v1/Room/GetRoomByRateType/{rateTypeId}",
              new { controller = "Room", action = "GetRoomByRateType" },
              constraints: new { rateTypeId = RegExConstants.NumericRegEx }
              );

            config.Routes.MapHttpRoute(
            "GetRoomById",
            "api/v1/Room/GetRoomById/{roomId}",
            new { controller = "Room", action = "GetRoomById" },
            constraints: new { roomId = RegExConstants.NumericRegEx }
            );
           
            config.Routes.MapHttpRoute(
            "GetRoomByRoomType",
            "api/v1/Room/GetRoomByRoomType/{typeId}",
            new { controller = "Room", action = "GetRoomByRoomType" },
            constraints: new { typeId = RegExConstants.NumericRegEx }
            );

            config.Routes.MapHttpRoute(
             "GetRoomByStatus",
             "api/v1/Room/{propertyId}/GetRoomByStatus/{statusId}",
             new { controller = "Room", action = "GetRoomByStatus" },
             constraints: new { propertyId = RegExConstants.NumericRegEx, statusId = RegExConstants.NumericRegEx }
             );

            config.Routes.MapHttpRoute(
            "GetRoomByRoomNumber",
            "api/v1/Room/{propertyId}/GetRoomByRoomNumber/{roomNumber}",
            new { controller = "Room", action = "GetRoomByRoomNumber" },
            constraints: new { propertyId = RegExConstants.NumericRegEx, roomNumber = RegExConstants.AlphaNumericRegEx }
            );
        }

        [HttpPost, ActionName("AddRoom")]
        public PmsResponseDto AddRoom([FromBody] AddRoomRequestDto request)
        {
            if (request == null || request.Room == null) throw new PmsException("Room can not be added.");

            var response = new PmsResponseDto();
            return response;
        }

        [HttpPut, ActionName("UpdateRoom")]
        public PmsResponseDto UpdateRoom([FromBody] UpdateRoomRequestDto request)
        {
            if (request == null || request.Room == null || request.Room.Id <= 0) throw new PmsException("Room can not be updated.");

            var response = new PmsResponseDto();
            return response;
        }

        [HttpDelete, ActionName("DeleteRoom")]
        public PmsResponseDto DeleteRoom(int roomId)
        {
            if (roomId <= 0) throw new PmsException("Roomid is not valid. Hence Room can not be deleted.");

            var response = new PmsResponseDto();
            return response;
        }

        [HttpGet, ActionName("GetRoomByProperty")]
        public GetRoomResponseDto GetRoomByProperty(int propertyId)
        {
            if (propertyId <= 0) throw new PmsException("Property id is not valid.");

            //test data
            var response = new GetRoomResponseDto()
            {
                Rooms = new List<Resources.Entities.Room>
                {
                    new Room
                    {
                        Id = 1,
                        Number = "Room AB"
                    },

                    new Room
                    {
                       Id = 2,
                       Number = "Room AC"
                    },

                    new Room
                    {
                       Id = 3,
                       Number = "Room AD"
                    },

                    new Room
                    {
                       Id = 4,
                       Number = "Room AE"
                    }


                }
            };

            return response;
        }
        
        [HttpGet, ActionName("GetRoomById")]
        public GetRoomResponseDto GetRoomById(int roomId)
        {
            var response = new GetRoomResponseDto();
            if (roomId <= 0)
            {
                return response;
            }
            return response;
        }

        [HttpGet, ActionName("GetRoomByStatus")]
        public GetRoomResponseDto GetRoomByStatus(int propertyId, int statusId)
        {
            if (propertyId <= 0) throw new PmsException("Property id is not valid.");

            var response = new GetRoomResponseDto();
            if (statusId <= 0)
            {
                return response;
            }
            return response;
        }

        [HttpGet, ActionName("GetRoomByRoomType")]
        public GetRoomResponseDto GetRoomByRoomType(int typeId)
        {
            var response = new GetRoomResponseDto();
            if (typeId <= 0)
            {
                return response;
            }
            return response;
        }

        [HttpGet, ActionName("GetRoomByRateType")]
        public GetRoomResponseDto GetRoomByRateType(int rateTypeId)
        {
            var response = new GetRoomResponseDto();
            if (rateTypeId <= 0)
            {
                return response;
            }
            return response;
        }

        [HttpGet, ActionName("GetRoomByRoomNumber")]
        public GetRoomResponseDto GetRoomByRoomNumber(int propertyId, string roomNumber)
        {
            if (propertyId <= 0) throw new PmsException("Property id is not valid.");

            var response = new GetRoomResponseDto();
            if (string.IsNullOrWhiteSpace(roomNumber))
            {
                return response;
            }
            return response;
        }    
    }
}
