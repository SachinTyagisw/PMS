using PMS.Resources.Core;
using PMS.Resources.DTO.Response;
using PMS.Resources.Logging.CustomException;
using PMS.Resources.Logic;
using System;
using System.Collections.Generic;
using System.ComponentModel.Composition;
using System.Data;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace PMS.Api.Controllers
{
    [Export(typeof(IRestController))]
    [PartCreationPolicy(CreationPolicy.NonShared)]
    public class ReportsController : ApiController, IRestController
    {
        private readonly IPmsLogic _iPmsLogic = null;
        public ReportsController()
            : this(ServiceLocator.Current.GetInstance<IPmsLogic>())
        {

        }

        public ReportsController(IPmsLogic iPmsLogic)
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
            MapHttpRoutesForExpense(config);
        }

        private void MapHttpRoutesForExpense(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
             "ShiftReport",
             "api/v1/Reports/ShiftReport",
             new { controller = "Reports", action = "ShiftReport" }
             );

            config.Routes.MapHttpRoute(
             "GetConsolidatedShiftReport",
             "api/v1/Reports/GetConsolidatedShiftReport",
             new { controller = "Reports", action = "GetConsolidatedShiftReport" }
             );
        }

        [HttpPost, ActionName("ShiftReport")]
        public ShiftReportResponseDto ShiftReport()
        {
            
            var response = new ShiftReportResponseDto();
           response.ShiftRecords= _iPmsLogic.GetShiftReport(new Resources.DTO.Request.ShiftReportDto ());            
            return response;
        }

        
        [HttpPost, ActionName("GetConsolidatedShiftReport")]
        public ConsolidatedShiftReportResponseDto GetConsolidatedShiftReport()
        {

            var response = new ConsolidatedShiftReportResponseDto();
            response.ConsolidatedShiftRecords = _iPmsLogic.GetConsolidatedShiftReport(new Resources.DTO.Request.ConsolidatedShiftReportDto());
            return response;
        }
    }
}