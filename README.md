# helloworld-net
Example app for .NET framework from the Microsoft [Hello World](https://docs.microsoft.com/en-us/visualstudio/get-started/csharp/tutorial-wpf) tutorial.  

## How to configure monitoring
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

Then run the script to download, install and configure the agent.  You will need to start PowerShell to run this.
```
& .\install-agent.ps1
```

Finally, start the Infrastructure agent as follows:
```
net start newrelic-infra
```

