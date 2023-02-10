<#
Author: Nicholas Schneider
Date: 7/14/2020
Last Updated: 8/4/2020
Purpose: This script takes in a SubNet and provides the next available IP to the script master. This SubNet is based on location and is the VLAN 200 from the datacenter in the location provided. 

Arguments:
	SubNet - This value would be based on the location (VLAN 200 in whichever data center is used)
#>

## Start Setup ##

## Start Script Path ##
$Today = (Get-Date -Format yyyy-MM-dd-hh-mm-ss)
$Script_Directory = Split-Path $script:MyInvocation.MyCommand.Path
$Log_Folder_Path = $Script_Directory + "\Logs"
$Log_File_Path = $Log_Folder_Path + "\" + $Today + ".log"
## End Script Path ##

## End Setup ##

## Start Functions ##
<#
	Arguments:
		$Folder_Path - Path to a folder you wish to check
	Purpose:
		The purpose of this function to make sure that a folder..
		(Which is part folder path used in the script)
		exists, and if it does not, but is used later on, it will create it
	Returns:
		Nothing. This function has no return. It either finds it or creates it
#>
Function Check_Folder_Exists
{
	Param([String]$Folder_Path)
	#Test the path of the file to see if it exists
	If(-Not (Test-Path $Folder_Path))
	{
		New-Item -ItemType "directory" -Path $Folder_Path | Out-Null
	}
}
<#
	Arguments:
		$File_Path - Path to a folder you wish to check
	Purpose:
		The purpose of this function to make sure that a file..
		(Which is part file path used in the script)
		exists, and if it does not, but is used later on, it will create it
	Returns:
		Nothing. This function has no return. It either finds it or creates it
#>
Function Check_File_Exists
{
	Param([String]$File_Path)
	#Test the path of the file to see if it exists
	If(-Not (Test-Path $File_Path))
	{
		New-Item -ItemType "file" -Path $File_Path | Out-Null
	}
}
<#
	Arguments:
		$Log_Data - Data you wish to pass to the log file
	Purpose:
		The purpose of this function to make sure that a file..
		(Which is part file path used in the script)
		exists, and if it does not, but is used later on, it will create it
	Returns:
		Nothing. This function has no return. It either finds it or creates it
#>
Function Log
{
	Param([string]$Log_Data)
	$Time = (Get-Date -Format hh-mm-ss)
	#Checks to make sure that the log folder exists, if not, it creates it
	Check_Folder_Exists $Log_Folder_Path
	#Checks to make sure the log file exists, if not it creates it
	Check_File_Exists $Log_File_Path
	#Appends Data ($Log_Data) to a File located at $Log_File_Path
	$Formatted_Log_Data = $Time + " | " + $Log_Data
	$Formatted_Log_Data >> $Log_File_Path
}

<#
	Arguments:
		$IP - Pulls all data for the given IP address and returns it to the function it was called
		
	Purpose:
		Takes the given IP value and pulls the data on it
	
	Returns:
		String: 
			String containing the response to a GET API call for a specific IP
#>
Function Get_IP_Record([string]$IP)
{
	$Method = "GET"
	$URI = "############" + $IP
	$Response = Invoke-RestMethod -Method $Method -Uri $URI -Credential $Creds
	
	Return $Response
}

<#
	Arguments:
		$SubNet - Pulls all data for the given SubNet and returns it to the function it was called
		
	Purpose:
		Takes the given SubNet and pulls the data on it
	
	Returns:
		String: 
			String containing the response to a GET API call for a specific SubNet
#>
Function Get_SubNet_Info([string]$SubNet)
{
	$Method = "GET"
	$URI = "############" + "&_return_fields%2B=extattrs"
	$Response = Invoke-RestMethod -Method $Method -Uri $URI -Credential $Creds
	Return $Response
}
<#
	Arguments:
		$SubNet - ##.##.##.0/##
		
	Purpose:
		Input is a SubNet, which is then checked to make sure it is VLAN 200 and available on the network
		More checks can be added. 
	
	Returns:
		Boolean: 
			True - SubNet passed it's check
			False - SubNet failed the check
#>
Function Check_SubNet([string]$SubNet)
{
	$SubNet_Response = Get_SubNet_Info $SubNet
	If($SubNet_Response.extattrs.VLAN.Value -ne 300)
	{
		Return $False
	}
	Return $True
}
<#
	Arguments:
		$SubNet - SubNet used to get the next available IP from
		
	Purpose:
		The SubNet in this function has been checked and is ready to provide a Next_Available_IP
	
	Returns:
		String: 
			Strintg containing the IP that was next available in the SubNet range. 
#>
Function Get_Next_IP([string]$SubNet)
{
	$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
	$headers.Add("Content-Type", "application/json")

	$body = "[
	`n  {
	`n    `"method`": `"GET`",
	`n    `"object`": `"network`",
	`n    `"data`": 
	`n    {
	`n      `"network`": `"$SubNet`"
	`n    },
	`n    `"assign_state`": 
	`n    {
	`n      `"netw_ref`": `"_ref`"
	`n    },
	`n    `"discard`": true
	`n  },
	`n  {
	`n    `"method`": `"POST`",
	`n    `"object`": `"##STATE:netw_ref:##`",
	`n    `"args`": 
	`n    {
	`n      `"_function`": `"next_available_ip`"
	`n    },
	`n    `"enable_substitution`": true
	`n  }
	`n]"

	$response = Invoke-RestMethod '############' -Method 'POST' -Headers $headers -Body $body -Credential $Creds
	Return $Response
}
## End Functions ##






## Start Main ##

## Start Arguments ##

#Variable used to pass the SubNet into the script
$SubNet = $args[0]

Log ("SubNet being used: " + $SubNet)
## End Arguments ##

## Infoblox API Credentials ##
$Password_File_Path = $Script_Directory + "\Credentials\Password.txt"
$Password = Get-Content $Password_File_Path | ConvertTo-SecureString
$creds = New-Object System.Management.Automation.PsCredential("gnsapi",$Password)

#Check DNS is valid
Log "Checking SubNet Viability"
$IP_Results = Check_SubNet $SubNet

If($IP_Results)
{
	Log ("SubNet Results: Pass")
}
Else
{
	Log ("SubNet Results: Failed")
	Log ("SubNet Check Failed - Exiting Program. IP not found")
	Return ("Error")
}

$Next_IP = Get_Next_IP $SubNet
If($Next_IP -ne $NULL)
{
	Log ("IP was found: " + $Next_IP.ips)
	Return ("Next Available IP: " + $Next_IP.ips)
}
Else
{
	Log ("IP Was NOT found")
	Return ("No IP was found")
}
## End Main ##




