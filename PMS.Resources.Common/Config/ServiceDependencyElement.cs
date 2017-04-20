using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Common.Config
{
    /// <summary>
    /// Represents each dependency element within the url section
    /// </summary>
    public class ServiceDependencyElement : ConfigurationElement, IKeyContainer
    {
        /// <summary>
        /// Gets the name of the resourceurl attribute
        /// </summary>
        [ConfigurationProperty("resourceurl")]
        public string ResourceUrl
        {
            get
            {
                return this["resourceurl"] as string;
            }
        }

        /// <summary>
        /// Gets the value of the baseurl attribute
        /// </summary>
        [ConfigurationProperty("baseurl")]
        public string BaseUrl
        {
            get
            {
                return this["baseurl"] as string;
            }
        }

        /// <summary>
        /// Gets the name of the methodname attribute
        /// </summary>
        [ConfigurationProperty("methodname")]
        public string MethodName
        {
            get
            {
                return this["methodname"] as string;
            }
        }

        #region IKeyContainer Members

        public string Key
        {
            get { return MethodName; }
            set
            {
                // Do nothing
            }
        }

        #endregion
    }
}
