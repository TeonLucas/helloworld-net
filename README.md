# helloworld-net
Hello World app for .NET framework from the Microsoft [Hello World](https://docs.microsoft.com/en-us/visualstudio/get-started/csharp/tutorial-wpf) tutorial.  It assumes you are on a Windows machine.

## Monitoring setup
In addition there is an install script for New Relic monitoring, for both Windows infrastructure and the .NET application.

## How to configure monitoring
First copy the template to newrelic.env
```
copy newrelic.template.env newrelic.env
```

Next edit `newrelic.env` and set the license key on the first line:
```
NEW_RELIC_LICENSE_KEY=YOUR_LICENSE_KEY_HERE
```
Alternatively you can set this environment variable and it will be used by the install script.

Then run the install-agent script.  You will need to start PowerShell to run this.
```
& .\install-agent.ps1
```
This will download, install and configure the agent.

Finally, start the agent as follows:
```
net start newrelic-infra
```

