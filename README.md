# helloworld-net
Example app for .NET framework from the Microsoft [Hello World](https://docs.microsoft.com/en-us/visualstudio/get-started/csharp/tutorial-wpf) tutorial.

## Configure monitoring
This project assumes you are on a Windows machine.  It includes an install script for New Relic monitoring, for both Windows infrastructure and the .NET application.

First copy the template to newrelic.env
```
copy newrelic.template.env newrelic.env
```

Next edit `newrelic.env` and set the license key on the first line:
```
NEW_RELIC_LICENSE_KEY=YOUR_LICENSE_KEY_HERE
```
Alternatively you can set this environment variable and it will be used by the install script.

## Install the Agents using PowerShell
Then run the script to download, install and configure the agents.  You will need PowerShell to run this.
```
& .\install-agent.ps1
```
This installs and configures the Infrastructure and .NET agents, customizing the following 3 files:
1. `C:\Program Files\New Relic\newrelic-infra\newrelic-infra.yml`, the config file for the Infrastructure agent.  It is auto-generated when the PowerShell script runs msi-exec with the license key and generate config options.
2. `C:\ProgramData\New Relic\.NET Agent\newrelic.config`, the config file for the .NET agent, which specifies the executable to instrument.  The PowerShell script calls a function to edit this file and insert the license key.
3. `C:\Program Files\New Relic\.NET Agent\NewRelic.Api.Agent.dll`, the DLL used for custom attributes.  The PowerShell script runs msi-exec with `ADDLOCAL=ApiFeature` to include this DLL in the installation.

Finally, start the Infrastructure agent as follows:
```
net start newrelic-infra
```

## Build the example app
The subdirectory `HelloWpfApp` is a .NET application project which you can open with Visual Studio.  Once open, type Ctrl-B to build the executable.  You can then run the application as follows:
```
.\HelloWpfAp\HelloWpfApp\bin\Release\HelloWpfApp.exe
```

Select a radio button option and press the _Display_ button as shown below:
![Figure 1: App UI](https://github.com/DavidSantia/helloworld-net/blob/master/HelloWpfApp%20UI.png)

* Each time you press _Display_, it starts a transaction event.
* The radio button selection is reported as a custom attribute within that event.

Notice the directory `HelloWpfAp\HelloWpfApp\bin\Release` contains the Api Agent DLL.  This library is needed for the custom instrumentation used in [Greetings.xaml.cs](https://github.com/DavidSantia/helloworld-net/blob/master/HelloWpfApp/HelloWpfApp/Greetings.xaml.cs):
```
newrelic.AddCustomParameter("WpfAppButton","Hello")
```

The logs for the .NET agent will be in `C:\ProgramData\New Relic\.NET Agent\Logs`, check for a pair of these as follows:

1. `NewRelic.Profiler.1234.log`, which reports when instrumentation is added to a .NET application, as defined in the newrelic.config file which identifies the executable name.
2. `newrelic_agent_HelloWpfApp.log`, which is only created after you press the button on the app.  This log reports the connection to the New Relic collector, along with details about what is being monitored.

