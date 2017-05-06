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
            //var request = new AddBookingRequestDto()
            //{
            //    Booking = new Resources.Entities.Booking
            //    {
            //        //PropertyID = 23,
            //        CheckinTime = DateTime.Now
            //    }
            //};
            
            //var response = PmsService.AddBooking(request);
            return View();
        }
    }
}