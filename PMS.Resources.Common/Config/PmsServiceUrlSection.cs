using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Common.Config
{
    /// <summary>
    /// Configuration section for PmsServiceUrl
    /// </summary>
    public class PmsServiceUrlSection : ConfigurationSection
    {
        private const string PmsServiceUrlSectionName = "PmsServiceUrlConfiguration";
        private static PmsServiceUrlSection _section;

        /// <summary>
        /// Loads the PmsServiceUrl configuration section from configuration files
        /// </summary>
        /// <returns>PmsServiceUrlSection</returns>
        /// <exception cref="ConfigurationErrorsException">Thrown when there's an error loading the section</exception>
        public static PmsServiceUrlSection LoadSection()
        {
            if (_section != null) return _section;

            _section = ConfigurationManager.GetSection(PmsServiceUrlSectionName) as PmsServiceUrlSection;

            if (_section == null)
                throw new ConfigurationErrorsException(string.Format("Failed to load the PmsServiceUrl section: '{0}'",
                                                                     PmsServiceUrlSectionName));
            return _section;
        }

        /// <summary>
        /// A list of UrlSettings provided in the configuration section
        /// </summary>
        [ConfigurationProperty("UrlSettings")]
        public GenericConfigurationElementCollection<ServiceDependencyElement> UrlSettings
        {
            get
            {
                return this["UrlSettings"] as GenericConfigurationElementCollection<ServiceDependencyElement>;
            }
        }

    }
}
