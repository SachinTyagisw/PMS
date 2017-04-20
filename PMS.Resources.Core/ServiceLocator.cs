using System;
using System.Collections.Generic;
using System.Reflection;
using System.ComponentModel.Composition.Hosting;
using System.Linq;
using System.Web;

namespace PMS.Resources.Core
{
    public sealed class ServiceLocator
    {
        private static volatile ServiceLocator instance;
        private static object syncRoot = new Object();
        private static Dictionary<object, object> serviceContainerWithOutKey = null;
        private static Dictionary<string, object> serviceContainerWithKey = null;
        private ServiceLocator() { }

        public static ServiceLocator Current
        {
            get
            {
                if (instance == null)
                {
                    lock (syncRoot)
                    {
                        if (instance == null)
                        {
                            instance = new ServiceLocator();
                            serviceContainerWithOutKey = new Dictionary<object, object>();
                            serviceContainerWithKey = new Dictionary<string, object>();
                        }
                    }
                }

                return instance;
            }
        }

        public TService GetInstance<TService>(string key = "")
        {
            try
            {
                var catalog = new AggregateCatalog(new AssemblyCatalog(Assembly.GetExecutingAssembly()), new DirectoryCatalog(HttpContext.Current.Server.MapPath("~/bin")));
                //catalog.Catalogs.Add(new AssemblyCatalog(typeof(TService).Assembly));
                CompositionContainer compContainer = new CompositionContainer(catalog);
                IEnumerable<Lazy<object, object>> exports = compContainer.GetExports(typeof(TService), null, key);
                var objTService = new object();

                if ((exports != null) && (exports.Count() > 0))
                {
                    if (!string.IsNullOrWhiteSpace(key))
                    {
                        // If there is more than one value, this will throw an InvalidOperationException, 
                        // which will be wrapped by the base class as an ActivationException.
                        if (!serviceContainerWithKey.ContainsKey(key))
                            serviceContainerWithKey.Add(key, (TService)Activator.CreateInstance(exports.Single().Value.GetType()));

                        objTService = (TService)serviceContainerWithKey[key];

                    }
                    else
                    {
                        // If there is more than one value, this will throw an InvalidOperationException, 
                        // which will be wrapped by the base class as an ActivationException.
                        if (!serviceContainerWithOutKey.ContainsKey(typeof(TService)))
                            serviceContainerWithOutKey.Add(typeof(TService), (TService)Activator.CreateInstance(exports.Single().Value.GetType()));
                        
                        objTService = (TService)serviceContainerWithOutKey[typeof(TService)];

                    }
                }

                return (TService)objTService;
            }
            catch
            {
                throw;
            }
        }

        public IEnumerable<TService> GetAllInstance<TService>(string key = "")
        {
            List<TService> listInstances = new List<TService>();

            try
            {
                var catalog = new AggregateCatalog(new AssemblyCatalog(Assembly.GetExecutingAssembly()), new DirectoryCatalog(HttpContext.Current.Server.MapPath("~/bin")));
                //catalog.Catalogs.Add(new AssemblyCatalog(typeof(TService).Assembly));
                CompositionContainer compContainer = new CompositionContainer(catalog);
                IEnumerable<Lazy<object, object>> exports = compContainer.GetExports(typeof(TService), null, key);

                if ((exports != null) && (exports.Count() > 0))
                {
                    // If there is more than one value, this will throw an InvalidOperationException, 
                    // which will be wrapped by the base class as an ActivationException.
                    if (!serviceContainerWithOutKey.ContainsKey(typeof(TService)))
                    {
                            foreach (var item in exports)
                            listInstances.Add((TService)Activator.CreateInstance(item.Value.GetType()));
                    }
                }

                return listInstances.AsEnumerable<TService>();
            }
            catch 
            {
                throw;
            }
        }

    }
}
