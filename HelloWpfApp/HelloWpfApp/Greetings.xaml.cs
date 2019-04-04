using System.Windows;
using NewRelic.Api.Agent;
using newrelic = NewRelic.Api.Agent.NewRelic;

namespace HelloWpfApp
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        [Transaction]
        private void Button_Click(object sender, RoutedEventArgs e)
        {
            if (HelloButton.IsChecked == true)
            {
                MessageBox.Show("Hello!");
                newrelic.AddCustomParameter("WpfAppButton","Hello");
            }
            else if (GoodbyeButton.IsChecked == true)
            {
                MessageBox.Show("Goodbye!");
                newrelic.AddCustomParameter("WpfAppButton", "Goodbye");
            }
        }
    }
}
