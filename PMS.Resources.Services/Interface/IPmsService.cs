using PMS.Resources.DTO.Request;
using PMS.Resources.DTO.Response;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Services.Interface
{
    public interface IPmsService
    {
        PmsResponseDto AddBooking(AddBookingRequestDto request);
    }
}
