﻿using PMS.Resources.Common.Constants;
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
             "GetInvoice",
             "api/v1/Invoice/GetInvoice",
             new { controller = "Invoice", action = "GetInvoice" }
             );
        }

        [HttpPost, ActionName("GetInvoice")]
        public GetInvoiceResponseDto GetInvoice([FromBody] GetInvoiceRequestDto request )
        {
            if (request.Invoice == null || request.Invoice.PropertyId <=0
                || request.Invoice.RateTypeId <= 0 || request.Invoice.RoomTypeId <= 0 
                ) throw new PmsException("Get Invoice call failed.");
            
            var response = new GetInvoiceResponseDto();
            var mock = true;
            if(mock)
            {
                //mock data
                response.Tax = new List<Resources.Entities.Tax>
                {
                    new Tax 
                    {
                       TaxName = "Base Room Charge",
                       TaxId = 4,
                       Value = 11
                    },
                    new Tax 
                    {
                       TaxName = "VAT",
                       TaxId = 1,
                       Value = 10
                    },
                    new Tax 
                    {
                       TaxName = "Service Tax",
                       TaxId = 2,
                       Value = 20
                    },
                    new Tax 
                    {
                       TaxName = "Misc Tax",
                       TaxId = 3,
                       Value = 30
                    }
                };
                response.Tax.OrderBy(x => x.TaxName);
                return response;
            }
            
            response.Tax = _iPmsLogic.GetInvoice(request.Invoice);
            return response;
        }   
    }
}
