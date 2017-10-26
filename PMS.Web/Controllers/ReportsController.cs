using PMS.Resources.Services.Interface;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace PMS.Web.Controllers
{
    public class ReportsController : Controller
    {
        private IPmsService PmsService
        {
            get
            {
                return (IPmsService)System.Web.HttpContext.Current.Application["PMSService"];
            }
        }
        // GET: Report
        [HttpGet]
        public ActionResult ViewTransaction()
        {
            return View();
        }

        [HttpGet]
        public ActionResult ShiftReport()
        {
            return View();
        }

        [HttpGet]
        public ActionResult ManagerReport()
        {
            return View();
        }
    }
}