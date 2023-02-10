## Begin Clean Data Functions ##

Function Clean_Mac_Address()
{
	param(
	[Parameter(Mandatory=$True)][string]$Unclean_Mac_Address
	)

	$Clean_Mac_Addr = ""
	$Unclean_Mac_Address = $Unclean_Mac_Address.ToUpper()
	
	For($Count = 0; $Count -lt $Unclean_Mac_Address.length; $Count++)
	{
	
		$Clean_Mac_Addr += $Unclean_Mac_Address[$Count]
	
	}
	$Host_Name_Gen_Dict["Mac Address"] = $Clean_Mac_Addr
	Return $Clean_Mac_Addr
}

Function Clean_Host_Name()
{
	param(
	[Parameter(Mandatory=$True)][string]$Unclean_Host_Name
	)

	$Clean_Host_Name = ""
	$Unclean_Host_Name = $Unclean_Host_Name.ToLower()
	
	For($Count = 0; $Count -lt $Unclean_Host_Name.Length; $Count++)
	{
		[int]$Temp_Value = $Unclean_Host_Name[$Count]
		If((($Temp_Value -ge 45) -AND ($Temp_Value -le 46)) -OR (($Temp_Value -ge 48) -AND ($Temp_Value -le 57)) -OR (($Temp_Value -ge 65) -AND ($Temp_Value -le 90)) -OR (($Temp_Value -ge 97) -AND ($Temp_Value -le 122)))
		{
			$Clean_Host_Name += $Unclean_Host_Name[$Count]
		}
	}
	Return $Clean_Host_Name
}

Function Clean_IP_Address()
{
	param(
	[Parameter(Mandatory=$True)][string]$Unclean_IP_Address
	)
	$Clean_IP = ""
	$Unclean_IP_Address = $Unclean_IP_Address.ToLower()
	For($Count = 0; $Count -lt $Unclean_IP_Address.Length; $Count++)
	{
		[int]$Temp_Value = $Unclean_IP_Address[$Count]
		If(($Temp_Value -eq 46) -OR (($Temp_Value -ge 48) -AND ($Temp_Value -le 57)))
		{
			$Clean_IP += $Unclean_IP_Address[$Count]

		}
	}
	Return $Clean_IP
}
## End Clean Data Functions ##
