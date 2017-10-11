using PMS.Resources.Common.Constants;
using PMS.Resources.Common.Helper;
using PMS.Resources.Core;
using PMS.Resources.DTO.Request;
using PMS.Resources.DTO.Response;
using PMS.Resources.Entities;
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
    public partial class ExpenseCategoryController : ApiController, IRestController
    {
        private readonly IPmsLogic _iPmsLogic = null;
        public ExpenseCategoryController()
            : this(ServiceLocator.Current.GetInstance<IPmsLogic>())
        {
            
        }

        public ExpenseCategoryController(IPmsLogic iPmsLogic)
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
            MapHttpRoutesForExpenseCategory(config);
        }

        private void MapHttpRoutesForExpenseCategory(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
             "AddExpenseCategory",
             "api/v1/ExpenseCategory/AddExpenseCategory",
             new { controller = "ExpenseCategory", action = "AddExpenseCategory" }
             );

            config.Routes.MapHttpRoute(
             "UpdateExpenseCategory",
             "api/v1/ExpenseCategory/UpdateExpenseCategory",
             new { controller = "ExpenseCategory", action = "UpdateExpenseCategory" }
             );

            config.Routes.MapHttpRoute(
             "DeleteExpenseCategory",
             "api/v1/ExpenseCategory/DeleteExpenseCategory/{ExpenseCategoryId}",
             new { controller = "ExpenseCategory", action = "DeleteExpenseCategory" },
             constraints: new { ExpenseCategoryId = RegExConstants.NumericRegEx }
             );

            config.Routes.MapHttpRoute(
              "GetExpenseCategoryByProperty",
              "api/v1/ExpenseCategory/GetExpenseCategoryByProperty/{propertyId}",
              new { controller = "ExpenseCategory", action = "GetExpenseCategoryByProperty" },
              constraints: new { propertyId = RegExConstants.NumericRegEx }
              );
        }


        [HttpPost, ActionName("AddExpenseCategory")]
        public PmsResponseDto AddExpenseCategory([FromBody] ExpenseCategoryRequestDto request)
        {
            if (request == null || request.ExpenseCategory == null)
                throw new PmsException("ExpenseCategory Type can not be added.");

            var response = new PmsResponseDto();
            var Id = _iPmsLogic.AddExpenseCategory(request.ExpenseCategory);
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

        [HttpPut, ActionName("UpdateExpenseCategory")]
        public PmsResponseDto UpdateExpenseCategory([FromBody] ExpenseCategoryRequestDto request)
        {
            if (request == null || request.ExpenseCategory == null || request.ExpenseCategory.Id <= 0)
                throw new PmsException("ExpenseCategory Type can not be updated.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.UpdateExpenseCategory(request.ExpenseCategory))
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

        [HttpDelete, ActionName("DeleteExpenseCategory")]
        public PmsResponseDto DeleteExpenseCategory(int ExpenseCategoryId)
        {
            if (ExpenseCategoryId <= 0) throw new PmsException("ExpenseCategory Type is not valid. Hence ExpenseCategory Type can not be deleted.");

            var response = new PmsResponseDto();
            if (_iPmsLogic.DeleteExpenseCategory(ExpenseCategoryId))
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


        [HttpGet, ActionName("GetExpenseCategoryByProperty")]
        public GetExpenseCategoryResponseDto GetExpenseCategoryByProperty(int propertyId)
        {
            if (propertyId <= 0) throw new PmsException("Property id is not valid.");

            var response = new GetExpenseCategoryResponseDto();
            response.ExpenseCategories = _iPmsLogic.GetExpenseCategoryByProperty(propertyId);

            return response;
        }

    }
}
