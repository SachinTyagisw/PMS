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
    public partial class UserController : ApiController, IRestController
    {
        private readonly IPmsLogic _iPmsLogic = null;

        public UserController()
            : this(ServiceLocator.Current.GetInstance<IPmsLogic>())
        {

        }

        public UserController(IPmsLogic iPmsLogic)
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
            MapHttpRoutesForUser(config);
        }

        private void MapHttpRoutesForUser(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
             "AddUser",
             "api/v1/User/AddUser",
             new { controller = "User", action = "AddUser" }
             );

            config.Routes.MapHttpRoute(
             "UpdateUser",
             "api/v1/User/UpdateUser",
             new { controller = "User", action = "UpdateUser" }
             );

            config.Routes.MapHttpRoute(
             "DeleteUser",
             "api/v1/User/DeleteUser/{userId}",
             new { controller = "User", action = "DeleteUser" },
             constraints: new { userId = RegExConstants.NumericRegEx }
             );

            config.Routes.MapHttpRoute(
             "GetUserById",
             "api/v1/User/GetUserById/{userId}",
             new { controller = "User", action = "GetUserById" },
             constraints: new { userId = RegExConstants.NumericRegEx }
             );

            config.Routes.MapHttpRoute(
              "GetAllUser",
              "api/v1/User/GetAllUser",
              new { controller = "User", action = "GetAllUser" }
              );

            config.Routes.MapHttpRoute(
              "InsertUserAccess",
              "api/v1/User/InsertUserAccess",
              new { controller = "User", action = "InsertUserAccess" }
              );

            config.Routes.MapHttpRoute(
              "UpdatePassword",
              "api/v1/User/UpdatePassword",
              new { controller = "User", action = "UpdatePassword" }
              );

        }

        [HttpPost, ActionName("AddUser")]
        public PmsResponseDto AddUser([FromBody] UserRequestDto request)
        {
            if (request == null || request.User == null) throw new PmsException("User can not be added.");

            var response = new PmsResponseDto();
            var Id = _iPmsLogic.AddUser(request.User);
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


        [HttpPut, ActionName("UpdateUser")]
        public PmsResponseDto UpdateUser([FromBody] UserRequestDto request)
        {
            if (request == null || request.User == null || request.User.Id <= 0)
                throw new PmsException("User can not be updated.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.UpdateUser(request.User))
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

        [HttpDelete, ActionName("DeleteUser")]
        public PmsResponseDto DeleteUser(int userId)
        {
            if (userId <= 0) throw new PmsException("User is not valid. Hence User can not be deleted.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.DeleteUser(userId))
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


        [HttpGet, ActionName("GetAllUser")]
        public GetUserResponseDto GetAllUser()
        {
            var response = new GetUserResponseDto();
            response.Users = _iPmsLogic.GetAllUser();
            return response;
        }

        [HttpPost, ActionName("InsertUserAccess")]
        public PmsResponseDto InsertUserAccess(UserAccessRequestDto request)
        {
            if (request == null || request.UserId <= 0)
                throw new PmsException("User can not be updated.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.InsertUserAccess(request))
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

        [HttpPost, ActionName("UpdatePassword")]
        public PmsResponseDto UpdatePassword([FromBody] UpdateUserPasswordDto request)
        {
            if (request == null || request.UserId <= 0)
                throw new PmsException("User can not be updated.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.UpdatePassword(request))
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
    }
}
