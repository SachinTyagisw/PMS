using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Entities
{
    public class Property
    {
        public int Id { get; set; }
        public string PropertyDetails { get; set; }
        public bool IsActive { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string LastUpdatedBy { get; set; }
        public Nullable<System.DateTime> LastUpdatedOn { get; set; }
        public int UserId { get; set; }
        public int PropertyTypeId { get; set; }
        public string PropertyName { get; set; }
        public string SecondaryName { get; set; }
        public string PropertyCode { get; set; }
        public string FullAddress { get; set; }
        public string Phone { get; set; }
        public string Fax { get; set; }
        public string LogoPath { get; set; }
        public string WebSiteAddress { get; set; }
        public string TimeZone { get; set; }        
        public Nullable<int> CurrencyID { get; set; }
        public Nullable<System.TimeSpan> CheckinTime { get; set; }
        public Nullable<System.TimeSpan> CheckoutTime { get; set; }
        public Nullable<System.TimeSpan> CloseOfDayTime { get; set; }
        public State State { get; set; }
        public Country Country { get; set; }
        public City City { get; set; }
        public string Email { get; set; }
        public string Zipcode { get; set; }
    }
}
