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
    }
}
