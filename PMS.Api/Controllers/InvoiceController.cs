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
        }

        [HttpPost, ActionName("GetPaymentCharges")]
        public GetPaymentChargesResponseDto GetPaymentCharges([FromBody] GetPaymentChargesRequestDto request )
        {
            if (request == null || request.PropertyId <=0
                || request.RateTypeId <= 0 || request.RoomTypeId <= 0 
                ) throw new PmsException("Get Invoice call failed.");

            var response = new GetPaymentChargesResponseDto();
            TimeSpan? ts = request.CheckoutTime - request.CheckinTime;
            response.StayDays = !ts.HasValue || Convert.ToBoolean(request.IsHourly) ? 1 : Convert.ToInt32(ts.Value.TotalDays);

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
                    TaxId = 4,
                    Value = 11,
                    IsEnabled = true
                },
                new Tax 
                {
                    TaxName = "VAT",
                    TaxId = 1,
                    Value = 10,
                    IsEnabled = true
                },
                new Tax 
                {
                    TaxName = "ServiceTax",
                    TaxId = 2,
                    Value = 20,
                    IsEnabled = true
                },
                new Tax 
                {
                    TaxName = "Misc Tax",
                    TaxId = 3,
                    Value = 30,
                    IsEnabled = true
                }
            };
            return response;
        }   
    }
}
