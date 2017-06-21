//------------------------------------------------------------------------------
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
    
    public partial class GetBookingDetails_Result
    {
        public int BookingID { get; set; }
        public int PropertyID { get; set; }
        public Nullable<System.DateTime> CheckinTime { get; set; }
        public Nullable<System.DateTime> CheckoutTime { get; set; }
        public Nullable<int> NoOfAdult { get; set; }
        public Nullable<int> NoOfChild { get; set; }
        public string GuestRemarks { get; set; }
        public string TransactionRemarks { get; set; }
        public bool IsActive { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string LastUpdatedBy { get; set; }
        public Nullable<System.DateTime> LastUpdatedOn { get; set; }
        public string Status { get; set; }
        public Nullable<bool> ISHOURLYCHECKIN { get; set; }
        public Nullable<int> HOURSTOSTAY { get; set; }
        public Nullable<int> AdditionalGuestID { get; set; }
        public string AdditionalGuestFirstName { get; set; }
        public string AdditionalGuestLastName { get; set; }
        public string AdditionalGuestIDPath { get; set; }
        public string AdditionalGuestGender { get; set; }
        public Nullable<int> RoomBookingRoomId { get; set; }
        public Nullable<int> RoomBookingID { get; set; }
        public Nullable<int> RoomBookingGuestID { get; set; }
        public Nullable<int> GuestMappingId { get; set; }
        public Nullable<int> IDTYPEID { get; set; }
        public Nullable<int> GuestMappingGuestID { get; set; }
        public string GuestMappingIDDETAILS { get; set; }
        public Nullable<System.DateTime> IDExpiryDate { get; set; }
        public string IDIssueState { get; set; }
        public string IDIssueCountry { get; set; }
        public Nullable<int> GuestID { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public Nullable<long> MobileNumber { get; set; }
        public string EmailAddress { get; set; }
        public Nullable<System.DateTime> DOB { get; set; }
        public string Gender { get; set; }
        public string PhotoPath { get; set; }
        public Nullable<int> InvoiceId { get; set; }
        public Nullable<int> RoomTypeID { get; set; }
        public string RoomTypeName { get; set; }
        public string RoomTypeShortName { get; set; }
        public Nullable<int> RoomID { get; set; }
        public string RoomNumber { get; set; }
        public Nullable<int> AddressID { get; set; }
        public Nullable<int> AddressTypeID { get; set; }
        public string Address1 { get; set; }
        public string Address2 { get; set; }
        public string AddressCity { get; set; }
        public string AddressState { get; set; }
        public string AddressZipCode { get; set; }
        public string AddressCountry { get; set; }
    }
}
