﻿using PMS.Resources.Common.Constants;
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
    public partial class BookingController : ApiController, IRestController
    {
        private readonly IPmsLogic _iPMSLogic = null;
        public BookingController()
            : this(ServiceLocator.Current.GetInstance<IPmsLogic>())
        {
            
        }

        public BookingController(IPmsLogic iPMSLogic)
        {
            _iPMSLogic = iPMSLogic;
        }

        /// <summary>
        /// Map Routes for REST
        /// </summary>
        /// <param name="config"></param>
        [System.Web.Http.NonAction]
        public void MapHttpRoutes(HttpConfiguration config)
        {
            MapHttpRoutesForBooking(config);
        }

        private void MapHttpRoutesForBooking(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
             "AddBooking",
             "api/v1/Booking/AddBooking",
             new { controller = "Booking", action = "AddBooking" }
             );

            config.Routes.MapHttpRoute(
             "GetBooking",
             "api/v1/Booking/GetBooking",
             new { controller = "Booking", action = "GetBooking" }
             );
        }

        [HttpPost, ActionName("AddBooking")]
        public PmsResponseDto AddBooking([FromBody] AddBookingRequestDto request)
        {
            if (request == null || request.Booking == null) throw new PmsException("Room Booking can not be done.");
            
            var response = new PmsResponseDto();
            if(_iPMSLogic.AddBooking(request.Booking))
            {
                response.ResponseStatus = PmsApiStatus.Success;
                response.StatusDescription = "Booking is done successfully.";
            }
            else
            {
                response.ResponseStatus = PmsApiStatus.Failure;
                response.StatusDescription = "Booking is failed.Contact administrator.";
            }

            return response;
        }

        [HttpGet, ActionName("GetBooking")]
        public GetBookingResponseDto GetBooking()
        {
            var queryParams = Request.GetQueryNameValuePairs();
            var startDate = queryParams.FirstOrDefault(x => x.Key == "startdate").Value;
            var endDate = queryParams.FirstOrDefault(x => x.Key == "enddate").Value;
            var dtFormats = new[] { "dd/MM/yyyy", "yyyy-MM-dd" , "dd/M/yyyy", "dd/MM/yyyy"};
            DateTime dtStart;
            DateTime dtEnd;

            if (!DateTime.TryParseExact(startDate, dtFormats, CultureInfo.InvariantCulture, DateTimeStyles.None, out dtStart))
            {
                throw new PmsException("Incorrect booking start date");
            }
            
            if (!DateTime.TryParseExact(endDate, dtFormats, CultureInfo.InvariantCulture, DateTimeStyles.None , out dtEnd))
            {
                throw new PmsException("Incorrect booking end date");
            }

            //test data
            var response = new GetBookingResponseDto()
            {
                Bookings = new List<Resources.Entities.Booking>
                {
                   new Booking 
                   {
                       CheckinTime = Convert.ToDateTime(String.Format("{0:s}", DateTime.Now)),
                       CheckoutTime = Convert.ToDateTime(String.Format("{0:s}", DateTime.Now.AddHours(3))),
                       RoomBookings = new List<RoomBooking>
                       {
                          new RoomBooking
                          { 
                             Id = 100,
                             Room = new Room
                             {
                                 Id = 1,
                                 Number = "Room B"
                             },
                             Guest = new Guest
                             {
                                 Id = 11,
                                 FirstName = "Tyagi"
                             }                            
                             
                          },
                          new RoomBooking
                          {
                             Id = 200,
                             Room = new Room
                             {
                                 Id = 2,
                                 Number = "Room C"
                             },
                             Guest = new Guest
                             {
                                 Id = 22,
                                 FirstName = "Sharma"
                             }    
                          },
                          new RoomBooking
                          {
                             Id = 300,
                             Room = new Room
                             {
                                 Id = 3,
                                 Number = "Room D"
                             },
                             Guest = new Guest
                             {
                                 Id = 33,
                                 FirstName = "Deepak"
                             }    
                          },
                          new RoomBooking
                          {
                             Id = 400,
                             Room = new Room
                             {
                                 Id = 4,
                                 Number = "Room E"
                             },
                             Guest = new Guest
                             {
                                 Id = 44,
                                 FirstName = "Sharma123"
                             }    
                          }
                       }
                   }
                  
                   
                }
            };

            return response;
        }
    }
}
