<#
Author: Nicholas Schneider
Org: SC Johnson - End User Productivity
Date: 1/8/2019
Purpose:
	1) Pull information from the XenMobile API
		A) Do they have a device in XenMobile?
		B) Is it tagged as Corporate or BYOD?
		C) Inactivity Days?
#>

<# Global Variables #>

# Server Information #
$loginServer = "###########"
$loginPort = "###########"
# Server Information #

# Credentials #
$loginUsername = "###########"
$loginPassword = "###########"
# Credentials #

$OutPutPath = "###########"

# Email Variables #

# Email Variables #

<# Global Variables #>


<# Functions #>

# API Functions #

	#This function uses the XenMobileShell function library to open a session with the XenMobile API
Function Start_Session()
{
	$XMSAuthtoken = new-XMSession -user $loginUsername -password $loginPassword -server $loginServer -port $loginPort

}

	#This function uses XenMobile Shell to pull a list of devices that have not been used in more than 30 days.
Function Get_XenMobile_Device_Filtered()
{

	$fullDeviceList = get-XMDevice -filter "[device.inactive.time.more.than.0.days]" -ResultSetSize 100000

	Return $fullDeviceList
}

Function Enterprise_Wipe_Devices($ID)
{
	
	
	
}


# API Functions #


# File Input Functions #

#Grabs the content from the CSV at path $Data_File_Path
Function Pull_Data_From_CSV([String]$Data_File_Path)
{

	$Data_Input = (Get-Content $Data_File_Path | Select -skip 2 | ConvertFrom-Csv -Header "Email")

	Return $Data_Input
}

# File Input Functions #

Function Get_AD_Email([string]$guid)
{

	$userEmail = Get-ADUser $guid | select UserPrincipalName
	Return $userEmail.UserPrincipalName
	
}

<# Functions #>

############# Main Program #############
Start_Session

$XenMobile_Devices = Get_XenMobile_Device_Filtered

$userInfo = @()

ForEach($Line in (Get-Content -Path "###########"))
{
	$DeviceNotFound = $True
	$UserInfo = $Line + "`t"
	ForEach($Device in $XenMobile_Devices)
	{
		If($Device.UserName -Match $Line)
		{
			$DeviceID = $Device.ID
			
		}
	}
}

############# Main Program #############