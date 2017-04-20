using PMS.Resources.Common.Constants;
using PMS.Resources.Common.Helper;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Caching;

namespace PMS.Resources.Caching
{
    public class CacheProvider : ICacheProvider
    {
        private Double CacheDuration
        {
            get
            {
                return AppConfigReaderHelper.AppConfigToDouble(AppSettingKeys.CacheDuration);
            }            
        }

        private Boolean CacheEnabled
        {
            get
            {
                return AppConfigReaderHelper.AppConfigToBool(AppSettingKeys.CacheEnabled);
            }
        }

        /// <summary>
        /// return cache object based cache key
        /// </summary>
        /// <param name="rawKey"></param>
        /// <param name="dependentKey"></param>
        /// <returns>cache object</returns>
        public object GetCacheItem(string rawKey, string dependentKey)
        {
            if (!this.CacheEnabled) return null;
            return HttpRuntime.Cache[GetCacheKey(dependentKey, rawKey)];
        }

        /// <summary>
        /// add object for cache based on cache key
        /// </summary>
        /// <param name="rawKey"></param>
        /// <param name="dependentKey"></param>
        /// <param name="value"></param>
        public void AddCacheItem(string rawKey, string dependentKey, object value)
        {
            if (!this.CacheEnabled) return;

            var dataCache = HttpRuntime.Cache;
            var dependentKeyArr = new[] { dependentKey };

            // Make sure dependentKey is in the cache - if not, add it
            if (dataCache[dependentKeyArr[0]] == null)
            {
                dataCache[dependentKeyArr[0]] = DateTime.Now;
            }

            var cacheKey = GetCacheKey(dependentKeyArr[0], rawKey);

            // Add a CacheDependency
            var dependency = new CacheDependency(null, dependentKeyArr);

            //TODO: cache duration value from client where addcacheitem is called
            dataCache.Insert(cacheKey, value, dependency, DateTime.Now.AddSeconds(this.CacheDuration), Cache.NoSlidingExpiration);
        }

        /// <summary>
        /// remove object for cache based on cache key
        /// </summary>
        /// <param name="rawKey"></param>
        public void RemoveCacheItem(string rawKey)
        {
            if (!this.CacheEnabled) return;
            HttpContext.Current.Cache.Remove(rawKey);
        }

        #region helper methods

        private string GetCacheKey(string dependentKey, string cacheKey)
        {
            return string.Concat(dependentKey, "-", cacheKey);
        }

        #endregion
    }
}
