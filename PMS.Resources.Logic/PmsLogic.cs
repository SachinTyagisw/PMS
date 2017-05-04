using PMS.Resources.Caching;
using PMS.Resources.DAL;
using PmsEntity = PMS.Resources.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel.Composition;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using PMS.Resources.Logging.Logger;

namespace PMS.Resources.Logic
{
    [Export(typeof(IPmsLogic))]
    [PartCreationPolicy(CreationPolicy.NonShared)]
    public class PmsLogic : IPmsLogic
    {
        public PmsLogic()
        {

        }

        private IDalFactory DalFactory
        {
            get
            {
                return (IDalFactory)HttpContext.Current.Application["DalFactory"];
            }
        }

        private ICacheProvider CacheProvider
        {
            get
            {
                return (ICacheProvider)HttpContext.Current.Application["CacheProvider"];
            }
        }

        public bool AddBooking(PmsEntity.Booking booking)
        {
            var isAdded = DalFactory.AddBooking(booking);
            return isAdded;
        }

        public List<PmsEntity.Booking> GetBooking(DateTime startDate, DateTime endDate)
        {
            var bookings = DalFactory.GetBooking(startDate, endDate);
            return bookings;
        }
        public bool AddProperty(PmsEntity.Property property)
        {
            var isAdded = DalFactory.AddProperty(property);
            return isAdded;
        }
        public bool UpdateProperty(PmsEntity.Property property)
        {
            var isUpdated = DalFactory.UpdateProperty(property);
            return isUpdated;
        }
        public bool DeleteProperty(int propertyId)
        {
            var isDeleted = DalFactory.DeleteProperty(propertyId);
            return isDeleted;
        }
        public List<PmsEntity.Property> GetAllProperty()
        {
            var properties = DalFactory.GetAllProperty();
            return properties;
        }
        public bool AddPropertyType(PmsEntity.PropertyType propertyType)
        {
            var isAdded = DalFactory.AddPropertyType(propertyType);
            return isAdded;
        }
        public bool UpdatePropertyType(PmsEntity.PropertyType propertyType)
        {
            var isUpdated = DalFactory.UpdatePropertyType(propertyType);
            return isUpdated;
        }
        public bool DeletePropertyType(int propertyTypeId)
        {
            var isDeleted = DalFactory.DeletePropertyType(propertyTypeId);
            return isDeleted;
        }
        public List<PmsEntity.PropertyType> GetAllPropertyType()
        {
            var propertyTypes = DalFactory.GetAllPropertyType();
            return propertyTypes;
        }
        public bool AddRoom(PmsEntity.Room room)
        {
            var isAdded = DalFactory.AddRoom(room);
            return isAdded;
        }
        public bool UpdateRoom(PmsEntity.Room room)
        {
            var isUpdated = DalFactory.UpdateRoom(room);
            return isUpdated;
        }
        public bool DeleteRoom(int roomId)
        {
            var isDeleted = DalFactory.DeleteRoom(roomId);
            return isDeleted;
        }
        public List<PmsEntity.Room> GetRoomByProperty(int propertyId)
        {
            var rooms = DalFactory.GetRoomByProperty(propertyId);
            return rooms;
        }
        public bool AddRateType(PmsEntity.RateType rateType)
        {
            var isAdded = DalFactory.AddRateType(rateType);
            return isAdded;
        }
        public bool UpdateRateType(PmsEntity.RateType rateType)
        {
            var isUpdated = DalFactory.UpdateRateType(rateType);
            return isUpdated;
        }
        public bool DeleteRateType(int rateTypeId)
        {
            var isDeleted = DalFactory.DeleteRateType(rateTypeId);
            return isDeleted;
        }
        public List<PmsEntity.RateType> GetRateTypeByProperty(int propertyId)
        {
            var rateTypes = DalFactory.GetRateTypeByProperty(propertyId);
            return rateTypes;
        }
        public bool AddRoomType(PmsEntity.RoomType roomType)
        {
            var isAdded = DalFactory.AddRoomType(roomType);
            return isAdded;
        }
        public bool UpdateRoomType(PmsEntity.RoomType roomType)
        {
            var isUpdated = DalFactory.UpdateRoomType(roomType);
            return isUpdated;
        }
        public bool DeleteRoomType(int roomTypeId)
        {
            var isDeleted = DalFactory.DeleteRoomType(roomTypeId);
            return isDeleted;
        }
        public List<PmsEntity.RoomType> GetRoomTypeByProperty(int propertyId)
        {
            var roomTypes = DalFactory.GetRoomTypeByProperty(propertyId);
            return roomTypes;
        }
        public bool AddRoomPrice(PmsEntity.RoomPricing roomPrice)
        {
            var isAdded = DalFactory.AddRoomPrice(roomPrice);
            return isAdded;
        }
        public bool UpdateRoomPrice(PmsEntity.RoomPricing roomPrice)
        {
            var isUpdated = DalFactory.UpdateRoomPrice(roomPrice);
            return isUpdated;
        }
        public bool DeleteRoomPrice(int priceId)
        {
            var isDeleted = DalFactory.DeleteRoomPrice(priceId);
            return isDeleted;
        }
        public List<PmsEntity.RoomPricing> GetRoomPriceByProperty(int propertyId)
        {
            var roomPricing = DalFactory.GetRoomPriceByProperty(propertyId);
            return roomPricing;
        }
        public bool AddRoomStatus(PmsEntity.RoomStatus roomStatus)
        {
            var isAdded = DalFactory.AddRoomStatus(roomStatus);
            return isAdded;
        }
        public bool UpdateRoomStatus(PmsEntity.RoomStatus roomStatus)
        {
            var isUpdated = DalFactory.UpdateRoomStatus(roomStatus);
            return isUpdated;
        }
        public bool DeleteRoomStatus(int statusId)
        {
            var isDeleted = DalFactory.DeleteRoomStatus(statusId);
            return isDeleted;
        }
        public List<PmsEntity.RoomStatus> GetRoomStatus()
        {
            var roomStatus = DalFactory.GetRoomStatus();
            return roomStatus;
        }
        public bool AddReward(PmsEntity.GuestReward reward)
        {
            var isAdded = DalFactory.AddReward(reward);
            return isAdded;
        }
        public bool UpdateReward(PmsEntity.GuestReward reward)
        {
            var isUpdated = DalFactory.UpdateReward(reward);
            return isUpdated;
        }
        public bool DeleteReward(int rewardId)
        {
            var isDeleted = DalFactory.DeleteReward(rewardId);
            return isDeleted;
        }
        public List<PmsEntity.GuestReward> GetAllReward()
        {
            var rewards = DalFactory.GetAllReward();
            return rewards;
        }
        public List<PmsEntity.GuestReward> GetRewardByGuestId(int guestId)
        {
            var rewards = DalFactory.GetRewardByGuestId(guestId);
            return rewards;
        }
        public bool AddRewardCategory(PmsEntity.RewardCategory rewardCategory)
        {
            var isAdded = DalFactory.AddRewardCategory(rewardCategory);
            return isAdded;
        }
        public bool UpdateRewardCategory(PmsEntity.RewardCategory rewardCategory)
        {
            var isUpdated = DalFactory.UpdateRewardCategory(rewardCategory);
            return isUpdated;
        }
        public bool DeleteRewardCategory(int catId)
        {
            var isDeleted = DalFactory.DeleteRewardCategory(catId);
            return isDeleted;
        }
        public List<PmsEntity.RewardCategory> GetAllRewardCategory()
        {
            var rewardCategory = DalFactory.GetAllRewardCategory();
            return rewardCategory;
        }
    }
}
