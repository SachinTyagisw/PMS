using PMS.Resources.DTO.Request;
using PMS.Resources.DTO.Response;
using PMS.Resources.Services.Interface;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace PMS.Web.Controllers
{
    public class BookingController : Controller
    {
        private IPmsService PmsService
        {
            get
            {
                return (IPmsService)System.Web.HttpContext.Current.Application["PMSService"];
            }
        }

        // GET: Booking
        public ActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public ActionResult Checkin()
        {
            if (Session["username"] == null) return RedirectToAction("Login", "Account");
            var pmsUser = Convert.ToString(Session["username"]);
            if (string.IsNullOrWhiteSpace(pmsUser))
            {
                return RedirectToAction("Login", "Account");
            }

            ViewBag.UserName = pmsUser;
            return View();
        }

        [HttpGet]
        public ActionResult Manage()
        {
            return View();
        }
    }
}