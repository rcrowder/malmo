Import-Module .\pslib\malmo_lib.psm1

# get the malmo install dir
$MALMO_HOME = (Get-Item -Path "..\" -Verbose).FullName

# Make a temp directory for all the downloaded installers:
cd $env:HOMEPATH
if (-Not (Test-Path .\temp))
{
    mkdir temp
}

$error.clear()
try {
    # Install dependencies:
    Display-Heading "Checking dependencies"
    $InstallList = "Install-7Zip;
         Install-Ffmpeg;
         Install-Java;
         Install-Python;
         Install-XSD;
         Install-VCRedist;
         Install-Mesa;"
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
    {
        Write-Host "Elevating to admin ..."
        $InstallScript = [ScriptBlock]::Create("cd $env:HOMEPATH; Import-Module $MALMO_HOME\scripts\pslib\malmo_lib.psm1;" + $InstallList + "Check-Error")
        $process = Start-Process -FilePath powershell.exe -ArgumentList $InstallScript -verb RunAs -WorkingDirectory $env:HOMEPATH -PassThru -Wait
        if ($process.ExitCode)
        {
            throw new-object System.ApplicationException "Error while installing dependencies"
        }
    }
    else
    {
        $InstallScript = [ScriptBlock]::Create($InstallList)
        Invoke-Command $InstallScript
    }

    # Now install Malmo:
    Display-Heading ("Installing Malmo in " + $MALMO_HOME)
    cd $MALMO_HOME
    Add-MalmoXSDPathEnv $MALMO_HOME

} catch {
    Write-Host $error -foreground Red
    Write-Host "An error occurred, please check for error messages above. If the error persists, please raise an issue on https://github.com/Microsoft/malmo."
}

if (!$error) {

    Write-Host "Malmo installed successfully" -foreground Green

    Display-Heading "Run your first Malmo example"
    Write-Host "1. Launch the Malmo client" -foreground Yellow
    Write-Host ("   > cd " + $MALMO_HOME + "\Minecraft")
    Write-Host  "   > .\launchClient.bat"
    Write-Host "2. Start a second PowerShell and start an agent:" -foreground Yellow
    Write-Host ("   > cd " + $MALMO_HOME + "\Python_Examples")
    Write-Host ("   > python tabular_q_learning.py")

    Display-Heading "Further reading & getting help"
    Write-Host (" - Tutorial " + $MALMO_HOME + "\Python_Examples\Tutorial.pdf")
    Write-Host (" - More python examples: " + $MALMO_HOME + "\Python_Examples")
    Write-Host (" - Detailed documentation: " + $MALMO_HOME + "\Documentation\index.html.")
    Write-Host (" - Wiki (troubleshooting and more) : https://github.com/Microsoft/malmo/wiki.")
    Write-Host (" - Malmo gitter channel for community discussions: https://gitter.im/Microsoft/malmo.")
    Write-Host ""
}