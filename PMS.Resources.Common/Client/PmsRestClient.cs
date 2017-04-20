using Newtonsoft.Json;
using RestSharp;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Common.Client
{
    public class PmsRestClient : IPmsRestClient
    {
        RestClient restClient = null;
        RestRequest restRequest = null;

        public PmsRestClient()
        {
            if(restClient == null)
            {
                restClient = new RestClient();
            }
            
            if(restRequest == null)
            {
                restRequest = new RestRequest();
            }
            
        }

        #region Interface Methods

        public IRestResponse GetRequest(string baseUrl, string resourceUrl, string token = "")
        {
            var request = CreateRequest(ref restClient, baseUrl, resourceUrl, Method.GET, token);
            request.RequestFormat = DataFormat.Json;
            return restClient.Execute(request);
        }

        public IRestResponse PostWithJson(string baseUrl, string resourceUrl, string jsonData, string token = "")
        {
            var request = CreateRequest(ref restClient, baseUrl, resourceUrl, Method.POST, token);            
            request.AddParameter("text/json", jsonData, ParameterType.RequestBody);
            request.RequestFormat = DataFormat.Json;
            return restClient.Execute(request);
        }

        public IRestResponse PutWithJson(string baseUrl, string resourceUrl, string jsonData, string token = "")
        {
            var request = CreateRequest(ref restClient, baseUrl, resourceUrl, Method.PUT, token);    
            request.AddParameter("text/json", jsonData, ParameterType.RequestBody);
            request.RequestFormat = DataFormat.Json;
            return restClient.Execute(request);
        }

        public IRestResponse DeleteRequest(string baseUrl, string resourceUrl, string token = "")
        {
            var request = CreateRequest(ref restClient, baseUrl, resourceUrl, Method.DELETE, token);    
            return restClient.Execute(request);
        }

        public string GetAuthToken(string address, string body)
        {
            var client = new RestClient(address);
            var request = new RestRequest(Method.POST);
            string encodedBody = string.Format(body);
            request.AddParameter("application/x-www-form-urlencoded", encodedBody, ParameterType.RequestBody);
            request.AddParameter("Content-Type", "application/x-www-form-urlencoded", ParameterType.HttpHeader);
            var response = restClient.Execute(request);
            return response.Content;
        }
       
        #endregion 

        #region Private Methods

        private RestRequest CreateRequest(ref RestClient restClient, string baseUrl, string resourceUrl, Method method, string token = "")
        {
            restClient.BaseUrl = new Uri(baseUrl);
            restRequest.Resource = resourceUrl;
            restRequest.Method = method;

            if (!string.IsNullOrWhiteSpace(token))
            {
                restRequest.AddHeader(HttpRequestHeader.Authorization.ToString(), "Bearer " + token);
            }
            
            return restRequest;
        }

        #endregion 
    }
}
