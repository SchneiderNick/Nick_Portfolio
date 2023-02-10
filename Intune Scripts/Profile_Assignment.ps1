<#
Template Made By Nicholas Schneider
#>

<#
Author: Nicholas Schneider
Date:
Purpose:

#>


<# Global Variables #> 

# Declare all variables from templates in here

$Script_Name = "Profile_Assignment"

$TenantId = '############'
$ClientSecret ='############'
$AppId = '############'

$profileDict = New-Object System.Collections.Generic.Dictionary"[String,String]"
$managedDeviceDict = New-Object System.Collections.Generic.Dictionary"[String,String]"

#Pathways#
$InputPath = "############"
#Pathways#

<# Function Declarations #>

# Paste all function delcarations into this section

Function Check_File_Exists
{
	Param([String]$filePath)
	#Test the path of the file to see if it exists
	If(-Not (Test-Path $filePath))
	{
		 New-Item -ItemType "file" -Path $filePath
	}
}
Function Check_Folder_Exists
{
	Param([String]$folderPath)
	#Test the path of the file to see if it exists
	If(-Not (Test-Path $folderPath))
	{
		 New-Item -ItemType "directory" -Path $folderPath
	}
}

Function Create_PaperTrail()
{
	$Formated_Date = (Get-Date -format yyyy-MM-dd-HH-mm-ss).ToString()
	#Log File
	$Log_File_Name = ($Script_Name + "_" + $Formated_Date + ".log")
	$global:Log_Path = "############\$Script_Name\Logs\$Log_File_Name"
	Check_File_Exists $Log_Path
	#Backup File
	$Backup_File_Name = ($Script_Name + "_" + $Formated_Date + ".csv")
	$global:Backup_Path = "############\$Script_Name\Backups\$Backup_File_Name"
	Check_File_Exists $Backup_Path
	"Device_Serial`tEnrollment_Profile`tNew_Enrollment_Profile" > $Backup_Path
	#Archives
	$Archive_Folder_Name = ($Script_Name + "_" + $Formated_Date + "_Archive")
	$global:Archive_Path = "############\$Script_Name\Archives\$Archive_Folder_Name"
	Check_Folder_Exists $Archive_Path
	
}
Function Log([string]$logData,[string]$Type)
{
	$Temp_Date = (Get-Date -format yyyy-MM-dd-HH-mm-ss).ToString()
	($Temp_Date + "  |  " + $Type + "  |  " + $logData) >> $global:Log_Path
}
Function Add_Backup([string]$Device_Serial, [string]$Enrollment_Profile, [string]$New_Enrollment_Profile)
{
	Log ("Adding $Device_Serial to the Backup File") "Log"
	("$Device_Serial`t$Enrollment_Profile`t$New_Enrollment_Profile") >> $Backup_Path
}
Function Archive_File($file_Path)
{
	Log ("Moving $File_Path to $Archive_Path") "Log"
	Move-Item -Path $File_Path -Destination $Archive_Path
}
Function Build_Dict()
{
	Log "Building the Profile Dictionary" "Log"
	$graphApiVersion = "beta"
	$Resource = "deviceManagement/depOnboardingSettings/"
	$uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
	Foreach($EnrollmentToken in ((Invoke-RestMethod -Uri $uri -Headers $authToken -Method Get).value))
	{
		$Temp_ID = $EnrollmentToken.id
		Log "Enrollment ID Found: $Temp_ID" "Log"
		$graphApiVersion = "beta"
		$Resource = "deviceManagement/depOnboardingSettings/$Temp_ID/enrollmentProfiles"
		$SyncURI = "https://graph.microsoft.com/$graphApiVersion/$($resource)"
		Foreach($EnrollmentProfile in ((Invoke-RestMethod -Uri $SyncURI -Headers $authToken -Method GET).Value | Select id,displayName))
		{
			Log ("Profile Found: " + $EnrollmentProfile.displayName + " - With ID: " + $EnrollmentProfile.id) "Log"
			$profileDict.Add($EnrollmentProfile.displayName,$EnrollmentProfile.id)
		}
	}
}

Function Build_Managed_Device_List
{
	$Last_Page = $False
	$Original_URI = "https://graph.microsoft.com/beta/deviceManagement/managedDevices"
	$Original_Data = Invoke-RestMethod -Uri $Original_URI -Headers $authToken -Method Get
	$Original_Data.value | foreach-object -Process {If($_.operatingSystem -ne "Windows"){Try{$managedDeviceDict.Add($_.serialNumber,$_.enrollmentProfileName)}Catch{}}}
	$Temp_Page_URL = $Original_Data.("@odata.nextlink")
	While($Last_Page -eq $False)
	{
		
		If($Temp_Page_URL -ne $NULL)
		{
			
			$New_Data = Invoke-RestMethod -Uri $Temp_Page_URL -Headers $authToken -Method Get
			$New_Data.value | foreach-object -Process {If($_.operatingSystem -ne "Windows"){try{$managedDeviceDict.Add($_.serialNumber,$_.enrollmentProfileName)}Catch{}}}
			$Temp_Page_URL = $New_Data.("@odata.nextlink")
		}
		Else
		{
			$Last_Page = $True
		}
	}
}

Function Update_Enrollment([string]$ProfileId,[string]$Device_SerialNumber,[string]$enrollmentID,[string]$Profile_Name)
{
	$graphApiVersion = "beta"
	$Resource = "deviceManagement/depOnboardingSettings/$enrollmentID/enrollmentProfiles('$ProfileId')/updateDeviceProfileAssignment"
	$DevicesArray = @("$Device_SerialNumber")
	$JSON = @{ "deviceIds" = $DevicesArray } | ConvertTo-Json
	$uri = "https://graph.microsoft.com/$graphApiVersion/$($Resource)"
	Try{
		Invoke-RestMethod -Uri $uri -Headers $authToken -Method Post -Body $JSON
		Log "Successfully assigned Serial: $Device_SerialNumber to Profile: $Profile_Name" "Log"
	}
	Catch{
		Log "Failed to Assign profile to Serial: $Device_SerialNumber" "Error"
	}

}
<# Function Declarations #>

<# Main Program Start #>

# Place all of the function calls, in order, into this section
# Note that functions can be called from within other functions, for instance a log function can be called from other functions
If((Get-ChildItem -Path $InputPath).Count -ge 1)
{
	
	<# Modules #>
	Import-Module -Name "MSAL.PS"
	Import-Module -Name "Microsoft.Graph.Intune"
	Import-Module -Name "AzureAD"
	<# Modules #>

	#Get auth token
	Try{
		$Token = Get-MsalToken -TenantId $TenantId -ClientId $AppId -ClientSecret ($ClientSecret | ConvertTo-SecureString -AsPlainText -Force)
		$authToken = @{
			'Content-Type'='application/json'
			'Authorization'="Bearer " + $Token.AccessToken
		}
	}
	Catch{
		exit
	}
	
	#Create Log File, Backup File, and Archive Folder
	Create_PaperTrail

	#Build Dictionary of all Profiles, mapping profile name to profile ID
	Build_Dict

	#Grabbing list of all managed devices. 
	#Build_Managed_Device_List

	Foreach($Input_File in (Get-ChildItem -Path $InputPath))
	{
		Log ("Checking File Formatting for: " + $Input_File.Name) "Log"
		If(-Not ($Input_File.Name -Like "*.csv"))
		{
			Log ("File: " + $Input_File.Name + " Is not a CSV. Skipping File") "Error"
			Break
		}
		$Temp_CSV = Import-CSV $Input_File.FullName
		Log "Checking for proper CSV formatting" "Log"
		$Headers = ($Temp_CSV[0].psobject.properties | Select Name)
		If((-Not ($Headers.Name -Contains "SerialNumber")) -or (-Not ($Headers.Name -Contains "EnrollmentProfile")))
		{
			Log "Headers did not contain SerialNumber and/or EnrollmentProfile. Skipping File" "Error"
			Break
		}
		Log ("File: " + $Input_File.Name + " - Passed the File Formatting and Headers Test. Beginning to Process.") "Log"
		Foreach($Device in $Temp_CSV)
		{
			$Temp_Serial = $Device.SerialNumber
			$Temp_Profile_Name = $Device.EnrollmentProfile
			$Temp_Profile_ID = $profileDict.Get_Item($Temp_Profile_Name)
			$Temp_Token_ID = ($Temp_Profile_ID.Split("_"))[0]
			$Temp_Old_Profile = $managedDeviceDict[$Temp_Serial]
			
			#Add_Backup $Temp_Serial $Temp_Old_Profile $Temp_Profile_Name
			
			Update_Enrollment $Temp_Profile_ID $Temp_Serial $Temp_Token_ID $Temp_Profile_Name
		}
		Archive_File $Input_File.FullName
	}
	
}
<# Main Program End #>





