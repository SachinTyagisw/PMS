using System.Web;
using System.Web.Optimization;

namespace PMS.Web
{
    public class BundleConfig
    {
        // For more information on bundling, visit http://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.UseCdn = true;
            //var jqueryCdnPath = "http://ajax.aspnetcdn.com/ajax/jQuery/jquery-3.1.1.min.js";
            //var jqueryBundle = new ScriptBundle("~/bundles/jquery", jqueryCdnPath).Include("~/Scripts/jquery-{version}.min.js");
            //jqueryBundle.CdnFallbackExpression = "window.jquery";
            //bundles.Add(jqueryBundle);

            //bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
            //            "~/Scripts/jquery-{version}.js"));

            //bundles.Add(new ScriptBundle("~/bundles/jqueryval").Include(
            //            "~/Scripts/jquery.validate*"));

            bundles.Add(new ScriptBundle("~/bundles/js/jquery").Include("~/Scripts/Jquery/jquery-2.2.3.min.js")
                .Include("~/Scripts/Jquery/jquery-ui.min.js")
                .Include("~/Scripts/Jquery/jquery.tmpl.js"));

            bundles.Add(new ScriptBundle("~/bundles/js/angular").Include("~/Scripts/Angular/angular.min.js")
                       .Include("~/Scripts/Angular/angular-resource.min.js")
                       .Include("~/Scripts/Angular/angular-route.min.js")
                       .Include("~/Scripts/Angular/ng-grid.min.js")
                       .Include("~/Scripts/Angular/ng-grid-flexible-height.min.js")
                       .Include("~/Scripts/daypilot/daypilot-all.min.js"));

            bundles.Add(new ScriptBundle("~/bundles/js/bootstrap").Include("~/Scripts/Bootstrap/bootstrap.min.js")
                        .Include("~/Scripts/Bootstrap/ui-bootstrap-tpls.min.js"));                       

            //bundles.Add(new ScriptBundle("~/bundles/js").Include("~/Scripts/loginModule.js")
            //            .Include("~/Scripts/index.js")
            //            .Include("~/Scripts/messageModalService.js")
            //            .Include("~/Scripts/tokenService.js")
            //            .Include("~/Scripts/authenticationService.js")
            //            .Include("~/Scripts/redirectionService.js")
            //            .Include("~/Scripts/productService.js")
            //            .Include("~/Scripts/userService.js")
            //            .Include("~/Scripts/loginController.js")
            //            .Include("~/Scripts/productController.js"));

            // Use the development version of Modernizr to develop with and learn from. Then, when you're
            // ready for production, use the build tool at http://modernizr.com to pick only the tests you need.
            //bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
            //            "~/Scripts/modernizr-*"));

            bundles.Add(new StyleBundle("~/bundles/css/bootstrap")
                       .Include("~/Content/Bootstrap/bootstrap.min.css"));
                       //.Include("~/Content/fonts/font.css"));
                //.Include("~/Css/font-awesome/font-awesome.min.css")
                //.Include("~/Css/ionicons/ionicons.min.css")
                // .Include("~/Content/jvectormap/jquery-jvectormap.min.css"));

            bundles.Add(new StyleBundle("~/bundles/daypilotmedia/css").Include("~/Content/daypilot-media/layout.css")
            .Include("~/Content/daypilot-media/custom.css")
            .Include("~/Content/daypilot-media/modal.css"));

            //bundles.Add(new StyleBundle("~/bundles/css/angular").Include("~/Content/Angular/ng-grid.min.css"));
        }
    }
}
