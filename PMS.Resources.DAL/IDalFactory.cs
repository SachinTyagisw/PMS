using PMS.Resources.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PmsEntity = PMS.Resources.Entities;

namespace PMS.Resources.DAL
{
    public interface IDalFactory
    {
        void LogExceptionToDb(PmsEntity.ExceptionLog additionalExData);
        bool AddBooking(int propertyId, string bookingXml);
        List<PmsEntity.Booking> GetBooking(int propertyId, DateTime startDate, DateTime endDate);
        bool AddProperty(PmsEntity.Property property);
        bool UpdateProperty(PmsEntity.Property property);
        bool DeleteProperty(int propertyId);
        List<PmsEntity.Property> GetAllProperty();
        bool AddPropertyType(PmsEntity.PropertyType propertyType);
        bool UpdatePropertyType(PmsEntity.PropertyType propertyType);
        bool DeletePropertyType(int propertyTypeId);
        List<PmsEntity.PropertyType> GetAllPropertyType();
        bool AddRoom(PmsEntity.Room room);
        bool UpdateRoom(PmsEntity.Room room);
        bool DeleteRoom(int roomId);
        List<PmsEntity.Room> GetRoomByProperty(int propertyId);
        bool AddRateType(PmsEntity.RateType rateType);
        bool UpdateRateType(PmsEntity.RateType rateType);
        bool DeleteRateType(int rateTypeId);
        List<PmsEntity.RateType> GetRateTypeByProperty(int propertyId);
        bool AddRoomType(PmsEntity.RoomType roomType);
        bool UpdateRoomType(PmsEntity.RoomType roomType);
        bool DeleteRoomType(int roomTypeId);
        List<PmsEntity.RoomType> GetRoomTypeByProperty(int propertyId);
        bool AddRoomPrice(PmsEntity.RoomPricing roomPrice);
        bool UpdateRoomPrice(PmsEntity.RoomPricing roomPrice);
        bool DeleteRoomPrice(int priceId);
        List<PmsEntity.RoomPricing> GetRoomPriceByProperty(int propertyId);
        bool AddRoomStatus(PmsEntity.RoomStatus roomStatus);
        bool UpdateRoomStatus(PmsEntity.RoomStatus roomStatus);
        bool DeleteRoomStatus(int statusId);
        List<PmsEntity.RoomStatus> GetRoomStatus();
        bool AddReward(PmsEntity.GuestReward reward);
        bool UpdateReward(PmsEntity.GuestReward reward);
        bool DeleteReward(int rewardId);
        List<PmsEntity.GuestReward> GetAllReward();
        List<PmsEntity.GuestReward> GetRewardByGuestId(int guestId);
        bool AddRewardCategory(PmsEntity.RewardCategory rewardCategory);
        bool UpdateRewardCategory(PmsEntity.RewardCategory rewardCategory);
        bool DeleteRewardCategory(int catId);
        List<PmsEntity.RewardCategory> GetAllRewardCategory();
        List<PmsEntity.Room> GetRoomByDate(int propertyId, DateTime checkinDate , DateTime checkoutDate);
        List<PmsEntity.Booking> GetGuestHistory(int guestId);
        bool UpdateBooking(PmsEntity.Booking booking);
    }
}

