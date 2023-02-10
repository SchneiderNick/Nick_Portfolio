<#
Author: Nicholas Schneider
Org: SC Johnson - End User Productivity
Date: 1/8/2019
Purpose:
	1) Monday
		a) Pull data from XenMobile using API - Pull in VIP list
		b) Sort XenMobile Data into VIP / Non-VIP
		c) Send email to each user delinquent for 25 days
			i) If VIP, compile list and email to Rick
	2) Wednesday
		a) Pull data from XenMobile using API - Pull in VIP list
		b) Sort XenMobile Data into VIP / Non-VIP
		c) Send reminder email to each user delinquent for 27 days
	3) Friday
		a) Pull data from XenMobile using API - Pull in VIP list
		b) Sort XenMobile Data into VIP / Non-VIP
		c) Run a selective wipe of the device that is delinquent for 30 days
#>

<# Global Variables #>

# Server Information #
#$loginServer = "####################"
$loginServer = "####################"
$loginPort = "####################"
# Server Information #

# Credentials #
$loginUsername = "####################"
$loginPassword = "####################"
# Credentials #

# VIP Filter #
$VIP_Group = "####################"
$CVP_Group = "####################"
$Admin_Group = "####################"
# VIP Filter #

# Log Variables #
$fileToday = Get-Date -Format yyyy-MM-dd
$today = (Get-Date).DayOfWeek
$today_Hour = (Get-Date).Hour
$IsMondayMorning = $false

$logFolderName = $fileToday.ToString() + "_Logs"
$logMainFileName = $today.ToString() + "-Main-log.log"
$logToDeleteFileName = $today.ToString() + "-ToDelete-log.log"
$logDeletedFileName = $today.ToString() + "-Deleted-log.log"
$logToNoteFileName = $today.ToString() + "-ToNote-log.log"
$logMainFolderPath = "####################" + "\" + $logFolderName

If(($today -eq "Monday") -And ($today_Hour -lt 11))
{
	$IsMondayMorning = $True
	$logMainFileName = $today.ToString() + "-Morning-Main-log.log"
	$logToDeleteFileName = $today.ToString() + "-Morning-ToDelete-log.log"
	$logDeletedFileName = $today.ToString() + "-Morning-Deleted-log.log"
	$logToNoteFileName = $today.ToString() + "-Morning-ToNote-log.log"
}

$logMainFilePath = $logMainFolderPath + "\" + $logMainFileName
$logToDeleteFilePath = $logMainFolderPath + "\" + $logToDeleteFileName
$logDeletedFilePath = $logMainFolderPath + "\" + $logDeletedFileName
$logToNoteFilePath = $logMainFolderPath + "\" + $logToNoteFileName


# Log Variables #

# Email Variables #
$smtpServer = "####################"
$emailFrom = "####################"
$vipEmail = "####################"
# Email Variables #

<# Global Variables #>


<# Functions #>

# API Functions #

	#This function uses the XenMobileShell function library to open a session with the XenMobile API
Function Start_Session()
{
	#Log("Initiate XenMobile session") $logMainFilePath $logMainFolderPath
	$XMSAuthtoken = new-XMSession -user $loginUsername -password $loginPassword -server $loginServer -port $loginPort
	#Log("Session created") $logMainFilePath $logMainFolderPath
}

	#This function uses XenMobile Shell to pull a list of devices that have not been used in more than 30 days.
Function Get_XenMobile_Device_Filtered([int]$days)
{
	$deviceList = @()
	Log("Call get-XMDevice for ${$days} Days delinquent") $logMainFilePath $logMainFolderPath
	$fullDeviceList = get-XMDevice -filter "[device.inactive.time.more.than.0.days]" -ResultSetSize 100000
	Log("Call get-XMDevice made successfully") $logMainFilePath $logMainFolderPath
	Log("Finding Devices that are inactive " + $days + " days or more.") $logMainFilePath $logMainFolderPath
	ForEach($fullDevice in $fullDeviceList)
	{
		[int]$intDays = [convert]::ToInt32($fullDevice.inactivityDays)
		If(($fullDevice.Managed -eq $true) -And ($intDays -ge $days))
		{
			$deviceList += $fullDevice
		}
		ElseIf(($fullDevice.Managed -eq $False) -And ($intDays -ge $days) -And ($fullDevice.mdmKnown -eq $False) -And ($fullDevice.mamKnown -eq $True))
		{

			$tempOutput = ($fullDevice.Id).ToString() + ", " + $fullDevice.UserName + ", " + $fullDevice.deviceModel + ", " +  $fullDevice.InactivityDays
			Log $tempOutput $logToNoteFilePath $logMainFolderPath

		}
		ElseIf(($fullDevice.Managed -eq $False) -And ($intDays -ge $days))
		{
			$tempOutput = ($fullDevice.Id).ToString() + ", " + $fullDevice.UserName + ", " + $fullDevice.deviceModel + ", " +  $fullDevice.InactivityDays
			Log $tempOutput $logToDeleteFilePath $logMainFolderPath
		}
	}
	Return $deviceList
}

Function Get_XenMobile_Device_Filtered_Unmanaged_Delete([int]$days)
{
	$deviceList = @()
	Log("Call get-XMDevice for ${$days} Days delinquent") $logMainFilePath $logMainFolderPath
	$fullDeviceList = get-XMDevice -filter "[device.inactive.time.more.than.0.days]" -ResultSetSize 100000
	Log("Call get-XMDevice made successfully") $logMainFilePath $logMainFolderPath
	Log("Finding Devices that are inactive " + $days + " days or more.") $logMainFilePath $logMainFolderPath
	ForEach($fullDevice in $fullDeviceList)
	{
		[int]$intDays = [convert]::ToInt32($fullDevice.inactivityDays)
		If(($fullDevice.Managed -eq $true) -And ($intDays -ge $days))
		{
			$tempOutput = ($fullDevice.Id).ToString() + ", " + $fullDevice.UserName + ", " + $fullDevice.deviceModel + ", " +  $fullDevice.InactivityDays
			Log $tempOutput $logDeletedFilePath $logMainFolderPath
			$deviceList += $fullDevice
		}
		ElseIf(($fullDevice.Managed -eq $False) -And ($intDays -ge $days) -And ($fullDevice.mdmKnown -eq $False) -And ($fullDevice.mamKnown -eq $True))
		{

			$tempOutput = ($fullDevice.Id).ToString() + ", " + $fullDevice.UserName + ", " + $fullDevice.deviceModel + ", " +  $fullDevice.InactivityDays
			Log $tempOutput $logToNoteFilePath $logMainFolderPath

		}
		ElseIf(($fullDevice.Managed -eq $False) -And ($intDays -ge $days))
		{
			$tempOutput = ($fullDevice.Id).ToString() + ", " + $fullDevice.UserName + ", " + $fullDevice.deviceModel + ", " +  $fullDevice.InactivityDays
			Log $tempOutput $logDeletedFilePath $logMainFolderPath
			$deviceList += $fullDevice
		}
	}
	Return $deviceList
}

Function XenMobile_Selective_Wipe([string]$id)
{
	Log ("Call Invoke-XMDeviceSelectiveWipe initiated for ID: " +  $id) $logMainFilePath $logMainFolderPath
	Invoke-XMDeviceSelectiveWipe -id $id -Confirm:$false 
	#Write-output ("Would have Wiped: " + $id)
	Log ("ID $id successfully selective wiped") $logMainFilePath $logMainFolderPath

}

Function Remove_XenMobile_Object([string]$id)
{
	Log ("Call Remove_XenMobile_Object initiated for ID: " +  $id) $logMainFilePath $logMainFolderPath
	Remove-XMDevice -id $id -Confirm: $False
	#Write-output ("Would have Deleted: " + $id)
	Log ("ID $id successfully Removed") $logMainFilePath $logMainFolderPath	
}

# API Functions #

# Log Functions #

	#Check_File_Exists
Function Check_File_Exists([String]$filePath)
{
	#Test the path of the file to see if it exists
	If(-Not (Test-Path $filePath))
	{
		 New-Item -ItemType "file" -Path $filePath
	}
}
	#Check_Folder_Exists
Function Check_Folder_Exists([String]$folderPath)
{
	#Test the path of the file to see if it exists
	If(-Not (Test-Path $folderPath))
	{
		 New-Item -ItemType "directory" -Path $folderPath
	}
}
	#Log Function
Function Log([string]$logData, [String]$logFilePath, [string]$logFolderPath)
{
	Check_Folder_Exists $logFolderPath

	Check_File_Exists $logFilePath

	$logData >> $logFilePath

}

# Log Functions #

# File Input Functions #

#Grabs the content from the AD grups to create a list of all VIPS, CVPS, and Admins
Function Pull_Data_From_AD([String]$VIP_AD_Group, [string]$CVP_AD_Group, [string]$Admin_VIP_Group)
{
	$VIP_Users = Get-ADGroupMember $VIP_AD_Group | Select SamAccountName
	$VIP_Users += Get-ADGroupMember $CVP_AD_Group | Select SamAccountName
	$VIP_Users += Get-ADGroupMember $Admin_VIP_Group | Select SamAccountName
	Return $VIP_Users
}

# File Input Functions #

# Filter VIP / Sort Emails #

Function Sort_Emails_Filter_VIP([PSObject]$XenMobileData,[String]$weekDay)
{
	$vipList = Pull_Data_From_AD $VIP_Group $CVP_Group $Admin_Group
	Log ("Successfully pulled VIP data") $logMainFilePath $logMainFolderPath
	$XenMobile_Object_List = @()
	$XenMobile_VIP_Object_List = @()
	Log ("Beginning Device/VIP filtering") $logMainFilePath $logMainFolderPath
	ForEach($Device in $XenMobileData)
	{
		$properties = @{
		'id' = $Device.id
		'userName' = $Device.userName
		'serialNumber' = $Device.serialNumber
		'imeiOrMeid' = $Device.imeiOrMeid
		'deviceModel' = $Device.deviceModel
		'inactivityDays' = $Device.inactivityDays
		'deviceType' = $Device.deviceType
		}

		$tempObj = New-Object -TypeName PSObject -Property $properties
		$VIP_Status = $False

		ForEach($VIP in $vipList)
		{
			If($VIP.SamAccountName -eq ($tempObj.userName.Substring(0,7)))
			{
				Log ("VIP User Found: " + $tempObj.UserName) $logMainFilePath $logMainFolderPath
				$XenMobile_VIP_Object_List += $tempObj
				$VIP_Status = $True
			}
		}
		If(-Not ($VIP_Status))
		{
			Log("Non-VIP User Found: " + $tempObj.UserName) $logMainFilePath $logMainFolderPath
			$XenMobile_Object_List += $tempObj
		}
	}
	Log("Sorting of VIP/Non-VIP objects complete") $logMainFilePath $logMainFolderPath
	$VIP_Email_Body = "Rick, `n`n Listed below are the VIP users of XenMobile that have had inactive phones for over 25 Days.`n"`
	+ "These users are excluded from the automated process of XenMobile Audit emailing and removal from XenMobile. If they do not use the device anymore, you can remove them from XenMobile.`n`n "
	$NON_VIP_Email_Body = ""
	$VIP_Email_Subject = "VIP XenMobile Users With Inactive Devices"
	$NON_VIP_Subject = ""
	If($weekDay -eq "Monday")
	{
		Log("Monday logic started") $logMainFilePath $logMainFolderPath
		ForEach($IS_VIP in $XenMobile_VIP_Object_List)
		{
			$tempLength = ($IS_VIP.userName).length
			$userName = (($IS_VIP.userName).SubString(24).TrimEnd('"'))
			$VIP_Email_Body += "User: " + $userName + " | Device Model: " + $IS_VIP.deviceModel + " | Device Type: " + $IS_VIP.deviceType + " | Days Inactive: " + $IS_VIP.inactivityDays + "`n"
		}
		If(($XenMobile_VIP_Object_List).length -eq 0)
		{
			Log("No VIP users have been found with delinquent devices") $logMainFilePath $logMainFolderPath
			$VIP_Email_Body = "There are currently no VIP users with delinquent devices"
			Send_Email_VIP $VIP_Email_Body $VIP_Email_Subject
		}
		Else
		{
			Log("VIP were found with delinquent devices - Sending email to $vipEmail") $logMainFilePath $logMainFolderPath
			Send_Email_VIP $VIP_Email_Body $VIP_Email_Subject
			Log("Email sent to $vipEmail") $logMainFilePath $logMainFolderPath
		}
		ForEach($NON_VIP in $XenMobile_Object_List)
		{
			$tempLength = ($NON_VIP.userName).length
			$NON_VIP_Subject = "Mobile Device Inactivity"
			$NON_VIP_Email_Body = '<html>'`
			+ '<body>'`
			+ "<p>**This is an auto-generated email. If you have any questions about the message you are receiving, please contact the SCJ Service Desk**</p>`n"`
			+ "<p>Hello " + ($NON_VIP.userName).SubString(24).TrimEnd('"') + ",</p>`n"`
			+ "<p>Your " + $NON_VIP.deviceType + " device has been inactive for " + $NON_VIP.inactivityDays + " days. In an effort to maintain continuity on our systems and licenses, if you do not check in on this device by "`
			+ "<b><span style=" + [convert]::ToChar(34) + "background-color: #FFFF00" + [convert]::ToChar(34) + ">" + (Get-Date).AddDays(4).DayOfWeek + ", " + (Get-Culture).DateTimeFormat.GetMonthName((Get-Date).AddDays(4).Month) + " " + (Get-Date).AddDays(4).Day + "</span></b> "`
			+ "at 12 PM CST, your device will be enterprise wiped. This means all SCJ management (Exchange, Wi-Fi, SCJ Apps) will be removed from your device.</p>`n"`
			+ "<p>If you are still using your device, please open Secure Hub and log into the application (you will need your Secure Hub passcode, or your Network Password).</p>`n"`
			+ "<p>If you recently upgraded your device and are actively using your new device, this email was generated against your old device and doesn't necessarily indicate a problem. Please follow the instructions listed above on your new phone to ensure compliance.</p>"`
			+ "Thank you for your compliance and assistance with this audit."`
			+ "</p></body></html>"
			$NON_VIP_Email_Recipient = Get_AD_Email ($NON_VIP.userName.Substring(0,7))
			Send_Email $NON_VIP_Email_Body $NON_VIP_Email_Recipient $NON_VIP_Subject
			Log("Email sent to: " + $NON_VIP_Email_Recipient) $logMainFilePath $logMainFolderPath
		}
		Log("Monday logic finished") $logMainFilePath $logMainFolderPath
	}
	ElseIf($weekDay -eq "Wednesday")
	{
		Log("Wednesday Logic Started") $logMainFilePath $logMainFolderPath
		ForEach($NON_VIP in $XenMobile_Object_List)
		{
			$tempLength = ($NON_VIP.userName).length
			$NON_VIP_Subject = "Mobile Device Inactivity - REMINDER"
			$NON_VIP_Email_Body = '<html>'`
			+ '<body>'`
			+ "<p>**This is an auto-generated email. If you have any questions about the message you are receiving, please contact the SCJ Service Desk**</p>`n"`
			+ "<p>Hello " + ($NON_VIP.userName).SubString(24).TrimEnd('"') + ",</p>`n"`
			+ "<p>Your " + $NON_VIP.deviceType + " device has been inactive for " + $NON_VIP.inactivityDays + " days. In an effort to maintain continuity on our systems and licenses, if you do not check in on this device by "`
			+ "<b><span style=" + [convert]::ToChar(34) + "background-color: #FFFF00" + [convert]::ToChar(34) + ">" + (Get-Date).AddDays(2).DayOfWeek + ", " + (Get-Culture).DateTimeFormat.GetMonthName((Get-Date).AddDays(2).Month) + " " + (Get-Date).AddDays(2).Day + "</span></b> "`
			+ "at 12 PM CST, your device will be enterprise wiped. This means all SCJ management (Exchange, Wi-Fi, SCJ Apps) will be removed from your device.</p>`n"`
			+ "<p>If you are still using your device, please open Secure Hub and log into the application (you will need your Secure Hub passcode, or your Network Password).</p>`n"`
			+ "<p>If you recently upgraded your device and are actively using your new device, this email was generated against your old device and doesn't necessarily indicate a problem. Please follow the instructions listed above on your new phone to ensure compliance.</p>"`
			+ "Thank you for your compliance and assistance with this audit."`
			+ "</p></body></html>"
			$NON_VIP_Email_Recipient = Get_AD_Email ($NON_VIP.userName.Substring(0,7))
			Send_Email $NON_VIP_Email_Body $NON_VIP_Email_Recipient $NON_VIP_Subject
			Log("Non-VIP email sent to: " + $NON_VIP_Email_Recipient) $logMainFilePath $logMainFolderPath
		}
		Log("Wednesday Logic Finished") $logMainFilePath $logMainFolderPath
	}
	ElseIf($weekDay -eq "Friday")
	{
		Log("Friday Logic Started") $logMainFilePath $logMainFolderPath
		ForEach($NON_VIP in $XenMobile_Object_List)
		{
			XenMobile_Selective_Wipe $NON_VIP.id
		}
		Log("Friday Logic Ended") $logMainFilePath $logMainFolderPath
	}
	ElseIf($weekDay -eq "Monday Morning")
	{
		Log("Monday Logic Started") $logMainFilePath $logMainFolderPath
		ForEach($NON_VIP in $XenMobile_Object_List)
		{
			Remove_XenMobile_Object $NON_VIP.id
		}
		Log("Monday Morning Logic Started") $logMainFilePath $logMainFolderPath
	}
}

# Filter VIP / Sort Emails #

# Send Email #
Function Send_Email([string]$body, [string]$emailRecipient, [string]$subject)
{
	$bcc = @("####################","####################")
	$Msg = @{
		to          = $emailRecipient
		from        = $emailFrom
		bcc         = $bcc
		Body        = $body
		subject     = $subject
		BodyAsHtml  = $True
		priority    = 2
		smtpserver  = $smtpServer
		}

	# Necessary Settings #
	
	If($emailRecipient -eq "####################")
	{
	$Msg = @{
		to          = $vipEmail
		from        = $emailFrom
		bcc         = $bcc
		Body        = $body
		subject     = "**This Email Would Have Been Sent to ####################**"
		BodyAsHtml  = $True
		priority    = 2
		smtpserver  = $smtpServer
		}
		#Send-MailMessage @Msg
	}
	Else
	{
	Send-MailMessage @Msg
	}
}

Function Send_Email_VIP([string]$body, [string]$subject)
{
	$cc = @("####################","####################")
	$Msg = @{
		to          = $vipEmail
		from        = $emailFrom
		cc          = $cc
		bcc         = "####################"
		Body        = $body
		subject     = $subject
		priority    = 2
		smtpserver  = $smtpServer
		}

	# Necessary Settings #
	Send-MailMessage @Msg
}
# Send Email #

Function Get_AD_Email([string]$guid)
{

	$userEmail = Get-ADUser $guid | select UserPrincipalName
	Return $userEmail.UserPrincipalName
	
}

# Day Functions #

Function Monday_Function()
{

$daysInactive = 25

Start_Session

$mondayXenMobileData = Get_XenMobile_Device_Filtered $daysInactive

Sort_Emails_Filter_VIP $mondayXenMobileData "Monday"

Log("Emails have been sent to users successfully.") $logMainFilePath $logMainFolderPath
}

Function Wednesday_Function()
{

$daysInactive = 27

Start_Session

$wednesdayXenMobileData = Get_XenMobile_Device_Filtered $daysInactive

Sort_Emails_Filter_VIP $wednesdayXenMobileData "Wednesday"

Log("Reminder Emails have been sent to users successfully.") $logMainFilePath $logMainFolderPath

}

Function Friday_Function()
{

$daysInactive = 29

Start_Session

$fridayXenMobileData = Get_XenMobile_Device_Filtered $daysInactive

Sort_Emails_Filter_VIP $fridayXenMobileData "Friday"

Log("Users have been removed from XenMobile Successfully") $logMainFilePath $logMainFolderPath
}

Function Monday_Morning_Function()
{

$daysInactive = 32

Start_Session

$mondayXenMobileData = Get_XenMobile_Device_Filtered_Unmanaged_Delete $daysInactive 

Sort_Emails_Filter_VIP $mondayXenMobileData "Monday Morning"

Log("Emails have been sent to users successfully.") $logMainFilePath $logMainFolderPath
}

# Day Functions #

<# Functions #>



############# Main Program #############
Check_Folder_Exists $logMainFolderPath
Check_File_Exists $logMainFilePath
Check_File_Exists $logToDeleteFilePath
Check_File_Exists $logToNoteFilePath
Check_File_Exists $logDeletedFilePath



If(($today -eq "Monday") -And ($IsMondayMorning -eq $False))
{
	Monday_Function
}ElseIf($today -eq "Wednesday")
{
	Wednesday_Function
}ElseIf($today -eq "Friday")
{
	Friday_Function
}ElseIf(($today -eq "Monday") -And ($IsMondayMorning -eq $True))
{
	Monday_Morning_Function
}
############# Main Program #############