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
    public partial class GuestController : ApiController, IRestController
    {
        private readonly IPmsLogic _iPmsLogic = null;

        public GuestController()
            : this(ServiceLocator.Current.GetInstance<IPmsLogic>())
        {
            
        }

        public GuestController(IPmsLogic iPmsLogic)
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
            MapHttpRoutesForGuest(config);
            MapHttpRoutesForGuestReward(config);
        }

        private void MapHttpRoutesForGuest(HttpConfiguration config)
        {

           config.Routes.MapHttpRoute(
           "GetAllGuest",
           "api/v1/Guest/GetAllGuest",
           new { controller = "Guest", action = "GetAllGuest" }
           );

           config.Routes.MapHttpRoute(
           "GetGuestById",
           "api/v1/Guest/GetGuestById/{guestId}",
           new { controller = "Guest", action = "GetGuestById" },
           constraints: new { guestId = RegExConstants.NumericRegEx }
           );

          config.Routes.MapHttpRoute(
          "GetGuestByRoomNumber",
          "api/v1/Guest/{propertyId}/GetGuestByRoomNumber/{roomNumber}",
          new { controller = "Guest", action = "GetGuestByRoomNumber" },
          constraints: new { propertyId = RegExConstants.NumericRegEx, roomNumber = RegExConstants.AlphaNumericRegEx }
          );

          config.Routes.MapHttpRoute(
          "GetGuestByIdType",
          "api/v1/Guest/{idType}/GetGuestByIdType/{idNumber}",
          new { controller = "Guest", action = "GetGuestByIdType" },
          constraints: new { idType = RegExConstants.AlphabetRegEx, idNumber = RegExConstants.AlphaNumericRegEx }
          );

          config.Routes.MapHttpRoute(
          "GetGuestHistoryById",
          "api/v1/Guest/GetGuestHistoryById/{guestId}",
          new { controller = "Guest", action = "GetGuestHistoryById" },
          constraints: new { guestId = RegExConstants.NumericRegEx }
          );

            config.Routes.MapHttpRoute(
             "AddGuest",
             "api/v1/Guest/AddGuest",
             new { controller = "Guest", action = "AddGuest" }
             );

            config.Routes.MapHttpRoute(
             "UpdateGuest",
             "api/v1/Guest/UpdateGuest",
             new { controller = "Guest", action = "UpdateGuest" }
             );

            config.Routes.MapHttpRoute(
             "DeleteGuest",
             "api/v1/Guest/DeleteGuest/{GuestId}",
             new { controller = "Guest", action = "DeleteGuest" },
             constraints: new { GuestId = RegExConstants.NumericRegEx }
             );
            config.Routes.MapHttpRoute(
           "GetGuest",
           "api/v1/Guest/GetGuest",
           new { controller = "Guest", action = "GetGuest" }
           );

        }

        [HttpGet, ActionName("GetAllGuest")]
        public GetGuestResponseDto GetAllGuest()
        {
            var response = new GetGuestResponseDto();
            response.Guest = _iPmsLogic.GetAllGuest();
            return response;
        }

        [HttpGet, ActionName("GetGuestById")]
        public GetGuestResponseDto GetGuestById(int guestId)
        {
            var response = new GetGuestResponseDto();
            if (guestId <= 0)
            {
                return response;
            }
            return response;
        }

        [HttpGet, ActionName("GetGuestByRoomNumber")]
        public GetGuestResponseDto GetGuestByRoomNumber(int propertyId, string roomNumber)
        {
            if (propertyId <= 0) throw new PmsException("Property id is not valid.");

            var response = new GetGuestResponseDto();
            if (string.IsNullOrWhiteSpace(roomNumber))
            {
                return response;
            }
            return response;
        }

        [HttpGet, ActionName("GetGuestByIdType")]
        public GetGuestResponseDto GetGuestByIdType(string idType, string idNumber)
        {
            if (string.IsNullOrWhiteSpace(idType)) throw new PmsException("Guest IdType is not valid.");
            if (string.IsNullOrWhiteSpace(idNumber)) throw new PmsException("Guest IdNumber is not valid.");

            var response = new GetGuestResponseDto();
            return response;
        }

        [HttpGet, ActionName("GetGuestHistoryById")]
        public GetGuestHistoryResponseDto GetGuestHistoryById(int guestId)
        {
            var response = new GetGuestHistoryResponseDto();
            if (guestId <= 0) return response;

            response.GuestHistory = _iPmsLogic.GetGuestHistory(guestId);
            return response;
        }

        [HttpPost, ActionName("AddGuest")]
        public PmsResponseDto AddGuest([FromBody] GuestRequestDto request)
        {
            if (request == null || request.Guest == null) throw new PmsException("Guest can not be added.");

            var response = new PmsResponseDto();
            var Id = _iPmsLogic.AddGuest(request.Guest);
            if (Id > 0)
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Record saved successfully.";
                response.ResponseObject = Id;
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Operation failed.Please contact administrator.";
            }
            return response;
        }


        [HttpPut, ActionName("UpdateGuest")]
        public PmsResponseDto UpdateGuest([FromBody] GuestRequestDto request)
        {
            if (request == null || request.Guest == null || request.Guest.Id <= 0)
                throw new PmsException("Guest can not be updated.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.UpdateGuest(request.Guest))
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

        [HttpDelete, ActionName("DeleteGuest")]
        public PmsResponseDto DeleteGuest(int GuestId)
        {
            if (GuestId <= 0) throw new PmsException("Guest is not valid. Hence Guest can not be deleted.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.DeleteGuest(GuestId))
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

        [HttpGet, ActionName("GetGuest")]
        public GetGuestResponseDto GetGuest()
        {
            var response = new GetGuestResponseDto();
            response.Guest = _iPmsLogic.GetAllGuest(false);
            return response;
        }
    }
}
