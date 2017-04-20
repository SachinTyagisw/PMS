using PmsEntity = PMS.Resources.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PMS.Resources.Common.Converter;

namespace PMS.Resources.DAL
{
    public class DalFactory : IDalFactory
    {
        public void LogExceptionToDb(PmsEntity.ExceptionLog additionalExData)
        {
            throw new NotImplementedException();
        }
        public bool AddBooking(PmsEntity.Booking booking)
        {
            var xml = PmsConverter.SerializeObjectToXmlString(booking);
            return true;
        }
    }
}
