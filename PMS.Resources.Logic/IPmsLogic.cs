﻿using PmsEntity = PMS.Resources.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using System.Threading.Tasks;
using PMS.Resources.DTO.Request;
using PMS.Resources.DTO.Response;

namespace PMS.Resources.Logic
{
    public interface IPmsLogic
    {
        bool UpdateBooking(PmsEntity.Booking booking);
        bool AddBooking(PmsEntity.Booking booking, ref int bookingId, ref int guestId);
        List<PmsEntity.Booking> GetBooking(int propertyId, DateTime startDate, DateTime endDate);
        int AddProperty(PmsEntity.Property property);
        bool UpdateProperty(PmsEntity.Property property);
        bool DeleteProperty(int propertyId);
        List<PmsEntity.Property> GetAllProperty();
        int AddPropertyType(PmsEntity.PropertyType propertyType);
        bool UpdatePropertyType(PmsEntity.PropertyType propertyType);
        bool DeletePropertyType(int propertyTypeId);
        List<PmsEntity.PropertyType> GetAllPropertyType();
        bool AddRoom(List<PmsEntity.Room> room);
        bool UpdateRoom(List<PmsEntity.Room> room);
        bool DeleteRoom(int roomId);
        List<PmsEntity.Room> GetRoomByProperty(int propertyId);
        int AddRateType(PmsEntity.RateType rateType);
        bool UpdateRateType(PmsEntity.RateType rateType);
        bool DeleteRateType(int rateTypeId);
        List<PmsEntity.RateType> GetRateTypeByProperty(int propertyId);
        int AddRoomType(PmsEntity.RoomType roomType);
        bool UpdateRoomType(PmsEntity.RoomType roomType);
        bool DeleteRoomType(int roomTypeId);
        List<PmsEntity.RoomType> GetRoomTypeByProperty(int propertyId);

        //Payment Type Methods
        int AddPaymentType(PmsEntity.PaymentType paymentType);
        bool UpdatePaymentType(PmsEntity.PaymentType paymentType);
        bool DeletePaymentType(int paymentTypeId);
        List<PmsEntity.PaymentType> GetPaymentTypeByProperty(int propertyId);
       
        //Floor Methods
        int AddFloor(PmsEntity.PropertyFloor propertyFloor);
        bool UpdateFloor(PmsEntity.PropertyFloor propertyFloor);
        bool DeleteFloor(int propertyFloorId);
        List<PmsEntity.PropertyFloor> GetFloorsByProperty(int propertyId);

        //Extra Charges
        int AddExtraCharge(PmsEntity.ExtraCharge extraCharge);
        bool UpdateExtraCharge(PmsEntity.ExtraCharge extraCharge);
        bool DeleteExtraCharge(int extraChargeId);
        List<PmsEntity.ExtraCharge> GetExtraCharges(int propertyId);

        //Taxes
        int AddTax(PmsEntity.Tax tax);
        bool UpdateTax(PmsEntity.Tax tax);
        bool DeleteTax(int TaxId);
        List<PmsEntity.Tax> GetTaxByProperty(int propertyId);

        int AddRoomPrice(PmsEntity.RoomPricing roomPrice);
        bool UpdateRoomPrice(PmsEntity.RoomPricing roomPrice);
        bool DeleteRoomPrice(int priceId);
        List<PmsEntity.RoomPricing> GetRoomPriceByProperty(int propertyId);
        int AddRoomStatus(PmsEntity.RoomStatus roomStatus);
        bool UpdateRoomStatus(PmsEntity.RoomStatus roomStatus);
        bool DeleteRoomStatus(int statusId);
        List<PmsEntity.RoomStatus> GetRoomStatus();
        int AddReward(PmsEntity.GuestReward reward);
        bool UpdateReward(PmsEntity.GuestReward reward);
        bool DeleteReward(int rewardId);
        List<PmsEntity.GuestReward> GetAllReward();
        List<PmsEntity.GuestReward> GetRewardByGuestId(int guestId);
        int AddRewardCategory(PmsEntity.RewardCategory rewardCategory);
        bool UpdateRewardCategory(PmsEntity.RewardCategory rewardCategory);
        bool DeleteRewardCategory(int catId);
        List<PmsEntity.RewardCategory> GetAllRewardCategory();
        List<PmsEntity.Room> GetRoomByDate(GetRoomByDateRequestDto request);
        List<PmsEntity.Booking> GetGuestHistory(int guestId);
        List<PmsEntity.State> GetStateByCountry(int id);
        List<PmsEntity.City> GetCityByState(int id);
        List<PmsEntity.Country> GetCountry();
        List<PmsEntity.Guest>  GetAllGuest();
        List<PmsEntity.Tax> GetPaymentCharges(GetPaymentChargesRequestDto request);
        int AddInvoice(PmsEntity.Invoice invoice);
        PmsEntity.Invoice GetInvoiceById(int invoiceId);
        PmsEntity.Booking GetBookingById(int bookingId);
        List<PmsEntity.RateType> GetRoomRateByProperty(int propertyId);
        bool AddRoomRate(List<PmsEntity.Rate> rates);
        bool UpdateRoomRate(List<PmsEntity.Rate> rates);
        bool DeleteRoomRate(int rateId);
    }
}
