using Microsoft.Owin;
using Owin;

//[assembly: OwinStartupAttribute(typeof(PMS.Web.Startup))]
namespace PMS.Web
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
