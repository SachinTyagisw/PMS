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
            MapHttpRoutesForReports(config);
        }

        private void MapHttpRoutesForReports(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
             "GetShiftReport",
             "api/v1/Reports/GetShiftReport",
             new { controller = "Reports", action = "GetShiftReport" }
             );

            config.Routes.MapHttpRoute(
             "GetConsolidatedShiftReport",
             "api/v1/Reports/GetConsolidatedShiftReport",
             new { controller = "Reports", action = "GetConsolidatedShiftReport" }
             );

            config.Routes.MapHttpRoute(
             "GetManagerData",
             "api/v1/Reports/GetManagerData",
             new { controller = "Reports", action = "GetManagerData" }
             );
        }

        [HttpPost, ActionName("GetShiftReport")]
        public ShiftReportResponseDto GetShiftReport(Resources.DTO.Request.ShiftReportDto shiftReportRequest)
        {
            
            var response = new ShiftReportResponseDto();
           response.ShiftRecords= _iPmsLogic.GetShiftReport(shiftReportRequest);            
            return response;
        }

        
        [HttpPost, ActionName("GetConsolidatedShiftReport")]
        public ConsolidatedShiftReportResponseDto GetConsolidatedShiftReport
            (Resources.DTO.Request.ConsolidatedShiftReportDto consolidatedShiftReportRequest)
        {

            var response = new ConsolidatedShiftReportResponseDto();
            response.ConsolidatedShiftRecords = _iPmsLogic.GetConsolidatedShiftReport(consolidatedShiftReportRequest);
            return response;
        }

        [HttpPost, ActionName("GetManagerData")]
        public ManagerReportResponseDto GetManagerData(Resources.DTO.Request.ManagerReportDto managerReportRequest)
        {

            var response = new ManagerReportResponseDto();
            response.ManagerRecords = _iPmsLogic.GetManagerData(managerReportRequest);
            return response;
        }
    }
}