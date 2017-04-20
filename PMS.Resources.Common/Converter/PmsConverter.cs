using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Serialization;

namespace PMS.Resources.Common.Converter
{
    public class PmsConverter
    {
        public static string SerializeObjectToXmlString<T>(T obj)
        {
            var xmls = new XmlSerializer(typeof(T));
            using (var ms = new MemoryStream())
            {
                var settings = new XmlWriterSettings();
                settings.Encoding = Encoding.UTF8;
                settings.ConformanceLevel = ConformanceLevel.Document;
                using (var writer = XmlTextWriter.Create(ms, settings))
                {
                    xmls.Serialize(writer, obj);
                }
                //string xml = Encoding.UTF8.GetString(ms.ToArray());
                ms.Seek(0, System.IO.SeekOrigin.Begin);
                string xml = new System.IO.StreamReader(ms).ReadToEnd();
                return xml;
            }
        }

        public static T DeserializeXmlStringToObject<T>(string xmlString)
        {
            var xmls = new XmlSerializer(typeof(T));
            using (var ms = new MemoryStream(Encoding.UTF8.GetBytes(xmlString)))
            {
                return (T)xmls.Deserialize(ms);
            }
        }

        public static string SerializeObjectToJson(object obj)
        {
            return JsonConvert.SerializeObject(obj);
        }

        public static T DeserializeJsonToObject<T>(string json)
        {
            return JsonConvert.DeserializeObject<T>(json);
        }
    }
}
