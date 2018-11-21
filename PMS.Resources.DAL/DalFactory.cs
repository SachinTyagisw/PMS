using PmsEntity = PMS.Resources.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PMS.Resources.Common.Converter;
using System.Data.SqlClient;
using System.Data;
using PMS.Resources.Entities;

namespace PMS.Resources.DAL
{
    public class DalFactory : IDalFactory
    {
        public void LogExceptionToDb(PmsEntity.ExceptionLog additionalExData)
        {
            throw new NotImplementedException();
        }
        public bool AddBooking(int propertyId, string bookingXml, ref int bookingId, ref int guestId, ref int roomBookingId)
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

                var roombookingid = new SqlParameter
                {
                    ParameterName = "ROOMBOOKINGID",
                    DbType = DbType.Int32,
                    Direction = ParameterDirection.Output
                };

                var result = pmsContext.Database.ExecuteSqlCommand("InsertBooking @propertyID, @bookingXML, @BOOKINGID OUTPUT, @GUESTID OUTPUT, @ROOMBOOKINGID OUTPUT", propId, roomBookingXml, bookingid, guestid, roombookingid);

                bookingId = Convert.ToInt32(bookingid.Value);
                guestId = Convert.ToInt32(guestid.Value);
                roomBookingId = Convert.ToInt32(roombookingid.Value);
                if (bookingId > 0 && guestId > 0 && roomBookingId > 0)
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
                    booking.Id = result.ID != null ? result.ID.Value : -1;
                    booking.CheckinTime = result.CHECKINTIME;
                    booking.CheckoutTime = result.CHECKOUTTIME;
                    booking.Status = result.Status;
                    booking.RoomBookings = new List<PmsEntity.RoomBooking>
                    {
                        new PmsEntity.RoomBooking
                        {
                            Id = result.ROOMBOOKINGID != null ? result.ROOMBOOKINGID.Value : -1,
                            Room = new PmsEntity.Room
                            {
                                Id = result.ROOMID != null ? result.ROOMID.Value : -1,
                                Number = result.ROOMNUMBER,
                                RoomStatus = new PmsEntity.RoomStatus
                                {
                                    Name = result.RoomStatus
                                },
                                RoomType = new PmsEntity.RoomType
                                {
                                    Name = result.RoomTypeName,
                                    Id = result.RoomTypeID != null ? result.RoomTypeID.Value : -1,
                                    ShortName = result.RoomTypeShortName
                                }
                            },
                            Guest = new PmsEntity.Guest
                            {
                                Id = result.GUESTID != null ? result.GUESTID.Value : -1,
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
                             (p, c) => new { p, c })
                             .Join(pmsContext.Cities, x => x.p.City, ct => ct.ID,
                             (x, ct) => new { x, ct })
                             .Join(pmsContext.States, s => s.x.p.State, k => k.ID,
                             (s, k) => new { s, k }).Where(l => l.s.x.p.IsActive)
                             .Join(pmsContext.UsersPropertyMappings, r => r.s.x.p.ID, n => n.PropertyID,
                             (r, n) => new { r, n })
                             .Select(m => new PmsEntity.Property
                             {
                                 CreatedOn = m.r.s.x.p.CreatedOn,
                                 PropertyName = m.r.s.x.p.PropertyName,
                                 CreatedBy = m.r.s.x.p.CreatedBy,
                                 LastUpdatedBy = m.r.s.x.p.LastUpdatedBy,
                                 LastUpdatedOn = m.r.s.x.p.LastUpdatedOn,
                                 Id = m.r.s.x.p.ID,
                                 IsActive = m.r.s.x.p.IsActive,
                                 CheckinTime = m.r.s.x.p.CheckinTime,
                                 CheckoutTime = m.r.s.x.p.CheckoutTime,
                                 CloseOfDayTime = m.r.s.x.p.CloseOfDayTime,
                                 Zipcode = m.r.s.x.p.Zipcode,
                                 UserId = m.n.UserID,
                                 Country = new PmsEntity.Country
                                 {
                                     Name = m.r.s.x.c.Name,
                                     Id = m.r.s.x.c.ID
                                 },
                                 City = new PmsEntity.City
                                 {
                                     Name = m.r.s.ct.Name,
                                     Id = m.r.s.ct.ID
                                 },
                                 State = new PmsEntity.State
                                 {
                                     Name = m.r.k.Name,
                                     Id = m.r.k.ID
                                 },
                                 Fax = m.r.s.x.p.Fax,
                                 FullAddress = m.r.s.x.p.FullAddress,
                                 LogoPath = m.r.s.x.p.LogoPath,
                                 Phone = m.r.s.x.p.Phone,
                                 PropertyCode = m.r.s.x.p.PropertyCode,
                                 PropertyDetails = m.r.s.x.p.PropertyDetails,
                                 SecondaryName = m.r.s.x.p.SecondaryName,
                                 TimeZone = m.r.s.x.p.TimeZone,
                                 WebSiteAddress = m.r.s.x.p.WebSiteAddress,
                                 CurrencyID = m.r.s.x.p.CurrencyId
                             }).ToList();
            }
            return properties;
        }

        public List<PmsEntity.Property> GetPropertyForAccess()
        {
            var properties = new List<PmsEntity.Property>();

            using (var pmsContext = new PmsEntities())
            {
                properties = pmsContext.Properties
                             .Where(p => p.IsActive)
                             .Select(m => new PmsEntity.Property
                             {
                                 CreatedOn = m.CreatedOn,
                                 PropertyName = m.PropertyName,
                                 CreatedBy = m.CreatedBy,
                                 LastUpdatedBy = m.LastUpdatedBy,
                                 LastUpdatedOn = m.LastUpdatedOn,
                                 Id = m.ID,
                                 IsActive = m.IsActive,
                                 CheckinTime = m.CheckinTime,
                                 CheckoutTime = m.CheckoutTime,
                                 CloseOfDayTime = m.CloseOfDayTime,
                                 Zipcode = m.Zipcode,
                                 Fax = m.Fax,
                                 FullAddress = m.FullAddress,
                                 LogoPath = m.LogoPath,
                                 Phone = m.Phone,
                                 PropertyCode = m.PropertyCode,
                                 PropertyDetails = m.PropertyDetails,
                                 SecondaryName = m.SecondaryName,
                                 TimeZone = m.TimeZone,
                                 WebSiteAddress = m.WebSiteAddress,
                                 CurrencyID = m.CurrencyId
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
        public bool AddRoom(int propertyId, string roomXml)
        {
            return SaveRoom(propertyId, roomXml);
        }
        public bool UpdateRoom(int propertyId, string roomXml)
        {
            return SaveRoom(propertyId, roomXml);
        }

        private bool SaveRoom(int propertyId, string roomXml)
        {
            var isSaved = false;
            using (var pmsContext = new PmsEntities())
            {
                var propIdField = new SqlParameter
                {
                    ParameterName = "@propertyID",
                    DbType = DbType.Int32,
                    Value = propertyId
                };

                var roomXmlField = new SqlParameter
                {
                    ParameterName = "@RoomXML",
                    DbType = DbType.Xml,
                    Value = roomXml
                };
                try
                {
                    var result = pmsContext.Database.ExecuteSqlCommand("InsertRoom @propertyID, @RoomXML", propIdField, roomXmlField);
                    isSaved = true;
                }
                catch (Exception ex)
                {

                }
            }
            return isSaved;
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
                                        .Join(pmsContext.PropertyFloors, a => a.FloorId, f => f.ID,
                                        (a, f) => new { a, f })
                                        .Join(pmsContext.RoomTypes, i => i.a.RoomTypeID, r => r.ID,
                                        (i, r) => new { i, r })
                                        .Select(x => new PmsEntity.Room
                                        {
                                            CreatedOn = x.i.a.CreatedOn,
                                            Number = x.i.a.Number,
                                            CreatedBy = x.i.a.CreatedBy,
                                            LastUpdatedBy = x.i.a.LastUpdatedBy,
                                            LastUpdatedOn = x.i.a.LastUpdatedOn,
                                            Id = x.i.a.ID,
                                            Property = new PmsEntity.Property
                                            {
                                                Id = x.i.a.PropertyID
                                            },
                                            IsActive = x.i.a.IsActive,
                                            RoomType = new PmsEntity.RoomType
                                            {
                                                Id = x.r.ID,
                                                Name = x.r.NAME
                                            },
                                            Floor = new PmsEntity.PropertyFloor
                                            {
                                                Id = x.i.f.ID,
                                                FloorNumber = x.i.f.FloorNumber
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
        public bool UpdateRoomStatus(PmsEntity.Room room)
        {
            var isUpdated = false;
            if (room.Id <= 0) return isUpdated;

            var roomObj = new DAL.Room
            {
                ID = room.Id,
                LastUpdatedOn = DateTime.Now,
                STATUS = room.RoomStatus.Name,
                LastUpdatedBy = room.LastUpdatedBy
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Entry(roomObj).State = System.Data.Entity.EntityState.Modified;
                pmsContext.Entry(roomObj).Property(x => x.PropertyID).IsModified = false;
                pmsContext.Entry(roomObj).Property(x => x.RoomTypeID).IsModified = false;
                pmsContext.Entry(roomObj).Property(x => x.CreatedBy).IsModified = false;
                pmsContext.Entry(roomObj).Property(x => x.CreatedOn).IsModified = false;
                pmsContext.Entry(roomObj).Property(x => x.Number).IsModified = false;
                pmsContext.Entry(roomObj).Property(x => x.IsActive).IsModified = false;
                pmsContext.Entry(roomObj).Property(x => x.FloorId).IsModified = false;
                var result = pmsContext.SaveChanges();
                isUpdated = result == 1 ? true : false;
            }

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
        public List<PmsEntity.Room> GetRoomByDate(int propertyId, DateTime checkinDate, DateTime checkoutDate, int BookingId)
        {
            var rooms = new List<PmsEntity.Room>();
            using (var pmsContext = new PmsEntities())
            {
                var resultSet = pmsContext.GETROOMSTATUS(propertyId, checkinDate, checkoutDate, BookingId).ToList();
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
                    booking.Invoice = new PmsEntity.Invoice
                    {
                        TotalAmount = result.InvoiceAmount
                    };
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
                                   PropertyDetails = result.PROPERTYDETAILS,
                                   PropertyName = result.PropertyName
                                },
                                RateType = new PmsEntity.RateType
                                {
                                     Rates = new List<PmsEntity.Rate>
                                     {
                                        new PmsEntity.Rate
                                        {
                                            Value = result.ROOMCHARGE
                                        }
                                     }
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

        public int AddGuest(PmsEntity.Guest guest)
        {
            var Id = -1;
            if (guest == null) return Id;

            var addressE = new List<Address>();
            addressE.Add(new Address
            {
                Address1 = guest.Address1,
                Address2 = guest.Address2,
                City = guest.City.Name,
                Country = guest.Country.Name,
                CreatedBy = guest.CreatedBy,
                IsActive = true,
                CreatedOn = guest.CreatedOn,
                State = guest.State.Name,
                ZipCode = guest.ZipCode,
                GuestID = guest.Id,
                ID = guest.AddressId,
                AddressTypeID = 1
            });

            var guestE = new DAL.Guest
            {
                CreatedOn = guest.CreatedOn,
                IsActive = true,
                CreatedBy = guest.CreatedBy,
                DOB = guest.DOB,
                EmailAddress = guest.EmailAddress,
                FirstName = guest.FirstName,
                Gender = guest.Gender,
                ID = guest.Id,
                LastName = guest.LastName,
                MobileNumber = guest.MobileNumber,
                Addresses = addressE,
                PhotoPath = guest.PhotoPath
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Guests.Add(guestE);
                var result = pmsContext.SaveChanges();
                Id = result >= 1 ? guestE.ID : -1;
            }

            return Id;
        }

        public bool UpdateGuest(PmsEntity.Guest guest)
        {
            var isUpdated = false;
            if (guest == null) return isUpdated;
            var addressE = new Address
            {
                Address1 = guest.Address1,
                Address2 = guest.Address2,
                City = guest.City.Name,
                Country = guest.Country.Name,
                CreatedBy = guest.CreatedBy,
                IsActive = true,
                CreatedOn = guest.CreatedOn,
                State = guest.State.Name,
                ZipCode = guest.ZipCode,
                LastUpdatedOn = guest.LastUpdatedOn,
                LastUpdatedBy = guest.LastUpdatedBy,
                GuestID = guest.Id,
                ID = guest.AddressId,
                AddressTypeID = 1
            };
            var guestE = new DAL.Guest
            {
                CreatedOn = guest.CreatedOn,
                IsActive = true,
                CreatedBy = guest.CreatedBy,
                DOB = guest.DOB,
                EmailAddress = guest.EmailAddress,
                FirstName = guest.FirstName,
                Gender = guest.Gender,
                ID = guest.Id,
                LastName = guest.LastName,
                MobileNumber = guest.MobileNumber,
                PhotoPath = guest.PhotoPath,
                LastUpdatedBy = guest.LastUpdatedBy,
                LastUpdatedOn = guest.LastUpdatedOn
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Entry(guestE).State = System.Data.Entity.EntityState.Modified;
                pmsContext.Entry(addressE).State = System.Data.Entity.EntityState.Modified;
                var result = pmsContext.SaveChanges();
                isUpdated = result >= 1 ? true : false;
            }
            return isUpdated;
        }

        public bool DeleteGuest(int guestId)
        {
            var isDeleted = false;
            if (guestId <= 0) return isDeleted;

            var guest = new DAL.Guest
            {
                IsActive = false,
                ID = guestId
            };
            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Guests.Attach(guest);
                pmsContext.Entry(guest).Property(x => x.IsActive).IsModified = true;
                var result = pmsContext.SaveChanges();
                isDeleted = result == 1 ? true : false;
            }
            return isDeleted;
        }

        public List<PmsEntity.Guest> GetAllGuest()
        {
            var guest = new List<PmsEntity.Guest>();
            using (var pmsContext = new PmsEntities())
            {
                guest = (from x in pmsContext.Guests
                         join a in pmsContext.Addresses on x.ID equals a.GuestID
                         join i in pmsContext.Cities on a.City equals i.Name
                         join j in pmsContext.States on a.State equals j.Name
                         join k in pmsContext.Countries on a.Country equals k.Name
                         where x.IsActive
                         select new PmsEntity.Guest
                         {
                             Id = x.ID,
                             DOB = x.DOB,
                             EmailAddress = x.EmailAddress,
                             Address1 = a.Address1,
                             Address2 = a.Address2,
                             ZipCode = a.ZipCode,
                             City = new PmsEntity.City
                             {
                                 Name = i.Name,
                                 Id = i.ID
                             },
                             State = new PmsEntity.State
                             {
                                 Name = j.Name,
                                 Id = j.ID
                             },
                             Country = new PmsEntity.Country
                             {
                                 Name = k.Name,
                                 Id = k.ID
                             },
                             AddressId = a.ID,
                             FirstName = x.FirstName,
                             Gender = x.Gender,
                             LastName = x.LastName,
                             MobileNumber = x.MobileNumber,
                             PhotoPath = x.PhotoPath,
                             GuestMappings = (from m in pmsContext.GuestMappings
                                              join l in pmsContext.IDTypes on m.IDTYPEID equals l.ID
                                              join n in pmsContext.States on m.IdIssueState equals n.Name
                                              join o in pmsContext.Countries on m.IdIssueCountry equals o.Name
                                              where m.IsActive && m.GUESTID == x.ID
                                              select new PmsEntity.GuestMapping
                                              {
                                                  Id = m.ID,
                                                  IDDETAILS = m.IDDETAILS,
                                                  IdExpiryDate = m.IdExpiryDate,
                                                  IdIssueState = n.Name,
                                                  IdIssueStateID = n.ID,
                                                  IdIssueCountry = o.Name,
                                                  IdIssueCountryID = o.ID,
                                                  IdType = new PmsEntity.IDType
                                                  {
                                                      ID = l.ID,
                                                      Name = l.Name
                                                  }
                                              }).ToList()
                         }).ToList();
            }
            // to have records with distinct email id
            guest = guest.GroupBy(x => x.EmailAddress).Select(x => x.First()).ToList();
            return guest;
        }

        public List<PmsEntity.Guest> GetAllGuest(bool fullInfo)
        {
            var guest = new List<PmsEntity.Guest>();
            if (fullInfo)
            {
                guest = GetAllGuest();
            }
            else
            {
                using (var pmsContext = new PmsEntities())
                {
                    guest = (from x in pmsContext.Guests
                             join a in pmsContext.Addresses on x.ID equals a.GuestID
                             join i in pmsContext.Cities on a.City equals i.Name
                             join j in pmsContext.States on a.State equals j.Name
                             join k in pmsContext.Countries on a.Country equals k.Name
                             where x.IsActive
                             select new PmsEntity.Guest
                             {
                                 Id = x.ID,
                                 DOB = x.DOB,
                                 EmailAddress = x.EmailAddress,
                                 Address1 = a.Address1,
                                 Address2 = a.Address2,
                                 ZipCode = a.ZipCode,
                                 City = new PmsEntity.City
                                 {
                                     Name = i.Name,
                                     Id = i.ID
                                 },
                                 State = new PmsEntity.State
                                 {
                                     Name = j.Name,
                                     Id = j.ID
                                 },
                                 Country = new PmsEntity.Country
                                 {
                                     Name = k.Name,
                                     Id = k.ID
                                 },
                                 AddressId = a.ID,
                                 FirstName = x.FirstName,
                                 Gender = x.Gender,
                                 LastName = x.LastName,
                                 MobileNumber = x.MobileNumber,
                                 PhotoPath = x.PhotoPath,
                                 CreatedBy = x.CreatedBy,
                                 CreatedOn = x.CreatedOn,
                                 LastUpdatedBy = x.LastUpdatedBy,
                                 LastUpdatedOn = x.LastUpdatedOn,
                                 IsActive = x.IsActive
                             }).ToList();
                    // to have records with distinct email id
                    guest = guest.GroupBy(x => x.EmailAddress).Select(x => x.First()).ToList();
                }
            }
            return guest;
        }

        public List<PmsEntity.Tax> GetPaymentCharges(int? propertyId, int? roomTypeId, int? rateTypeId, int? noOfHours, bool? IsHourly, int? roomId)
        {
            var taxes = new List<PmsEntity.Tax>();
            using (var pmsContext = new PmsEntities())
            {
                var resultSet = pmsContext.GETBOOKINGAMOUNT(propertyId, roomTypeId, rateTypeId, noOfHours, 0, IsHourly, roomId).ToList();
                if (resultSet == null || resultSet.Count <= 0) return taxes;
                foreach (var result in resultSet.OrderBy(x => x.OrderBy))
                {
                    var tax = new PmsEntity.Tax();
                    tax.TaxName = result.ITEM;
                    tax.Value = result.ITEMAMOUNT;
                    tax.IsDefaultCharges = true;
                    tax.IsTaxIncluded = true;

                    taxes.Add(tax);
                    if (taxes != null && taxes[0].TaxName.Equals("ROOM CHARGES") && taxes.Count == 1)
                    {
                        var totalRoomCharge = new PmsEntity.Tax();
                        totalRoomCharge.TaxName = "Total Room Charge";
                        totalRoomCharge.Value = 0;
                        totalRoomCharge.IsDefaultCharges = true;
                        taxes.Add(totalRoomCharge);
                    }
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

        public PmsEntity.Invoice GetInvoiceById(int invoiceId, int? propertyId, int? roomTypeId, int? rateTypeId, int? noOfHours, int? noOfDays, bool? IsHourly, int? roomId)
        {
            var invoice = new PmsEntity.Invoice();
            var taxes = new List<PmsEntity.Tax>();
            var paymentDetails = new List<PmsEntity.InvoicePaymentDetail>();
            using (var pmsContext = new PmsEntities())
            {
                var resultSet = pmsContext.GETINVOICEDETAILS(invoiceId, propertyId, roomTypeId, rateTypeId, noOfHours, noOfDays, IsHourly, roomId).ToList();
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
                            ItemValue = row.ItemValue,
                            CreatedOn= row.InvoiceItemCreatedOn
                        })
                        .Where(x => !x.ItemName.Equals("ROOM CHARGES") && !x.ItemName.Equals("Total Room Charge"))
                        .Distinct().ToList();

                if (distinctItemValues != null && distinctItemValues.Count > 0)
                {
                    foreach (var tax in distinctItemValues)
                    {
                        // user defined charges
                        taxes.Add(new PmsEntity.Tax
                        {
                            TaxName = tax.ItemName,
                            Value = tax.ItemValue,
                            IsDefaultCharges = false,
                            CreatedOn = tax.CreatedOn
                        });
                    }
                }

                var distinctTaxValues = resultSet.AsEnumerable()
                        .Select(row => new
                        {
                            TaxName = row.TaxShortName,
                            TaxValue = row.TaxAmount,
                            IsTaxIncluded = row.IsConsidered.HasValue ? row.IsConsidered.Value : false,
                            Amount = row.TaxValue.HasValue ? row.TaxValue.Value : 0
                        })
                        .Distinct().ToList();

                if (distinctTaxValues != null && distinctTaxValues.Count > 0)
                {
                    foreach (var tax in distinctTaxValues)
                    {
                        taxes.Add(new PmsEntity.Tax
                        {
                            TaxName = tax.TaxName,
                            Value = tax.TaxValue,
                            IsDefaultCharges = true,
                            IsTaxIncluded = tax.IsTaxIncluded,
                            Amount = tax.Amount
                        });
                    }
                }

                var distinctPaymentValues = resultSet.AsEnumerable()
                        .Select(row => new
                        {
                            Detail = row.PaymentDetails,
                            Mode = row.PaymentMode,
                            Value = row.PaymentValue,
                            CreatedOn = row.InvoicePaymentCreatedOn
                        })
                        .Distinct().ToList();

                if (distinctPaymentValues != null && distinctPaymentValues.Count > 0)
                {
                    foreach (var payment in distinctPaymentValues)
                    {
                        if (payment.Mode == null) continue;
                        paymentDetails.Add(new PmsEntity.InvoicePaymentDetail
                        {
                            PaymentDetails = payment.Detail,
                            PaymentValue = payment.Value,
                            PaymentMode = payment.Mode,
                            CreatedOn = payment.CreatedOn
                        });
                    }
                }

                var distinctOtherCharges = resultSet.AsEnumerable()
                        .Select(row => new
                        {
                            DiscountPercent = row.DISCOUNT,
                            DiscountAmount = row.DISCOUNTAmount,
                            TotalAmt = row.TotalAmount,
                            BookingId = row.BookingID,
                            InvoiceId = row.InvoiceId,
                            CreditCardDetail = row.CreditCardDetail,
                            CreatedOn = row.CreatedOn,
                            CreateBy = row.CreatedBy,
                            LastUpdateOn = row.LastUpdatedOn,
                            LastUpdatedBy = row.LastUpdatedBy
                        })
                        .Distinct().ToList();

                if (distinctOtherCharges != null && distinctOtherCharges.Count > 0)
                {
                    foreach (var otherCharges in distinctOtherCharges)
                    {
                        invoice.DiscountPercent = otherCharges.DiscountPercent;
                        invoice.DiscountAmount = otherCharges.DiscountAmount;
                        invoice.TotalAmount = otherCharges.TotalAmt;
                        invoice.BookingId = otherCharges.BookingId;
                        invoice.Id = otherCharges.InvoiceId;
                        invoice.CreditCardDetail = otherCharges.CreditCardDetail;
                        invoice.CreatedOn = otherCharges.CreatedOn;
                        invoice.CreatedBy = otherCharges.CreateBy;
                        invoice.LastUpdatedOn = otherCharges.LastUpdateOn;
                        invoice.LastUpdatedBy = otherCharges.LastUpdatedBy;
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
            booking.RateType = new PmsEntity.RateType();

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
                booking.RateType.Name = bookingInformation.RateTypeName;
                booking.RateType.Id = bookingInformation.RateTypeId.HasValue ? Convert.ToInt32(bookingInformation.RateTypeId) : -1;

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
        public List<PmsEntity.RateType> GetRoomRateByProperty(int propertyId)
        {
            var rateTypes = new List<PmsEntity.RateType>();
            using (var pmsContext = new PmsEntities())
            {
                var resultSet = pmsContext.GetRoomRates(propertyId)
                                .GroupBy(a => a.MasterRateTypeID).ToList();

                if (resultSet == null || resultSet.Count <= 0) return rateTypes;
                foreach (var result in resultSet)
                {
                    if (result == null || result.ToList().Count <= 0 || !result.ToList()[0].RateTypeIsActive) continue;
                    var ratetype = new PmsEntity.RateType();
                    ratetype.Id = result.ToList()[0].MasterRateTypeID;
                    ratetype.Name = result.ToList()[0].RateTypeName;
                    ratetype.Hours = result.ToList()[0].Hours;
                    ratetype.IsActive = result.ToList()[0].RateTypeIsActive;
                    ratetype.Units = result.ToList()[0].Units;
                    ratetype.Rates = new List<PmsEntity.Rate>();
                    foreach (var value in result)
                    {
                        if (!value.IsActive.HasValue || !Convert.ToBoolean(value.IsActive)
                            || !value.RoomStatus.HasValue || !Convert.ToBoolean(value.RoomStatus)) continue;

                        var rate = new PmsEntity.Rate();
                        rate.CreatedBy = value.CreatedBy;
                        rate.CreatedOn = value.CreatedOn;
                        rate.Id = value.ID.HasValue ? Convert.ToInt32(value.ID) : -1;
                        rate.InputKeyHours = value.InputKeyHours;
                        rate.IsActive = value.IsActive;
                        rate.LastUpdatedBy = value.LastUpdatedBy;
                        rate.LastUpdatedOn = value.LastUpdatedOn;
                        rate.PropertyId = value.PropertyID;
                        rate.Room = new PmsEntity.Room
                        {
                            Id = value.RoomId.HasValue ? Convert.ToInt32(value.RoomId) : -1,
                            Number = value.RoomNumber,
                            Floor = new PmsEntity.PropertyFloor
                            {
                                FloorNumber = value.FloorNumber,
                                Id = value.FloorId.HasValue ? Convert.ToInt32(value.FloorId) : -1
                            },
                            RoomType = new PmsEntity.RoomType
                            {
                                Id = value.RoomTypeID.HasValue ? Convert.ToInt32(value.RoomTypeID) : -1,
                                Name = value.RoomTypeName
                            }
                        };
                        rate.Type = value.Type;
                        rate.Value = value.Value;

                        ratetype.Rates.Add(rate);
                    }
                    rateTypes.Add(ratetype);
                }
            }

            return rateTypes;
        }

        public bool AddRoomRate(int propertyId, string rateXml)
        {
            return SaveRoomRateIndDb(propertyId, rateXml);
        }
        public bool UpdateRoomRate(int propertyId, string rateXml)
        {
            return SaveRoomRateIndDb(propertyId, rateXml);
        }
        public bool DeleteRoomRate(int rateId)
        {
            var isDeleted = false;
            if (rateId <= 0) return isDeleted;

            var rate = new DAL.Rate
            {
                IsActive = false,
                ID = rateId
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Rates.Attach(rate);
                pmsContext.Entry(rate).Property(x => x.IsActive).IsModified = true;
                var result = pmsContext.SaveChanges();
                isDeleted = result == 1 ? true : false;
            }
            return isDeleted;
        }

        public List<PmsEntity.Booking> GetBookingTransaction(DateTime? startDate, DateTime? endDate, string guestName, string roomType, decimal? minAmountPaid, decimal? maxAmountPaid, string paymentMode, bool? transactionStatus, string propertyId, out List<BookingSummary> bookingSummary)
        {
            var bookings = new List<PmsEntity.Booking>();
            bookingSummary = new List<BookingSummary>();
            using (var pmsContext = new PmsEntities())
            {
                var resultSet = pmsContext.GetTransactionData(startDate, endDate, guestName, roomType, minAmountPaid, maxAmountPaid, paymentMode, transactionStatus, propertyId).ToList();
                if (resultSet == null || resultSet.Count <= 0) return bookings;
                foreach (var result in resultSet)
                {
                    var booking = new PmsEntity.Booking();
                    booking.Id = result.TransactionNumber;
                    booking.CheckinTime = result.TransactionDate;
                    booking.IsActive = result.Status;
                    booking.RateType = new PmsEntity.RateType
                    {
                        Rates = new List<PmsEntity.Rate>
                        {
                            new PmsEntity.Rate
                            {
                                Value = result.RoomRate
                            }
                        }
                    };
                    booking.Invoice = new PmsEntity.Invoice
                    {
                        TotalAmount = result.AmountPaid,
                        InvoicePaymentDetails = new List<PmsEntity.InvoicePaymentDetail>
                        {
                            new PmsEntity.InvoicePaymentDetail
                            {
                                PaymentMode = result.ModeOfPayment
                            }
                        },
                        InvoiceTaxDetails = new List<PmsEntity.InvoiceTaxDetail>
                        {
                            new PmsEntity.InvoiceTaxDetail
                            {
                                 TaxAmount = result.TaxCollected
                            }
                        }
                    };
                    booking.RoomBookings = new List<PmsEntity.RoomBooking>
                    {
                        new PmsEntity.RoomBooking
                        {
                            Room = new PmsEntity.Room
                            {
                                RoomType = new PmsEntity.RoomType
                                {
                                    Name = result.RoomType
                                }
                            },
                            Guest = new PmsEntity.Guest
                            {   
                                // GuestName include both fname and lname
                                FirstName = result.GuestName,
                            }
                        }
                    };
                    bookings.Add(booking);
                }
                if (resultSet != null && resultSet.Count > 0)
                {
                    bookingSummary = resultSet.GroupBy(result => result.Status).Select(summary => new BookingSummary
                    {
                        DateRange = startDate.HasValue ? startDate.ToString() : DateTime.MinValue.ToShortDateString() + " - " + (endDate.HasValue ? endDate.ToString() : DateTime.Now.ToShortDateString()),
                        TotalAmount = summary.Sum(record => record.AmountPaid).Value,
                        TotalTax = summary.Sum(record => record.TaxCollected).Value,
                        TotalBooking = summary.Count(),
                        Status = summary.FirstOrDefault().Status
                    }).ToList();
                }
            }

            return bookings;
        }

        public bool UpdateStatus(List<PmsEntity.Booking> booking)
        {
            //TODO: temp code till new SP is ready for bulk insertion
            var isUpdated = false;
            foreach (var b in booking)
            {
                isUpdated = false;
                var bookingId = b.Id;
                if (bookingId <= 0) return isUpdated;

                var dalBooking = new DAL.Booking
                {
                    CreatedOn = DateTime.Now,
                    IsActive = Convert.ToBoolean(b.Status),
                    ID = bookingId,
                    LastUpdatedOn = DateTime.Now,
                    PropertyID = b.PropertyId
                };

                using (var pmsContext = new PmsEntities())
                {
                    pmsContext.Entry(dalBooking).State = System.Data.Entity.EntityState.Modified;
                    pmsContext.Entry(dalBooking).Property(x => x.CheckinTime).IsModified = false;
                    pmsContext.Entry(dalBooking).Property(x => x.CheckoutTime).IsModified = false;
                    pmsContext.Entry(dalBooking).Property(x => x.CreatedBy).IsModified = false;
                    pmsContext.Entry(dalBooking).Property(x => x.CreatedOn).IsModified = false;
                    pmsContext.Entry(dalBooking).Property(x => x.GuestRemarks).IsModified = false;
                    pmsContext.Entry(dalBooking).Property(x => x.HOURSTOSTAY).IsModified = false;
                    pmsContext.Entry(dalBooking).Property(x => x.ISHOURLYCHECKIN).IsModified = false;
                    pmsContext.Entry(dalBooking).Property(x => x.Status).IsModified = false;
                    pmsContext.Entry(dalBooking).Property(x => x.NoOfAdult).IsModified = false;
                    pmsContext.Entry(dalBooking).Property(x => x.NoOfChild).IsModified = false;
                    pmsContext.Entry(dalBooking).Property(x => x.GuestRemarks).IsModified = false;
                    pmsContext.Entry(dalBooking).Property(x => x.TransactionRemarks).IsModified = false;
                    var result = pmsContext.SaveChanges();
                    isUpdated = result == 1 ? true : false;
                }
            }
            return isUpdated;
        }

        public bool DeleteBooking(int bookingId)
        {
            var isDeleted = false;
            if (bookingId <= 0) return isDeleted;

            var booking = new DAL.Booking
            {
                IsActive = false,
                ID = bookingId
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Bookings.Attach(booking);
                pmsContext.Entry(booking).Property(x => x.IsActive).IsModified = true;
                var result = pmsContext.SaveChanges();
                isDeleted = result == 1 ? true : false;
            }
            return isDeleted;
        }

        public PmsEntity.User GetValidUser(string loginName, string password)
        {
            PmsEntity.User user = null;
            //new PmsEntity.User()
            using (var pmsContext = new PmsEntities())
            {
                user = pmsContext.Users.ToList().Where(x => x.IsActive && x.UserName.Equals(loginName) && x.Password.Equals(password))
                                                .Select(m => new PmsEntity.User
                                                {
                                                    CreatedOn = m.CreatedOn,
                                                    CreatedBy = m.CreatedBy,
                                                    DOB = m.DOB,
                                                    EmailAddress = m.EmailAddress,
                                                    FirstName = m.FirstName,
                                                    Gender = m.Gender,
                                                    Id = m.ID,
                                                    IsActive = m.IsActive,
                                                    LastName = m.LastName,
                                                    LastUpdatedBy = m.LastUpdatedBy,
                                                    LastUpdatedOn = m.LastUpdatedOn,
                                                    MobileNumber = m.MobileNumber,
                                                    Password = m.Password,
                                                    UserName = m.UserName
                                                }).FirstOrDefault();
            }

            return user;
        }


        #region Expense Category
        public int AddExpenseCategory(PmsEntity.ExpenseCategory expenseCategory)
        {
            var Id = -1;
            if (expenseCategory == null) return Id;

            var expensecategory = new DAL.ExpenseCategory
            {
                CreatedOn = expenseCategory.CreatedOn,
                IsActive = true,
                CreatedBy = expenseCategory.CreatedBy,
                PropertyID = expenseCategory.PropertyId,
                ShortName = expenseCategory.ShortName,
                Description = expenseCategory.Description
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.ExpenseCategories.Add(expensecategory);
                var result = pmsContext.SaveChanges();
                Id = result == 1 ? expensecategory.ID : -1;
            }

            return Id;
        }

        public bool UpdateExpenseCategory(PmsEntity.ExpenseCategory expenseCategory)
        {
            var isUpdated = false;
            if (expenseCategory == null) return isUpdated;

            var expensecategory = new DAL.ExpenseCategory
            {
                LastUpdatedOn = expenseCategory.LastUpdatedOn,
                IsActive = expenseCategory.IsActive,
                LastUpdatedBy = expenseCategory.LastUpdatedBy,
                PropertyID = expenseCategory.PropertyId,
                Description = expenseCategory.Description,
                ShortName = expenseCategory.ShortName,
                ID = expenseCategory.Id,
                CreatedBy = expenseCategory.CreatedBy,
                CreatedOn = expenseCategory.CreatedOn
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Entry(expensecategory).State = System.Data.Entity.EntityState.Modified;
                var result = pmsContext.SaveChanges();
                isUpdated = result == 1 ? true : false;
            }

            return isUpdated;
        }

        public bool DeleteExpenseCategory(int expenseCategoryId)
        {
            var isDeleted = false;
            if (expenseCategoryId <= 0) return isDeleted;

            var expensecategory = new DAL.ExpenseCategory
            {
                IsActive = false,
                ID = expenseCategoryId
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.ExpenseCategories.Attach(expensecategory);
                pmsContext.Entry(expensecategory).Property(x => x.IsActive).IsModified = true;
                var result = pmsContext.SaveChanges();
                isDeleted = result == 1 ? true : false;
            }
            return isDeleted;
        }

        public List<PmsEntity.ExpenseCategory> GetExpenseCategoryByProperty(int propertyId)
        {
            var expenseCategorys = new List<PmsEntity.ExpenseCategory>();
            using (var pmsContext = new PmsEntities())
            {
                expenseCategorys = pmsContext.ExpenseCategories.Where(x => x.PropertyID == propertyId && x.IsActive)
                                                 .Select(x => new PmsEntity.ExpenseCategory
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

            return expenseCategorys;

        }
        #endregion 

        #region Expense
        public int AddExpense(PmsEntity.Expense expense)
        {
            var Id = -1;
            if (expense == null) return Id;

            var expens = new DAL.Expens
            {
                CreatedOn = expense.CreatedOn,
                IsActive = true,
                CreatedBy = expense.CreatedBy,
                PropertyID = expense.PropertyID,
                Description = expense.Description,
                Amount = expense.Amount,
                ExpenseCategoryID = expense.ExpenseCategoryID,
                PaymentTypeID = expense.PaymentTypeID,
                ExpenseDate = expense.ExpenseDate
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Expenses.Add(expens);
                var result = pmsContext.SaveChanges();
                Id = result == 1 ? expens.ID : -1;
            }

            return Id;
        }

        public bool UpdateExpense(PmsEntity.Expense expense)
        {
            var isUpdated = false;
            if (expense == null) return isUpdated;

            var expens = new DAL.Expens
            {
                LastUpdatedOn = expense.LastUpdatedOn,
                IsActive = expense.IsActive,
                LastUpdatedBy = expense.LastUpdatedBy,
                PropertyID = expense.PropertyID,
                Description = expense.Description,
                Amount = expense.Amount,
                ExpenseCategoryID = expense.ExpenseCategoryID,
                PaymentTypeID = expense.PaymentTypeID,
                ID = expense.Id,
                CreatedBy = expense.CreatedBy,
                CreatedOn = expense.CreatedOn,
                ExpenseDate = expense.ExpenseDate
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Entry(expens).State = System.Data.Entity.EntityState.Modified;
                var result = pmsContext.SaveChanges();
                isUpdated = result == 1 ? true : false;
            }

            return isUpdated;
        }

        public bool DeleteExpense(int expenseId)
        {
            var isDeleted = false;
            if (expenseId <= 0) return isDeleted;

            var expens = new DAL.Expens
            {
                IsActive = false,
                ID = expenseId
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Expenses.Attach(expens);
                pmsContext.Entry(expens).Property(x => x.IsActive).IsModified = true;
                var result = pmsContext.SaveChanges();
                isDeleted = result == 1 ? true : false;
            }
            return isDeleted;
        }

        public List<PmsEntity.Expense> GetExpenseBySearch(DateTime? startDate, DateTime? endDate, int? paymentId, int? expenseCategoryId,
            decimal? amountPaidMin, decimal? amountPaidMax, int? propertyId)
        {
            var expenses = new List<PmsEntity.Expense>();
            using (var pmsContext = new PmsEntities())
            {
                expenses = pmsContext.GetExpenseData(startDate, endDate, paymentId, expenseCategoryId, amountPaidMin, amountPaidMax, propertyId)
                    .Select(x => new Expense
                    {
                        Id = x.ID,
                        Amount = x.Amount,
                        CreatedOn = x.CreatedOn,
                        CreatedBy = x.CreatedBy,
                        Description = x.Description,
                        ExpenseDate = x.ExpenseDate,
                        ExpenseCategory = new PmsEntity.ExpenseCategory
                        {
                            ShortName = x.CategoryShortName,
                            Description = x.CategoryDesc
                        },
                        ExpenseCategoryID = x.ExpenseCategoryID,
                        IsActive = x.IsActive,
                        LastUpdatedBy = x.LastUpdatedBy,
                        LastUpdatedOn = x.LastUpdatedOn,
                        PaymentType = new PmsEntity.PaymentType
                        {
                            ShortName = x.PaymentShortName,
                            Description = x.PaymentDesc
                        },
                        PaymentTypeID = x.PaymentTypeID,
                        PropertyID = x.PropertyID

                    }).ToList();
            }

            return expenses;

        }
        #endregion

        #region Reports
        public DataTable GetShiftReport(DateTime? startDate, DateTime? endDate, int? propertyId)
        {
            DataTable dt = new DataTable();
            var context = new PmsEntities();
            var conn = context.Database.Connection;
            var connectionState = conn.State;
            try
            {
                using (context)
                {
                    if (connectionState != ConnectionState.Open)
                        conn.Open();
                    using (var cmd = conn.CreateCommand())
                    {
                        cmd.CommandText = "[GetShiftReport]";
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add(new SqlParameter("StartDate", startDate));
                        cmd.Parameters.Add(new SqlParameter("EndDate", endDate));
                        cmd.Parameters.Add(new SqlParameter("PropertyId", propertyId));
                        using (var reader = cmd.ExecuteReader())
                        {
                            dt.Load(reader);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (connectionState != ConnectionState.Open)
                    conn.Close();
            }
            return dt;
        }

        public DataTable GetConsolidatedShiftReport(DateTime? startDate, DateTime? endDate, int? propertyId)
        {
            DataTable dt = new DataTable();
            var context = new PmsEntities();
            var conn = context.Database.Connection;
            var connectionState = conn.State;
            try
            {
                using (context)
                {
                    if (connectionState != ConnectionState.Open)
                        conn.Open();
                    using (var cmd = conn.CreateCommand())
                    {
                        cmd.CommandText = "[GetConsolidatedShiftReport]";
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add(new SqlParameter("StartDate", startDate));
                        cmd.Parameters.Add(new SqlParameter("EndDate", endDate));
                        cmd.Parameters.Add(new SqlParameter("PropertyId", propertyId));
                        using (var reader = cmd.ExecuteReader())
                        {
                            dt.Load(reader);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (connectionState != ConnectionState.Open)
                    conn.Close();
            }
            return dt;
        }


        public DataTable GetManagerData(DateTime startDate, DateTime endDate, int propertyId)
        {
            DataTable dt = new DataTable();
            var context = new PmsEntities();
            var conn = context.Database.Connection;
            var connectionState = conn.State;
            try
            {
                using (context)
                {
                    if (connectionState != ConnectionState.Open)
                        conn.Open();
                    using (var cmd = conn.CreateCommand())
                    {
                        cmd.CommandText = "[GetManagerData]";
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add(new SqlParameter("StartDate", startDate));
                        cmd.Parameters.Add(new SqlParameter("EndDate", endDate));
                        cmd.Parameters.Add(new SqlParameter("PropertyID", propertyId));
                        using (var reader = cmd.ExecuteReader())
                        {
                            dt.Load(reader);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (connectionState != ConnectionState.Open)
                    conn.Close();
            }
            return dt;
        }

        public DataTable GetConsolidatedManagerData(DateTime startDate, DateTime endDate, int propertyId, int option)
        {

            DataTable dt = new DataTable();
            var context = new PmsEntities();
            var conn = context.Database.Connection;
            var connectionState = conn.State;
            try
            {
                using (context)
                {
                    if (connectionState != ConnectionState.Open)
                        conn.Open();
                    using (var cmd = conn.CreateCommand())
                    {
                        cmd.CommandText = "[GetConsolidatedManagerData]";
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add(new SqlParameter("StartDate", startDate));
                        cmd.Parameters.Add(new SqlParameter("EndDate", endDate));
                        cmd.Parameters.Add(new SqlParameter("PropertyID", propertyId));
                        cmd.Parameters.Add(new SqlParameter("option", option));
                        using (var reader = cmd.ExecuteReader())
                        {
                            dt.Load(reader);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                if (connectionState != ConnectionState.Open)
                    conn.Close();
            }
            return dt;
        }

        public List<PmsEntity.GuestSummary> GETGuestSummary(int propertyId, DateTime currentDate)
        {
            var guestSummary = new List<PmsEntity.GuestSummary>();
            using (var pmsContext = new PmsEntities())
            {
                var resultSet = pmsContext.GETGuestSummary(propertyId, currentDate).ToList();
                if (resultSet == null || resultSet.Count <= 0) return guestSummary;
                foreach (var item in resultSet)
                {
                    guestSummary.Add(new GuestSummary
                    {

                        CheckinTime = item.CHECKINTIME,
                        CheckoutTime = item.CHECKOUTTIME,
                        FirstName = item.FIRSTNAME,
                        GuestId = item.GUESTID,
                        Id = item.ID,
                        LastName = item.LASTNAME,
                        PropertyId = item.PROPERTYID,
                        RoomBookingId = item.PROPERTYID,
                        RoomId = item.ROOMID,
                        RoomNumber = item.ROOMNUMBER,
                        RoomStatus = item.RoomStatus,
                        RoomTypeID = item.RoomTypeID,
                        RoomTypeName = item.RoomTypeName,
                        RoomTypeShortName = item.RoomTypeShortName,
                        Status = item.Status,
                        TotalAmount = item.TotalAmount,
                        ModeOFPayment = item.ModeOFPayment,
                        NextReservation = item.NextReservation,
                        Rate = item.Rate
                    });
                }
                return guestSummary;
            }
        }
        #endregion
        private bool SaveRoomRateIndDb(int propertyId, string rateXml)
        {
            using (var pmsContext = new PmsEntities())
            {
                var propId = new SqlParameter
                {
                    ParameterName = "propertyID",
                    DbType = DbType.Int32,
                    Value = propertyId
                };

                var roomRateXml = new SqlParameter
                {
                    ParameterName = "RateXML",
                    DbType = DbType.Xml,
                    Value = rateXml
                };

                var status = new SqlParameter
                {
                    ParameterName = "Status",
                    DbType = DbType.Boolean,
                    Direction = ParameterDirection.Output
                };
                var result = pmsContext.Database.ExecuteSqlCommand("InsertRoomRates @propertyID, @RateXML, @Status OUTPUT", propId, roomRateXml, status);
                return status.Value != null ? Convert.ToBoolean(status.Value) : false;
            }

        }

        public List<PmsEntity.Functionality> GetAllFunctionality()
        {
            var functioanlities = new List<PmsEntity.Functionality>();
            using (var pmsContext = new PmsEntities())
            {
                functioanlities = pmsContext.Functionalities.Where(x => x.IsActive)
                                                 .Select(x => new PmsEntity.Functionality
                                                 {
                                                     CreatedOn = x.CreatedOn,
                                                     Description = x.Description,
                                                     CreatedBy = x.CreatedBy,
                                                     LastUpdatedBy = x.LastUpdatedBy,
                                                     LastUpdatedOn = x.LastUpdatedOn,
                                                     Id = x.ID,
                                                     Functionality1 = x.Functionality1,
                                                     IsActive = x.IsActive
                                                 }).ToList();
            }

            return functioanlities;

        }

        public List<PmsEntity.Functionality> GetFunctionalityByUserId(int userId)
        {

            var functioanlities = new List<PmsEntity.Functionality>();
            using (var pmsContext = new PmsEntities())
            {
                functioanlities = pmsContext.Functionalities
                    .Join(pmsContext.UsersFunctionalityMappings, r => r.ID, n => n.FunctionalityID,
                             (r, n) => new { r, n })
                             .Where(x => x.r.IsActive && x.n.UserID == userId)
                                                 .Select(x => new PmsEntity.Functionality
                                                 {
                                                     CreatedOn = x.r.CreatedOn,
                                                     Description = x.r.Description,
                                                     CreatedBy = x.r.CreatedBy,
                                                     LastUpdatedBy = x.r.LastUpdatedBy,
                                                     LastUpdatedOn = x.r.LastUpdatedOn,
                                                     Id = x.r.ID,
                                                     Functionality1 = x.r.Functionality1,
                                                     IsActive = x.r.IsActive
                                                 }).ToList();
            }

            return functioanlities;
        }

        public bool InsertUserAccess(int userId, string functionalities, string properties, string createdBy)
        {
            using (var pmsContext = new PmsEntities())
            {
                pmsContext.InsertUserAccess(userId, functionalities, properties, createdBy);
                return true;
            }
        }

        #region User
        public int AddUser(PmsEntity.User user)
        {
            var Id = -1;
            if (user == null) return Id;

            var userE = new DAL.User
            {
                CreatedOn = user.CreatedOn,
                IsActive = true,
                CreatedBy = user.CreatedBy,
                DOB = user.DOB,
                EmailAddress = user.EmailAddress,
                FirstName = user.FirstName,
                Gender = user.Gender,
                ID = user.Id,
                LastName = user.LastName,
                MobileNumber = user.MobileNumber,
                Password = user.Password,
                UserName = user.UserName
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Users.Add(userE);
                var result = pmsContext.SaveChanges();
                Id = result == 1 ? userE.ID : -1;
            }

            return Id;
        }

        public bool UpdateUser(PmsEntity.User user)
        {
            var isUpdated = false;
            if (user == null) return isUpdated;

            var userE = new DAL.User
            {
                IsActive = true,
                CreatedBy = user.CreatedBy,
                DOB = user.DOB,
                EmailAddress = user.EmailAddress,
                FirstName = user.FirstName,
                Gender = user.Gender,
                ID = user.Id,
                LastName = user.LastName,
                LastUpdatedBy = user.LastUpdatedBy,
                LastUpdatedOn = user.LastUpdatedOn,
                MobileNumber = user.MobileNumber,
                CreatedOn = user.CreatedOn,
                Password = user.Password,
                UserName = user.UserName
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Entry(userE).State = System.Data.Entity.EntityState.Modified;
                var result = pmsContext.SaveChanges();
                isUpdated = result == 1 ? true : false;
            }

            return isUpdated;
        }

        public bool DeleteUser(int userId)
        {
            var isDeleted = false;
            if (userId <= 0) return isDeleted;

            var user = new DAL.User
            {
                IsActive = false,
                ID = userId,
                UserName = "username", //Temp code
                Password = "password"//Temp code
            };

            using (var pmsContext = new PmsEntities())
            {
                pmsContext.Users.Attach(user);
                pmsContext.Entry(user).Property(x => x.IsActive).IsModified = true;
                var result = pmsContext.SaveChanges();
                isDeleted = result == 1 ? true : false;
            }
            return isDeleted;
        }

        public List<PmsEntity.User> GetAllUser()
        {
            using (var pmsContext = new PmsEntities())
            {
                return (from u in pmsContext.Users
                        where u.IsActive
                        select new PmsEntity.User
                        {
                            CreatedBy = u.CreatedBy,
                            CreatedOn = u.CreatedOn,
                            DOB = u.DOB,
                            EmailAddress = u.EmailAddress,
                            FirstName = u.FirstName,
                            Gender = u.Gender,
                            Id = u.ID,
                            IsActive = u.IsActive,
                            LastName = u.LastName,
                            LastUpdatedBy = u.LastUpdatedBy,
                            LastUpdatedOn = u.LastUpdatedOn,
                            MobileNumber = u.MobileNumber,
                            UserName = u.UserName,
                            Password = u.Password
                        }).ToList();
            }
        }
        #endregion

        public bool CancelReservation(int bookingId)
        {
            using (var pmsContext = new PmsEntities())
            {
                var result=pmsContext.Bookings.Find(bookingId);
                if (result != null)
                {
                    result.IsActive = false;
                    if(pmsContext.SaveChanges()>0)
                    return true;
                }
            }
            return false;
        }

        public bool UpdatePassword(int UserId, string CurrentPassword, string NewPassword)
        {
            using (var pmsContext = new PmsEntities())
            {
                var result = pmsContext.Users.Find(UserId);
                if (result != null && result.Password== CurrentPassword) 
                {
                    result.Password = NewPassword;
                    if (pmsContext.SaveChanges() > 0)
                        return true;
                }
            }
            return false;
        }
    }
}
