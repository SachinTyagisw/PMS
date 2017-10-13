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
             "AddExpense",
             "api/v1/Expense/AddExpense",
             new { controller = "Expense", action = "AddExpense" }
             );

            config.Routes.MapHttpRoute(
             "UpdateExpense",
             "api/v1/Expense/UpdateExpense",
             new { controller = "Expense", action = "UpdateExpense" }
             );

            config.Routes.MapHttpRoute(
             "DeleteExpense",
             "api/v1/Expense/DeleteExpense/{ExpenseId}",
             new { controller = "Expense", action = "DeleteExpense" },
             constraints: new { ExpenseId = RegExConstants.NumericRegEx }
             );

            config.Routes.MapHttpRoute(
              "GetExpenseByProperty",
              "api/v1/Expense/GetExpenseByProperty/{propertyId}",
              new { controller = "Expense", action = "GetExpenseByProperty" },
              constraints: new { propertyId = RegExConstants.NumericRegEx }
              );
        }


        [HttpPost, ActionName("AddExpense")]
        public PmsResponseDto AddExpense([FromBody] ExpenseRequestDto request)
        {
            if (request == null || request.Expense == null)
                throw new PmsException("Expense Type can not be added.");

            var response = new PmsResponseDto();
            var Id = _iPmsLogic.AddExpense(request.Expense);
            if (Id > 0)
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Record(s) saved successfully.";
                response.ResponseObject = Id;
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Operation failed.Please contact administrator.";
            }
            return response;
        }

        [HttpPut, ActionName("UpdateExpense")]
        public PmsResponseDto UpdateExpense([FromBody] ExpenseRequestDto request)
        {
            if (request == null || request.Expense == null || request.Expense.Id <= 0)
                throw new PmsException("Expense Type can not be updated.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.UpdateExpense(request.Expense))
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

        [HttpDelete, ActionName("DeleteExpense")]
        public PmsResponseDto DeleteExpense(int ExpenseId)
        {
            if (ExpenseId <= 0) throw new PmsException("Expense is not valid. Hence Expense can not be deleted.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.DeleteExpense(ExpenseId))
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


        [HttpGet, ActionName("GetExpenseByProperty")]
        public GetExpenseResponseDto GetExpenseByProperty(int propertyId)
        {
            if (propertyId <= 0) throw new PmsException("Property id is not valid.");

            var response = new GetExpenseResponseDto();
            response.Expenses = _iPmsLogic.GetExpenseByProperty(propertyId);

            return response;
        }

    }
}
