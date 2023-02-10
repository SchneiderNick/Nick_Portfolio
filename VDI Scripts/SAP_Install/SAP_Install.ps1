<#
Template Made By Nicholas Schneider
#>

<#
Author: Nicholas Schneider
Date: 7/19/2022
Purpose: Add Reg Keys to SAP Install
#>

<# Global Variables #> 

# Declare all variables from templates in here


$SapLogon_Options_Path = "HKLM:\SOFTWARE\WOW6432Node\SAP\SAPLogon\Options"
$SAPLogon_Options_LFOS_Key = "LandscapeFileOnServer"
$SAPLogon_Options_LFOS_Value = "###########"
$SAPLogon_Options_LFOS_Type = "String"
$SAPLogon_Options_PCFL_Key = "PathConfigFilesLocal"
$SAPLogon_Options_PCFL_Value = "###########"
$SAPLogon_Options_PCFL_Type = "String"

$SAP_General_Themes_Path = "HKLM:\SOFTWARE\WOW6432Node\SAP\General\Appearance\Themes"
$SAP_General_Themes_Key = "SelectableThemes"
$SAP_General_Themes_Value = 1
$SAP_General_Themes_Type = "DWORD"

$SAP_LocalUser_Theme_Path = "HKCU:\Software\SAP\General\Appearance"
$SAP_LocalUser_Theme_Key = "SelectedTheme"
$SAP_LocalUser_Theme_Value = 1
$SAP_LocalUser_Theme_Type = "DWORD"


<# Global Variables #> 


<# Function Declarations #>

# Paste all function delcarations into this section

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
		
	If(-Not (Test-Path $SapLogon_Options_Path))
	{
		New-Item -Path $SapLogon_Options_Path
	}
	If(-Not (Test-Path $SAP_General_Themes_Path))
	{
		New-Item -Path $SAP_General_Themes_Path
	}
	If(-Not (Test-Path $SAP_LocalUser_Theme_Path))
	{
		New-Item -Path $SAP_LocalUser_Theme_Path
	}
	New-ItemProperty -Path $SapLogon_Options_Path -Name $SAPLogon_Options_LFOS_Key -PropertyType $SAPLogon_Options_LFOS_Type -Value $SAPLogon_Options_LFOS_Value

	New-ItemProperty -Path $SapLogon_Options_Path -Name $SAPLogon_Options_PCFL_Key -PropertyType $SAPLogon_Options_PCFL_Type -Value $SAPLogon_Options_PCFL_Value

	New-ItemProperty -Path $SAP_General_Themes_Path -Name $SAP_General_Themes_Key -PropertyType $SAP_General_Themes_Type -Value $SAP_General_Themes_Value

	New-ItemProperty -Path $SAP_LocalUser_Theme_Path -Name $SAP_LocalUser_Theme_Key -PropertyType $SAP_LocalUser_Theme_Type -Value $SAP_LocalUser_Theme_Value

}



<# Main Program End #>

