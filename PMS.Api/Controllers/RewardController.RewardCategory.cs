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
    public partial class RewardController : ApiController, IRestController
    {
        private void MapHttpRoutesForRewardCategory(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
            "AddRewardCategory",
            "api/v1/Reward/AddRewardCategory",
            new { controller = "Reward", action = "AddRewardCategory" }
            );

            config.Routes.MapHttpRoute(
             "UpdateRewardCategory",
             "api/v1/Reward/UpdateRewardCategory",
             new { controller = "Reward", action = "UpdateRewardCategory" }
             );

            config.Routes.MapHttpRoute(
             "DeleteRewardCategory",
             "api/v1/Reward/DeleteRewardCategory/{catId}",
             new { controller = "Reward", action = "DeleteRewardCategory" },
             constraints: new { catId = RegExConstants.NumericRegEx }
             );

            config.Routes.MapHttpRoute(
              "GetAllRewardCategory",
              "api/v1/Reward/GetAllRewardCategory",
              new { controller = "Reward", action = "GetAllRewardCategory" }
              );

            config.Routes.MapHttpRoute(
              "GetRewardCategoryById",
              "api/v1/Reward/GetRewardCategoryById/{catId}",
              new { controller = "Reward", action = "GetRewardCategoryById" },
              constraints: new { catId = RegExConstants.NumericRegEx }
              );
        }

        [HttpPost, ActionName("AddRewardCategory")]
        public PmsResponseDto AddRewardCategory([FromBody] AddRewardCategoryRequestDto request)
        {
            if (request == null || request.RewardCategory == null) throw new PmsException("RewardCategory can not be added.");

            var response = new PmsResponseDto();
            if (_iPMSLogic.AddRewardCategory(request.RewardCategory))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Reward Category Added successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Reward Category Addition failed.Contact administrator.";
            }
            return response;
        }

        [HttpPut, ActionName("UpdateRewardCategory")]
        public PmsResponseDto UpdateRewardCategory([FromBody] UpdateRewardCategoryRequestDto request)
        {
            if (request == null || request.RewardCategory == null || request.RewardCategory.Id <= 0) throw new PmsException("Reward type can not be updated.");

            var response = new PmsResponseDto();
            if (_iPMSLogic.UpdateRewardCategory(request.RewardCategory))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Reward Category Updated successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Reward Category Updation failed.Contact administrator.";
            }
            return response;
        }

        [HttpDelete, ActionName("DeleteRewardCategory")]
        public PmsResponseDto DeleteRewardCategory(int catId)
        {
            if (catId <= 0) throw new PmsException("RewardCategory id is not valid. Hence RewardCategory can not be deleted.");

            var response = new PmsResponseDto();
            if (_iPMSLogic.DeleteRewardCategory(catId))
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Reward Category Deleted successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Reward Category Deletion failed.Contact administrator.";
            }
            return response;
        }

        [HttpGet, ActionName("GetRewardCategoryById")]
        public GetRewardCategoryResponseDto GetRewardCategoryById(int catId)
        {
            var response = new GetRewardCategoryResponseDto();
            if (catId <= 0)
            {
                return response;
            }
            var rewardCategoryResponseDto = GetAllRewardCategory();
            if (rewardCategoryResponseDto == null || rewardCategoryResponseDto.RewardCategories == null || rewardCategoryResponseDto.RewardCategories.Count <= 0) return response;

            response.RewardCategories = rewardCategoryResponseDto.RewardCategories.Where(x => x.Id.Equals(catId)).ToList();
            return response;
        }

        [HttpGet, ActionName("GetAllRewardCategory")]
        public GetRewardCategoryResponseDto GetAllRewardCategory()
        {
            var response = new GetRewardCategoryResponseDto();
            if (!AppConfigReaderHelper.AppConfigToBool(AppSettingKeys.MockEnabled))
            {
                response.RewardCategories = _iPMSLogic.GetAllRewardCategory();
            }
            else
            {
                //mock data
            }
            return response;
        }
    }
}