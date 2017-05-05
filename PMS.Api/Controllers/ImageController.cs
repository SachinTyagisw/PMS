using PMS.Resources.Common.Constants;
using PMS.Resources.Common.Helper;
using PMS.Resources.Core;
using PMS.Resources.DTO.Request;
using PMS.Resources.DTO.Response;
using PMS.Resources.Entities;
using PMS.Resources.Logging.CustomException;
using PMS.Resources.Logging.Logger;
using PMS.Resources.Logic;
using System;
using System.Collections.Generic;
using System.ComponentModel.Composition;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Web.Http;

namespace PMS.Api.Controllers
{
     [Export(typeof(IRestController))]
    [PartCreationPolicy(CreationPolicy.NonShared)]
    public partial class ImageController : ApiController, IRestController
    {
        /// <summary>
        /// Map Routes for REST
        /// </summary>
        /// <param name="config"></param>
        [System.Web.Http.NonAction]
        public void MapHttpRoutes(HttpConfiguration config)
        {
            MapHttpRoutesForImage(config);
        }
        private void MapHttpRoutesForImage(HttpConfiguration config)
        {
            config.Routes.MapHttpRoute(
             "ImageUpload",
             "api/v1/Image/ImageUpload",
             new { controller = "Image", action = "ImageUpload" }
             );
        }

        [HttpPost]
        public void ImageUpload()
        {
            var logService = LoggingManager.GetLogInstance();
            if (HttpContext.Current.Request.Files.AllKeys.Any())
            {
                // Get the uploaded image from the Files collection
                var httpPostedFile = HttpContext.Current.Request.Files["UploadedImage"];
                if (httpPostedFile != null)
                {
                    // Validate the uploaded image(optional)

                    // Get the complete file path
                    var fileSavePath = Path.Combine(HttpContext.Current.Server.MapPath("~/UploadedFiles"), httpPostedFile.FileName);
                    logService.LogInformation("file path :" + fileSavePath);
                    // Save the uploaded file to "UploadedFiles" folder
                    httpPostedFile.SaveAs(fileSavePath);
                }
                else
                {
                    logService.LogInformation("NO file path");
                }
            }
        }

    }
}
