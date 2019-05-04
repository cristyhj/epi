using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EPI_SIEM
{
    class Register
    {
        public String Engine { get; set; }
        public String Time { get; set; }
        public String Protocol { get; set; }
        public String IpS { get; set; }
        public String PortS { get; set; }
        public String IpD { get; set; }
        public String PortD { get; set; }
        public byte[] Data { get; set; }

        public Register(string engine, string time, string protocol, string ipS, string portS, string ipD, string portD)
        {
            Engine = engine;
            Time = time;
            Protocol = protocol;
            IpS = ipS;
            PortS = portS;
            IpD = ipD;
            PortD = portD;
        }

        public Register()
        {
        }

        public static String GetLongIpFormat(String shortIp)
        {
            int ip = int.Parse(shortIp);
            uint ip2 = (uint)ip;
            uint a = ip2 & 0x000000FF;
            uint b = (ip2 & 0x0000FF00) >> 8;
            uint c = (ip2 & 0x00FF0000) >> 16;
            uint d = (ip2 & 0xFF000000) >> 24;
            return a.ToString() + "." + b.ToString() + "." + c.ToString() + "." + d.ToString();
        }

        public static String GetProtocolName(String number)
        {
            switch (number)
            {
                case "1":   return "ICMP";
                case "6":   return "TCP";
                case "16":   return "UDP";
                default:    return number;
            }
        }
    }
}
