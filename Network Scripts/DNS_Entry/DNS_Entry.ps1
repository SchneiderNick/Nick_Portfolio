<#
Author: Nicholas Schneider
Date: 7/7/2020
Last Updated: 8/3/2020
Purpose: Take in arguments and use those arguments to create and deploy an A record into Infoblox
using the API. This will allow users to log into servers using both the IP and a Sevrer Name (############ as an example)

Arguments:
	DNS Name
	IP Address
	
Possible Next iterations:
	Name as Arg -> Name generated
		Infoblox integration for name information based on IP location
	Create and Integrate the Infoblox PowerShell Module to ensure flawless delivery of current and future API calls
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
		New-Item -ItemType "directory" -Path $Folder_Path
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
		New-Item -ItemType "file" -Path $File_Path
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
		$DNS - The DNS name used in the A Record creation process
		$IP - The IP used in the A Record creation process
	Purpose:
		Function takes in DNS and IP address and calls the Infoblox API to create an A record in the SCJ environment
	Returns:
		This function will return an array, with status information
			200 - A Record was successfully created
			400 - Bad request, Function errored out
			500 - Server encountered an error
#>
Function Post_A_Record([string]$DNS, [string]$IP)
{	
	$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
	$headers.Add("Content-Type", "application/json")
	$body = "{`n    `"name`":  `"$DNS`",`n    `"ipv4addr`":  `"$IP`"`n}"
	$response = Invoke-RestMethod '############' -Method 'POST' -Headers $headers -Body $body -Credential $Creds
	Return $response
}
<#
	Arguments:
		$DNS - A string DNS name meant to be a part of the A Record being created
		
	Purpose:
		Takes the given DNS and pulls the Infoblox value for any A records attached to this DNS
	
	Returns:
		String: 
			String containing the response to a GET API call for a specific DNS
#>
Function Get_Host_Record([string]$DNS)
{
	$Method = "GET"
	$URI = "############" + $DNS
	$Response = Invoke-RestMethod -Method $Method -Uri $URI -Credential $Creds
	
	Return $Response
}
<#
	Arguments:
		$IP - Pulls all data for the given IP address and returns it to the function it was called
		
	Purpose:
		Takes the given DNS and pulls the Infoblox value for any A records attached to this DNS
	
	Returns:
		String: 
			String containing the response to a GET API call for a specific DNS
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
		$IP - A String containing the IP Address of the server being attached to the DNS
		
	Purpose:
		Test the IP to make sure that it is attached to a server without an A Record and that it is in use
			
	Returns:
		Boolean value based on the Success/Failure in the tests
			True - The IP is currently in use and attached to a server without an A Record attached to it
			False - The IP is either not in use, or is is already attached to a DNS through an A Record different from the one being aplied here
#>
Function Check_IP_Status([string]$IP)
{
	$Get_IP_Results = Get_IP_Record $IP
	
	If(($Get_IP_Results.Error -ne $NULL) -OR ($Get_IP_Results.types -Contains "HOST") -OR ($Get_IP_Results.types -Contains "Lease") -OR ($Get_IP_Results.lease_state -eq "Active") -OR ($Get_IP_Results.lease_state -eq "Backup") -OR ($Get_IP_Results.lease_state -eq "Abandoned"))
	{
		Return $False
	}
	Else
	{
		Return $True
	}
}
<#
	Arguments:
		$DNS - A string DNS name meant to be a part of the A Record being created
		
	Purpose:
		Function takes a DNS name in string form and does checks on that name to m ake sure that it is not currently in use
	
	Returns:
		Boolean value based on the Success/Failure in the tests
			True - The DNS is not currently in use and can be used for the A Record
			False - The DNS is currently in use and cannot be used for the A Record, the DNS will have to be changed before moving forward
#>
Function Check_DNS_Availability([string]$DNS)
{
	#Check Infoblox info for a DNS entry
	$Host_Record_Check = Get_Host_Record($DNS)
	#Ping DNS
	$PingResults = ping $DNS
	# If the host record is not found in infoblox and the script cannnot ping the DNS, it is an available address
	# The ping request is necessary to make sure that it is not a public (Non-SCJ value, like google) DNS entry
	If(($Host_Record_Check -eq $NULL) -And ($PingResults -eq ("Ping request could not find host " + $DNS + ". Please check the name and try again.")))
	{
		Return $True
	}
	Else
	{
		Return $False
	}
}

<#
	Arguments:
		$Previous_DNS - A string containing the failed DNS (Failed with function "Check_DNS_Availability") name
		
	Purpose:
		Assign a new DNS, based on the failed DNS input that fits the server it is being attached to, but is not in use.
		This would be done by either incrementing the ### value at the end of the DNS (USRAIPA608 -> USRACIPA609)
		Or it would be done by checking the master list fo the data cache for the next available DNS in the range based ont he lcoation of the IP (USRACIPA###)
		
	Returns:
		This function will return an array in this format ([Boolean]$Test_Result, [string]$Old_DNS, [string]$New_DNS)
			[Boolean]$Test_Result
				True - This means that a new DNS was found and that the old DNS can be replaced
				False - This means that a new DNS was not found, and that there is no new DNS to replace the old one
			[string]$Old_DNS
				"OLD_DNS_Name"
			[string]$New_DNS or $Error_Message
				"New_DNS_Name"
#>
<#Function Get_New_DNS([string]$Previous_DNS)
{
	$Results_Array = @("",$Previous_DNS,"")
	$Previous_DNS_Split = $Previous_DNS.Split(".")
	# This will contain ".scj.com"
	$Domain = "." + $Previous_DNS_Split[1] + "." + $Previous_DNS_Split[2]
	$Host_Name = $Previous_DNS_Split[0]
	$Host_Name_Split_Number = $HostName -split '(?=\d)',2
	$Host_String = $Host_Name_Split_Number[0]
	$Host_Number = $Host_Name_Split_Number[1]
	$New_Host_Number = $Host_Number
	# Old DNS at this point - $Previous_DNS = ($Host_String + $Host_Number + $Domain)
	# New DNS will be - $New_DNS = ($Host_String + $New_Host_Number + $Domain)
	$New_DNS_Check = $False

	While($New_DNS_Check -eq $False)
	{
		$New_Host_Number = [string]([int]$New_Host_Number + 1)
		$New_DNS = $Host_String + $New_Host_Number + $Domain
		If($New_Host_Number -lt ($Host_Number + 50))
		{
			If(Check_DNS_Availability $New_DNS)
			{
				$Results_Array[0] = $True
				$Results_Array[2] = $New_DNS
				$New_DNS_Check = $True
			}
			Else
			{
				$Results_Array[0] = $False
				$Results_Array[2] = "N/A"
			}
		}
		Else
		{
			$Results_Array[0] = $False
			$Results_Array[2] = "Ran out of potential DNS values (50)"
			$New_DNS_Check = $True
		}
	}
	Return $Results_Array
}#>

## End Functions ##

## Start Main ##

## Start Arguments ##

#Variable used to pass the DNS name into the script
$DNS_Name = $args[0]
#Variable used to pass the IP address to be attached to the DNS name given above
$IP_Address = $args[1]
Log ("DNS Name being used: " + $DNS_Name)
Log ("IP Address being used: " + $IP_Address)
## End Arguments ##

## Infoblox API Credentials ##
$Password_File_Path = $Script_Directory + "\Credentials\Password.txt"
$Password = Get-Content $Password_File_Path | ConvertTo-SecureString
$creds = New-Object System.Management.Automation.PsCredential("gnsapi",$Password)
## Infoblox API Credentials ##

#Check DNS is valid
Log "Checking DNS Availability"
$DNS_Results = Check_DNS_Availability $DNS_Name

If($DNS_Results)
{
	Log ("DNS Results: Pass")
}
Else
{
	Log ("DNS Results: Failed")
	Log ("DNS Failed - Exiting Program. A Record NOT created")
	Exit
}

#Check IP is valid
Log "Checking IP Availability"
$IP_Results = Check_IP_Status $IP_Address

If($IP_Results)
{
	Log ("IP Results: Pass")
}
Else
{
	Log ("IP Results: Failed")
	Log ("IP Failed - Exiting Program. A Record NOT created")
	Exit
}

If(($DNS_Results) -AND ($IP_Results))
{
	Log ("Creating the A Record: DNS - " + $DNS_Name + " IP - " + $IP_Address)
	$A_Record_Results = Post_A_Record $DNS_Name $IP_Address
	Log ("A Record Creation Results: " + $A_Record_Results)
}

## End Main ##




