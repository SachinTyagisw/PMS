using PmsEntity = PMS.Resources.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PMS.Resources.Common.Converter;
using System.Data.SqlClient;
using System.Data;

namespace PMS.Resources.DAL
{
    public class DalFactory : IDalFactory
    {
        public void LogExceptionToDb(PmsEntity.ExceptionLog additionalExData)
        {
            throw new NotImplementedException();
        }
        public bool AddBooking(int propertyId, string bookingXml, ref int bookingId, ref int guestId)
        {
            var isAdded = false;
            using (var pmsContext = new PmsEntities())
            {
                var propId = new SqlParameter
                {
                    ParameterName = "propertyID",
                    DbType = DbType.Int32,
                    Value = propertyId
                };

                var roomBookingXml = new SqlParameter
                {
                    ParameterName = "bookingXML",
                    DbType = DbType.Xml,
                    Value = bookingXml
                };

                var bookingid = new SqlParameter
                {
                    ParameterName = "BOOKINGID",
                    DbType = DbType.Int32,
                    Direction = ParameterDirection.Output
                };

                var guestid = new SqlParameter
                {
                    ParameterName = "GUESTID",
                    DbType = DbType.Int32,
                    Direction = ParameterDirection.Output
                };

                var result = pmsContext.Database.ExecuteSqlCommand("InsertBooking @propertyID, @bookingXML, @BOOKINGID OUTPUT, @GUESTID OUTPUT", propId, roomBookingXml, bookingid, guestid);

                bookingId = Convert.ToInt32(bookingid.Value);
                guestId = Convert.ToInt32(guestid.Value);
                if (bookingId > 0 && guestId > 0)
                {
                    isAdded = true;
                }
            }
            return isAdded;
        }
        public List<PmsEntity.Booking> GetBooking(int propertyId, DateTime startDate, DateTime endDate)
        {
            var bookings = new List<PmsEntity.Booking>();

            using (var pmsContext = new PmsEntities())
            {
                var resultSet = pmsContext.GETALLBOOKINGS(propertyId, startDate, endDate).ToList();
                if (resultSet == null || resultSet.Count <= 0) return bookings;
                foreach (var result in resultSet)
                {
                    var booking = new PmsEntity.Booking();
                    booking.Id = result.ID;
                    booking.CheckinTime = result.CHECKINTIME;
                    booking.CheckoutTime = result.CHECKOUTTIME;

                    booking.RoomBookings = new List<PmsEntity.RoomBooking>
                    {
                        new PmsEntity.RoomBooking
                        { 
                            Id = result.ROOMBOOKINGID,
                            Room = new PmsEntity.Room
                            {
                                Id = result.ROOMID,
                                Number = result.ROOMNUMBER
                            },
                            Guest = new PmsEntity.Guest
                            {
                                Id = result.GUESTID,
                                FirstName = result.FIRSTNAME,
                                LastName = result.LASTNAME
                            }                            
                        }
                    };
                    bookings.Add(booking);
                }
            }
            return bookings;
        }
        public int AddProperty(PmsEntity.Property property)
        {
            var Id = -1;
            if (property == null) return Id;

            var prop = new DAL.Property
            {
                CreatedOn = property.CreatedOn,
                IsActive = true,
                CreatedBy = property.CreatedBy,
                PropertyName = property.PropertyName,
                SecondaryName = property.SecondaryName,
                PropertyCode = property.PropertyCode,
                FullAddress = property.FullAddress,
                Phone = property.Phone,
                Fax = property.Fax,
                LogoPath = property.LogoPath,
                WebSiteAddress = property.WebSiteAddress,
                TimeZone = property.TimeZone,
                CheckinTime = property.CheckinTime,
                CheckoutTime = property.CheckoutTime,
                CloseOfDayTime = property.CloseOfDayTime,
                CurrencyId = property.CurrencyID,
                State = property.State.Id,
                Country = property.Country.Id,
                City = property.City.Id,
                PropertyDetails = property.PropertyDetails,
                Zipcode = property.Zipcode
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Properties.Add(prop);
                var result = pmsContext.SaveChanges();
                Id = result == 1 ? prop.ID : -1;               
            }
            return Id;
        }
        public bool UpdateProperty(PmsEntity.Property property)
        {
            var isUpdated = false;
            if (property == null || property.Id <= 0) return isUpdated;

            var prop = new DAL.Property
            {
                LastUpdatedOn = property.LastUpdatedOn,
                IsActive = property.IsActive,
                LastUpdatedBy = property.LastUpdatedBy,
                PropertyName = property.PropertyName,
                SecondaryName = property.SecondaryName,
                PropertyCode = property.PropertyCode,
                FullAddress = property.FullAddress,
                Phone = property.Phone,
                Fax = property.Fax,
                LogoPath = property.LogoPath,
                WebSiteAddress = property.WebSiteAddress,
                TimeZone = property.TimeZone,
                CheckinTime = property.CheckinTime,
                CheckoutTime = property.CheckoutTime,
                CloseOfDayTime = property.CloseOfDayTime,
                CurrencyId = property.CurrencyID,
                ID = property.Id,
                CreatedBy = property.CreatedBy,
                CreatedOn = property.CreatedOn,
                PropertyDetails = property.PropertyDetails,
                Zipcode = property.Zipcode,
                City = property.City.Id,
                Country = property.Country.Id,
                State = property.State.Id
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Entry(prop).State = System.Data.Entity.EntityState.Modified;
                var result = pmsContext.SaveChanges();
                isUpdated = result == 1 ? true : false;
            }
            return isUpdated;
        }
        public bool DeleteProperty(int propertyId)
        {
            var isDeleted = false;
            if (propertyId <= 0) return isDeleted;

            var prop = new DAL.Property
            {
                IsActive = false,
                ID = propertyId
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Properties.Attach(prop);
                pmsContext.Entry(prop).Property(x => x.IsActive).IsModified = true;
                var result = pmsContext.SaveChanges();
                isDeleted = result == 1 ? true : false;
            }
            return isDeleted;
        }
        public List<PmsEntity.Property> GetAllProperty()
        {
            var properties = new List<PmsEntity.Property>();

            using (var pmsContext = new PmsEntities())
            {
                properties = pmsContext.Properties
                             .Join(pmsContext.Countries, p => p.Country, c => c.ID,
                             (p, c) => new {p, c})
                             .Join(pmsContext.Cities, x => x.p.City, ct => ct.ID,
                             (x, ct) => new {x, ct})
                             .Join(pmsContext.States, s => s.x.p.State, k => k.ID,
                             (s, k) => new {s, k}).Where(l => l.s.x.p.IsActive)
                             .Select(m => new PmsEntity.Property
                             {
                                CreatedOn = m.s.x.p.CreatedOn,
                                PropertyName = m.s.x.p.PropertyName,
                                CreatedBy = m.s.x.p.CreatedBy,
                                LastUpdatedBy = m.s.x.p.LastUpdatedBy,
                                LastUpdatedOn = m.s.x.p.LastUpdatedOn,
                                Id = m.s.x.p.ID,
                                IsActive = m.s.x.p.IsActive,
                                CheckinTime = m.s.x.p.CheckinTime,
                                CheckoutTime = m.s.x.p.CheckoutTime,
                                CloseOfDayTime = m.s.x.p.CloseOfDayTime,
                                Zipcode = m.s.x.p.Zipcode,
                                Country = new PmsEntity.Country
                                {
                                    Name = m.s.x.c.Name,
                                    Id = m.s.x.c.ID
                                },
                                City = new PmsEntity.City
                                {
                                    Name = m.s.ct.Name,
                                    Id = m.s.ct.ID
                                },
                                State = new PmsEntity.State
                                {
                                    Name = m.k.Name,
                                    Id = m.k.ID
                                },
                                Fax = m.s.x.p.Fax,
                                FullAddress = m.s.x.p.FullAddress,
                                LogoPath = m.s.x.p.LogoPath,
                                Phone = m.s.x.p.Phone,
                                PropertyCode = m.s.x.p.PropertyCode,
                                PropertyDetails = m.s.x.p.PropertyDetails,
                                SecondaryName = m.s.x.p.SecondaryName,
                                TimeZone = m.s.x.p.TimeZone,
                                WebSiteAddress = m.s.x.p.WebSiteAddress,
                                CurrencyID = m.s.x.p.CurrencyId
                             }).ToList();
            }
            return properties;
        }
        public int AddPropertyType(PmsEntity.PropertyType propertyType)
        {
            var Id = -1;
            return Id;
        }
        public bool UpdatePropertyType(PmsEntity.PropertyType propertyType)
        {
            var isUpdated = false;
            return isUpdated;
        }
        public bool DeletePropertyType(int propertyTypeId)
        {
            var isDeleted = false;
            return isDeleted;
        }
        public List<PmsEntity.PropertyType> GetAllPropertyType()
        {
            var propertyTypes = new List<PmsEntity.PropertyType>();
            return propertyTypes;
        }
        public int AddRoom(List<PmsEntity.Room> room)
        {
            var Id = -1;
            if (room == null || room.Count <= 0) return Id;

            var roomObj = new DAL.Room
            {
                CreatedOn = room[0].CreatedOn,
                IsActive = true,
                CreatedBy = room[0].CreatedBy,
                PropertyID = room[0].Property.Id,
                Number = room[0].Number,
                RoomTypeID = room[0].RoomType.Id
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Rooms.Add(roomObj);
                var result = pmsContext.SaveChanges();
                Id = result == 1 ? roomObj.ID : -1;
            }

            return Id;
        }
        public bool UpdateRoom(PmsEntity.Room room)
        {
            var isUpdated = false;

            if (room == null) return isUpdated;

            var roomObj = new DAL.Room
            {
                LastUpdatedOn = room.LastUpdatedOn,
                IsActive = room.IsActive,
                LastUpdatedBy = room.LastUpdatedBy,
                ID = room.Id,
                CreatedBy = room.CreatedBy,
                CreatedOn = room.CreatedOn,
                PropertyID = room.Property.Id,
                Number = room.Number,
                RoomTypeID = room.RoomType.Id
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Entry(roomObj).State = System.Data.Entity.EntityState.Modified;
                var result = pmsContext.SaveChanges();
                isUpdated = result == 1 ? true : false;
            }
            return isUpdated;
        }
        public bool DeleteRoom(int roomId)
        {
            var isDeleted = false;
            if (roomId <= 0) return isDeleted;

            var room = new DAL.Room
            {
                IsActive = false,
                ID = roomId,
                PropertyID = 0,
                RoomTypeID = 0
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Rooms.Attach(room);
                pmsContext.Entry(room).Property(x => x.IsActive).IsModified = true;
                var result = pmsContext.SaveChanges();
                isDeleted = result == 1 ? true : false;
            }
            return isDeleted;
        }
        public List<PmsEntity.Room> GetRoomByProperty(int propertyId)
        {
            var rooms = new List<PmsEntity.Room>();
            using (var pmsContext = new PmsEntities())
            {
                rooms = pmsContext.Rooms.Where(x => x.IsActive && x.PropertyID == propertyId)
                                                 .Select(x => new PmsEntity.Room
                                                 {
                                                     CreatedOn = x.CreatedOn,
                                                     Number = x.Number,
                                                     CreatedBy = x.CreatedBy,
                                                     LastUpdatedBy = x.LastUpdatedBy,
                                                     LastUpdatedOn = x.LastUpdatedOn,
                                                     Id = x.ID,
                                                     Property = new PmsEntity.Property
                                                     {
                                                         Id = x.PropertyID
                                                     },
                                                     IsActive = x.IsActive,
                                                     RoomType = new PmsEntity.RoomType
                                                     {
                                                         Id = x.RoomTypeID
                                                     }
                                                 }).ToList();

            }
            return rooms;
        }
        public int AddRateType(PmsEntity.RateType rateType)
        {
            var Id = -1;
            if (rateType == null) return Id;

            var rateTypeObj = new DAL.RateType
            {
                CreatedOn = rateType.CreatedOn,
                IsActive = true,
                CreatedBy = rateType.CreatedBy,
                PropertyID = rateType.PropertyId,
                NAME = rateType.Name,
                Units = rateType.Units,
                Hours = rateType.Hours
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.RateTypes.Add(rateTypeObj);
                var result = pmsContext.SaveChanges();
                Id = result == 1 ? rateTypeObj.ID : -1;
            }
            return Id;
        }

        public bool UpdateRateType(PmsEntity.RateType rateType)
        {
            var isUpdated = false;
            if (rateType == null) return isUpdated;

            var rateTypeObj = new DAL.RateType
            {
                CreatedOn = rateType.CreatedOn,
                IsActive = true,
                CreatedBy = rateType.CreatedBy,
                PropertyID = rateType.PropertyId,
                NAME = rateType.Name,
                Units = rateType.Units,
                ID = rateType.Id,
                LastUpdatedBy = rateType.CreatedBy,
                LastUpdatedOn = rateType.LastUpdatedOn,
                Hours = rateType.Hours
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Entry(rateTypeObj).State = System.Data.Entity.EntityState.Modified;
                var result = pmsContext.SaveChanges();
                isUpdated = result == 1 ? true : false;
            }
            return isUpdated;
        }
        public bool DeleteRateType(int rateTypeId)
        {
            var isDeleted = false;
            if (rateTypeId <= 0) return isDeleted;

            var rateType = new DAL.RateType
            {
                IsActive = false,
                ID = rateTypeId
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.RateTypes.Attach(rateType);
                pmsContext.Entry(rateType).Property(x => x.IsActive).IsModified = true;
                var result = pmsContext.SaveChanges();
                isDeleted = result == 1 ? true : false;
            }
            return isDeleted;
        }
        public List<PmsEntity.RateType> GetRateTypeByProperty(int propertyId)
        {
            var rateTypes = new List<PmsEntity.RateType>();
            using (var pmsContext = new PmsEntities())
            {
                rateTypes = pmsContext.RateTypes.Where(x => x.IsActive && x.PropertyID == propertyId)
                                                 .Select(x => new PmsEntity.RateType
                                                 {
                                                     CreatedOn = x.CreatedOn,
                                                     Name = x.NAME,
                                                     CreatedBy = x.CreatedBy,
                                                     LastUpdatedBy = x.LastUpdatedBy,
                                                     LastUpdatedOn = x.LastUpdatedOn,
                                                     Id = x.ID,
                                                     PropertyId = x.PropertyID,
                                                     Units = x.Units,
                                                     Hours = x.Hours
                                                 }).ToList();

            }
            return rateTypes;
        }
        public int AddRoomType(PmsEntity.RoomType roomType)
        {
            var Id = -1;
            if (roomType == null) return Id;

            var roomtype = new DAL.RoomType
            {
                CreatedOn = roomType.CreatedOn,
                IsActive = true,
                CreatedBy = roomType.CreatedBy,
                PropertyID = roomType.PropertyId,
                NAME = roomType.Name,
                ShortName = roomType.ShortName
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.RoomTypes.Add(roomtype);
                var result = pmsContext.SaveChanges();
                Id = result == 1 ? roomtype.ID : -1;               
            }

            return Id;
        }
        public bool UpdateRoomType(PmsEntity.RoomType roomType)
        {
            var isUpdated = false;
            if (roomType == null) return isUpdated;

            var roomtype = new DAL.RoomType
            {
                LastUpdatedOn = roomType.LastUpdatedOn,
                IsActive = roomType.IsActive,
                LastUpdatedBy = roomType.LastUpdatedBy,
                PropertyID = roomType.PropertyId,
                NAME = roomType.Name,
                ShortName = roomType.ShortName,
                ID = roomType.Id,
                CreatedBy = roomType.CreatedBy,
                CreatedOn = roomType.CreatedOn
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Entry(roomtype).State = System.Data.Entity.EntityState.Modified;
                var result = pmsContext.SaveChanges();
                isUpdated = result == 1 ? true : false;
            }
           
            return isUpdated;
        }
        public bool DeleteRoomType(int roomTypeId)
        {
            var isDeleted = false;
            if (roomTypeId <= 0) return isDeleted;

            var roomtype = new DAL.RoomType
            {
                IsActive = false,
                ID = roomTypeId
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.RoomTypes.Attach(roomtype);
                pmsContext.Entry(roomtype).Property(x => x.IsActive).IsModified = true;
                var result = pmsContext.SaveChanges();
                isDeleted = result == 1 ? true : false;
            }
            return isDeleted;
        }
        public List<PmsEntity.RoomType> GetRoomTypeByProperty(int propertyId)
        {
            var roomTypes = new List<PmsEntity.RoomType>();
            using (var pmsContext = new PmsEntities())
            {
                roomTypes = pmsContext.RoomTypes.Where(x => x.IsActive && x.PropertyID == propertyId)
                                                 .Select(x => new PmsEntity.RoomType
                                                 {
                                                     CreatedOn = x.CreatedOn,
                                                     Name = x.NAME,
                                                     CreatedBy = x.CreatedBy,
                                                     LastUpdatedBy = x.LastUpdatedBy,
                                                     LastUpdatedOn = x.LastUpdatedOn,
                                                     Id = x.ID,
                                                     PropertyId = x.PropertyID,
                                                     ShortName = x.ShortName,
                                                     IsActive = x.IsActive
                                                 }).ToList();

            }

            return roomTypes;
        }
        public int AddRoomPrice(PmsEntity.RoomPricing roomPrice)
        {
            var Id = -1;
            return Id;
        }
        public bool UpdateRoomPrice(PmsEntity.RoomPricing roomPrice)
        {
            var isUpdated = false;
            return isUpdated;
        }
        public bool DeleteRoomPrice(int priceId)
        {
            var isDeleted = false;
            return isDeleted;
        }
        public List<PmsEntity.RoomPricing> GetRoomPriceByProperty(int propertyId)
        {
            var roomPricing = new List<PmsEntity.RoomPricing>();
            return roomPricing;
        }
        public int AddRoomStatus(PmsEntity.RoomStatus roomStatus)
        {
            var Id = -1;
            return Id;
        }
        public bool UpdateRoomStatus(PmsEntity.RoomStatus roomStatus)
        {
            var isUpdated = false;
            return isUpdated;
        }
        public bool DeleteRoomStatus(int statusId)
        {
            var isDeleted = false;
            return isDeleted;
        }
        public List<PmsEntity.RoomStatus> GetRoomStatus()
        {
            var roomStatus = new List<PmsEntity.RoomStatus>();
            return roomStatus;
        }
        public int AddReward(PmsEntity.GuestReward reward)
        {
            var Id = -1;
            return Id;
        }
        public bool UpdateReward(PmsEntity.GuestReward reward)
        {
            var isUpdated = false;
            return isUpdated;
        }
        public bool DeleteReward(int rewardId)
        {
            var isDeleted = false;
            return isDeleted;
        }
        public List<PmsEntity.GuestReward> GetAllReward()
        {
            var rewards = new List<PmsEntity.GuestReward>();
            return rewards;
        }
        public List<PmsEntity.GuestReward> GetRewardByGuestId(int guestId)
        {
            var rewards = new List<PmsEntity.GuestReward>();
            return rewards;
        }
        public int AddRewardCategory(PmsEntity.RewardCategory rewardCategory)
        {
            var Id = -1;
            return Id;
        }
        public bool UpdateRewardCategory(PmsEntity.RewardCategory rewardCategory)
        {
            var isUpdated = false;
            return isUpdated;
        }
        public bool DeleteRewardCategory(int catId)
        {
            var isDeleted = false;
            return isDeleted;
        }
        public List<PmsEntity.RewardCategory> GetAllRewardCategory()
        {
            var rewardCategory = new List<PmsEntity.RewardCategory>();
            return rewardCategory;
        }
        public List<PmsEntity.Room> GetRoomByDate(int propertyId, DateTime checkinDate, DateTime checkoutDate)
        {
            var rooms = new List<PmsEntity.Room>();
            using (var pmsContext = new PmsEntities())
            {
                var resultSet = pmsContext.GETROOMSTATUS(propertyId, checkinDate, checkoutDate).ToList();
                if (resultSet == null || resultSet.Count <= 0) return rooms;
                foreach (var result in resultSet)
                {
                    var room = new PmsEntity.Room();
                    room.RoomType = new PmsEntity.RoomType();
                    room.RoomStatus = new PmsEntity.RoomStatus();
                    room.Id = result.ID;
                    room.Number = result.NUMBER;
                    room.RoomType.Id = result.ROOMTypeID;
                    room.RoomStatus.Name = result.ROOMSTATUS;

                    rooms.Add(room);
                }
            }
            return rooms;
        }
        public List<PmsEntity.Booking> GetGuestHistory(int guestId)
        {
            var bookings = new List<PmsEntity.Booking>();

            using (var pmsContext = new PmsEntities())
            {
                var resultSet = pmsContext.GETGUESTTRANSACTIONS(guestId).ToList();
                if (resultSet == null || resultSet.Count <= 0) return bookings;
                foreach (var result in resultSet)
                {
                    var booking = new PmsEntity.Booking();
                    booking.CheckinTime = result.CheckinTime;
                    booking.CheckoutTime = result.CheckoutTime;
                    TimeSpan? ts = booking.CheckoutTime - booking.CheckinTime;
                    booking.DurationOfStay = ts.HasValue ? ts.Value.TotalHours : 0;
                    booking.RoomBookings = new List<PmsEntity.RoomBooking>
                    {
                        new PmsEntity.RoomBooking
                        { 
                            Room = new PmsEntity.Room
                            {
                                Number = result.ROOMNUMBER,
                                RoomType = new PmsEntity.RoomType
                                {
                                    Name = result.ROOMTYPE
                                },
                                Property = new PmsEntity.Property
                                {
                                   PropertyDetails = result.PROPERTY
                                }
                            }
                        }
                    };
                    bookings.Add(booking);
                }
            }
            return bookings;
        }
        public bool UpdateBooking(PmsEntity.Booking booking)
        {
            var isUpdated = false;
            using (var pmsContext = new PmsEntities())
            {
                var bookingId = new SqlParameter
                {
                    ParameterName = "BOOKINGID",
                    DbType = DbType.Int32,
                    Value = booking.Id
                };

                var dtCheckin = new SqlParameter
                {
                    ParameterName = "CHECKINTIME",
                    DbType = DbType.DateTime,
                    Value = booking.CheckinTime
                };

                var dtCheckout = new SqlParameter
                {
                    ParameterName = "CHECKOUTTIME",
                    DbType = DbType.DateTime,
                    Value = booking.CheckoutTime
                };

                var roomId = new SqlParameter
                {
                    ParameterName = "RoomID",
                    DbType = DbType.Int32,
                    Value = booking.RoomBookings[0].RoomId
                };

                var result = pmsContext.Database.ExecuteSqlCommand("UpdateBooking @BOOKINGID, @CHECKINTIME, @CHECKOUTTIME, @RoomID", bookingId, dtCheckin, dtCheckout, roomId);
                isUpdated = true;
            }
            return isUpdated;
        }

        public List<PmsEntity.State> GetStateByCountry(int id)
        {
            var states = new List<PmsEntity.State>();

            using (var pmsContext = new PmsEntities())
            {
                states = pmsContext.States.Where(x => x.IsActive)
                           .Select(x => new PmsEntity.State
                           {
                               Id = x.ID,
                               Name = x.Name,
                               CountryId = x.CountryID.Value
                           }).ToList();

            }
            if (id > 0)
            {
                states = states.Where(x => x.CountryId.Equals(id)).ToList();
            }
            return states;
        }

        public List<PmsEntity.City> GetCityByState(int id)
        {
            var city = new List<PmsEntity.City>();
            using (var pmsContext = new PmsEntities())
            {
                city = pmsContext.Cities.Where(x => x.IsActive)
                           .Select(x => new PmsEntity.City
                           {
                               Id = x.ID,
                               Name = x.Name,
                               StateId = x.StateID,
                               CountryId = x.CountryID
                           }).ToList();

            }
            if (id > 0)
            {
                city = city.Where(x => x.StateId.Equals(id)).ToList();
            }
            return city;
        }

        public List<PmsEntity.Country> GetCountry()
        {
            var country = new List<PmsEntity.Country>();
            using (var pmsContext = new PmsEntities())
            {
                country = pmsContext.Countries.Where(x => x.IsActive)
                           .Select(x => new PmsEntity.Country
                           {
                               Id = x.ID,
                               Name = x.Name
                           }).ToList();

            }
            return country;
        }
        public List<PmsEntity.Guest> GetAllGuest()
        {
            var guest = new List<PmsEntity.Guest>();
            using (var pmsContext = new PmsEntities())
            {
                guest = (from x in pmsContext.Guests
                         where x.IsActive
                         select new PmsEntity.Guest
                         {
                             Id = x.ID,
                             DOB = x.DOB,
                             EmailAddress = x.EmailAddress,
                             FirstName = x.FirstName,
                             Gender = x.Gender,
                             LastName = x.LastName,
                             MobileNumber = x.MobileNumber,
                             PhotoPath = x.PhotoPath,
                             GuestMappings = (from m in pmsContext.GuestMappings
                                              join i in pmsContext.IDTypes on m.IDTYPEID equals i.ID
                                              where m.IsActive && m.GUESTID == x.ID
                                              select new PmsEntity.GuestMapping
                                              {
                                                  Id = m.ID,
                                                  IDDETAILS = m.IDDETAILS,
                                                  IdType = new PmsEntity.IDType
                                                  {
                                                      ID = i.ID,
                                                      Name = i.Name
                                                  }
                                              }).ToList()

                         }).ToList();
            }
            return guest;
        }

        public List<PmsEntity.Tax> GetPaymentCharges(int? propertyId, int? roomTypeId, int? rateTypeId, int? noOfHours, bool? IsHourly)
        {
            var taxes = new List<PmsEntity.Tax>();
            using (var pmsContext = new PmsEntities())
            {
                var resultSet = pmsContext.GETBOOKINGAMOUNT(propertyId, roomTypeId, rateTypeId, noOfHours, 0, IsHourly).ToList();
                if (resultSet == null || resultSet.Count <= 0) return taxes;
                foreach (var result in resultSet.OrderBy(x => x.OrderBy))
                {
                    var tax = new PmsEntity.Tax();
                    tax.TaxName = result.ITEM;
                    tax.Value = result.ITEMAMOUNT;
                    tax.IsDefaultCharges = true;

                    taxes.Add(tax);
                }
            }
            return taxes;
        }

        public int AddInvoice(int propertyId, string invoiceXml)
        {
            var id = -1;
            using (var pmsContext = new PmsEntities())
            {
                var propId = new SqlParameter
                {
                    ParameterName = "propertyID",
                    DbType = DbType.Int32,
                    Value = propertyId
                };

                var invoicexml = new SqlParameter
                {
                    ParameterName = "InvoiceXML",
                    DbType = DbType.Xml,
                    Value = invoiceXml
                };

                var invoiceId = new SqlParameter
                {
                    ParameterName = "INVOICEID",
                    DbType = DbType.Int32,
                    Direction = ParameterDirection.Output
                };

                pmsContext.Database.ExecuteSqlCommand("InsertInvoice @propertyID, @InvoiceXML, @INVOICEID OUTPUT", propId, invoicexml, invoiceId);
                id = Convert.ToInt32(invoiceId.Value);

            }
            return id;
        }

        public PmsEntity.Invoice GetInvoiceById(int invoiceId)
        {
            var invoice = new PmsEntity.Invoice();
            var taxes = new List<PmsEntity.Tax>();
            var paymentDetails = new List<PmsEntity.InvoicePaymentDetail>();
            using (var pmsContext = new PmsEntities())
            {
                var resultSet = pmsContext.GETINVOICEDETAILS(invoiceId).ToList();
                if (resultSet == null || resultSet.Count <= 0) return invoice;

                var distinctBaseRoomCharge = resultSet.AsEnumerable()
                       .Select(row => new
                       {
                           ItemName = row.ItemName,
                           ItemValue = row.ItemValue
                       })
                       .Where(x => x.ItemName.Equals("ROOM CHARGES"))
                       .Distinct().ToList();

                if (distinctBaseRoomCharge != null && distinctBaseRoomCharge.Count > 0)
                {
                    foreach (var basecharge in distinctBaseRoomCharge)
                    {
                        taxes.Add(new PmsEntity.Tax { TaxName = basecharge.ItemName, Value = basecharge.ItemValue, IsDefaultCharges = true });
                    }
                }

                var distinctTaxValues = resultSet.AsEnumerable()
                        .Select(row => new
                        {
                            TaxName = row.TaxShortName,
                            TaxValue = row.TaxAmount
                        })
                        .Distinct().ToList();

                if (distinctTaxValues != null && distinctTaxValues.Count > 0)
                {
                    foreach (var tax in distinctTaxValues)
                    {
                        taxes.Add(new PmsEntity.Tax { TaxName = tax.TaxName, Value = tax.TaxValue, IsDefaultCharges = true });
                    }
                }

                // default charges
                var distinctTotalRoomCharge = resultSet.AsEnumerable()
                       .Select(row => new
                       {
                           ItemName = row.ItemName,
                           ItemValue = row.ItemValue
                       })
                       .Where(x => x.ItemName.Equals("Total Room Charge"))
                       .Distinct().ToList();

                if (distinctTotalRoomCharge != null && distinctTotalRoomCharge.Count > 0)
                {
                    foreach (var totalcharge in distinctTotalRoomCharge)
                    {
                        taxes.Add(new PmsEntity.Tax { TaxName = totalcharge.ItemName, Value = totalcharge.ItemValue, IsDefaultCharges = true });
                    }
                }

                var distinctItemValues = resultSet.AsEnumerable()
                        .Select(row => new
                        {
                            ItemName = row.ItemName,
                            ItemValue = row.ItemValue
                        })
                        .Where(x => !x.ItemName.Equals("ROOM CHARGES") && !x.ItemName.Equals("Total Room Charge"))
                        .Distinct().ToList();

                if (distinctItemValues != null && distinctItemValues.Count > 0)
                {
                    foreach (var tax in distinctItemValues)
                    {
                        // user defined charges
                        taxes.Add(new PmsEntity.Tax { TaxName = tax.ItemName, Value = tax.ItemValue, IsDefaultCharges = false });
                    }
                }

                var distinctPaymentValues = resultSet.AsEnumerable()
                        .Select(row => new
                        {
                            Detail = row.PaymentDetails,
                            Mode = row.PaymentMode,
                            Value = row.PaymentValue
                        })
                        .Distinct().ToList();

                if (distinctPaymentValues != null && distinctPaymentValues.Count > 0)
                {
                    foreach (var payment in distinctPaymentValues)
                    {
                        paymentDetails.Add(new PmsEntity.InvoicePaymentDetail { PaymentDetails = payment.Detail, PaymentValue = payment.Value, PaymentMode = payment.Mode });
                    }
                }

                var distinctOtherCharges = resultSet.AsEnumerable()
                        .Select(row => new
                        {
                            Discount = row.DISCOUNT,
                            TotalAmt = row.TotalAmount,
                            BookingId = row.BookingID,
                            InvoiceId = row.InvoiceId,
                        })
                        .Distinct().ToList();

                if (distinctOtherCharges != null && distinctOtherCharges.Count > 0)
                {
                    foreach (var otherCharges in distinctOtherCharges)
                    {
                        invoice.Discount = otherCharges.Discount;
                        invoice.TotalAmount = otherCharges.TotalAmt;
                        invoice.BookingId = otherCharges.BookingId;
                        invoice.Id = otherCharges.InvoiceId;
                    }
                }
            }

            invoice.Tax = taxes;
            invoice.InvoicePaymentDetails = paymentDetails;
            return invoice;
        }

        public PmsEntity.Booking GetBookingById(int bookingId)
        {
            var booking = new PmsEntity.Booking();
            booking.RoomBookings = new List<PmsEntity.RoomBooking>();
            booking.Guests = new List<PmsEntity.Guest>();
            booking.AdditionalGuests = new List<PmsEntity.AdditionalGuest>();
            booking.Addresses = new List<PmsEntity.Address>();
            booking.GuestMappings = new List<PmsEntity.GuestMapping>();
            booking.Invoice = new PmsEntity.Invoice();

            var roomBookings = new List<PmsEntity.RoomBooking>();
            var guests = new List<PmsEntity.Guest>();
            var addresses = new List<PmsEntity.Address>();
            var guestMappings = new List<PmsEntity.GuestMapping>();
            var additionalGuests = new List<PmsEntity.AdditionalGuest>();

            using (var pmsContext = new PmsEntities())
            {
                var resultSet = pmsContext.GetBookingDetails(bookingId).ToList();
                if (resultSet == null || resultSet.Count <= 0) return booking;

                //Populate Booking Object

                var bookingInformation = resultSet.FirstOrDefault();
                if (bookingInformation == null) return booking;

                booking.Id = bookingInformation.BookingID;
                booking.CheckinTime = bookingInformation.CheckinTime;
                booking.CheckoutTime = bookingInformation.CheckoutTime;
                booking.NoOfAdult = bookingInformation.NoOfAdult;
                booking.NoOfChild = bookingInformation.NoOfChild;
                booking.GuestRemarks = bookingInformation.GuestRemarks;
                booking.TransactionRemarks = bookingInformation.TransactionRemarks;
                booking.IsActive = bookingInformation.IsActive;
                booking.ISHOURLYCHECKIN = bookingInformation.ISHOURLYCHECKIN;
                booking.HOURSTOSTAY = bookingInformation.HOURSTOSTAY;
                booking.CreatedBy = bookingInformation.CreatedBy;
                booking.CreatedOn = bookingInformation.CreatedOn;
                booking.LastUpdatedBy = bookingInformation.LastUpdatedBy;
                booking.LastUpdatedOn = bookingInformation.LastUpdatedOn;
                booking.Status = bookingInformation.Status;
                booking.Invoice.Id = bookingInformation.InvoiceId.HasValue ? Convert.ToInt32(bookingInformation.InvoiceId) : -1;

                //Populate RoomBooking
                var distinctRoomBookings = resultSet.AsEnumerable()
                        .Select(row => new
                        {
                            RoomID = (row.RoomBookingRoomId.HasValue) ? row.RoomBookingRoomId.Value : default(int),
                            ID = (row.RoomBookingID.HasValue) ? row.RoomBookingID.Value : default(int),
                            GuestID = (row.RoomBookingGuestID.HasValue) ? row.RoomBookingGuestID.Value : default(int),
                            RoomTypeId = (row.RoomTypeID.HasValue) ? row.RoomTypeID.Value : default(int),
                            RoomTypeName = row.RoomTypeName,
                            RoomNumber = row.RoomNumber
                        })
                        .Distinct().ToList();

                if (distinctRoomBookings != null && distinctRoomBookings.Count > 0)
                {
                    foreach (var roomBooking in distinctRoomBookings)
                    {
                        booking.RoomBookings.Add(new PmsEntity.RoomBooking { Id = roomBooking.ID, GuestID = roomBooking.GuestID, Room = new PmsEntity.Room { Id = roomBooking.RoomID, Number = roomBooking.RoomNumber, RoomType = new PmsEntity.RoomType { Name = roomBooking.RoomTypeName, Id = roomBooking.RoomTypeId } } });
                    }
                }


                //Populate Additional Guests
                var distinctAdditionalGuests = resultSet.AsEnumerable()
                    .Select(row => new
                    {
                        FirstName = row.AdditionalGuestFirstName,
                        LastName = row.AdditionalGuestLastName,
                        GUESTIDPath = row.AdditionalGuestIDPath,
                        Gender = row.AdditionalGuestGender,
                        Id = (row.AdditionalGuestID.HasValue) ? row.AdditionalGuestID.Value : default(int)
                    })
                    .Distinct().ToList();

                if (distinctAdditionalGuests != null && distinctAdditionalGuests.Count > 0)
                {
                    foreach (var additionalGuest in distinctAdditionalGuests)
                    {
                        booking.AdditionalGuests.Add(new PmsEntity.AdditionalGuest { FirstName = additionalGuest.FirstName, LastName = additionalGuest.LastName, Gender = additionalGuest.Gender, GUESTIDPath = additionalGuest.GUESTIDPath, Id = additionalGuest.Id, BookingId = booking.Id });
                    }
                }


                //Populate GuestsMapping
                var distinctGuestsMapping = resultSet.AsEnumerable()
                    .Select(row => new
                    {
                        IDTYPEID = (row.IDTYPEID.HasValue) ? row.IDTYPEID.Value : default(int),
                        GUESTID = (row.GuestMappingGuestID.HasValue) ? row.GuestMappingGuestID.Value : default(int),
                        IDDETAILS = row.GuestMappingIDDETAILS,
                        IdExpiryDate = row.IDExpiryDate,
                        IdIssueState = row.IDIssueState,
                        IdIssueCountry = row.IDIssueCountry,
                        Id = (row.GuestMappingId.HasValue) ? row.GuestMappingId.Value : default(int)
                    }).Distinct().ToList();

                if (distinctGuestsMapping != null && distinctGuestsMapping.Count > 0)
                {
                    foreach (var guestMapping in distinctGuestsMapping)
                    {
                        booking.GuestMappings.Add(new PmsEntity.GuestMapping { Id = guestMapping.Id, IDTYPEID = guestMapping.IDTYPEID, GUESTID = guestMapping.GUESTID, IDDETAILS = guestMapping.IDDETAILS, IdExpiryDate = guestMapping.IdExpiryDate.Value, IdIssueState = guestMapping.IdIssueState, IdIssueCountry = guestMapping.IdIssueCountry });
                    }
                }


                //Populate Guests
                var distinctGuests = resultSet.AsEnumerable()
                    .Select(row => new
                    {
                        GuestID = (row.GuestID.HasValue) ? row.GuestID.Value : default(int),
                        FirstName = row.FirstName,
                        LastName = row.LastName,
                        MobileNumber = row.MobileNumber,
                        EmailAddress = row.EmailAddress,
                        DOB = row.DOB,
                        PhotoPath = row.PhotoPath,
                        Gender = row.Gender
                    }).Distinct().ToList();

                if (distinctGuests != null && distinctGuests.Count > 0)
                {
                    foreach (var guest in distinctGuests)
                    {
                        booking.Guests.Add(new PmsEntity.Guest { Id = guest.GuestID, FirstName = guest.FirstName, LastName = guest.LastName, MobileNumber = guest.MobileNumber, EmailAddress = guest.EmailAddress, DOB = guest.DOB, PhotoPath = guest.PhotoPath, Gender = guest.Gender });
                    }
                }

                //Populate Address
                var distinctAddress = resultSet.AsEnumerable()
                    .Select(row => new
                    {
                        AddressId = (row.AddressID.HasValue) ? row.AddressID.Value : default(int),
                        AddressTypeId = (row.AddressTypeID.HasValue) ? row.AddressTypeID.Value : default(int),
                        Address1 = row.Address1,
                        Address2 = row.Address2,
                        City = row.AddressCity,
                        State = row.AddressState,
                        Zipcode = row.AddressZipCode,
                        Country = row.AddressCountry
                    }).Distinct().ToList();

                if (distinctAddress != null && distinctAddress.Count > 0)
                {
                    foreach (var address in distinctAddress)
                    {
                        booking.Addresses.Add(new PmsEntity.Address { Id = address.AddressId, Address1 = address.Address1, Address2 = address.Address2, City = address.City, State = address.State, Country = address.Country, ZipCode = address.Zipcode, AddressTypeID = address.AddressTypeId });
                    }
                }

                return booking;
            }
        }

        public int AddPaymentType(PmsEntity.PaymentType paymentType)
        {
            var Id = -1;
            if (paymentType == null) return Id;

            var paymenttype = new DAL.PaymentType
            {
                CreatedOn = paymentType.CreatedOn,
                IsActive = true,
                CreatedBy = paymentType.CreatedBy,
                PropertyID = paymentType.PropertyId,
                ShortName = paymentType.ShortName,
                Description = paymentType.Description
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.PaymentTypes.Add(paymenttype);
                var result = pmsContext.SaveChanges();
                Id = result == 1 ? paymenttype.ID : -1;
            }

            return Id;
        }

        public bool UpdatePaymentType(PmsEntity.PaymentType paymentType)
        {
            var isUpdated = false;
            if (paymentType == null) return isUpdated;

            var paymenttype = new DAL.PaymentType
            {
                LastUpdatedOn = paymentType.LastUpdatedOn,
                IsActive = paymentType.IsActive,
                LastUpdatedBy = paymentType.LastUpdatedBy,
                PropertyID = paymentType.PropertyId,
                Description = paymentType.Description,
                ShortName = paymentType.ShortName,
                ID = paymentType.Id,
                CreatedBy = paymentType.CreatedBy,
                CreatedOn = paymentType.CreatedOn
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Entry(paymenttype).State = System.Data.Entity.EntityState.Modified;
                var result = pmsContext.SaveChanges();
                isUpdated = result == 1 ? true : false;
            }

            return isUpdated;
        }

        public bool DeletePaymentType(int paymentTypeId)
        {
            var isDeleted = false;
            if (paymentTypeId <= 0) return isDeleted;

            var paymenttype = new DAL.PaymentType
            {
                IsActive = false,
                ID = paymentTypeId
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.PaymentTypes.Attach(paymenttype);
                pmsContext.Entry(paymenttype).Property(x => x.IsActive).IsModified = true;
                var result = pmsContext.SaveChanges();
                isDeleted = result == 1 ? true : false;
            }
            return isDeleted;
        }

        public List<PmsEntity.PaymentType> GetPaymentTypeByProperty(int propertyId)
        {
            var paymentTypes = new List<PmsEntity.PaymentType>();
            using (var pmsContext = new PmsEntities())
            {
                paymentTypes = pmsContext.PaymentTypes.Where(x => x.PropertyID == propertyId && x.IsActive)
                                                 .Select(x => new PmsEntity.PaymentType
                                                 {
                                                     CreatedOn = x.CreatedOn,
                                                     Description = x.Description,
                                                     CreatedBy = x.CreatedBy,
                                                     LastUpdatedBy = x.LastUpdatedBy,
                                                     LastUpdatedOn = x.LastUpdatedOn,
                                                     Id = x.ID,
                                                     PropertyId = x.PropertyID,
                                                     ShortName = x.ShortName,
                                                     IsActive = x.IsActive
                                                 }).ToList();

            }

            return paymentTypes;

        }
        
        public int AddFloor(PmsEntity.PropertyFloor propertyFloor)
        {
            var Id = -1;
            if (propertyFloor == null) return Id;

            var propertyFloorObj = new DAL.PropertyFloor
            {
                CreatedOn = propertyFloor.CreatedOn,
                IsActive = true,
                CreatedBy = propertyFloor.CreatedBy,
                PropertyId = propertyFloor.PropertyId,
                FloorNumber = propertyFloor.FloorNumber,
                LastUpdatedBy = propertyFloor.CreatedBy,
                LastUpdatedOn = propertyFloor.LastUpdatedOn
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.PropertyFloors.Add(propertyFloorObj);
                var result = pmsContext.SaveChanges();
                Id = result == 1 ? propertyFloorObj.ID : -1;
            }
            return Id;
        }

        public bool UpdateFloor(PmsEntity.PropertyFloor propertyFloor)
        {
            var isUpdated = false;
            if (propertyFloor == null) return isUpdated;

            var propertyFloorObj = new DAL.PropertyFloor
            {
                LastUpdatedOn = propertyFloor.LastUpdatedOn,
                IsActive = propertyFloor.IsActive,
                LastUpdatedBy = propertyFloor.LastUpdatedBy,
                PropertyId = propertyFloor.PropertyId,
                FloorNumber = propertyFloor.FloorNumber,
                ID = propertyFloor.Id,
                CreatedBy = propertyFloor.CreatedBy,
                CreatedOn = propertyFloor.CreatedOn
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Entry(propertyFloorObj).State = System.Data.Entity.EntityState.Modified;
                var result = pmsContext.SaveChanges();
                isUpdated = result == 1 ? true : false;
            }

            return isUpdated;
        }

        public bool DeleteFloor(int propertyFloorId)
        {
            var isDeleted = false;
            if (propertyFloorId <= 0) return isDeleted;

            var propertyFloorObj = new DAL.PropertyFloor
            {
                IsActive = false,
                ID = propertyFloorId
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.PropertyFloors.Attach(propertyFloorObj);
                pmsContext.Entry(propertyFloorObj).Property(x => x.IsActive).IsModified = true;
                var result = pmsContext.SaveChanges();
                isDeleted = result == 1 ? true : false;
            }
            return isDeleted;
        }

        public List<PmsEntity.PropertyFloor> GetFloorsByProperty(int propertyId)
        {
            var propertyFloors = new List<PmsEntity.PropertyFloor>();
            using (var pmsContext = new PmsEntities())
            {
                propertyFloors = pmsContext.PropertyFloors.Where(x => x.PropertyId == propertyId && x.IsActive)
                                                 .Select(x => new PmsEntity.PropertyFloor
                                                 {
                                                     CreatedOn = x.CreatedOn,
                                                     CreatedBy = x.CreatedBy,
                                                     LastUpdatedBy = x.LastUpdatedBy,
                                                     LastUpdatedOn = x.LastUpdatedOn,
                                                     Id = x.ID,
                                                     PropertyId = x.PropertyId,
                                                     FloorNumber = x.FloorNumber,
                                                     IsActive = x.IsActive
                                                 }).ToList();

            }

            return propertyFloors;

        }


        public int AddExtraCharge(PmsEntity.ExtraCharge extraCharge)
        {
            var Id = -1;
            if (extraCharge == null) return Id;

            var extrachargesObj = new DAL.ExtraCharge
            {
                CreatedOn = extraCharge.CreatedOn,
                IsActive = true,
                CreatedBy = extraCharge.CreatedBy,
                PropertyID = extraCharge.PropertyId,
                FacilityName = extraCharge.FacilityName,
                Value = extraCharge.Value,
                LastUpdatedBy = extraCharge.CreatedBy,
                LastUpdatedOn = extraCharge.LastUpdatedOn
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.ExtraCharges.Add(extrachargesObj);
                var result = pmsContext.SaveChanges();
                Id = result == 1 ? extrachargesObj.ID : -1;
            }
            return Id;
        }

        public bool UpdateExtraCharge(PmsEntity.ExtraCharge extraCharge)
        {
            var isUpdated = false;
            if (extraCharge == null) return isUpdated;

            var extraChargeObj = new DAL.ExtraCharge
            {
                CreatedOn = extraCharge.CreatedOn,
                IsActive = true,
                CreatedBy = extraCharge.CreatedBy,
                PropertyID = extraCharge.PropertyId,
                FacilityName = extraCharge.FacilityName,
                Value = extraCharge.Value,
                ID = extraCharge.Id,
                LastUpdatedBy = extraCharge.CreatedBy,
                LastUpdatedOn = extraCharge.LastUpdatedOn
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Entry(extraChargeObj).State = System.Data.Entity.EntityState.Modified;
                var result = pmsContext.SaveChanges();
                isUpdated = result == 1 ? true : false;
            }

            return isUpdated;
        }

        public bool DeleteExtraCharge(int extraChargeId)
        {
            var isDeleted = false;
            if (extraChargeId <= 0) return isDeleted;

            var extraChargeObj = new DAL.ExtraCharge
            {
                IsActive = false,
                ID = extraChargeId,
                FacilityName = string.Empty
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.ExtraCharges.Attach(extraChargeObj);
                pmsContext.Entry(extraChargeObj).Property(x => x.IsActive).IsModified = true;
                var result = pmsContext.SaveChanges();
                isDeleted = result == 1 ? true : false;
            }
            return isDeleted;
        }

        public List<PmsEntity.ExtraCharge> GetExtraCharges(int propertyId)
        {
            var extraCharges = new List<PmsEntity.ExtraCharge>();
            using (var pmsContext = new PmsEntities())
            {
                extraCharges = pmsContext.ExtraCharges.Where(x => x.PropertyID == propertyId && x.IsActive)
                                                 .Select(x => new PmsEntity.ExtraCharge
                                                 {
                                                     CreatedOn = x.CreatedOn,
                                                     CreatedBy = x.CreatedBy,
                                                     LastUpdatedBy = x.LastUpdatedBy,
                                                     LastUpdatedOn = x.LastUpdatedOn,
                                                     Id = x.ID,
                                                     PropertyId = x.PropertyID,
                                                     Value = x.Value,
                                                     FacilityName = x.FacilityName,
                                                     IsActive = x.IsActive
                                                 }).ToList();

            }

            return extraCharges;
        }

        public int AddTax(PmsEntity.Tax tax)
        {
            var Id = -1;
            if (tax == null) return Id;

            var taxsObj = new DAL.Tax
            {
                CreatedOn = tax.CreatedOn,
                IsActive = true,
                CreatedBy = tax.CreatedBy,
                PropertyID = tax.PropertyId,
                TaxName = tax.TaxName,
                Value = tax.Value
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Taxes.Add(taxsObj);
                var result = pmsContext.SaveChanges();
                Id = result == 1 ? taxsObj.ID : -1;
            }
            return Id;
        }

        public bool UpdateTax(PmsEntity.Tax tax)
        {
            var isUpdated = false;
            if (tax == null) return isUpdated;

            var taxObj = new DAL.Tax
            {
                CreatedOn = tax.CreatedOn,
                IsActive = true,
                CreatedBy = tax.CreatedBy,
                PropertyID = tax.PropertyId,
                TaxName = tax.TaxName,
                Value = tax.Value,
                ID = tax.Id,
                LastUpdatedBy = tax.CreatedBy,
                LastUpdatedOn = tax.LastUpdatedOn
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Entry(taxObj).State = System.Data.Entity.EntityState.Modified;
                var result = pmsContext.SaveChanges();
                isUpdated = result == 1 ? true : false;
            }

            return isUpdated;
        }

        public bool DeleteTax(int taxId)
        {
            var isDeleted = false;
            if (taxId <= 0) return isDeleted;

            var taxObj = new DAL.Tax
            {
                IsActive = false,
                ID = taxId
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Taxes.Attach(taxObj);
                pmsContext.Entry(taxObj).Property(x => x.IsActive).IsModified = true;
                var result = pmsContext.SaveChanges();
                isDeleted = result == 1 ? true : false;
            }
            return isDeleted;
        }

        public List<PmsEntity.Tax> GetTaxByProperty(int propertyId)
        {
            var taxes = new List<PmsEntity.Tax>();
            using (var pmsContext = new PmsEntities())
            {
                taxes = pmsContext.Taxes.Where(x => x.PropertyID == propertyId && x.IsActive)
                                                 .Select(x => new PmsEntity.Tax
                                                 {
                                                     CreatedOn = x.CreatedOn,
                                                     CreatedBy = x.CreatedBy,
                                                     LastUpdatedBy = x.LastUpdatedBy,
                                                     LastUpdatedOn = x.LastUpdatedOn,
                                                     Id = x.ID,
                                                     PropertyId = x.PropertyID,
                                                     Value = x.Value,
                                                     TaxName = x.TaxName,
                                                     IsActive = x.IsActive
                                                 }).ToList();

            }

            return taxes;
        }

        public List<PmsEntity.Rate> c(int propertyId)
        {
            var rates = new List<PmsEntity.Rate>();
            using (var pmsContext = new PmsEntities())
            {
                var resultSet = pmsContext.GetRoomRates(propertyId).ToList();
                if (resultSet == null || resultSet.Count <= 0) return rates;
                foreach(var result in resultSet)
                {
                    var rate = new PmsEntity.Rate();
                    rate.CreatedBy = result.CreatedBy;
                    rate.CreatedOn = result.CreatedOn;
                    rate.Id = result.ID;
                    rate.InputKeyHours = result.InputKeyHours;
                    rate.IsActive = result.IsActive;
                    rate.LastUpdatedBy = result.LastUpdatedBy;
                    rate.LastUpdatedOn = result.LastUpdatedOn;
                    rate.PropertyId = result.PropertyID;
                    rate.RateType = new PmsEntity.RateType
                    {
                        Id = result.RateTypeID.HasValue ? Convert.ToInt32(result.RateTypeID) : -1,
                        Name = result.RateTypeName
                    };
                    rate.RoomType = new PmsEntity.RoomType
                    {
                        Id = result.RoomTypeID.HasValue ? Convert.ToInt32(result.RoomTypeID) : -1,
                        Name = result.RoomTypeName
                    };
                    rate.Type = result.Type;
                    rate.Value = result.Value;

                    rates.Add(rate);
                }
            }

            return rates;
        }
    }
}
