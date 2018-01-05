using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PrimePMSService
{
    public static class Helper
    {
        public static string ToFormat(this string str, string pattern)
        {
            if (!string.IsNullOrEmpty(str))
            {
                return str.Split(new string[] { pattern }, StringSplitOptions.None)[1];
            }
            else {

                return "";
            }
        }
        public static string ToDate(this string str)
        {
            if (!string.IsNullOrEmpty(str))
            {
                return str.Substring(0,2)+"/"+ str.Substring(2,2)+ "/"+ str.Substring(4, 4);
            }
            else
            {

                return "";
            }
        }
    }
}
