<#
Author: Nicholas Schneider
Org: SC Johnson - End User Productivity
Date: 4/3/2019
Purpose:

#>

<# Global Variables #>

# Server Information #
$loginServer = "####################"
$loginPort = "####################"
$smtpServer = "####################"
# Server Information #

# Credentials #
$loginUsername = "####################"
$loginPassword = "####################"
# Credentials #

$OutPutPath = "$PSScriptRoot\OutPut.csv"
$VIPOutPutPath = "$PSScriptRoot\VIPOutPut.csv"
$vipPath = "$PSScriptRoot\VIP_List\VIP_Users.csv"
# Email Variables #

$attachments = @()
$attachments += $OutPutPath
$attachments += $VIPOutPutPath

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

	$fullDeviceList = get-XMDevice -filter "[device.inactive.time.more.than.0.days]" -ResultSetSize 10000

	Return $fullDeviceList
}

# API Functions #


# File Input Functions #

#Grabs the content from the CSV at path $Data_File_Path
Function Pull_Data_From_CSV([String]$Data_File_Path)
{

	$Data_Input = (Get-Content $Data_File_Path | Select -skip 2 | ConvertFrom-Csv -Header "LastName","FirstName","UserID","VIPType","Manager","Email","BusinessPhone","CostCenter")

	Return $Data_Input
}

# File Input Functions #

Function Get_AD_Email([string]$guid)
{

	$userEmail = Get-ADUser $guid | select UserPrincipalName
	Return $userEmail.UserPrincipalName
	
}


Function Send_Email([string]$body)
{
	$Msg = @{
    to          = "####################"
    cc          = "####################"
    from        = "####################"
    Body        = $body
    subject     = "Xenmobile Version Audit Output"
    smtpserver  = $smtpServer
    Attachments = $attachments
	}
	Send-MailMessage @Msg
}


<# Functions #>

############# Main Program #############
"ID`tManaged`tMDM Known`tmamRegistered`tMAM Known`tUsername`tSerialnumber`timeiOrMeid`tOS Version`tDevice Model`tDevice Type`tProduct Name`tPlatform`tCarrier`tCorporate Owned`tModel ID`tProduct Name`tSIM Carrier Network" > $OutPutPath
"ID`tManaged`tMDM Known`tmamRegistered`tMAM Known`tUsername`tSerialnumber`timeiOrMeid`tOS Version`tDevice Model`tDevice Type`tProduct Name`tPlatform`tCarrier`tCorporate Owned`tModel ID`tProduct Name`tSIM Carrier Network" > $VIPOutPutPath

Start_Session

$XenMobile_Devices = Get_XenMobile_Device_Filtered

$objectCount = ($XenMobile_Devices | Measure | Select Count).count

$vipList = Pull_Data_From_CSV $vipPath

For($counter = 0; $counter -lt $objectCount; $counter++)
{
	$carrierCheck = $False
	$corporateOwnedCheck = $False
	$modelIDCheck = $False
	$productNameCheck = $False
	$simCarrierNetworkCheck = $False
	
	$tempDevice = $XenMobile_Devices[$counter]
	$tempOutput = ($tempDevice.id | Out-String).Replace("`r`n",'') + "`t" + ($tempDevice.managed | Out-String).Replace("`r`n",'') + "`t" + ($tempDevice.mdmKnown | Out-String).Replace("`r`n",'') + "`t" + ($tempDevice.mamRegistered | Out-String).Replace("`r`n",'') + "`t" + ($tempDevice.mamKnown | Out-String).Replace("`r`n",'') + "`t" + ($tempDevice.userName | Out-String).Replace("`r`n",'') + "`t" + ($tempDevice.serialNumber | Out-String).Replace("`r`n",'') + "`t" +($tempDevice.imeiOrMeid | Out-String).Replace("`r`n",'') + "`t" + ($tempDevice.osVersion | Out-String).Replace("`r`n",'') + "`t" + ($tempDevice.deviceModel | Out-String).Replace("`r`n",'') + "`t" + ($tempDevice.deviceType | Out-String).Replace("`r`n",'') + "`t" + ($tempDevice.productName | Out-String).Replace("`r`n",'') + "`t" + ($tempDevice.platform | Out-String).Replace("`r`n",'') 

	$propertiesCount = ($tempDevice.Properties | Measure | Select Count).count
	For($internalCounter = 0; $internalCounter -lt $propertiesCount; $internalCounter++)
	{
		$tempName = ($tempDevice.properties[$internalCounter].Name | Out-String).replace("`r`n",'')
		If($tempName -eq "CARRIER")
		{
			$carrier = ($tempDevice.properties[$internalCounter].Value | Out-String).replace("`r`n",'')
			$carrierCheck = $True
		}
		If($tempName -eq "CORPORATE_OWNED")
		{
			$corporateOwned = ($tempDevice.properties[$internalCounter].Value | Out-String).replace("`r`n",'')
			$corporateOwnedCheck = $True
		}
		If($tempName -eq "MODEL_ID")
		{
			$modelID = ($tempDevice.properties[$internalCounter].Value | Out-String).replace("`r`n",'')
			$modelIDCheck = $True
		}
		If($tempName -eq "PRODUCT_NAME")
		{
			$productName = ($tempDevice.properties[$internalCounter].Value | Out-String).replace("`r`n",'')
			$productNameCheck = $True
		}
		If($tempName -eq "SIM_CARRIER_NETWORK")
		{
			$simCarrierNetwork = ($tempDevice.properties[$internalCounter].Value | Out-String).replace("`r`n",'')
			$simCarrierNetworkCheck = $True
		}
	}
	If($carrierCheck -eq $True)
	{
		$tempOutput += "`t" + $carrier
	}
	Else
	{
		$tempOutput += "`t"
	}
	If($corporateOwnedCheck -eq $True)
	{
		$tempOutput += "`t" + $corporateOwned
	}
	Else
	{
		$tempOutput += "`t"
	}
	If($modelIDCheck -eq $True)
	{
		$tempOutput += "`t" + $modelID
	}
	Else
	{
		$tempOutput += "`t"
	}
	If($productNameCheck -eq $True)
	{
		$tempOutput += "`t" + $productName
	}
	Else
	{
		$tempOutput += "`t"
	}
	If($simCarrierNetworkCheck -eq $True)
	{
		$tempOutput += "`t" + $simCarrierNetwork
	}
	Else
	{
		$tempOutput += "`t"
	}
	$Is_VIP = $False
	Foreach($VIP in $VIPList)
	{
		Write-Output $VIP.UserID
		If($VIP.UserId -eq ((($tempDevice.userName | Out-String).Replace("`r`n",'')).Substring(0,7)))
		{
			$Is_VIP = $True
			Break
		}
	}
	If($Is_VIP)
	{
		$tempOutput >> $VIPOutPutPath
	}
	Else
	{
		$tempOutput >> $OutPutPath
	}
}


Send_Email "Current users and VIP users Phone Versions"



############# Main Program #############