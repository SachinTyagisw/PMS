using PMS.Resources.DTO.Request;
using PMS.Resources.DTO.Response;
using PMS.Resources.Services.Interface;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace PMS.Web.Controllers
{
    public class ExtraChargeController : Controller
    {
        // GET: ExtraCharge
        public ActionResult Index()
        {
            return View();
        }
    }
}