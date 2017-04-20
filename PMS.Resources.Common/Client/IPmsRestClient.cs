using RestSharp;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Common.Client
{
    public interface IPmsRestClient
    {
        #region Interface Methods

        IRestResponse GetRequest(string baseUrl, string resourceUrl, string token = "");

        IRestResponse PostWithJson(string baseUrl, string resourceUrl, string jsonData, string token = "");

        IRestResponse PutWithJson(string baseUrl, string resourceUrl, string jsonData, string token = "");

        IRestResponse DeleteRequest(string baseUrl, string resourceUrl, string token = "");

        string GetAuthToken(string address, string body);

        #endregion 
    }
}
