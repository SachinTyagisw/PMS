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
using PMS.Resources.DTO.Request;
using PMS.Resources.Common.Converter;
using PMS.Resources.DTO.Response;

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

        public bool AddBooking(PmsEntity.Booking booking, ref int bookingId, ref int guestId)
        {
            var propertyId = booking.PropertyId;
            var bookingXml = PmsConverter.SerializeObjectToXmlString(booking);
            if(string.IsNullOrWhiteSpace(bookingXml)) return false;

            bookingXml = RemoveXmlDefaultNode(bookingXml);

            //var logService = LoggingManager.GetLogInstance();
            //logService.LogInformation("booking xml:" + bookingXml);

            return DalFactory.AddBooking(propertyId, bookingXml, ref bookingId, ref guestId);
        }       
        public List<PmsEntity.Booking> GetBooking(int propertyId, DateTime startDate, DateTime endDate)
        {
            return DalFactory.GetBooking(propertyId, startDate, endDate);
        }
        public int AddProperty(PmsEntity.Property property)
        {
            return DalFactory.AddProperty(property);
        }
        public bool UpdateProperty(PmsEntity.Property property)
        {
            return DalFactory.UpdateProperty(property);
        }
        public bool DeleteProperty(int propertyId)
        {
            return DalFactory.DeleteProperty(propertyId);
        }
        public List<PmsEntity.Property> GetAllProperty()
        {
            return DalFactory.GetAllProperty();
        }
        public int AddPropertyType(PmsEntity.PropertyType propertyType)
        {
            return DalFactory.AddPropertyType(propertyType);
        }
        public bool UpdatePropertyType(PmsEntity.PropertyType propertyType)
        {
            return DalFactory.UpdatePropertyType(propertyType);
        }
        public bool DeletePropertyType(int propertyTypeId)
        {
            return DalFactory.DeletePropertyType(propertyTypeId);
        }
        public List<PmsEntity.PropertyType> GetAllPropertyType()
        {
            return DalFactory.GetAllPropertyType();
        }

        public bool AddRoomRate(List<PmsEntity.Rate> rates)
        {
            var propertyId = rates[0].PropertyId.Value;
            var rateXml = PmsConverter.SerializeObjectToXmlString(rates);
            if (string.IsNullOrWhiteSpace(rateXml)) return false;
            
            rateXml = RemoveXmlDefaultNode(rateXml);
            rateXml = rateXml.Replace("ArrayOfRate", "Rates");
            //var logService = LoggingManager.GetLogInstance();
            //logService.LogInformation("ratexml :" + rateXml);

            return DalFactory.AddRoomRate(propertyId, rateXml);
        }
        public bool UpdateRoomRate(List<PmsEntity.Rate> rates)
        {
            var propertyId = rates[0].PropertyId.Value;
            var rateXml = PmsConverter.SerializeObjectToXmlString(rates);
            if (string.IsNullOrWhiteSpace(rateXml)) return false;

            rateXml = RemoveXmlDefaultNode(rateXml);
            rateXml = rateXml.Replace("ArrayOfRate", "Rates");
            //var logService = LoggingManager.GetLogInstance();
            //logService.LogInformation("ratexml :" + rateXml);

            return DalFactory.UpdateRoomRate(propertyId, rateXml);

        }
        public bool DeleteRoomRate(int rateId)
        {
            return DalFactory.DeleteRoomRate(rateId);
        }
        public bool AddRoom(List<PmsEntity.Room> room)
        {
            var propertyId = room[0].PropertyId;
            var roomXml = PmsConverter.SerializeObjectToXmlString(room);
            if (string.IsNullOrWhiteSpace(roomXml)) 
                return false;

            roomXml = RemoveXmlDefaultNode(roomXml);
            roomXml = roomXml.Replace("ArrayOfRoom", "Rooms");

            //var logService = LoggingManager.GetLogInstance();
            //logService.LogException("roomXml :" + roomXml);

            return DalFactory.AddRoom(propertyId, roomXml);
        }
        public bool UpdateRoom(List<PmsEntity.Room> room)
        {
            var propertyId = room[0].PropertyId;
            var roomXml = PmsConverter.SerializeObjectToXmlString(room);
            if (string.IsNullOrWhiteSpace(roomXml))
                return false;

            roomXml = RemoveXmlDefaultNode(roomXml);
            roomXml = roomXml.Replace("ArrayOfRoom", "Rooms");

            //var logService = LoggingManager.GetLogInstance();
            //logService.LogException("roomXml :" + roomXml);

            return DalFactory.UpdateRoom(propertyId, roomXml);
        }
        public bool DeleteRoom(int roomId)
        {
            return DalFactory.DeleteRoom(roomId);
        }
        public List<PmsEntity.Room> GetRoomByProperty(int propertyId)
        {
            return DalFactory.GetRoomByProperty(propertyId);
        }
        public int AddRateType(PmsEntity.RateType rateType)
        {
            return DalFactory.AddRateType(rateType);
        }
        public bool UpdateRateType(PmsEntity.RateType rateType)
        {
            return DalFactory.UpdateRateType(rateType);
        }
        public bool DeleteRateType(int rateTypeId)
        {
            return DalFactory.DeleteRateType(rateTypeId);
        }
        public List<PmsEntity.RateType> GetRateTypeByProperty(int propertyId)
        {
            return DalFactory.GetRateTypeByProperty(propertyId);
        }
        public int AddRoomType(PmsEntity.RoomType roomType)
        {
            return DalFactory.AddRoomType(roomType);
        }
        public bool UpdateRoomType(PmsEntity.RoomType roomType)
        {
            return DalFactory.UpdateRoomType(roomType);
        }
        public bool DeleteRoomType(int roomTypeId)
        {
            return DalFactory.DeleteRoomType(roomTypeId);
        }
        public List<PmsEntity.RoomType> GetRoomTypeByProperty(int propertyId)
        {
            return DalFactory.GetRoomTypeByProperty(propertyId);
        }
        public int AddRoomPrice(PmsEntity.RoomPricing roomPrice)
        {
            return DalFactory.AddRoomPrice(roomPrice);
        }
        public bool UpdateRoomPrice(PmsEntity.RoomPricing roomPrice)
        {
            return DalFactory.UpdateRoomPrice(roomPrice);
        }
        public bool DeleteRoomPrice(int priceId)
        {
            return DalFactory.DeleteRoomPrice(priceId);
        }
        public List<PmsEntity.RoomPricing> GetRoomPriceByProperty(int propertyId)
        {
            return DalFactory.GetRoomPriceByProperty(propertyId);
        }
        public int AddRoomStatus(PmsEntity.RoomStatus roomStatus)
        {
            return DalFactory.AddRoomStatus(roomStatus);
        }
        public bool UpdateRoomStatus(PmsEntity.RoomStatus roomStatus)
        {
            return DalFactory.UpdateRoomStatus(roomStatus);
        }
        public bool DeleteRoomStatus(int statusId)
        {
            return DalFactory.DeleteRoomStatus(statusId);
        }
        public List<PmsEntity.RoomStatus> GetRoomStatus()
        {
            return DalFactory.GetRoomStatus();
        }
        public int AddReward(PmsEntity.GuestReward reward)
        {
            return DalFactory.AddReward(reward);
        }
        public bool UpdateReward(PmsEntity.GuestReward reward)
        {
            return DalFactory.UpdateReward(reward);
        }
        public bool DeleteReward(int rewardId)
        {
            return DalFactory.DeleteReward(rewardId);
        }
        public List<PmsEntity.GuestReward> GetAllReward()
        {
            return DalFactory.GetAllReward();
        }
        public List<PmsEntity.GuestReward> GetRewardByGuestId(int guestId)
        {
            return DalFactory.GetRewardByGuestId(guestId);
        }
        public int AddRewardCategory(PmsEntity.RewardCategory rewardCategory)
        {
            return DalFactory.AddRewardCategory(rewardCategory);
        }
        public bool UpdateRewardCategory(PmsEntity.RewardCategory rewardCategory)
        {
            return DalFactory.UpdateRewardCategory(rewardCategory);
        }
        public bool DeleteRewardCategory(int catId)
        {
            return DalFactory.DeleteRewardCategory(catId);
        }
        public List<PmsEntity.RewardCategory> GetAllRewardCategory()
        {
            return DalFactory.GetAllRewardCategory();
        }
        public List<PmsEntity.Room> GetRoomByDate(GetRoomByDateRequestDto request)
        {
            return DalFactory.GetRoomByDate(request.PropertyId, request.CheckinDate, request.CheckoutDate);
        }
        public List<PmsEntity.Booking> GetGuestHistory(int guestId)
        {
            return DalFactory.GetGuestHistory(guestId);
        }

        public bool UpdateBooking(PmsEntity.Booking booking)
        {
            return DalFactory.UpdateBooking(booking);
        }
        public List<PmsEntity.State> GetStateByCountry(int id)
        {
            return DalFactory.GetStateByCountry(id);
        }

        public List<PmsEntity.City> GetCityByState(int id)
        {
            return DalFactory.GetCityByState(id);
        }

        public List<PmsEntity.Country> GetCountry()
        {
            return DalFactory.GetCountry();
        }
        public List<PmsEntity.Guest> GetAllGuest()
        {
            return DalFactory.GetAllGuest();
        }

        public List<PmsEntity.Tax> GetPaymentCharges(GetPaymentChargesRequestDto request)
        {
            return DalFactory.GetPaymentCharges(request.PropertyId, request.RoomTypeId, request.RateTypeId, request.NoOfHours, request.IsHourly, request.RoomId);
        }

        public int AddInvoice(PmsEntity.Invoice invoice)
        {
            var propertyId = invoice.PropertyId;
            var invoiceXml = PmsConverter.SerializeObjectToXmlString(invoice);
            
            if (string.IsNullOrWhiteSpace(invoiceXml)) return -1;

            invoiceXml = RemoveXmlDefaultNode(invoiceXml);
            
            //var logService = LoggingManager.GetLogInstance();
            //logService.LogInformation("invoice xml:" + invoiceXml);

            return DalFactory.AddInvoice(propertyId, invoiceXml);

        }
        public PmsEntity.Invoice GetInvoiceById(int invoiceId)
        {
            return DalFactory.GetInvoiceById(invoiceId);
        }

        public PmsEntity.Booking GetBookingById(int bookingId)
        {
            return DalFactory.GetBookingById(bookingId);
        }

        public int AddPaymentType(PmsEntity.PaymentType paymentType)
        {
            return DalFactory.AddPaymentType(paymentType);
        }

        public bool UpdatePaymentType(PmsEntity.PaymentType paymentType)
        {
            return DalFactory.UpdatePaymentType(paymentType);
        }

        public bool DeletePaymentType(int paymentTypeId)
        {
            return DalFactory.DeletePaymentType(paymentTypeId);
        }

        public List<PmsEntity.PaymentType> GetPaymentTypeByProperty(int propertyId)
        {
            return DalFactory.GetPaymentTypeByProperty(propertyId);
        }

        //Property Floor

        public int AddFloor(PmsEntity.PropertyFloor propertyFloor)
        {
            return DalFactory.AddFloor(propertyFloor);
        }

        public bool UpdateFloor(PmsEntity.PropertyFloor propertyFloor)
        {

            return DalFactory.UpdateFloor(propertyFloor);
        }

        public bool DeleteFloor(int propertyFloorId)
        {

            return DalFactory.DeleteFloor(propertyFloorId);
        }

        public List<PmsEntity.PropertyFloor> GetFloorsByProperty(int propertyId)
        {
            return DalFactory.GetFloorsByProperty(propertyId);
        }


        public int AddExtraCharge(PmsEntity.ExtraCharge extraCharge)
        {
            return DalFactory.AddExtraCharge(extraCharge);
        }

        public bool UpdateExtraCharge(PmsEntity.ExtraCharge extraCharge)
        {
            return DalFactory.UpdateExtraCharge(extraCharge);
        }

        public bool DeleteExtraCharge(int extraChargeId)
        {
            return DalFactory.DeleteExtraCharge(extraChargeId);
        }

        public List<PmsEntity.ExtraCharge> GetExtraCharges(int propertyId)
        {
            return DalFactory.GetExtraCharges(propertyId);
        }


        public int AddTax(PmsEntity.Tax tax)
        {
            return DalFactory.AddTax(tax);
        }

        public bool UpdateTax(PmsEntity.Tax tax)
        {
            return DalFactory.UpdateTax(tax);
        }

        public bool DeleteTax(int TaxId)
        {
            return DalFactory.DeleteTax(TaxId);
        }

        public List<PmsEntity.Tax> GetTaxByProperty(int propertyId)
        {
            return DalFactory.GetTaxByProperty(propertyId);
        }

        public List<PmsEntity.RateType> GetRoomRateByProperty(int propertyId)
        {
            return DalFactory.GetRoomRateByProperty(propertyId);
        }

        #region Helper method

        private string RemoveXmlDefaultNode(string xml)
        {
            var idxStartNode = xml.IndexOf("<?");
            var idxEndNode = xml.IndexOf("?>");
            var length = idxEndNode - idxStartNode + 2;
            xml = xml.Remove(idxStartNode, length);
            return xml;
        }
        #endregion
    }
}
