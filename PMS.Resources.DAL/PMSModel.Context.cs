﻿//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace PMS.Resources.DAL
{
    using System;
    using System.Data.Entity;
    using System.Data.Entity.Infrastructure;
    using System.Data.Entity.Core.Objects;
    using System.Linq;
    
    public partial class PmsEntities : DbContext
    {
        public PmsEntities()
            : base("name=PmsEntities")
        {
        }
    
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            throw new UnintentionalCodeFirstException();
        }
    
        public virtual DbSet<AdditionalGuest> AdditionalGuests { get; set; }
        public virtual DbSet<Address> Addresses { get; set; }
        public virtual DbSet<AddressType> AddressTypes { get; set; }
        public virtual DbSet<Booking> Bookings { get; set; }
        public virtual DbSet<ChargableFacility> ChargableFacilities { get; set; }
        public virtual DbSet<City> Cities { get; set; }
        public virtual DbSet<Country> Countries { get; set; }
        public virtual DbSet<Currency> Currencies { get; set; }
        public virtual DbSet<ExtraCharge> ExtraCharges { get; set; }
        public virtual DbSet<Guest> Guests { get; set; }
        public virtual DbSet<GuestMapping> GuestMappings { get; set; }
        public virtual DbSet<GuestReward> GuestRewards { get; set; }
        public virtual DbSet<IDType> IDTypes { get; set; }
        public virtual DbSet<Invoice> Invoices { get; set; }
        public virtual DbSet<InvoiceItem> InvoiceItems { get; set; }
        public virtual DbSet<InvoicePaymentDetail> InvoicePaymentDetails { get; set; }
        public virtual DbSet<InvoiceTaxDetail> InvoiceTaxDetails { get; set; }
        public virtual DbSet<PaymentType> PaymentTypes { get; set; }
        public virtual DbSet<Property> Properties { get; set; }
        public virtual DbSet<PropertyFloor> PropertyFloors { get; set; }
        public virtual DbSet<Rate> Rates { get; set; }
        public virtual DbSet<RateType> RateTypes { get; set; }
        public virtual DbSet<RewardCategory> RewardCategories { get; set; }
        public virtual DbSet<Room> Rooms { get; set; }
        public virtual DbSet<RoomBooking> RoomBookings { get; set; }
        public virtual DbSet<RoomPricing> RoomPricings { get; set; }
        public virtual DbSet<RoomType> RoomTypes { get; set; }
        public virtual DbSet<State> States { get; set; }
        public virtual DbSet<Tax> Taxes { get; set; }
        public virtual DbSet<User> Users { get; set; }
        public virtual DbSet<UsersPropertyMapping> UsersPropertyMappings { get; set; }
        public virtual DbSet<ExpenseCategory> ExpenseCategories { get; set; }
        public virtual DbSet<Expens> Expenses { get; set; }
        public virtual DbSet<Functionality> Functionalities { get; set; }
        public virtual DbSet<UsersFunctionalityMapping> UsersFunctionalityMappings { get; set; }
    
        public virtual ObjectResult<GETALLBOOKINGS_Result> GETALLBOOKINGS(Nullable<int> pROPERTYID, Nullable<System.DateTime> cHECKINTIME, Nullable<System.DateTime> cHECKOUTDATE)
        {
            var pROPERTYIDParameter = pROPERTYID.HasValue ?
                new ObjectParameter("PROPERTYID", pROPERTYID) :
                new ObjectParameter("PROPERTYID", typeof(int));
    
            var cHECKINTIMEParameter = cHECKINTIME.HasValue ?
                new ObjectParameter("CHECKINTIME", cHECKINTIME) :
                new ObjectParameter("CHECKINTIME", typeof(System.DateTime));
    
            var cHECKOUTDATEParameter = cHECKOUTDATE.HasValue ?
                new ObjectParameter("CHECKOUTDATE", cHECKOUTDATE) :
                new ObjectParameter("CHECKOUTDATE", typeof(System.DateTime));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<GETALLBOOKINGS_Result>("GETALLBOOKINGS", pROPERTYIDParameter, cHECKINTIMEParameter, cHECKOUTDATEParameter);
        }
    
        public virtual ObjectResult<GETALLGUESTS_Result> GETALLGUESTS()
        {
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<GETALLGUESTS_Result>("GETALLGUESTS");
        }
    
        public virtual ObjectResult<GETBOOKINGAMOUNT_Result> GETBOOKINGAMOUNT(Nullable<int> pROPERTYID, Nullable<int> rOOMTYPEID, Nullable<int> rATETYPEID, Nullable<int> nOOFHOURS, Nullable<int> nOOFDAYS, Nullable<bool> iSHOURLY, Nullable<int> roomID)
        {
            var pROPERTYIDParameter = pROPERTYID.HasValue ?
                new ObjectParameter("PROPERTYID", pROPERTYID) :
                new ObjectParameter("PROPERTYID", typeof(int));
    
            var rOOMTYPEIDParameter = rOOMTYPEID.HasValue ?
                new ObjectParameter("ROOMTYPEID", rOOMTYPEID) :
                new ObjectParameter("ROOMTYPEID", typeof(int));
    
            var rATETYPEIDParameter = rATETYPEID.HasValue ?
                new ObjectParameter("RATETYPEID", rATETYPEID) :
                new ObjectParameter("RATETYPEID", typeof(int));
    
            var nOOFHOURSParameter = nOOFHOURS.HasValue ?
                new ObjectParameter("NOOFHOURS", nOOFHOURS) :
                new ObjectParameter("NOOFHOURS", typeof(int));
    
            var nOOFDAYSParameter = nOOFDAYS.HasValue ?
                new ObjectParameter("NOOFDAYS", nOOFDAYS) :
                new ObjectParameter("NOOFDAYS", typeof(int));
    
            var iSHOURLYParameter = iSHOURLY.HasValue ?
                new ObjectParameter("ISHOURLY", iSHOURLY) :
                new ObjectParameter("ISHOURLY", typeof(bool));
    
            var roomIDParameter = roomID.HasValue ?
                new ObjectParameter("RoomID", roomID) :
                new ObjectParameter("RoomID", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<GETBOOKINGAMOUNT_Result>("GETBOOKINGAMOUNT", pROPERTYIDParameter, rOOMTYPEIDParameter, rATETYPEIDParameter, nOOFHOURSParameter, nOOFDAYSParameter, iSHOURLYParameter, roomIDParameter);
        }
    
        public virtual ObjectResult<GetBookingDetails_Result> GetBookingDetails(Nullable<int> bookingID)
        {
            var bookingIDParameter = bookingID.HasValue ?
                new ObjectParameter("BookingID", bookingID) :
                new ObjectParameter("BookingID", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<GetBookingDetails_Result>("GetBookingDetails", bookingIDParameter);
        }
    
        public virtual ObjectResult<GETGUESTTRANSACTIONS_Result> GETGUESTTRANSACTIONS(Nullable<int> gUESTID)
        {
            var gUESTIDParameter = gUESTID.HasValue ?
                new ObjectParameter("GUESTID", gUESTID) :
                new ObjectParameter("GUESTID", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<GETGUESTTRANSACTIONS_Result>("GETGUESTTRANSACTIONS", gUESTIDParameter);
        }
    
        public virtual ObjectResult<GETINVOICEDETAILS_Result> GETINVOICEDETAILS(Nullable<int> iNVOICEID, Nullable<int> pROPERTYID, Nullable<int> rOOMTYPEID, Nullable<int> rATETYPEID, Nullable<int> nOOFHOURS, Nullable<int> nOOFDAYS, Nullable<bool> iSHOURLY, Nullable<int> roomID)
        {
            var iNVOICEIDParameter = iNVOICEID.HasValue ?
                new ObjectParameter("INVOICEID", iNVOICEID) :
                new ObjectParameter("INVOICEID", typeof(int));
    
            var pROPERTYIDParameter = pROPERTYID.HasValue ?
                new ObjectParameter("PROPERTYID", pROPERTYID) :
                new ObjectParameter("PROPERTYID", typeof(int));
    
            var rOOMTYPEIDParameter = rOOMTYPEID.HasValue ?
                new ObjectParameter("ROOMTYPEID", rOOMTYPEID) :
                new ObjectParameter("ROOMTYPEID", typeof(int));
    
            var rATETYPEIDParameter = rATETYPEID.HasValue ?
                new ObjectParameter("RATETYPEID", rATETYPEID) :
                new ObjectParameter("RATETYPEID", typeof(int));
    
            var nOOFHOURSParameter = nOOFHOURS.HasValue ?
                new ObjectParameter("NOOFHOURS", nOOFHOURS) :
                new ObjectParameter("NOOFHOURS", typeof(int));
    
            var nOOFDAYSParameter = nOOFDAYS.HasValue ?
                new ObjectParameter("NOOFDAYS", nOOFDAYS) :
                new ObjectParameter("NOOFDAYS", typeof(int));
    
            var iSHOURLYParameter = iSHOURLY.HasValue ?
                new ObjectParameter("ISHOURLY", iSHOURLY) :
                new ObjectParameter("ISHOURLY", typeof(bool));
    
            var roomIDParameter = roomID.HasValue ?
                new ObjectParameter("RoomID", roomID) :
                new ObjectParameter("RoomID", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<GETINVOICEDETAILS_Result>("GETINVOICEDETAILS", iNVOICEIDParameter, pROPERTYIDParameter, rOOMTYPEIDParameter, rATETYPEIDParameter, nOOFHOURSParameter, nOOFDAYSParameter, iSHOURLYParameter, roomIDParameter);
        }
    
        public virtual ObjectResult<GetPropertiesByUser_Result> GetPropertiesByUser(string userName)
        {
            var userNameParameter = userName != null ?
                new ObjectParameter("UserName", userName) :
                new ObjectParameter("UserName", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<GetPropertiesByUser_Result>("GetPropertiesByUser", userNameParameter);
        }
    
        public virtual ObjectResult<GetRoomRates_Result> GetRoomRates(Nullable<int> propertyId)
        {
            var propertyIdParameter = propertyId.HasValue ?
                new ObjectParameter("PropertyId", propertyId) :
                new ObjectParameter("PropertyId", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<GetRoomRates_Result>("GetRoomRates", propertyIdParameter);
        }
    
        public virtual ObjectResult<GETROOMSTATUS_Result> GETROOMSTATUS(Nullable<int> pROPERTYID, Nullable<System.DateTime> cHECKINTIME, Nullable<System.DateTime> cHECKOUTDATE)
        {
            var pROPERTYIDParameter = pROPERTYID.HasValue ?
                new ObjectParameter("PROPERTYID", pROPERTYID) :
                new ObjectParameter("PROPERTYID", typeof(int));
    
            var cHECKINTIMEParameter = cHECKINTIME.HasValue ?
                new ObjectParameter("CHECKINTIME", cHECKINTIME) :
                new ObjectParameter("CHECKINTIME", typeof(System.DateTime));
    
            var cHECKOUTDATEParameter = cHECKOUTDATE.HasValue ?
                new ObjectParameter("CHECKOUTDATE", cHECKOUTDATE) :
                new ObjectParameter("CHECKOUTDATE", typeof(System.DateTime));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<GETROOMSTATUS_Result>("GETROOMSTATUS", pROPERTYIDParameter, cHECKINTIMEParameter, cHECKOUTDATEParameter);
        }
    
        public virtual ObjectResult<InsertBooking_Result> InsertBooking(Nullable<int> propertyID, string bookingXML, ObjectParameter bOOKINGID, ObjectParameter gUESTID, ObjectParameter rOOMBOOKINGID)
        {
            var propertyIDParameter = propertyID.HasValue ?
                new ObjectParameter("propertyID", propertyID) :
                new ObjectParameter("propertyID", typeof(int));
    
            var bookingXMLParameter = bookingXML != null ?
                new ObjectParameter("bookingXML", bookingXML) :
                new ObjectParameter("bookingXML", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<InsertBooking_Result>("InsertBooking", propertyIDParameter, bookingXMLParameter, bOOKINGID, gUESTID, rOOMBOOKINGID);
        }
    
        public virtual ObjectResult<Nullable<int>> InsertInvoice(Nullable<int> propertyID, string invoiceXML, ObjectParameter iNVOICEID)
        {
            var propertyIDParameter = propertyID.HasValue ?
                new ObjectParameter("propertyID", propertyID) :
                new ObjectParameter("propertyID", typeof(int));
    
            var invoiceXMLParameter = invoiceXML != null ?
                new ObjectParameter("InvoiceXML", invoiceXML) :
                new ObjectParameter("InvoiceXML", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<Nullable<int>>("InsertInvoice", propertyIDParameter, invoiceXMLParameter, iNVOICEID);
        }
    
        public virtual int InsertRoom(Nullable<int> propertyID, string roomXML)
        {
            var propertyIDParameter = propertyID.HasValue ?
                new ObjectParameter("propertyID", propertyID) :
                new ObjectParameter("propertyID", typeof(int));
    
            var roomXMLParameter = roomXML != null ?
                new ObjectParameter("RoomXML", roomXML) :
                new ObjectParameter("RoomXML", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("InsertRoom", propertyIDParameter, roomXMLParameter);
        }
    
        public virtual ObjectResult<Nullable<bool>> InsertRoomRates(Nullable<int> propertyID, string rateXML, ObjectParameter status)
        {
            var propertyIDParameter = propertyID.HasValue ?
                new ObjectParameter("propertyID", propertyID) :
                new ObjectParameter("propertyID", typeof(int));
    
            var rateXMLParameter = rateXML != null ?
                new ObjectParameter("RateXML", rateXML) :
                new ObjectParameter("RateXML", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<Nullable<bool>>("InsertRoomRates", propertyIDParameter, rateXMLParameter, status);
        }
    
        public virtual int UpdateBooking(Nullable<int> bOOKINGID, Nullable<System.DateTime> cHECKINTIME, Nullable<System.DateTime> cHECKOUTTIME, Nullable<int> roomID)
        {
            var bOOKINGIDParameter = bOOKINGID.HasValue ?
                new ObjectParameter("BOOKINGID", bOOKINGID) :
                new ObjectParameter("BOOKINGID", typeof(int));
    
            var cHECKINTIMEParameter = cHECKINTIME.HasValue ?
                new ObjectParameter("CHECKINTIME", cHECKINTIME) :
                new ObjectParameter("CHECKINTIME", typeof(System.DateTime));
    
            var cHECKOUTTIMEParameter = cHECKOUTTIME.HasValue ?
                new ObjectParameter("CHECKOUTTIME", cHECKOUTTIME) :
                new ObjectParameter("CHECKOUTTIME", typeof(System.DateTime));
    
            var roomIDParameter = roomID.HasValue ?
                new ObjectParameter("RoomID", roomID) :
                new ObjectParameter("RoomID", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("UpdateBooking", bOOKINGIDParameter, cHECKINTIMEParameter, cHECKOUTTIMEParameter, roomIDParameter);
        }
    
        public virtual ObjectResult<GetTransactionData_Result> GetTransactionData(Nullable<System.DateTime> startDate, Nullable<System.DateTime> endDate, string customerName, string roomType, Nullable<decimal> minAmountPaid, Nullable<decimal> maxAmountPaid, string paymentmode, Nullable<bool> transactionStatus, string propertyId)
        {
            var startDateParameter = startDate.HasValue ?
                new ObjectParameter("StartDate", startDate) :
                new ObjectParameter("StartDate", typeof(System.DateTime));
    
            var endDateParameter = endDate.HasValue ?
                new ObjectParameter("EndDate", endDate) :
                new ObjectParameter("EndDate", typeof(System.DateTime));
    
            var customerNameParameter = customerName != null ?
                new ObjectParameter("CustomerName", customerName) :
                new ObjectParameter("CustomerName", typeof(string));
    
            var roomTypeParameter = roomType != null ?
                new ObjectParameter("RoomType", roomType) :
                new ObjectParameter("RoomType", typeof(string));
    
            var minAmountPaidParameter = minAmountPaid.HasValue ?
                new ObjectParameter("MinAmountPaid", minAmountPaid) :
                new ObjectParameter("MinAmountPaid", typeof(decimal));
    
            var maxAmountPaidParameter = maxAmountPaid.HasValue ?
                new ObjectParameter("MaxAmountPaid", maxAmountPaid) :
                new ObjectParameter("MaxAmountPaid", typeof(decimal));
    
            var paymentmodeParameter = paymentmode != null ?
                new ObjectParameter("paymentmode", paymentmode) :
                new ObjectParameter("paymentmode", typeof(string));
    
            var transactionStatusParameter = transactionStatus.HasValue ?
                new ObjectParameter("TransactionStatus", transactionStatus) :
                new ObjectParameter("TransactionStatus", typeof(bool));
    
            var propertyIdParameter = propertyId != null ?
                new ObjectParameter("PropertyId", propertyId) :
                new ObjectParameter("PropertyId", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<GetTransactionData_Result>("GetTransactionData", startDateParameter, endDateParameter, customerNameParameter, roomTypeParameter, minAmountPaidParameter, maxAmountPaidParameter, paymentmodeParameter, transactionStatusParameter, propertyIdParameter);
        }
    
        public virtual ObjectResult<GetExpenseData_Result> GetExpenseData(Nullable<System.DateTime> startDate, Nullable<System.DateTime> endDate, Nullable<int> paymentTypeID, Nullable<int> expenseCategoryID, Nullable<decimal> amountPaidMin, Nullable<decimal> amountPaidMax, Nullable<int> propertyId)
        {
            var startDateParameter = startDate.HasValue ?
                new ObjectParameter("StartDate", startDate) :
                new ObjectParameter("StartDate", typeof(System.DateTime));
    
            var endDateParameter = endDate.HasValue ?
                new ObjectParameter("EndDate", endDate) :
                new ObjectParameter("EndDate", typeof(System.DateTime));
    
            var paymentTypeIDParameter = paymentTypeID.HasValue ?
                new ObjectParameter("PaymentTypeID", paymentTypeID) :
                new ObjectParameter("PaymentTypeID", typeof(int));
    
            var expenseCategoryIDParameter = expenseCategoryID.HasValue ?
                new ObjectParameter("ExpenseCategoryID", expenseCategoryID) :
                new ObjectParameter("ExpenseCategoryID", typeof(int));
    
            var amountPaidMinParameter = amountPaidMin.HasValue ?
                new ObjectParameter("AmountPaidMin", amountPaidMin) :
                new ObjectParameter("AmountPaidMin", typeof(decimal));
    
            var amountPaidMaxParameter = amountPaidMax.HasValue ?
                new ObjectParameter("AmountPaidMax", amountPaidMax) :
                new ObjectParameter("AmountPaidMax", typeof(decimal));
    
            var propertyIdParameter = propertyId.HasValue ?
                new ObjectParameter("PropertyId", propertyId) :
                new ObjectParameter("PropertyId", typeof(int));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<GetExpenseData_Result>("GetExpenseData", startDateParameter, endDateParameter, paymentTypeIDParameter, expenseCategoryIDParameter, amountPaidMinParameter, amountPaidMaxParameter, propertyIdParameter);
        }
    
        public virtual int InsertUserAccess(Nullable<int> userID, string functionalities, string properties, string createdBy)
        {
            var userIDParameter = userID.HasValue ?
                new ObjectParameter("UserID", userID) :
                new ObjectParameter("UserID", typeof(int));
    
            var functionalitiesParameter = functionalities != null ?
                new ObjectParameter("Functionalities", functionalities) :
                new ObjectParameter("Functionalities", typeof(string));
    
            var propertiesParameter = properties != null ?
                new ObjectParameter("Properties", properties) :
                new ObjectParameter("Properties", typeof(string));
    
            var createdByParameter = createdBy != null ?
                new ObjectParameter("CreatedBy", createdBy) :
                new ObjectParameter("CreatedBy", typeof(string));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction("InsertUserAccess", userIDParameter, functionalitiesParameter, propertiesParameter, createdByParameter);
        }
    
        public virtual ObjectResult<GETGuestSummary_Result> GETGuestSummary(Nullable<int> pROPERTYID, Nullable<System.DateTime> cURRENTDATE)
        {
            var pROPERTYIDParameter = pROPERTYID.HasValue ?
                new ObjectParameter("PROPERTYID", pROPERTYID) :
                new ObjectParameter("PROPERTYID", typeof(int));
    
            var cURRENTDATEParameter = cURRENTDATE.HasValue ?
                new ObjectParameter("CURRENTDATE", cURRENTDATE) :
                new ObjectParameter("CURRENTDATE", typeof(System.DateTime));
    
            return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<GETGuestSummary_Result>("GETGuestSummary", pROPERTYIDParameter, cURRENTDATEParameter);
        }
    }
}
