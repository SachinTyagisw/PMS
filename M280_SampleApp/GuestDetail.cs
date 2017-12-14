using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace M280_SampleApp
{
    public class GuestDetail
    {
        public string Title { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Address { get; set; }
        public string Country { get; set; }
        public string State { get; set; }
        public string City { get; set; }
        public string Zip { get; set; }
        public string PhoneNo { get; set; }
        public string EmailId { get; set; }
        public string DOB { get; set; }
        public string IdNumber { get; set; }
        public string ExpiryDate { get; set; }
        public string IdType { get; set; }

    }

    public class GuestImages {
        public string ImageBase64 { get; set; }
    }
}
