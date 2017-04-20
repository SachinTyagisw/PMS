using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PMS.Resources.Logging.Logger
{
    public static class LoggingManager
    {
        private static ILogService _logger;

        public static ILogService GetLogInstance()
        {
            if (_logger == null)
            {
                _logger = new LogService();
            }
            return _logger;
        }
    }
}

