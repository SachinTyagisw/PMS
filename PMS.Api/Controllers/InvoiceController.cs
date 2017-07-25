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
using System.Globalization;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace PMS.Api.Controllers
{
    [Export(typeof(IRestController))]
    [PartCreationPolicy(CreationPolicy.NonShared)]
    public partial class InvoiceController : ApiController, IRestController
    {
        private readonly IPmsLogic _iPmsLogic = null;
        public InvoiceController()
            : this(ServiceLocator.Current.GetInstance<IPmsLogic>())
        {
            
        }

        public InvoiceController(IPmsLogic iPmsLogic)
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
            MapHttpRoutesForInvoice(config);
        }

        private void MapHttpRoutesForInvoice(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
             "GetPaymentCharges",
             "api/v1/Invoice/GetPaymentCharges",
             new { controller = "Invoice", action = "GetPaymentCharges" }
             );

            config.Routes.MapHttpRoute(
             "AddInvoice",
             "api/v1/Invoice/AddInvoice",
             new { controller = "Invoice", action = "AddInvoice" }
             );

            config.Routes.MapHttpRoute(
              "GetInvoiceById",
              "api/v1/Invoice/GetInvoiceById/{invoiceId}",
              new { controller = "Invoice", action = "GetInvoiceById" },
              constraints: new { invoiceId = RegExConstants.NumericRegEx }
              );
        }

        [HttpGet, ActionName("GetInvoiceById")]
        public GetInvoiceResponseDto GetInvoiceById(int invoiceId)
        {
            if (invoiceId <= 0) throw new PmsException("Invoice id is not valid.");

            var response = new GetInvoiceResponseDto();
            response.Invoice = _iPmsLogic.GetInvoiceById(invoiceId);

            return response;
        }

        [HttpPost, ActionName("AddInvoice")]
        public PmsResponseDto AddInvoice([FromBody] AddInvoiceRequestDto request)
        {
            if (request == null || request.Invoice == null || request.Invoice.PropertyId <= 0 || request.Invoice.BookingId <= 0) throw new PmsException("Invoice can not be added.");

            var response = new PmsResponseDto();
            var id = _iPmsLogic.AddInvoice(request.Invoice);
            if (id > 0)
            {
                response.ResponseStatus = PmsApiStatus.Success.ToString();
                response.StatusDescription = "Invoice is added successfully.";
                response.ResponseObject = id;
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure.ToString();
                response.StatusDescription = "Invoice is not added.Contact administrator.";
                response.ResponseObject = id;
            }
            return response;
        }

        [HttpPost, ActionName("GetPaymentCharges")]
        public GetPaymentChargesResponseDto GetPaymentCharges([FromBody] GetPaymentChargesRequestDto request )
        {
            if (request == null || request.PropertyId <=0
                || request.RoomTypeId <= 0 || request.RoomId <= 0
                ) throw new PmsException("Get Invoice call failed.");

            var response = new GetPaymentChargesResponseDto();
            if (!AppConfigReaderHelper.AppConfigToBool(AppSettingKeys.MockEnabled))
            {
                response.Tax = _iPmsLogic.GetPaymentCharges(request);    
                return response;
            }
            
            //mock data
            response.Tax = new List<Resources.Entities.Tax>
            {
                new Tax 
                {
                    TaxName = "ROOM CHARGES",
                    Id = 4,
                    Value = 11,
                    IsDefaultCharges = true
                },
                new Tax 
                {
                    TaxName = "VAT",
                    Id = 1,
                    Value = 10,
                    IsDefaultCharges = true
                },
                new Tax 
                {
                    TaxName = "ServiceTax",
                    Id = 2,
                    Value = 20,
                    IsDefaultCharges = true
                },
                new Tax 
                {
                    TaxName = "Misc Tax",
                    Id = 3,
                    Value = 30,
                    IsDefaultCharges = false
                }
            };
            return response;
        }   
    }
}
