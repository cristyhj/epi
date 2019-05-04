using System;
using System.Collections.Generic;
using System.IO.Ports;
using System.Linq;
using System.Management;
using System.Text;
using System.Threading.Tasks;
using System.Windows;

namespace EPI_SIEM
{
    class UART
    {
        private static ManagementEventWatcher arrival;
        private static ManagementEventWatcher removal;

        public static event Action<String> RemovalEvent;
        public static event Action<String> InsertionEvent;

        private static SerialPort serial;
        private static int BAUD_RATE = 115200;

        public static void Connect()
        {
            String port = GetCorrectPort();
            if (port != null)
            {
                serial = new SerialPort(port, BAUD_RATE, Parity.None, 8, StopBits.Two);
                serial.Open();
                if (serial.IsOpen)
                {
                    InsertionEvent("Connected!");
                }
            }
            else
            {
                RemovalEvent("NOT Connected!");
            }
        }

        public static void Send(CustomProtocol command)
        {
            String com = command.GetStringCommand();
            serial.WriteLine(com);
            if (command.HasData())
            {
                serial.Write(command.Data, 0, command.Data.Length);
            }
        }

        public static CustomProtocol Receive()
        {
            String com = serial.ReadLine();
            //if (com.Equals("\r")) com = serial.ReadLine();
            CustomProtocol cp = new CustomProtocol();

            cp.ParseStringCommand(com);
            if (cp.HasData())
            {
                int len = int.Parse(cp.GetAttribute("DataLength"));
                cp.Data = new byte[len];
                System.Threading.Thread.Sleep(200);
                serial.Read(cp.Data, 0, len);
            }

            return cp;
        }

        private static String GetCorrectPort()
        {
            ManagementObjectSearcher searcher = 
                new ManagementObjectSearcher("root\\CIMV2", "SELECT * FROM Win32_PnPEntity WHERE Manufacturer = \"FTDI\"");

            foreach (ManagementObject queryObj in searcher.Get())
            {
                String[] hardwareId = queryObj["HardwareID"] as String[];
                String devName = queryObj["Name"] as String;
                String[] last = hardwareId[1].Split("&".ToCharArray());
                if (last[last.Length - 1].Equals("MI_01"))
                {
                    return devName.Split("()".ToCharArray(), StringSplitOptions.RemoveEmptyEntries).Last();
                }
            }
            return null;
        }

        private static bool IsCorrectPort(String port)
        {
            ManagementObjectSearcher searcher =
                new ManagementObjectSearcher("root\\CIMV2", "SELECT * FROM Win32_PnPEntity WHERE Manufacturer = \"FTDI\"");

            foreach (ManagementObject queryObj in searcher.Get())
            {
                String[] hardwareId = queryObj["HardwareID"] as String[];
                String devName = queryObj["Name"] as String;
                String[] last = hardwareId[1].Split("&".ToCharArray());
                if (last.Last().Equals("MI_01") && devName.Contains(port))
                {
                    return true;
                }
            }
            return false;
        }

        public static void RegisterEventWatcher()
        {
            String[] ports = SerialPort.GetPortNames();
            try
            {
                var deviceArrivalQuery = new WqlEventQuery("SELECT * FROM Win32_DeviceChangeEvent WHERE EventType = 2");
                var deviceRemovalQuery = new WqlEventQuery("SELECT * FROM Win32_DeviceChangeEvent WHERE EventType = 3");

                arrival = new ManagementEventWatcher(deviceArrivalQuery);
                removal = new ManagementEventWatcher(deviceRemovalQuery);

                arrival.EventArrived += (o, args) => RaisePortsChangedIfNecessary(EventType.Insertion);
                removal.EventArrived += (sender, eventArgs) => RaisePortsChangedIfNecessary(EventType.Removal);

                // Start listening for events
                arrival.Start();
                removal.Start();
            }
            catch (ManagementException err)
            {
                MessageBox.Show(err.Message, "Management Exception!", MessageBoxButton.OK, MessageBoxImage.Asterisk);
            }
        }
        private static void RaisePortsChangedIfNecessary(EventType eventType)
        {
            if (eventType == EventType.Removal)
            {
                RemovalEvent("Hardware Removed!");
            }
            if (eventType == EventType.Insertion)
            {
                Connect();
            }
        }

        private enum EventType
        {
            Insertion,
            Removal,
        }

    }
}
