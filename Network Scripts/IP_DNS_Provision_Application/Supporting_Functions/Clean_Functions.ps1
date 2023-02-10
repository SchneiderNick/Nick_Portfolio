## This File is part of the IP_DNS_Provision_Application ##

<#

## Author   : Nicholas Schneider
## File #   : 
## Owner    : 
## Type     :

## Comments :

#>

<# Start Of Function #>

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
	Return $Clean_Mac_Addr
}

Function Clean_DNS()
{
	param(
	[Parameter(Mandatory=$True)][string]$Unclean_DNS
	)

	$Clean_DNS = ""
	$Unclean_DNS = $Unclean_DNS.ToLower()
	
	For($Count = 0; $Count -lt $Unclean_DNS.Length; $Count++)
	{
		[int]$Temp_Value = $Unclean_DNS[$Count]
		If((($Temp_Value -ge 45) -AND ($Temp_Value -le 46)) -OR (($Temp_Value -ge 48) -AND ($Temp_Value -le 57)) -OR (($Temp_Value -ge 65) -AND ($Temp_Value -le 90)) -OR (($Temp_Value -ge 97) -AND ($Temp_Value -le 122)))
		{
			$Clean_DNS += $Unclean_DNS[$Count]
		}
	}
	Return $Clean_DNS
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

<# End Of Function #>