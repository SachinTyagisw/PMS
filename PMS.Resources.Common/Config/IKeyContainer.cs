using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Common.Config
{
    /// <summary>
    /// Interface representing a Configuration Element that has a key property
    /// </summary>
    public interface IKeyContainer
    {
        /// <summary>
        /// Key attribute of the Configuration Element
        /// </summary>
        string Key { get; set; }
    }
}
