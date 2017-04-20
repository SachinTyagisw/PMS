using PMS.Resources.Common.Client;
using PMS.Resources.Common.Config;
using PMS.Resources.Services.Interface;
using PMS.Resources.Common.Converter;
using PMS.Resources.DTO.Request;
using PMS.Resources.DTO.Response;
using PMS.Resources.Logging.CustomException;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Http;
using System.Reflection;
using System.Net;
using PMS.Resources.Common.Helper;
using System.Web;

namespace PMS.Resources.Services
{
    public class PmsService : IPmsService
    {
        private readonly IPmsRestClient _pmsRestClient = null;
        private readonly PmsServiceUrlSection _pmsServiceUrlSection = null;

        public PmsService()
        {
            _pmsRestClient = new PmsRestClient();
            _pmsServiceUrlSection = PmsServiceUrlSection.LoadSection();
        }

        public PmsResponseDto AddBooking(AddBookingRequestDto request)
        {
            var methodName = MethodBase.GetCurrentMethod().Name;

            //read url from config
            this.LoadUrlSettingsFromConfig(methodName);
            
            if (string.IsNullOrWhiteSpace(this.BaseUrl) || string.IsNullOrWhiteSpace(this.ResourceUrl))
                throw new PmsException("Invalid Booking Request Params");

            var jsonRequestDto = PmsConverter.SerializeObjectToJson(request);
            var jsonResponse = _pmsRestClient.PostWithJson(this.BaseUrl, this.ResourceUrl, jsonRequestDto);

            if (jsonResponse == null || !PmsHelper.IsValidJson(jsonResponse.Content)) return null;

            var jsonResponseDto = PmsConverter.DeserializeJsonToObject<PmsResponseDto>(jsonResponse.Content);

            return jsonResponseDto;
        }

        private string BaseUrl { get; set; }

        private string ResourceUrl { get; set; }

        private void LoadUrlSettingsFromConfig(string methodName)
        {
            var urlSettings = _pmsServiceUrlSection.UrlSettings;
            if (string.IsNullOrWhiteSpace(methodName) || urlSettings == null || urlSettings.Count <= 0) return;

            var urlConfigurationElement = urlSettings.FindElementByKey(methodName);
            if (urlConfigurationElement == null) return;

            BaseUrl = urlConfigurationElement.BaseUrl;
            ResourceUrl = urlConfigurationElement.ResourceUrl;
        }
    }
}
