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
        public bool AddBooking(int propertyId, string bookingXml)
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

                var result = pmsContext.Database.ExecuteSqlCommand("InsertBooking @propertyID, @bookingXML", propId, roomBookingXml);
                isAdded = true;
            }
            return isAdded;
        }
        public List<PmsEntity.Booking> GetBooking(int propertyId, DateTime startDate, DateTime endDate)
        {
            var bookings = new List<PmsEntity.Booking>();

            using (var pmsContext = new PmsEntities())
            {
                var resultSet = pmsContext.GETALLBOOKINGS(propertyId, startDate, endDate);
                if (resultSet == null) return bookings;
                foreach (var result in resultSet)
                {
                    var booking = new PmsEntity.Booking();
                    booking.Id = result.ID;
                    booking.CheckinTime = result.CHECKINTIME ;
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
        public bool AddProperty(PmsEntity.Property property)
        {
            var isAdded = false;
            return isAdded;
        }
        public bool UpdateProperty(PmsEntity.Property property)
        {
            var isUpdated = false;
            return isUpdated;
        }
        public bool DeleteProperty(int propertyId)
        {
            var isDeleted = false;
            return isDeleted;
        }
        public List<PmsEntity.Property> GetAllProperty()
        {
            var properties = new List<PmsEntity.Property>();
            return properties;
        }
        public bool AddPropertyType(PmsEntity.PropertyType propertyType)
        {
            var isAdded = false;
            return isAdded;
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
        public bool AddRoom(PmsEntity.Room room)
        {
            var isAdded = false;
            return isAdded;
        }
        public bool UpdateRoom(PmsEntity.Room room)
        {
            var isUpdated = false;
            return isUpdated;
        }
        public bool DeleteRoom(int roomId)
        {
            var isDeleted = false;
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
        public bool AddRateType(PmsEntity.RateType rateType)
        {
            var isAdded = false;
            return isAdded;
        }
        public bool UpdateRateType(PmsEntity.RateType rateType)
        {
            var isUpdated = false;
            return isUpdated;
        }
        public bool DeleteRateType(int rateTypeId)
        {
            var isDeleted = false;
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
                                                     Name = x.Name,
                                                     CreatedBy = x.CreatedBy,
                                                     LastUpdatedBy = x.LastUpdatedBy,
                                                     LastUpdatedOn = x.LastUpdatedOn,
                                                     Id = x.ID,
                                                     PropertyId = x.PropertyID
                                                 }).ToList();

            }
            return rateTypes;
        }
        public bool AddRoomType(PmsEntity.RoomType roomType)
        {
            var isAdded = false;
            return isAdded;
        }
        public bool UpdateRoomType(PmsEntity.RoomType roomType)
        {
            var isUpdated = false;
            return isUpdated;
        }
        public bool DeleteRoomType(int roomTypeId)
        {
            var isDeleted = false;
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
                                                     Name = x.Name,
                                                     CreatedBy = x.CreatedBy,
                                                     LastUpdatedBy = x.LastUpdatedBy,
                                                     LastUpdatedOn = x.LastUpdatedOn,
                                                     Id = x.ID,
                                                     PropertyId = x.PropertyID
                                                 }).ToList();
               
            }

            return roomTypes;
        }
        public bool AddRoomPrice(PmsEntity.RoomPricing roomPrice)
        {
            var isAdded = false;
            return isAdded;
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
        public bool AddRoomStatus(PmsEntity.RoomStatus roomStatus)
        {
            var isAdded = false;
            return isAdded;
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
        public bool AddReward(PmsEntity.GuestReward reward)
        {
            var isAdded = false;
            return isAdded;
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
        public bool AddRewardCategory(PmsEntity.RewardCategory rewardCategory)
        {
            var isAdded = false;
            return isAdded;
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
                var resultSet = pmsContext.GETROOMSTATUS(propertyId, checkinDate, checkoutDate);
                if (resultSet == null) return rooms;
                foreach(var result in resultSet)
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
                var resultSet = pmsContext.GETGUESTTRANSACTIONS(guestId);
                if (resultSet == null) return bookings;
                foreach (var result in resultSet)
                {
                    var booking = new PmsEntity.Booking();
                    booking.CheckinTime = result.CheckinTime;
                    booking.CheckoutTime = result.CheckoutTime;
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
                states = pmsContext.States.Where(x => x.IsActive && x.CountryID == id)
                           .Select(x => new PmsEntity.State
                           {
                               ID = x.ID,
                               Name = x.Name,
                               CountryId = x.CountryID.Value
                           }).ToList();
                    
            }

            return states;
        }

        public List<PmsEntity.City> GetCityByState(int id)
        {
            var city = new List<PmsEntity.City>();

            using (var pmsContext = new PmsEntities())
            {
                city = pmsContext.Cities.Where(x => x.IsActive && x.StateID == id)
                           .Select(x => new PmsEntity.City
                           {
                               Id = x.ID,
                               Name = x.Name,
                               StateId = x.StateID,
                               CountryId = x.CountryID
                           }).ToList();

            }

            return city;
        }
    }
}
