<#
Template Made By Nicholas Schneider
#>

<#
Author: Nicholas Schneider
Date: 7/19/2022
Purpose: Seal up the image
#>

<# Global Variables #> 

# Declare all variables from templates in here

<# Global Variables #> 


<# Function Declarations #>

# Paste all function delcarations into this section

Function SCCM_Cleanup()
{
	cls
	Write-Host "Deleting McAfee reg keys..."
	Remove-ItemProperty -Name "AgentGUID" -Path "HKLM:\SOFTWARE\Wow6432Node\Network Associates\ePolicy Orchestrator\Agent" -Force
	Remove-ItemProperty -Name "LastASCTime" -Path "HKLM:\SOFTWARE\Wow6432Node\Network Associates\ePolicy Orchestrator\Agent" -Force

	Write-Host "Stopping the CCMEXEC service..."
	Get-Service -Name CCMEXEC| Stop-Service -Force

	Write-Host "Removing existing certificates from SMS store..."
    & Invoke-Expression 'certutil -delstore SMS "SMS"'
		
	Write-Host "Resetting site key information..."
	& Invoke-Expression "WMIC /NAMESPACE:\\root\ccm\locationservices Path TrustedRootKey DELETE"

	Write-Host "Removing Hardware Inventory Cycle Action Item..."
	Get-WmiObject -Namespace root\ccm\invagt -Class inventoryactionstatus | Where-Object {$_.inventoryactionid -eq "{00000000-0000-0000-0000-000000000001}"} | Remove-WmiObject

	$FileName = "C:\Windows\smscfg.ini"
	Write-Host "Deleting file $FileName..."
	if (Test-Path $FileName) 
	{
	  Remove-Item -Path $FileName -Force
	}

	Write-Host "Deleting SCCM reg keys..."
	Remove-Item -Path HKLM:\Software\Microsoft\SystemCertificates\SMS\Certificates\* -Force
}

Function CCleaner()
{
	Try{
		Write-Host "Running CCleaner"
		& "###########\CCleaner.exe" /AUTO
		Return $True
	}
	Catch
	{
		Return $False
	}
}

Function Check_Edge()
{
	Write-Host "Checking for Edge"
	$Edge_Response = Get-WMIObject -Class Win32_Product | Where-Object {$_.Name -eq "Microsoft Edge"}
	If($Edge_Response -ne $NULL)
	{
		Write-Host "Edge Found"
		Return $True
	}
	Write-Host "Edge Not Found"
	Return $False
}

Function Edge_Script()
{
		# Clear screen
	cls

	# Configure security protocol to use TLS 1.2 for new connections
	Write-Host "Configuring TLS1.2 security protocol for new connections" -ForegroundColor Cyan
	Write-Host ""
	[Net.ServicePointManager]::SecurityProtocol = "tls12"

	# Download latest NuGet Package Provider
	If (!(Test-Path -Path "C:\Program Files\PackageManagement\ProviderAssemblies\nuget"))
	{
	Write-Host "Installing latest NuGet Package Provider" -ForegroundColor Cyan
	Write-Host ""
	Find-PackageProvider -Name 'Nuget' -ForceBootstrap -IncludeDependencies | Out-Null
	}    

	# Download latest Evergreen module
	Write-Host "Installing latest Evergreen module" -ForegroundColor Cyan
	Write-Host ""
	If (!(Get-Module -ListAvailable -Name Evergreen))
	{
	Install-Module Evergreen -Force | Import-Module Evergreen
	}
	else
	{
	Update-Module Evergreen -Force
	}

	# Configure Evergreen variables
	$Vendor = "Microsoft"
	$Product = "Edge"
	$EvergreenApp = Get-EvergreenApp -Name MicrosoftEdge | Where-Object {$_.Architecture -eq "x64" -and $_.Channel -eq "Stable" -and $_.Release -eq "Enterprise"}
	$EvergreenAppInstaller = Split-Path -Path $EvergreenApp.Uri -Leaf
	$EvergreenAppURL = $EvergreenApp.uri
	$EvergreenAppVersion = $EvergreenApp.Version
	$Destination = "C:\GDE\$Vendor $Product"

	# Application install arguments 
	# This will prevent desktop and taskbar shortcuts from appearing during first logon 
	$InstallArguments = "REBOOT=ReallySuppress /qn DONOTCREATEDESKTOPSHORTCUT=true DONOTCREATETASKBARSHORTCUT=true"

	# Create destination folder, if not exist
	If (!(Test-Path -Path $Destination))
	{
	Write-Host "Creating $Destination" -ForegroundColor Cyan
	Write-Host ""
	New-Item -ItemType Directory -Path $Destination | Out-Null
	}

	# Download and deploy application
	Write-Host "Downloading latest $Vendor $Product release" -ForegroundColor Cyan
	Write-Host ""
	Invoke-WebRequest -UseBasicParsing -Uri $EvergreenAppURL -OutFile $Destination\$EvergreenAppInstaller

	Write-Host "Installing $Vendor $Product v$EvergreenAppVersion" -ForegroundColor Cyan
	Write-Host ""
	Start-Process -FilePath $Destination\$EvergreenAppInstaller -Wait -ArgumentList $InstallArguments

	# Application post deployment tasks
	Write-Host "Applying post setup customizations" -ForegroundColor Cyan

	# Disable Microsoft Edge auto update
	If (!(Test-Path -Path HKLM:SOFTWARE\Policies\Microsoft\EdgeUpdate))
	{
		New-Item -Path HKLM:SOFTWARE\Policies\Microsoft\EdgeUpdate
	}

	If (Get-ItemProperty -Path HKLM:SOFTWARE\Policies\Microsoft\EdgeUpdate -Name UpdateDefault -ErrorAction SilentlyContinue){
		Set-ItemProperty -Path HKLM:SOFTWARE\Policies\Microsoft\EdgeUpdate -Name UpdateDefault -Value 0
	}
	else
	{
		New-ItemProperty -Path HKLM:SOFTWARE\Policies\Microsoft\EdgeUpdate -Name UpdateDefault -Value 0 -PropertyType DWORD
	}

	# Disable Microsoft Edge scheduled tasks
	Get-ScheduledTask -TaskName MicrosoftEdgeUpdate* | Disable-ScheduledTask | Out-Null

	# Configure Microsoft Edge update service to manual startup
	Set-Service -Name edgeupdate -StartupType Manual

	# Execute the Microsoft Edge browser replacement task to make sure that the legacy Microsoft Edge browser is tucked away
	# This is only needed on Windows 10 versions where Microsoft Edge is not included in the OS.
	#Start-Process -FilePath "${env:ProgramFiles(x86)}\Microsoft\EdgeUpdate\MicrosoftEdgeUpdate.exe" -Wait -ArgumentList "/browserreplacement"

}



<# Function Declarations #>




<# Main Program Start #>

# Place all of the function calls, in order, into this section
# Note that functions can be called from within other functions, for instance a log function can be called from other functions

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	[Windows.Forms.MessageBox]::Show("Re-opening powershell as admin...", "Powershell ", [Windows.Forms.MessageBoxButtons]::OK) | Out-Null
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
}
Else
{
	$CCleaner_Results = CCleaner
	$Check_Edge = Check_Edge
	If($Check_Edge)
	{
		$Edge_Results = Edge_Script
	}
	$SCCM_Results = SCCM_Cleanup
	
	If($CCleaner_Results -AND (($Edge_Results -eq $True) -or ($Check_Edge -eq $False)) -AND $SCCM_Results)
	{
		Stop-Computer
	}
	Else{
		Write-Host "CCleaner Results: $CCleaner_Results"
		Write-Host "Edge Results: $CCleaner_Results"
		Write-Host "CCleaner Results: $CCleaner_Results"
}
<# Main Program End #>

