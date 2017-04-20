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
        bool AddBooking(PmsEntity.Booking booking);
    }
}
