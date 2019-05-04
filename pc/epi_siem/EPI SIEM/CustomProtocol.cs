using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EPI_SIEM
{
    class CustomProtocol
    {
        private Command command;
        public Response response;
        private bool hasData = false;
        private List<Tuple<string, string>> list = new List<Tuple<string, string>>();
        public byte[] Data = null;

        public CustomProtocol()
        {
        }

        public CustomProtocol(Command command)
        {
            this.command = command;
        }

        public CustomProtocol(Command command, byte[] data)
        {
            this.command = command;
            this.Data = data;
        }

        public bool HasData()
        {
            return hasData;
        }

        public String GetStringCommand()
        {
            StringBuilder builder = new StringBuilder();

            builder.Append(command.ToString());
            builder.Append(":");
            if (Data != null)
            {
                builder.Append("HasData:");
                hasData = true;
            }
            foreach (var item in list)
            {
                builder.Append(item.Item1);
                builder.Append("=");
                builder.Append(item.Item2);
                builder.Append(":");
            }

            return builder.ToString();
        }

        public void ParseStringCommand(String str)
        {
            String[] tokens = str.Split(":".ToCharArray(), StringSplitOptions.RemoveEmptyEntries);
            if (tokens.Length >= 1)
            {
                switch (tokens[0])
                {
                    case "Ok":
                        response = Response.Ok;
                        break;
                    case "Error":
                        response = Response.Error;
                        break;
                    case "Warning":
                        response = Response.Warning;
                        break;
                    default:
                        return;
                }
            }
            if (tokens.Length >= 2)
            {
                if (tokens[1].Equals("HasData"))
                {
                    hasData = true;
                }
            }
            foreach (var item in tokens)
            {
                if (item.Contains("="))
                {
                    String[] kv = item.Split("=".ToCharArray(), StringSplitOptions.RemoveEmptyEntries);
                    AddAttribute(kv[0], kv[1]);
                }
            }
        }

        public Register GetRegister()
        {
            Register reg = new Register();
            reg.Engine = "0";
            reg.Time = DateTime.Now.ToString("d MMM h:mm:ss tt");
            reg.IpS = Register.GetLongIpFormat(GetAttribute("SourceIp"));
            reg.IpD = Register.GetLongIpFormat(GetAttribute("DestinationIp"));
            reg.PortS = GetAttribute("SourcePort");
            reg.PortD = GetAttribute("DestinationPort");
            reg.Protocol = Register.GetProtocolName(GetAttribute("Protocol"));
            reg.Data = Data;
            return reg;
        }

        public void AddAttribute(String key, String value)
        {
            list.Add(new Tuple<string, string>(key, value));
        }

        public String GetAttribute(String key)
        {
            foreach (var item in list)
            {
                if (item.Item1.Equals(key))
                {
                    return item.Item2;
                }
            }
            return null;
        }

    }
    
    public enum Command
    {
        GetMaxEnginesNumber,
        GetMaxEngineLength,
        GetEnginePattern,
        SetEnginePattern,
        StartListen,
        StopListen,
        ResponseReceived,
        Exit,

    }

    public enum Response
    {
        Ok,
        Error,
        Warning,
    }
}
