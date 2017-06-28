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
            var sessionUser = Session["username"].ToString();
            if (string.IsNullOrWhiteSpace(sessionUser))
            {
                return RedirectToAction("Login", "Account");
            }
            
            ViewBag.UserName = Session["username"].ToString();
            return View();
        }
    }
}