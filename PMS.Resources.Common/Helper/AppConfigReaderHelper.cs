using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Common.Helper
{
    public class AppConfigReaderHelper
    {
        /// <summary>
        /// Method to read app config value and return as string
        /// </summary>
        /// <param name="appConfigKey">App config Key</param>
        /// <returns></returns>
        public static string AppConfigToString(string appConfigKey)
        {
            return InnerAppConfigToString(appConfigKey);
        }

        /// <summary>
        /// Method to read app config value and return as string
        /// </summary>
        /// <param name="appConfigKey">App config Key</param>
        /// <returns></returns>
        public static Double AppConfigToDouble(string appConfigKey)
        {
            return Convert.ToDouble(InnerAppConfigToString(appConfigKey));
        }

        /// <summary>
        /// Method to read app config value and return as string
        /// </summary>
        /// <param name="appConfigKey">App config Key</param>
        /// <returns></returns>
        public static Boolean AppConfigToBool(string appConfigKey)
        {
            return Convert.ToBoolean(InnerAppConfigToString(appConfigKey));
        }

        /// <summary>
        /// Gets the given connection string from configuration files
        /// </summary>
        /// <param name="connectionStringName">Name of the connection string to get</param>
        /// <returns>A string value representing the requested connection string</returns>
        public static string GetConnectionString(string connectionStringName)
        {
            return ConfigurationManager.ConnectionStrings[connectionStringName].ConnectionString;
        }

        /// <summary>
        /// Method to read app config value and return as string
        /// </summary>
        /// <param name="appConfigKey">App config Key</param>
        /// <returns></returns>
        private static string InnerAppConfigToString(string appConfigKey)
        {
            return ConfigurationManager.AppSettings[appConfigKey];
        }
    }
}
