# Variables
$infraUrl = "https://download.newrelic.com/infrastructure_agent/windows/"
$infraFile = "newrelic-infra.msi"
$dotnetUrl = "https://download.newrelic.com/dot_net_agent/latest_release/"
$dotnetFile = "NewRelicDotNetAgent_x64.msi"
$dlPath = "c:\temp\"
$envFile = "newrelic.env"

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
    if ([string]::IsNullOrEmpty($env:NEW_RELIC_LICENSE_KEY)) {
        Write-Host "Env var NEW_RELIC_LICENSE_KEY must be set"
        exit
    }
}

function is_admin() {
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] “Administrator”)

    if (!$IsAdmin) {
        Write-Host "This script should be run as Administrator"
        exit
    }
}

function download_files(){
    Write-Host "Downloading New Relic Windows Infrastructure Agent"
    $dl = Invoke-WebRequest -uri $infraFullUrl -outfile $infraFullPath
    Write-Host $dl

    Write-Host "Downloading New Relic .NET Framework Agent"
    $dl = Invoke-WebRequest -uri $dotnetFullUrl -outfile $dotnetFullPath
    Write-Host $dl
}

function install() {
    $arguments = @(
        "/qn"
        "/i"
        $infraFullPath
        "GENERATE_CONFIG=true"
        "LICENSE_KEY=" + $env:NEW_RELIC_LICENSE_KEY
    )
    Write-Host "Installing $($infraFile)"
    $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -PassThru
    if ($process.ExitCode -ne 0){
        Write-Host "Installation Failed: exit code $($process.ExitCode)"
        exit
    }
    Write-Host "Success installing Infrastructure Agent"
    Remove-Item -path $infraFullPath

    $arguments = @(
        "/qb"
        "/i"
        $dotnetFullPath
        "INSTALLEVEL=1"
        "LICENSE_KEY=" + $env:NEW_RELIC_LICENSE_KEY
    )
    Write-Host "Installing $($dotnetFile)"
    $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -PassThru
    if ($process.ExitCode -ne 0){
        Write-Host "Installation Failed: exit code $($process.ExitCode)"
        exit
    }
    Write-Host "Success installing .NET Agent"
    Remove-Item -path $dotnetFullPath
}

# Execute functions
is_admin
set_env
download_files
install
