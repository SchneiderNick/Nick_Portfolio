## Begin Check Functions ##
Function Check_Hostname()
{
	param(
	[Parameter(Mandatory=$True)][string]$Hostname
	)
	try{$Clean_Host_Name = Clean_Host_Name -Unclean_Host_Name $Hostname}
	catch{
	Add-SCJLog -Data "Failed to run *Clean Host Name*" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data "Error Information" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data ($Error) -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data "Process Ending" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	$Error_Array = @($Hostname,$False,"Could Not Clean Hostname")	
	Return $Error_Array 
	}
	try{$Connection_Test = (Test-Connection $Clean_Host_Name -ErrorAction SilentlyContinue).Count}
	catch{
	Add-SCJLog -Data "Failed to Connect to: $Clean_Host_Name" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	$Error_Array = @($Clean_Host_Name,$False,"Could Not Run Hostname Connection Test")	
	Return $Error_Array 
	}
	If($Connection_Test -gt 0)
	{
		$Error_Array = @($Clean_Host_Name,$False,"Hostname Currently In Use")	
		Return $Error_Array 
	}
	$Error_Array = @($Clean_Host_Name,$True,"Hostname Available")	
	Return $Error_Array 
}

Function Check_IP()
{
	param(
	[Parameter(Mandatory=$True)][string]$IP_Address
	)
		
	$Clean_IP = Clean_IP_Address -Unclean_IP_Address $IP_Address
	
	$IP_Split = ($Clean_IP.Split("."))
	$Num_Periods = (($IP_Split).Count - 1)
	
	If($Num_Periods -ne 3)
	{
		$Error_Array = @($Clean_IP,$False,"IP Segment with inappropriate # of periods")
		Return $Error_Array
	}
	
	Foreach($Set in $IP_Split)
	{
		If(($Set.Count -lt 1) -OR ($Set.Count -gt 3))
		{
			$Error_Array = @($Clean_IP,$False,"IP Segment with inappropriate # of digits")
			Return $Error_Array
		}
	}
	
	try{$IP_Status = Call_Infoblox_IP_Pull -IP_Address $Clean_IP}
	catch{
	Add-SCJLog -Data "Failed to run *IP Does Not Exist on Network*" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data "Error Information" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data ($Error) -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	$Error_Array = @($Clean_IP,$False,"IP Not found on the Network")
	Return $Error_Array
	}
	
	If($IP_Status -eq "USED")
	{
		$Error_Array = @($Clean_IP,$False,"IP Currently In Use")
		Return $Error_Array
	}
	
	$Error_Array = @($Clean_IP,$True,"IP Successfully Verified")
	Return $Error_Array
}

Function Check_Mac_Address()
{
	param(
	[Parameter(Mandatory=$True)][string]$Mac_Address
	)

	$Clean_Mac_Address = Clean_Mac_Address -Unclean_Mac_Address $Mac_Address
	$Colon_Counter = 0
	$Hex_Character_Counter = 0
	$Period_Counter = 0
	$Dash_Counter = 0
	
	For($Count = 0; $Count -lt $Clean_Mac_Address.length; $Count++)
	{
		[int]$Temp_Ascii_Value = $Clean_Mac_Address[$Count]
		
		If((($Temp_Ascii_Value -ge 48) -AND ($Temp_Ascii_Value -le 57)) -OR (($Temp_Ascii_Value -ge 65) -AND ($Temp_Ascii_Value -le 70)))
		{
			$Hex_Character_Counter++
		}
		ElseIf($Temp_Ascii_Value -eq 58)
		{
			$Colon_Counter++
		}
		ElseIf($Temp_Ascii_Value -eq 46)
		{
			$Period_Counter++
		}
		ElseIf($Temp_Ascii_Value -eq 45)
		{
			$Dash_Counter++
		}
		Else
		{
			Return $False
		}
	}
	
	If($Hex_Character_Counter -eq 12)
	{
		If($Colon_Counter -eq 5)
		{
			$Split_Mac_Addr = $Clean_Mac_Address.Split(':')
			ForEach($Temp_Object in $Split_Mac_Addr)
			{
				If($Temp_Object.Length -ne 2)
				{
					Return $False
				}
			}
		}
		ElseIf($Period_Counter -eq 2)
		{
			$Split_Mac_Addr = $Clean_Mac_Address.Split('.')
			ForEach($Temp_Object in $Split_Mac_Addr)
			{
				If($Temp_Object.Length -ne 4)
				{
					Return $False
				}
			}
		}
		ElseIf($Dash_Counter -eq 3)
		{
			$Split_Mac_Addr = $Clean_Mac_Address.Split('-')
			ForEach($Temp_Object in $Split_Mac_Addr)
			{
				If($Temp_Object.Length -ne 2)
				{
					Return $False
				}
			}
		}
		Else
		{
			Return $False
		}
	}
	Else
	{
		Return $False	
	}

	Return $True
}

Function Check_Subnet_Full()
{
	param(
	[Parameter(Mandatory=$True)][string]$SubNet
	)
	
	$SubNet_Split_Periods = $SubNet.Split('.')
	$SubNet_Mask = ($SubNet_Split_Periods[3].Split('/'))[1] #Between 8 and 32
	$SubNet_Split_Periods[3] = ($SubNet_Split_Periods[3].Split('/'))[0]
	
	ForEach($Value in $SubNet_Split_Periods)
	{
		If($Value -eq "")
		{
			Return $False
		}
		$Int_Value = [INT]$Value
		If(($Int_Value -lt 0) -OR ($Int_Value -gt 255))
		{
			Return $False
		}
	}
	If(($SubNet_Mask -lt 8) -OR ($SubNet_Mask -gt 32))
	{
		Return $False
	}
	
	#Call Infoblox
	
	$InfoBlox_Response = Call_Infoblox_Subnet_Check -Subnet $SubNet
	If($InfoBlox_Response.length -ne 1)
	{
		Return $False
	}
	Return $SubNet
}

Function Check_Subnet_Incomplete()
{
	param(
	[Parameter(Mandatory=$True)][string]$SubNet
	)

	$InfoBlox_Response = Call_Infoblox_Subnet_Check -Subnet $SubNet
	
	If($InfoBlox_Response.length -eq 1)
	{
		Return $InfoBlox_Response[0].Network
	}
	Else
	{
		While($True)
		{
			$Counter = 1
			Clear-Host
			ForEach($Network in $InfoBlox_Response.Network)
			{
				Write-Host ("$Counter" + ": " + $Network)
				
				$Counter++
			}

			[int]$User_Response = Read-Host "Enter the # Value of the Network you would like to select"
			If(($User_Response -gt 0) -AND ($User_Response -lt ($InfoBlox_Response.length -1)))
			{
				Return $InfoBlox_Response[$User_Response - 1].Network
			}
		}
	}
}

## End Check Functions ##
