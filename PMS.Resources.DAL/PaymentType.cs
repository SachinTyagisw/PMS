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
    using System.Collections.Generic;
    
    public partial class PaymentType
    {
        public int ID { get; set; }
        public Nullable<int> PropertyID { get; set; }
        public string ShortName { get; set; }
        public string Description { get; set; }
        public Nullable<bool> IsActive { get; set; }
        public string CreatedBy { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string LastUpdatedBy { get; set; }
        public Nullable<System.DateTime> LastUpdatedOn { get; set; }
    
        public virtual Property Property { get; set; }
    }
}
