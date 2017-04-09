    <#
    .SYNOPSIS
    Configure the host and register

    .DESCRIPTION
    Configure and register the host 
    Use Subscription ID,  

    .EXAMPLE
    $Path = Get-ASArtifactPath -NugetName "Microsoft.Diagnostics.Tracing.EventSource.Redist"

    .PARAMETER NugetName
    The full name of the nuget without version information.

    #>

    #requires -RunAsAdministrator


function install-MASPStools
{


    write-verbose "Install the AzureRM.Bootstrapper module"
    Install-Module -Name AzureRm.BootStrapper -Force -Confirm:$false

    write-verbose "Installs and imports the API Version Profile required by Azure Stack into the current PowerShell session."
    Use-AzureRmProfile -Profile 2017-03-09-profile -Force -Confirm:$false

    write-verbose "Install module AzureStack Version 1.2.9"
    Install-Module -Name AzureStack -RequiredVersion 1.2.9 -Force -Confirm:$false




}








    function test-OMComputerisHost
    {

        Write-verbose "Test if the script run on the AzureStack Host or inside a A VM"
        if ((Get-WmiObject -Class win32_computersystem | Select-Object -Expandproperty Model) -eq "Virtual Machine") {
		    return $false
	    }
	    else {
		    if (((Get-WindowsFeature Hyper-V | Select-Object -ExpandProperty Installstate) -eq "Installed")) {
                return $true
		    }
            else {
                throw "Error Hyper-V and Azure Stack is not instaled on this computer"
                Exit-PSHostProcess
            }
	    }
    }



function get-OMRegistrationFile
{
    	param (
		[Parameter(Mandatory = $false)]
		[string]$Folder="c:\TEMP"
	    )	

        write-verbose "Test if Folder $Folder exist"
        if(Test-Path -path $Folder -PathType Container)
        {

            write-verbose "Trying to download the RegisterWithAzure.ps1 file from GitHub into $Folder"

            Invoke-WebRequest "https://raw.githubusercontent.com/Azure/AzureStack-Tools/master/Registration/RegisterWithAzure.ps1" -OutFile "$Folder\RegisterWithAzure.ps1"

            return $true
        }
        else 
        {
           write-verbose "Error : Folder $Folder does not exist"
           return $false
            trhow "ERROR: Folder $Folder does not exist"
        }



}


function register-OMMASTP3
{
    
    [CmdletBinding()]
    Param     (
        [Parameter(Mandatory = $true)]
        [string]$MasADDir,

        [Parameter(Mandatory = $true)]
        [String]$MasSubsriptionID,

        [Parameter(Mandatory = $true)]
        [String]$MasAdmin,

        [Parameter(Mandatory = $true)]
        [securestring]$azureSubscriptionPassword,

        [Parameter(Mandatory = $false)]
        [String]$Folder="c:\TEMP"
    )


    begin 
    {
        write-verbose "Perform Setup of MAS PowerShell Tools"
        install-MASPStools
    }


    process {

        write-verbose "Test if the computer is the host"

        $isComputerHost = test-OMComputerisHost

        $isRegestrationExist = get-OMRegistrationFile -Folder $Folder

        if ($isComputerHost -AND $isRegestrationExist)
        {
            . "$folder\RegisterWithAzure.ps1"  -azureDirectory $MasADDir -azureSubscriptionId $MasSubsriptionID  -azureSubscriptionOwner $MasAdmin -verbose
        }


    }

    
}

