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
    public class FunctionalityController : ApiController, IRestController
    {
        private readonly IPmsLogic _iPmsLogic = null;

        public FunctionalityController()
            : this(ServiceLocator.Current.GetInstance<IPmsLogic>())
        {

        }

        public FunctionalityController(IPmsLogic iPmsLogic)
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
            MapHttpRoutesForFunctionality(config);
        }

        private void MapHttpRoutesForFunctionality(HttpConfiguration config)
        {
            
            config.Routes.MapHttpRoute(
              "GetAllFunctionality",
              "api/v1/Functionality/GetAllFunctionality",
              new { controller = "Functionality", action = "GetAllFunctionality" }
              );

            config.Routes.MapHttpRoute(
             "GetFunctionalityByUserId",
             "api/v1/Functionality/GetFunctionalityByUserId/{userId}",
             new { controller = "Functionality", action = "GetFunctionalityByUserId" },
             constraints: new { userId = RegExConstants.NumericRegEx }
             );
        }


        [HttpGet, ActionName("GetAllFunctionality")]
        public GetFunctionalityResponseDto GetAllFunctionality()
        {
            var response = new GetFunctionalityResponseDto();

            var functionalities = _iPmsLogic.GetAllFunctionality();

            if (functionalities == null || functionalities.Count <= 0) return response;

            response.Functionalities = functionalities;
            return response;
        }

        [HttpGet, ActionName("GetFunctionalityByUserId")]
        public GetFunctionalityResponseDto GetFunctionalityByUserId(int userId)
        {
            var response = new GetFunctionalityResponseDto();
            if (userId <= 0)
            {
                return response;
            }
            var functionalities = _iPmsLogic.GetFunctionalityByUserId(userId);

            if (functionalities == null || functionalities.Count <= 0) return response;

            response.Functionalities = functionalities;
            return response;
        }

    }
}