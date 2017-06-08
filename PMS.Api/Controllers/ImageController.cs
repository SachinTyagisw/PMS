using PMS.Api.CustomStreamProvider;
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
using System.Threading.Tasks;
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
        public Task<IEnumerable<string>> ImageUpload()
        {
            var logService = LoggingManager.GetLogInstance();
            if (!HttpContext.Current.Request.Files.AllKeys.Any()) 
                throw new HttpResponseException(Request.CreateResponse(HttpStatusCode.NotAcceptable, "Invalid Request!"));  
            
            // Get the uploaded image from the Files collection
            var httpPostedFile = HttpContext.Current.Request.Files["UploadedImage"];
            if (httpPostedFile == null || !Request.Content.IsMimeMultipartContent()) 
                throw new HttpResponseException(Request.CreateResponse(HttpStatusCode.NotAcceptable, "Invalid Request!"));  

            /*Simulate large file upload*/  
            //System.Threading.Thread.Sleep(5000);
            var rootPath = HttpContext.Current.Server.MapPath("~/");
            var uploadDirectory = Convert.ToString(System.Configuration.ConfigurationManager.AppSettings["UploadDirectory"]);
            var fullPath = rootPath + uploadDirectory;
            
            if (!Directory.Exists(fullPath))
            {
                var di = Directory.CreateDirectory(fullPath);
                logService.LogInformation(uploadDirectory + " Directory Creation Time:" + Directory.GetCreationTime(fullPath));
            }
            
            var streamProvider = new CustomMultipartFormDataStreamProvider(fullPath);  
            var task = Request.Content.ReadAsMultipartAsync(streamProvider).ContinueWith(t =>  
            {  
                if (t.IsFaulted || t.IsCanceled)  
                    throw new HttpResponseException(HttpStatusCode.InternalServerError);  
  
                var fileInfo = streamProvider.FileData.Select(i =>  
                {  
                    var info = new FileInfo(i.LocalFileName);  
                    return "File saved as "  + info.FullName  + " (" +  info.Length +  ")";  
                });  
                return fileInfo;  
            });  
            return task;  
                    
            //// Validate the uploaded image(optional)

            //// Get the complete file path
            //var fileSavePath = Path.Combine(HttpContext.Current.Server.MapPath("~/UploadedFiles"), httpPostedFile.FileName);
            //logService.LogInformation("file path :" + fileSavePath);
            //// Save the uploaded file to "UploadedFiles" folder
            //httpPostedFile.SaveAs(fileSavePath);
        }

    }
}
