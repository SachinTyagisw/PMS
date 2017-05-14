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
    [Export(typeof(IRestController))]
    [PartCreationPolicy(CreationPolicy.NonShared)]
    public partial class RewardController : ApiController, IRestController
    {
        private readonly IPmsLogic _iPmsLogic = null;

        public RewardController()
            : this(ServiceLocator.Current.GetInstance<IPmsLogic>())
        {
            
        }

        public RewardController(IPmsLogic iPmsLogic)
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

            config.Routes.MapHttpRoute(
            "GetRewardByGuestId",
            "api/v1/Reward/GetRewardByGuestId/{guestId}",
            new { controller = "Reward", action = "GetRewardByGuestId" },
            constraints: new { guestId = RegExConstants.NumericRegEx }
            );
        }

        [HttpPost, ActionName("AddReward")]
        public PmsResponseDto AddReward([FromBody] AddRewardRequestDto request)
        {
            if (request == null || request.Reward == null) throw new PmsException("Reward can not be added.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.AddReward(request.Reward))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Reward Added successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Reward Addition failed.Contact administrator.";
            }
            return response;
        }

        [HttpPut, ActionName("UpdateReward")]
        public PmsResponseDto UpdateReward([FromBody] UpdateRewardRequestDto request)
        {
            if (request == null || request.Reward == null || request.Reward.Id <= 0) throw new PmsException("Reward can not be updated.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.UpdateReward(request.Reward))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Reward Updated successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Reward Updation failed.Contact administrator.";
            }
            return response;
        }

        [HttpDelete, ActionName("DeleteReward")]
        public PmsResponseDto DeleteReward(int rewardId)
        {
            if (rewardId <= 0) throw new PmsException("Reward id is not valid. Hence Reward can not be deleted.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.DeleteReward(rewardId))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Reward Deleted successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Reward Deletion failed.Contact administrator.";
            }
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
            var rewardResponseDto = GetAllReward();
            if (rewardResponseDto == null || rewardResponseDto.Rewards == null || rewardResponseDto.Rewards.Count <= 0) return response;

            response.Rewards = rewardResponseDto.Rewards.Where(x => x.Id.Equals(rewardId)).ToList();
            return response;
        }

        [HttpGet, ActionName("GetAllReward")]
        public GetRewardResponseDto GetAllReward()
        {
            var response = new GetRewardResponseDto();
            if (!AppConfigReaderHelper.AppConfigToBool(AppSettingKeys.MockEnabled))
            {
                response.Rewards = _iPmsLogic.GetAllReward();
            }
            else
            {
                //mock data
            }
            return response;
        }

        [HttpGet, ActionName("GetRewardByGuestId")]
        public GetRewardResponseDto GetRewardByGuestId(int guestId)
        {
            if (guestId <= 0) throw new PmsException("Invalid Guest Id.");

            var response = new GetRewardResponseDto();
            if (!AppConfigReaderHelper.AppConfigToBool(AppSettingKeys.MockEnabled))
            {
                response.Rewards = _iPmsLogic.GetRewardByGuestId(guestId);
            }
            else
            {
                //mock data
            }
            return response;
        }
    }
}
