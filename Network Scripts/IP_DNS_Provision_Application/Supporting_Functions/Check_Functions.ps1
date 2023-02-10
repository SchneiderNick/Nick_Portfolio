## This File is part of the IP_DNS_Provision_Application ##

<#

## Author   : Nicholas Schneider
## File #   : 
## Owner    : 
## Type     :

## Comments :

#>

<# Start Of Function #>
Function Check_DNS()
{
	param(
	[Parameter(Mandatory=$True)][string]$DNS
	)
	try{$Clean_DNS = Clean_DNS -Unclean_DNS $DNS}
	catch{
	Add-SCJLog -Data "Failed to run *Clean Host Name*" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data "Error Information" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data ($Error) -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data "Process Ending" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	$Info_Array = @($DNS,$False,"Could Not Clean Hostname")	
	Return $Info_Array 
	}
	
	If($Clean_DNS.Length -lt 10)
	{
		$Info_Array = @($Clean_DNS,$False,"DNS entry was too short")
		Return $Info_Array
	}
	
	try{$Connection_Test = (Test-Connection $Clean_DNS -ErrorAction SilentlyContinue).Count}
	catch{
	Add-SCJLog -Data "Failed to Connect to: $Clean_DNS" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	$Info_Array = @($Clean_DNS,$False,"Could Not Run Hostname Connection Test")	
	Return $Info_Array
	}
	If($Connection_Test -gt 0)
	{
		$Info_Array = @($Clean_DNS,$False,"Hostname Currently In Use")	
		Return $Info_Array 
	}
	$Info_Array = @($Clean_DNS,$True,"Hostname Available")	
	Return $Info_Array
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
		$Info_Array = @($Clean_IP,$False,"IP Segment with inappropriate # of periods")
		Return $Info_Array
	}
	
	Foreach($Set in $IP_Split)
	{
		If(($Set.Count -lt 1) -OR ($Set.Count -gt 3))
		{
			$Info_Array = @($Clean_IP,$False,"IP Segment with inappropriate # of digits")
			Return $Info_Array
		}
	}
	try{$IP_Status = Call_Infoblox_IP_Pull -IP_Address $Clean_IP}
	catch{
	Add-SCJLog -Data "Failed to run *IP Does Not Exist on Network*" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data "Error Information" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data ($Error) -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	$Info_Array = @($Clean_IP,$False,"IP Not found on the Network")
	Return $Info_Array
	}
	
	If($IP_Status -eq "USED")
	{
		$Info_Array = @($Clean_IP,$False,"IP Currently In Use")
		Return $Info_Array
	}
	
	$Info_Array = @($Clean_IP,$True,"IP Successfully Verified")
	Return $Info_Array
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
			$Info_Array = @($Clean_Mac_Address,$False,"Invalid Character")
			Return $Info_Array
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
					$Info_Array = @($Clean_Mac_Address,$False,"Colon Format Detected: Spacing Error")
					Return $Info_Array
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
					$Info_Array = @($Clean_Mac_Address,$False,"Period Format Detected: Spacing Error")
					Return $Info_Array
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
					$Info_Array = @($Clean_Mac_Address,$False,"Dash Format Detected: Spacing Error")
					Return $Info_Array
				}
			}
		}
		Else
		{
			$Info_Array = @($Clean_Mac_Address,$False,"Incorrect Format Detected")
			Return $Info_Array
		}
	}
	Else
	{
		$Info_Array = @($Clean_Mac_Address,$False,"Too Many or Not Enough Characters")
		Return $Info_Array
	}

	$Info_Array = @($Clean_Mac_Address,$True,"Mac Address Verified")
	Return $Info_Array
}
Function Check_SubNet()
{
	param(
	[Parameter(Mandatory=$True)][string]$SubNet
	)
	
	If($SubNet -Match "/")
	{
		Return (Check_Subnet_Full -SubNet $SubNet)
	}
	Else
	{
		Return (Check_Subnet_Incomplete -SubNet $SubNet)
	}
}

Function Check_Subnet_Full()
{
	param(
	[Parameter(Mandatory=$True)][string]$SubNet
	)
	[int]$SubNet_Mask = ($SubNet.Split('/'))[1] #Between 8 and 32
	$SubNet_Split_Periods = (($SubNet.Split('/'))[0]).Split('.')
	
	Clear
	Write-Host $SubNet_Split_Periods
	Write-Host $SubNet_Mask	
	Write-Host ($SubNet_Mask -lt 8)
	Write-Host ($SubNet_Mask -gt 32)
	
	ForEach($Value in $SubNet_Split_Periods)
	{
		If($Value -eq "")
		{
			$Info_Array = @($SubNet,$False,"Double Period Detected")
			Return $Info_Array
		}
		$Int_Value = [INT]$Value
		If(($Int_Value -lt 0) -OR ($Int_Value -gt 255))
		{
			$Info_Array = @($SubNet,$False,"SubNet Value out of range (0 - 255)")
			Return $Info_Array
		}
	}
	If(($SubNet_Mask -lt 8) -OR ($SubNet_Mask -gt 32))
	{
		$Info_Array = @($SubNet,$False,"SubNet Mask Out of Range (8 - 32)")
		Return $Info_Array
	}
	
	#Call Infoblox 
	
	$InfoBlox_Response = Call_Infoblox_Subnet_Check -Subnet $SubNet
	If($InfoBlox_Response.length -ne 1)
	{
		$Info_Array = @($SubNet,$False,"SubNet Not Found In Infoblox")
		Return $Info_Array
	}
	
	$Info_Array = @($SubNet,$True,"SubNet Verified")
	Return $Info_Array
}

Function Check_Subnet_Incomplete()
{
	param(
	[Parameter(Mandatory=$True)][string]$SubNet
	)
	$InfoBlox_Response = Call_Infoblox_Subnet_Check -Subnet $SubNet
	
	If($InfoBlox_Response.length -eq 1)
	{
		$Info_Array = @($InfoBlox_Response[0].Network,$True,"Network successfully Found")
		Return $Info_Array
	}
	ElseIf($InfoBlox_Response.length -eq 0)
	{
		$Info_Array = @($InfoBlox_Response[0].Network,$False,"No Network Found")
		Return $Info_Array
	}
	Else
	{
		$Incomplete_SubNet_Loop_Check = $False
		While($Incomplete_SubNet_Loop_Check -eq $False)
		{
			$Incomplete_SubNet_Form = Create_Form -Text "Check SubNet Incomplete Form"
			
			$Incomplete_Main_Label = Create_Label -Text "Please Select a SubNet from the List of Related SubNets"-Location_Width 87 -Location_Height 60 -Size_Width 225 -Size_Height 60 -Bold $True
			
			$Incomplete_Combo_Box = Create_ComboBox -Text "SubNet" -Location_Width 200 -Location_Height 150 -Size_Width 200 -Size_Height 30
			
			$Incomplete_Submit_Button = Create_Button -Text "Submit" -Location_Width 350 -Location_Height 250 -Size_Width 150 -Size_Height 50
			
			$Incomplete_Submit_Button.Add_Click({
			$Supporting_Info["Incomplete_Subnet"] = $Incomplete_Combo_Box.Text;
			[void]$Incomplete_SubNet_Form.Close();
			[void]$Incomplete_SubNet_Form.Dispose();
			})
			
			ForEach($Network in $InfoBlox_Response.Network)
			{
				[void]$Incomplete_Combo_Box.Items.Add($Network)
			}
			
			$Incomplete_SubNet_Form.Controls.AddRange(@($Incomplete_Main_Label,$Incomplete_Combo_Box,$Incomplete_Submit_Button))
			
			[void]$Incomplete_SubNet_Form.ShowDialog()
			If($Supporting_Info["Incomplete_Subnet"] -ne "SubNet")
			{
				$Info_Array = @($Supporting_Info["Incomplete_Subnet"],$True,"Network successfully Found") 
				Return $Info_Array
			}
		}
	}
}
<# End Of Function #>