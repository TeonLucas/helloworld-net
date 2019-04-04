# Variables
$infraUrl = "https://download.newrelic.com/infrastructure_agent/windows/"
$infraFile = "newrelic-infra.msi"
$dotnetUrl = "https://download.newrelic.com/dot_net_agent/latest_release/"
$dotnetFile = "NewRelicDotNetAgent_x64.msi"
$dlPath = "C:\temp\"
$envFile = "newrelic.env"
$configFile = "newrelic.config"
$configFullPath = "C:\ProgramData\New Relic\.NET Agent\" + $configFile

$infraFullUrl = $infraUrl + $infraFile
$infraFullPath = $dlPath + $infraFile
$dotnetFullUrl = $dotnetUrl + $dotnetFile
$dotnetFullPath = $dlPath + $dotnetFile

function set_env() {
    if (!(Test-Path -path $envFile)) {
        Write-Host "Copy newrelic.template.env to newrelic.env and configure"
        exit
    }
    Foreach ($line in (Get-Content -path $envFile | Where {$_ -notmatch '^#.*'})) {
        $var = $line.Split('=')
        [Environment]::SetEnvironmentVariable($var[0], $var[1], "Machine")
    }
    if ([string]::IsNullOrEmpty([Environment]::GetEnvironmentVariable("NEW_RELIC_LICENSE_KEY", "Machine"))) {
        Write-Host "Machine Env var NEW_RELIC_LICENSE_KEY must be set"
        exit
    }
}

function is_admin() {
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

    if (!$IsAdmin) {
        Write-Host "This script should be run as Administrator"
        exit
    }
}

function download_files(){
    Write-Host "Downloading New Relic Windows Infrastructure Agent"
    Invoke-WebRequest -uri $infraFullUrl -outfile $infraFullPath

    Write-Host "Downloading New Relic .NET Framework Agent"
    Invoke-WebRequest -uri $dotnetFullUrl -outfile $dotnetFullPath
}

function install() {
    $arguments = @(
        "/qn"
        "/i"
        $infraFullPath
        "GENERATE_CONFIG=true"
        "LICENSE_KEY=" + [Environment]::GetEnvironmentVariable("NEW_RELIC_LICENSE_KEY", "Machine")
    )
    Write-Host "Installing $($infraFile)"
    $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -PassThru
    if ($process.ExitCode -ne 0){
        Write-Host "Installation Failed: exit code $($process.ExitCode)"
        exit
    }
    Write-Host "Success: Infrastructure Agent installed"
    Remove-Item -path $infraFullPath

    $arguments = @(
        "/qb"
        "/i"
        $dotnetFullPath
        "INSTALLEVEL=1"
        "ADDLOCAL=ApiFeature"
        "LICENSE_KEY=" + [Environment]::GetEnvironmentVariable("NEW_RELIC_LICENSE_KEY", "Machine")
    )
    Write-Host "Installing $($dotnetFile)"
    $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -PassThru
    if ($process.ExitCode -ne 0){
        Write-Host "Installation Failed: exit code $($process.ExitCode)"
        exit
    }
    Write-Host "Success: .NET Agent installed"
    Remove-Item -path $dotnetFullPath
}

function edit_config {
    $local = ".\" + $configFile
    if (!(Test-Path -path $local)) {
        Write-Host "Could not find .NET config file template $($local))"
        exit
    }
    Write-Host "Updating .NET Agent config $($configFullPath)"
    (Get-Content -path $local) -replace "YOUR_LICENSE_KEY_HERE", [Environment]::GetEnvironmentVariable("NEW_RELIC_LICENSE_KEY", "Machine") | Set-Content -path $configFullPath
}

# Execute functions
is_admin
set_env
download_files
install
edit_config
