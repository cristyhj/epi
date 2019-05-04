using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.ComponentModel.Design;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.IO;
using System.Runtime.Serialization.Formatters.Binary;
using System.Threading;

namespace EPI_SIEM
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private Thread thread;
        private bool th_run = true;
        private bool once = true;

        private List<Register> regList = new List<Register>();
        private static event Action<String, List<Register>> RegListChanged;

        public MainWindow()
        {
            InitializeComponent();
            
            UART.RegisterEventWatcher();
            UART.RemovalEvent += new Action<string>(DisconnectedEventHandler);
            UART.InsertionEvent += new Action<string>(ConnectedEventHandler);
            RegListChanged += new Action<string, List<Register>>(RegListChangedHandler);
            UART.Connect();
        }

        private void RegListChangedHandler(String message, List<Register> list)
        {
            Dispatcher.Invoke(() =>
            {
                if (message.Equals("all"))
                {
                    listView.Items.Clear();
                    foreach (var item in list)
                    {
                        listView.Items.Add(item);
                    }
                }
                if (message.Equals("last"))
                {
                    listView.Items.Add(regList.Last());
                }
            });
        }

        private void ConnectedEventHandler(String message)
        {
            Dispatcher.Invoke(() =>
            {
                labelStatus.Content = message;
            });
        }

        private void DisconnectedEventHandler(String message)
        {
            Dispatcher.Invoke(() =>
            {
                labelStatus.Content = message;
            });
        }

        private void ButtonSearch_Click(object sender, RoutedEventArgs e)
        {
            if (buttonListen.Content.ToString().Equals("Start Listen"))
            {
                buttonListen.Content = "Stop Listen";
                labelStatus.Content = "Listening...";

                if (once)
                {
                    once = false;
                    thread = new Thread(() =>
                    {
                        while (true)
                        {
                            if (th_run)
                            {
                                CustomProtocol cp = UART.Receive();

                                Register reg = cp.GetRegister();
                                regList.Add(reg);
                                RegListChanged("last", null);

                                cp = new CustomProtocol(Command.ResponseReceived);
                                UART.Send(cp);
                            }
                        }
                    });
                    thread.Start();
                }
                th_run = true;
            }
            else if (buttonListen.Content.ToString().Equals("Stop Listen"))
            {
                buttonListen.Content = "Start Listen";
                labelStatus.Content = "Ready!";
                //CustomProtocol cp = new CustomProtocol(Command.Exit);
                //UART.Send(cp);
                th_run = false;
            }

        }

        private void ComboBox_Initialized(object sender, EventArgs e)
        {
            for (int i = 0; i < 16; i++) {
                comboBox.Items.Add(i.ToString());
            }
            comboBox.SelectedIndex = 0;
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            
        }

        private void Button1_Click(object sender, RoutedEventArgs e)
        {
            CustomProtocol cp = new CustomProtocol(Command.Exit);
            UART.Send(cp);
        }

        private void Button2_Copy_Click(object sender, RoutedEventArgs e)
        {
            CustomProtocol cp = new CustomProtocol(Command.GetEnginePattern);
            cp.AddAttribute("Engine", comboBox.SelectedValue as String);

            UART.Send(cp);

            cp = UART.Receive();
            if (cp.response == Response.Ok)
            {
                byteEditor2.Stream = new MemoryStream(cp.Data);
            }
        }

        private void Button2_Click(object sender, RoutedEventArgs e)
        {
            byte[] data = byteEditor2.GetAllBytes();
            if (data.Length <= 0 || data == null)
            {
                labelStatus.Content = "Insert data!";
                MessageBox.Show("Please type something!", "Warning!", MessageBoxButton.OK, MessageBoxImage.Information);
                return;
            }

            CustomProtocol cp = new CustomProtocol(Command.SetEnginePattern, data);
            cp.AddAttribute("DataLength", data.Length.ToString());
            cp.AddAttribute("Engine", comboBox.SelectedValue as String);

            UART.Send(cp);
            cp = UART.Receive();

            if (cp.response == Response.Ok)
            {
                labelStatus.Content = "Engine " + comboBox.SelectedValue + " set!";
            }
        }

        private void TextBox_Initialized(object sender, EventArgs e)
        {
            byteEditor2.Stream = new MemoryStream(new byte[256], 0, 256, true, true);
        }

        private void TextBox_KeyUp(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.Enter)
            {
                int len = int.Parse(textBox.Text);
                byteEditor2.Stream = new MemoryStream(new byte[len], 0, len, true, true);
            }
        }

        private void ListView_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            var reg = listView.SelectedItem as Register;
            byteEditor.Stream = new MemoryStream(reg.Data);
        }

        private void ButtonSearch_Click_1(object sender, RoutedEventArgs e)
        {
            String condition = textBox1.Text;
            List<Register> list = new List<Register>();
            foreach (var item in regList)
            {
                
            }
            var dsadas = regList.Where(x => ).ToList();
            
        }
    }
}
