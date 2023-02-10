#Author: Nicholas Schneider
#Date: 2/10/2020

<# Supporting Addons #>

	Add-Type -AssemblyName System.Windows.Forms | Out-Null
	Add-Type -AssemblyName System.Drawing | Out-Null
	[System.Windows.Forms.Application]::EnableVisualStyles() | Out-Null
	Import-Module -Name "D:\SCJ_PowerShell_Module_DEV\SCJ_PowerShell_Module.psm1"

<# Supporting Addons #>

# Adding Log Generation Function #
	. "D:\Network_Scripts\IP_DNS_Configuration_Application\Logs\Generate_Log_Name.ps1"

	$Log_File_Name = Generate_Log_Name
	$Log_Path = "\Logs\Log_Files\" + $Log_File_Name
	
	Add-SCJLog -Data "Script Started Successfully" -PartialPath $Log_Path -Action "New" -AddDate $True | Out-Null
# Adding Log Generation Function #

<# Variables #>

	$Script_Path = (split-path -parent $MyInvocation.MyCommand.Definition)

	$secpasswd = ConvertTo-SecureString "##############" -AsPlainText -Force
	$Creds = New-Object System.Management.Automation.PSCredential ("##############", $secpasswd)

	$Host_Name_Gen_Dict = @{}

<# Variables #>

Foreach($File in (Get-ChildItem -Path "$PSScriptRoot\Supporting_Functions\"))
{
	$File_Name = $File.FullName
	try{. $File_Name}
	catch{
	Add-SCJLog -Data ("Failed to load a Supporting Function File") -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data ("File: " + $File.Name) -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data "Vital Function Missing - collecting Failure Information and ending process" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data "Error Information" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data ($Error) -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data "Process Ending" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Exit
	}
	Add-SCJLog -Data ("Successfully Loaded Supporting Function File") -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null
	Add-SCJLog -Data ("File: " + $File.Name) -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null
}

## Begin Setup Network Catalog ##

Output_Loading_Status -Status_Percent 0
Try
{
	$Asia_Pacific_Data = Call_Infoblox_Network_Pull -Region "Asia Pacific";
}
Catch
{
	Add-SCJLog -Data "Error Information" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data ($Error) -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data "Process Ending" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Exit
}
Output_Loading_Status -Status_Percent 1
Try
{
	$Latin_America_Data = Call_Infoblox_Network_Pull -Region "Latin America";
}
Catch
{
	Add-SCJLog -Data "Error Information" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data ($Error) -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data "Process Ending" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Exit
}
Output_Loading_Status -Status_Percent 2
Try
{
	$EMEA_Data = Call_Infoblox_Network_Pull -Region "EMEA";
}
Catch
{
	Add-SCJLog -Data "Error Information" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data ($Error) -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data "Process Ending" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Exit
}
Output_Loading_Status -Status_Percent 3
Try
{
	$North_America_Data = Call_Infoblox_Network_Pull -Region "North America";
}
Catch
{
	Add-SCJLog -Data "Error Information" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data ($Error) -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data "Process Ending" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Exit
}

Output_Loading_Status -Status_Percent 4
Try
{
	$Other_Data = Call_Infoblox_Network_Pull -Region "Other";
}
Catch
{
	Add-SCJLog -Data "Error Information" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data ($Error) -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data "Process Ending" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Exit
}
Output_Loading_Status -Status_Percent 5

## End Setup Network Catalog ##

#Call Main Function
Add-SCJLog -Data "Beginning Main Function" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
Main_Function


#Display Built Dictionary
$Host_Name_Gen_Dict

Sleep 10
