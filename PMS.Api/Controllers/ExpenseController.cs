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
    public partial class ExpenseController : ApiController, IRestController
    {
        private readonly IPmsLogic _iPmsLogic = null;

        public ExpenseController()
            : this(ServiceLocator.Current.GetInstance<IPmsLogic>())
        {
            
        }

        public ExpenseController(IPmsLogic iPmsLogic)
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
            "GetAllExpense",
            "api/v1/Expense/GetAllExpense",
            new { controller = "Expense", action = "GetAllExpense" }
            );
        }

        [HttpGet, ActionName("GetAllExpense")]
        public GetExpenseResponseDto GetAllExpense()
        {
            var response = new GetExpenseResponseDto();
            return response;
        }
    }
}
