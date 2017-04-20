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
    public partial class RewardController : ApiController, IRestController
    {
        private readonly IPmsLogic _iPMSLogic = null;

        public RewardController()
            : this(ServiceLocator.Current.GetInstance<IPmsLogic>())
        {
            
        }

        public RewardController(IPmsLogic iPMSLogic)
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
            MapHttpRoutesForReward(config);
            MapHttpRoutesForRewardCategory(config);
        }

        private void MapHttpRoutesForReward(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
             "AddReward",
             "api/v1/Reward/AddReward",
             new { controller = "Reward", action = "AddReward" }
             );

            config.Routes.MapHttpRoute(
             "UpdateReward",
             "api/v1/Reward/UpdateReward",
             new { controller = "Reward", action = "UpdateReward" }
             );

            config.Routes.MapHttpRoute(
             "DeleteReward",
             "api/v1/Reward/DeleteReward/{rewardId}",
             new { controller = "Reward", action = "DeleteReward" },
             constraints: new { rewardId = RegExConstants.NumericRegEx }
             );

            config.Routes.MapHttpRoute(
             "GetAllReward",
             "api/v1/Reward/GetAllReward",
             new { controller = "Reward", action = "GetAllReward" }
             );

            config.Routes.MapHttpRoute(
            "GetRewardById",
            "api/v1/Reward/GetRewardById/{rewardId}",
            new { controller = "Reward", action = "GetRewardById" },
            constraints: new { rewardId = RegExConstants.NumericRegEx }
            );
        }

        [HttpPost, ActionName("AddReward")]
        public PmsResponseDto AddReward([FromBody] AddRewardRequestDto request)
        {
            if (request == null || request.Reward == null) throw new PmsException("Reward can not be added.");

            var response = new PmsResponseDto();
            return response;
        }

        [HttpPut, ActionName("UpdateReward")]
        public PmsResponseDto UpdateReward([FromBody] UpdateRewardRequestDto request)
        {
            if (request == null || request.Reward == null || request.Reward.Id <= 0) throw new PmsException("Reward can not be updated.");

            var response = new PmsResponseDto();
            return response;
        }

        [HttpDelete, ActionName("DeleteReward")]
        public PmsResponseDto DeleteReward(int rewardId)
        {
            if (rewardId <= 0) throw new PmsException("Reward id is not valid. Hence Reward can not be deleted.");

            var response = new PmsResponseDto();
            return response;
        }

        [HttpGet, ActionName("GetRewardById")]
        public GetRewardResponseDto GetRewardById(int rewardId)
        {
            var response = new GetRewardResponseDto();
            if (rewardId <= 0)
            {
                return response;
            }
            return response;
        }

        [HttpGet, ActionName("GetAllReward")]
        public GetRewardResponseDto GetAllReward()
        {
            var response = new GetRewardResponseDto();
            return response;
        }
    }
}
