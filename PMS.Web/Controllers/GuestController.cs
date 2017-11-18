using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace PMS.Web.Controllers
{
    public class GuestController : Controller
    {
        // GET: User
        public ActionResult Index()
        {
            return View();
        }
    }
}