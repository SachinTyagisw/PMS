using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using log4net;
using System.Globalization;
using PMS.Resources.Entities;
using PMS.Resources.DAL;
using System.Web;

namespace PMS.Resources.Logging.Logger
{
    public class LogService : ILogService
    {
        private readonly ILog _logger;
        private readonly IDalFactory _dalFactory;

        public LogService()
        {
             log4net.Config.XmlConfigurator.Configure();
            _logger = LogManager.GetLogger(GetType());
            if (_dalFactory == null)
            {
                _dalFactory = (IDalFactory)HttpContext.Current.Application["DalFactory"];
            }
        }

        public void LogInformation(string message, Exception exception = null)
        {
            if (_logger.IsInfoEnabled)
            {
                if (exception == null)
                {
                    _logger.Info(message);
                }
                else
                {
                    _logger.Info(message, exception);
                }
            }
        }

        public void LogInformationFormat(string format, params object[] args)
        {
            if (_logger.IsInfoEnabled)
            {
                this._logger.InfoFormat(CultureInfo.InvariantCulture, format, args);
            }
        }

        public void LogDebug(string message, Exception exception = null)
        {
            if (_logger.IsDebugEnabled)
            {
                if (exception == null)
                {
                    _logger.Debug(message);
                }
                else
                {
                    _logger.Debug(message, exception);
                }
            }
        }

        public void LogDebugFormat(string format, params object[] args)
        {
            if (_logger.IsDebugEnabled)
            {
                this._logger.DebugFormat(CultureInfo.InvariantCulture, format, args);
            }
        }

        public void LogWarning(string message, Exception exception = null)
        {
            if (_logger.IsWarnEnabled)
            {
                if (exception == null)
                {
                    _logger.Warn(message);
                }
                else
                {
                    _logger.Warn(message, exception);
                }
            }
        }

        public void LogWarningFormat(string format, params object[] args)
        {
            if (_logger.IsWarnEnabled)
            {
                this._logger.WarnFormat(CultureInfo.InvariantCulture, format, args);
            }
        }

        public void LogError(string message, Exception exception = null)
        {
            if (_logger.IsErrorEnabled)
            {
                if (exception == null)
                {
                    _logger.Error(message);
                }
                else
                {
                    _logger.Error(message, exception);
                }
            }
        }

        public void LogErrorFormat(string format, params object[] args)
        {
            if (_logger.IsErrorEnabled)
            {
                this._logger.ErrorFormat(CultureInfo.InvariantCulture, format, args);
            }
        }

        public void LogException(string message, Exception exception = null)
        {
            if (_logger.IsFatalEnabled)
            {
                if (exception == null)
                {
                    _logger.Fatal(message);
                }
                else
                {
                    _logger.Fatal(message, exception);
                };
            }
        }

        public void LogExceptionFormat(string format, params object[] args)
        {
            if (_logger.IsFatalEnabled)
            {
                this._logger.FatalFormat(CultureInfo.InvariantCulture, format, args);
            }
        }

        public bool IsDebugEnabled
        {
            get { return _logger.IsDebugEnabled; }
        }

        public void LogExceptionDataToDb(ExceptionLog additionalExData)
        {
            _dalFactory.LogExceptionToDb(additionalExData);
        }
    }
}
