<#
Author: Nicholas Schneider
Date: 8/20/2020
Last Updated: 8/20/2020
Purpose: Take in arguments and use those arguments to create and deploy an A record into Infoblox
using the API. This will allow users to log into servers using both the IP and a Sevrer Name (USRACIPA674 as an example)

Arguments:
	SubNet - Subnet for servers in the data center (Usually 200)
	DNS - Server name with .scj.com appended to it
	
Purpose:
	This script will take a SubNet and DNS and do the following:
		1) Find the next available IP in ther SubNet
		2) Create an A Record for the server (Using the IP and DNS)
		3) Create a PTR for the server using the DNS and the IP
#>


## Start Setup ##

## Start Script Path ##
$Today = (Get-Date -Format yyyy-MM-dd-hh-mm-ss)
$Script_Directory = Split-Path $script:MyInvocation.MyCommand.Path
$Log_Folder_Path = $Script_Directory + "\Logs"
$Log_File_Path = $Log_Folder_Path + "\" + $Today + ".log"
## End Script Path ##

## Infoblox API Credentials ##
$Password_File_Path = $Script_Directory + "\Credentials\Password.txt"
$Password = Get-Content $Password_File_Path | ConvertTo-SecureString
$creds = New-Object System.Management.Automation.PsCredential("gnsapi",$Password)
## Infoblox API Credentials ##


## End Setup ##

## Main Function ##
Function Main([string]$DNS, [string]$SubNet)
{
	Log("Starting the Main Process")
	
	Log("Calling `"Main_Get_IP`" with `"$SubNet`" as the argument")
	$IP_Address = Main_Get_IP $SubNet
	Log("`"Main_Get_IP`" returned `"$IP_Address`" as the output")
	
	Log("Calling `"Main_Post_A_Record`" with `"$IP_Address`" as the IP Address and `"$DNS`" as the DNS")
	$A_Record_Response = Main_Post_A_Record $IP_Address $DNS
	Log("`"Main_Post_A_Record`" returned $A_Record_Response `n from `"Main_Post_PTR`"")
	
	Log("Calling `"Main_Post_PTR`" with `"$IP_Address`" as the IP Address and `"$DNS`" as the DNS")
	$PTR_Response = Main_Post_PTR $IP_Address $DNS
	Log("`"Main_Post_PTR`" returned $PTR_Response `n from `"Main_Post_PTR`"")
	
	Log("Ending the Main Process")
}


## Main Function ##


## 3 Main Functions ##
Function Main_Get_IP([string]$SubNet)
{
	Log("-----Starting `"Main_Get_IP`" function-----")
	$SubNet_Check = Check_SubNet $SubNet
	If($SubNet_Check -eq $False)
	{
		Log("Script failed SubNet_Check - Terminating the Process")
		Exit
	}
	$IP_Address = Get_Next_IP $SubNet
	If($IP_Address -eq $NULL)
	{
		Log("Script failed to retrieve an IP Address. Exiting Process")
		Exit
	}
	Log("-----Ending the `"Main_Get_IP`" function-----")
	Return $IP_Address
}

Function Main_Post_A_Record([string]$IP_Address, [string]$DNS)
{
	Log("-----Starting `"Main_Post_A_Record`" function-----")
	$DNS_Results = Check_DNS_Availability $DNS
	If($DNS_Results -eq $False)
	{
		Log("DNS Failed availability check. Exiting Process")
		Exit
	}
	$Response = Post_A_Record $DNS $IP_Address
	If($Response -eq $NULL)
	{
		Log("Script failed to create the A Record. Exiting Process")
		Exit
	}

	Log("-----Ending the `"Main_Post_A_Record`" function-----")
	Return $Response
}

Function Main_Post_PTR([string]$IP_Address, [string]$DNS)
{
	Log("-----Starting `"Main_Post_PTR`" function-----")
	$PTR_Name = Create_PTR_Name $IP_Address
	$Response = Create_PTR $DNS $IP_Address $PTR_Name
	If($Response -eq $NULL)
	{
		Log("Failed to create the PTR. Exiting Process.")
		Exit
	}
	Log("-----Ending the `"Main_Post_PTR`" function-----")	
	Return $Response
}
## 3 Main Functions ##

## Infoblox Call Functions ##
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
	$URI = "https://ddi.scj.com/wapi/v2.7/ipv4address?ip_address=" + $IP
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
	$URI = "https://ddi.scj.com/wapi/v2.7/network?network~=$SubNet" + "&_return_fields%2B=extattrs"
	$Response = Invoke-RestMethod -Method $Method -Uri $URI -Credential $Creds
	
	Return $Response
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

	$response = Invoke-RestMethod 'https://ddi.scj.com/wapi/v2.7/request' -Method 'POST' -Headers $headers -Body $body -Credential $Creds
	Return $Response.ips
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
Function Post_A_Record([string]$DNS,[string]$IP)
{	
	$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
	$headers.Add("Content-Type", "application/json")
	$body = "{`n    `"name`":  `"$DNS`",`n    `"ipv4addr`":  `"$IP`"`n}"
	$response = Invoke-RestMethod 'https://ddi.scj.com/wapi/v2.7/record:a?_return_fields%2B=name,ipv4addr' -Method 'POST' -Headers $headers -Body $body -Credential $Creds
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
	$URI = "https://ddi.scj.com/wapi/v2.7/record:host?name=" + $DNS
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
	$URI = "https://ddi.scj.com/wapi/v2.7/ipv4address?ip_address=" + $IP
	$Response = Invoke-RestMethod -Method $Method -Uri $URI -Credential $Creds
	
	Return $Response
}
<#
	Arguments:
		$DNS = Current DNS Name
		$IP = Current IP in use
		$PTR_Name = Generated PTR Name used in the PTR Creation process
	Purpose:
		Takes in the IP / DNS / PTR Name and creates a PTR in INfoblox for the new server
	Returns:
		This will return the PTR that was created in Infoblox, for logging purposes
		
#>
Function Create_PTR([string]$DNS,[string]$IP,[string]$PTR_Name)
{
	$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
	$headers.Add("Content-Type", "application/json")
	$body = "{`n	`"name`":`"$PTR_Name`",`n	`"ptrdname`":`"$DNS`",`n	`"ipv4addr`":`"$IP`"`n}"
	$Response = Invoke-RestMethod 'https://ddi.scj.com/wapi/v2.7/record:ptr?_return_fields%2B=name,ptrdname,ipv4addr' -Method 'POST' -Headers $headers -Body $body -Credential $Creds
	Return $Response
	
}

## Infoblox Call Functions ##

## Supporting Functions ##
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

#>
Function Create_PTR_Name([string]$IP)
{
	Log("Creating PTR")
	$Split_IP = $IP.Split(".")
	$Reversed_IP = $Split_IP[3] + "." + $Split_IP[2] + "." + $Split_IP[1] + "." + $Split_IP[0] 
	$PTR_Name = $Reversed_IP + ".in-addr.arpa/default"
	Log("PTR Name Created: " + $PTR_Name)
	Return $PTR_Name
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

## Supporting Functions ##

## Setup Functions ##
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

## Setup Functions ##



## Start Program ##
Main $args[0] $args[1]
## Start Program ##






