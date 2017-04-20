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
    public partial class GuestController : ApiController, IRestController
    {
        private void MapHttpRoutesForGuestReward(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
              "GetGuestRewardById",
              "api/v1/Guest/GetGuestRewardById/{id}",
              new { controller = "Guest", action = "GetGuestRewardById" },
              constraints: new { id = RegExConstants.AlphaNumericRegEx }
            );
        }

        [HttpGet, ActionName("GetGuestRewardById")]
        public GetGuestRewardResponseDto GetGuestRewardById(string id)
        {
            if (string.IsNullOrWhiteSpace(id)) throw new PmsException("Guest Identification is not valid.");

            var response = new GetGuestRewardResponseDto();
            return response;
        }   
    }
}