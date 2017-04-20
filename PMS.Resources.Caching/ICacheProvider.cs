using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Caching
{
    public interface ICacheProvider
    {
        /// <summary>
        /// return cache object based cache key
        /// </summary>
        /// <param name="rawKey"></param>
        /// <param name="dependentKey"></param>
        /// <returns>cache object</returns>
        object GetCacheItem(string rawKey, string dependentKey);

        /// <summary>
        /// add object for cache based on cache key
        /// </summary>
        /// <param name="rawKey"></param>
        /// <param name="dependentKey"></param>
        /// <param name="value"></param>
        void AddCacheItem(string rawKey, string dependentKey, object value);

        /// <summary>
        /// remove object for cache based on cache key
        /// </summary>
        /// <param name="rawKey"></param>
        void RemoveCacheItem(string rawKey);
    }
}
