using PmsEntity = PMS.Resources.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PMS.Resources.Common.Converter;

namespace PMS.Resources.DAL
{
    public class DalFactory : IDalFactory
    {
        public void LogExceptionToDb(PmsEntity.ExceptionLog additionalExData)
        {
            throw new NotImplementedException();
        }
        public bool AddBooking(PmsEntity.Booking booking)
        {
            var isAdded = false;
            booking.CreatedBy = "vipul";
            booking.CreatedOn = DateTime.Now;
            var xml = PmsConverter.SerializeObjectToXmlString(booking);
            return isAdded;
        }

        public List<PmsEntity.Booking> GetBooking(DateTime startDate, DateTime endDate)
        {
            var bookings = new List<PmsEntity.Booking>();
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
                                                     RateType = new PmsEntity.RateType
                                                     {
                                                         Id = x.RateTypeID 
                                                     },
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
                                                     PropertyId = x.PropertyID,
                                                     RoomTypeId = x.RoomTypeID
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
    }
}
