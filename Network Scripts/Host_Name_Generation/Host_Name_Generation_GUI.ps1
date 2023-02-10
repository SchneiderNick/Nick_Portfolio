Add-Type -AssemblyName System.Windows.Forms    
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$Script_Path = (split-path -parent $MyInvocation.MyCommand.Definition)

$secpasswd = ConvertTo-SecureString "################" -AsPlainText -Force
$Creds = New-Object System.Management.Automation.PSCredential ("gnsapi", $secpasswd)

$Search_Button_Pressed = @{}
$Search_Button_Pressed["SubNet"] = $False
$Host_Name_Gen_Dict = @{}

## Begin Form Setup Functions ##

Function Create_Form([string]$text)
{
	$Form_Object = New-Object System.Windows.Forms.Form
    $Form_Object.Text = $text
	$Form_Object.Width = 600
	$Form_Object.Height = 400 + 39
	$Form_Object.AutoSize = $true
    $Form_Object.StartPosition = "CenterScreen"
	$Form_Object.BackColor = "#282828"
    $Form_Object.Topmost = $True
	
	$Image_Object = Create_Image ($Script_Path + "\Images\scj_logo_New.png") 10 300 150 100 
	$Form_Object.Controls.AddRange(@($Image_Object))
	
	Return $Form_Object
}

Function Create_Button([string]$text,[int]$l_width,[int]$l_height,[int]$s_width,[int]$s_height)
{
	$Button_Object = New-Object System.Windows.Forms.Button
    $Button_Object.Location = New-Object System.Drawing.Size($l_width,$l_height)
    $Button_Object.Size = New-Object System.Drawing.Size($s_width,$s_height)
	$Button_Object.BackColor = "#808080"
	$Button_Object.ForeColor = "#ffffff"
    $Button_Object.Text = $text
	
	Return $Button_Object
}
	
Function Create_Text_Box([int]$l_width,[int]$l_height,[int]$s_width,[int]$s_height,[int]$font_size)
{

	$Text_Box_Object = New-Object System.Windows.Forms.TextBox
    $Text_Box_Object.Location = New-Object System.Drawing.Size($l_width,$l_height)
    $Text_Box_Object.Size = New-Object System.Drawing.Size($s_width,$s_height)
	$Text_Box_Object.Font = ('Microsoft Sans Serif,' + "$font_size")
	
	Return $Text_Box_Object
	
	}

Function Create_Label([string]$text,[int]$l_width,[int]$l_height,[int]$s_width,[int]$s_height,$Font)
{
	$Label_Object = New-Object system.Windows.Forms.Label
	$Label_Object.text = $text
	$Label_Object.AutoSize = $true
	$Label_Object.width = $s_width
	$Label_Object.height = $s_height
	$Label_Object.location = New-Object System.Drawing.Point($l_width,$l_height)
	$Label_Object.Font = ('Microsoft Sans Serif,' + $Font + ',style=Bold')
	$Label_Object.ForeColor = "#ffffff"
	
	Return $Label_Object
}

Function Create_Image([string]$Image_Location,[int]$l_width,[int]$l_height,[int]$s_width,[int]$s_height)
{
	$Image_Object = New-Object system.Windows.Forms.PictureBox
	$Image_Object.width = $s_width 
	$Image_Object.height = $s_height
	$Image_Object.location = New-Object System.Drawing.Point($l_width,$l_height)
	$Image_Object.imageLocation = $Image_Location
	$Image_Object.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::zoom
	Return $Image_Object
}

Function Create_ComboBox([string]$Text,[int]$l_width,[int]$l_height,[int]$s_width,[int]$s_height,[string]$Font)
{
	$ComboBox_Object = New-Object system.Windows.Forms.ComboBox
	
	$ComboBox_Object.text = $Text
	$ComboBox_Object.width = $s_width
	$ComboBox_Object.height = $s_height
	$ComboBox_Object.location = New-Object System.Drawing.Point($l_width,$l_height)
	$ComboBox_Object.Font = "Microsoft Sans Serif,$Font"
	
	Return $ComboBox_Object
}


## End Form Setup Functions ##

## Begin Clean Data Functions ##

Function Clean_Mac_Address([String]$Unclean_Mac_Addr)
{
	$Clean_Mac_Addr = ""
	$Unclean_Mac_Addr = $Unclean_Mac_Addr.ToUpper()
	
	For($Count = 0; $Count -lt $Unclean_Mac_Addr.length; $Count++)
	{
	
		$Clean_Mac_Addr += $Unclean_Mac_Addr[$Count]
	
	}
	$Host_Name_Gen_Dict["Mac Address"] = $Clean_Mac_Addr
	Return $Clean_Mac_Addr
}

Function Clean_Host_Name([string]$Unclean_Host_Name)
{
	$Clean_Host_Name = ""
	$Unclean_Host_Name = $Unclean_Host_Name.ToLower()
	
	For($Count = 0; $Count -lt $Clean_Host_Name[$Count]; $Count++)
	{
		[int]$Temp_Value = $Clean_Host_Name[$Count]
		If((($Temp_Value -ge 45) -AND ($Temp_Value -le 46)) -OR (($Temp_Value -ge 48) -AND ($Temp_Value -le 57)) -OR (($Temp_Value -ge 65) -AND ($Temp_Value -le 90)) -OR (($Temp_Value -ge 97) -AND ($Temp_Value -le 122)))
		{
			$Clean_Host_Name += $Clean_Host_Name[$Count]
		}
	}
	Return $Clean_Host_Name
}

## End Clean Data Functions ##

## Begin Check Functions ##
Function Hostname_Check($Unclean_Host_Name)
{
	$Clean_Host_Name = Clean_Host_Name $Unclean_Host_Name
	
	If((Test-Connection $Clean_Host_Name -ErrorAction SilentlyContinue).Count -eq 1)
	{
		Return $False
	}
	Return $True
}

Function IP_Check($Unclean_IP_Address)
{
	Return $True
}

Function Check_Mac_Address([String]$Unclean_Mac_Address)
{
	$Clean_Mac_Address = Clean_Mac_Address $Unclean_Mac_Address
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

Function Check_Subnet_Full([string]$SubNet)
{
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
	
	$InfoBlox_Response = Call_Infoblox_Subnet_Check $SubNet
	If($InfoBlox_Response.length -ne 1)
	{
		Return $False
	}
	
	Return $SubNet
}

Function Check_Subnet_Incomplete([string]$SubNet)
{
	$InfoBlox_Response = Call_Infoblox_Subnet_Check $SubNet
	
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

## Begin Navigation Functions ##
Function IP_DNS()
{
	
	IP_Form
	Script_Status
	&$Host_Name_Gen_Dict["IP_Request_Type"]
	Script_Status
	DNS_Form
	Script_Status
	
}

Function DNS_IP()
{
	
	DNS_Form
	Script_Status
	IP_Form
	Script_Status
	&$Host_Name_Gen_Dict["IP_Request_Type"]
	Script_Status
	
}


Function Reserved()
{
	IP_Provision_Method
	Script_Status
	&$Host_Name_Gen_Dict["IP_Provision_Method"]
	Script_Status
}



Function Next_Available_IP()
{
	SubNet
	Script_Status
	
}

## End Navigation Functions ##

#### Begin Form Logic Functions ####

## Begin Level 1 Functions ##

Function Request_Type_Form()
{

    # Build Form
	$Request_Type_Form = Create_Form 'Host Name Generation'
	#Build label
	
	$Request_Label = Create_Label 'Please Select The Request Type' 80 60 225 60 "12"
	
    # Add Buttons
	$IP = Create_Button 'IP' 100 175 100 50
    $IP_DNS = Create_Button 'IP/DNS' 250 175 100 50
    $DNS = Create_Button 'DNS' 400 175 100 50
	
	
	#Add To Form
    $Request_Type_Form.Controls.AddRange(@($DNS,$IP_DNS,$IP,$Request_Label,$Form_Button_Object))

	#Add Button Functionality
    $IP.Add_Click({$Host_Name_Gen_Dict["Request_Type"] = "IP"; [void]$Request_Type_Form.Close(); [void]$Request_Type_Form.Dispose(); })
	$IP_DNS.Add_Click({$Host_Name_Gen_Dict["Request_Type"] = "IP/DNS"; [void]$Request_Type_Form.Close(); [void]$Request_Type_Form.Dispose(); })
	$DNS.Add_Click({$Host_Name_Gen_Dict["Request_Type"] = "DNS"; [void]$Request_Type_Form.Close(); [void]$Request_Type_Form.Dispose(); })
	
	#Display the GUI
    [void]$Request_Type_Form.ShowDialog() 
}

## End Level 1 Functions ##

## Begin Level 2 Functions ##

Function IP()
{
	IP_Form
	Script_Status
	&$Host_Name_Gen_Dict["IP_Request_Type"]
	Script_Status
	
}
Function IP/DNS()
{
	IP_DNS_Form
	Script_Status
	&$Host_Name_Gen_Dict["IP_DNS_Request_Type"]
	Script_Status

}
Function DNS()
{
	DNS_Form
	Script_Status
	Provide_IP
}

## End Level 2 Functions ##

## Begin Form Creation Functions ##
Function DNS_Form()
{
	$Hostname_Check = $True
	$Host_Name_First_Run = $True
	While(($Hostname_Check -eq $True) -AND ($Host_Name_Gen_Dict["Hostname"] -ne "N/A") -AND ($Host_Name_Gen_Dict["IP"] -ne "N/A"))
	{
		$DNS_Form = Create_Form 'Host Name Generation'

		$DNS_Text_Box = Create_Text_Box 250 150 200 20 15
		$IP_Text_Box = Create_Text_Box 250 200 200 20 15

		$DNS_Label = Create_Label 'Enter a Valid Hostname' 25 150 100 50 "12"
		$IP_Label = Create_Label 'Enter a Valid IP' 25 200 100 50 "12"

		#Submit Button 
		$Submit_Button = Create_Button "Submit" 400 310 150 40

		$DNS_Form.Controls.AddRange(@($Submit_Button,$DNS_Label,$IP_Text_Box,$IP_Label,$DNS_Text_Box))
		
		If($Host_Name_First_Run -eq $False)
		{
			If($Host_Name_Gen_Dict["Hostname"] -eq "")
			{
				$Host_Name_Error_Message = "No Hostname Detected"
			}
			ElseIf($Host_Name_Gen_Dict["Hostname"].length -lt 8)
			{
				$Host_Name_Error_Message = "Hostname is too short"
			}
			$Error_Message_Label = Create_Label $$Host_Name_Error_Message 25 150 100 50 "12"
			$DNS_Form.Controls.Add($Error_Message_Label)
		}
		
		
		
		$DNS_Form.KeyPreview = $True
		$DNS_Form.Add_KeyDown({if ($_.KeyCode -eq "Enter")
		{$Host_Name_Gen_Dict["DNS_Request_Type"] = "DNS_Form";$DNS_Form.Close()}})
		$DNS_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
		{$Host_Name_Gen_Dict["DNS_Request_Type"] = "N/A";$DNS_Form.Close()}})
		
		$Submit_Button.Add_Click({$Host_Name_Gen_Dict["Hostname"] = $DNS_Text_Box.Text; $Host_Name_Gen_Dict["IP"] = $DNS_Text_Box.Text; [void]$DNS_Form.Close(); [void]$DNS_Form.Dispose(); })
		
		[void]$DNS_Form.ShowDialog()
		
		If((Hostname_Check $Host_Name_Gen_Dict["Hostname"]) -AND (IP_Check $Host_Name_Gen_Dict["IP"]))
		{
			$Hostname_Check = $False
		}
	}
}

Function IP_DNS_Form()
{
	$IP_DNS_Form = Create_Form 'Host Name Generation'
	
	$IP_DNS_Label = Create_Label 'Choose to Enter an IP or Hostname' 80 60 225 60 "12"
	
	#Button One
	$IP = Create_Button 'IP' 150 175 100 50
	
	#Button 2
	$DNS = Create_Button 'DNS' 350 175 100 50

    $IP_DNS_Form.Controls.AddRange(@($IP,$DNS,$IP_DNS_Label))
	$IP_DNS_Form.KeyPreview = $True
	$IP_DNS_Form.Add_KeyDown({if ($_.KeyCode -eq "Enter")
	{$Host_Name_Gen_Dict["IP_DNS_Request_Type"] = "IP/DNS";$IP_DNS_Form.Close()}})
	$IP_DNS_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
	{$Host_Name_Gen_Dict["IP_DNS_Request_Type"] = "N/A";$IP_DNS_Form.Close()}})
	
	$IP.Add_Click({$Host_Name_Gen_Dict["IP_DNS_Request_Type"] = "IP_DNS"; [void]$IP_DNS_Form.Close(); [void]$IP_DNS_Form.Dispose(); })
	$DNS.Add_Click({$Host_Name_Gen_Dict["IP_DNS_Request_Type"] = "DNS_IP"; [void]$IP_DNS_Form.Close(); [void]$IP_DNS_Form.Dispose(); })
	
	[void]$IP_DNS_Form.ShowDialog()
}

Function IP_Form()
{
	$IP_Form = Create_Form 'Host Name Generation'
	
	$IP_Label = Create_Label 'Enter an IP Request Type' 80 60 225 60 "12"
	
	#Button One
	$Reserved = Create_Button 'Reserved' 150 175 100 50
	
	#Button 2
	$Fixed = Create_Button 'Fixed' 350 175 100 50

    $IP_Form.Controls.AddRange(@($Reserved,$Fixed,$IP_Label))
	$IP_Form.KeyPreview = $True
	$IP_Form.Add_KeyDown({if ($_.KeyCode -eq "Enter")
	{$Host_Name_Gen_Dict["IP_Request_Type"] = "Reserved";$IP_Form.Close()}})
	$IP_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
	{$Host_Name_Gen_Dict["IP_Request_Type"] = "N/A";$IP_Form.Close()}})
	
	$Reserved.Add_Click({$Host_Name_Gen_Dict["IP_Request_Type"] = "Reserved"; [void]$IP_Form.Close(); [void]$IP_Form.Dispose(); })
	$Fixed.Add_Click({$Host_Name_Gen_Dict["IP_Request_Type"] = "Fixed"; [void]$IP_Form.Close(); [void]$IP_Form.Dispose(); })
	
	[void]$IP_Form.ShowDialog()
}

Function Fixed()
{
	$Mac_Addr_Check = $True
	
	While(($Mac_Addr_Check -eq $True) -AND ($Host_Name_Gen_Dict["Mac Address"] -ne "N/A"))
	{
		$Mac_Addr_Form = Create_Form 'Host Name Generation'
		
		#Text Box
		$Fixed_Text_Box	= Create_Text_Box 250 150 200 20 15
		
		#Submit Button
		$Fixed_Button = Create_Button 'Enter Mac Address' 500 150 150 50
		
		$Fixed_Button.Add_Click({$Host_Name_Gen_Dict["Mac Address"] = $Fixed_Text_Box.Text; [void]$Mac_Addr_Form.Close(); [void]$Mac_Addr_Form.Dispose(); })
		
		#Add Label
		$Fixed_Label1 = Create_Label 'Enter a Valid Mac Address' 25 150 100 50 "12"
		$Fixed_Label2 = Create_Label 'Valid Formats:' 250 200 100 50 "10"
		$Fixed_Label3 = Create_Label '##:##:##:##:##:##' 250 225 100 50 "10"
		$Fixed_Label4 = Create_Label '####.####.####' 250 250 100 50 "10"
		$Fixed_Label5 = Create_Label '##-##-##-##-##-##' 250 275 100 50 "10"
		
		$Mac_Addr_Form.Controls.AddRange(@($Fixed_Button,$Fixed_Text_Box,$Fixed_Label1,$Fixed_Label2,$Fixed_Label3,$Fixed_Label4,$Fixed_Label5))
		
		$Mac_Addr_Form.KeyPreview = $True
		$Mac_Addr_Form.Add_KeyDown({if ($_.KeyCode -eq "Enter")
		{$Host_Name_Gen_Dict["Mac Address"] = $Fixed_Text_Box.Text;$Mac_Addr_Form.Close()}})
		$Mac_Addr_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
		{$Host_Name_Gen_Dict["Mac Address"] = "N/A";$Mac_Addr_Form.Close()}})

		[void]$Mac_Addr_Form.ShowDialog()
		
		If(Check_Mac_Address $Host_Name_Gen_Dict["Mac Address"])
		{
			Break
		}
	}
	IP_Provision_Method
	Script_Status
	&$Host_Name_Gen_Dict["IP_Provision_Method"]
	Script_Status
	
}

Function IP_Provision_Method()
{
	
	$IP_Provision_Form = Create_Form 'Host Name Generation'
	
	$IP_Label = Create_Label 'Enter an IP Provision Type' 80 60 225 60 "12"
	
	#Button One
	$Next_Available_IP = Create_Button 'Next Available IP' 100 175 150 50
	
	#Button two
	$Provide_IP = Create_Button 'Provide IP' 350 175 150 50
		
    $IP_Provision_Form.Controls.AddRange(@($Next_Available_IP,$Provide_IP,$IP_Label))
	$IP_Provision_Form.KeyPreview = $True
	$IP_Provision_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
	{$Host_Name_Gen_Dict["IP_Provision_Method"] = "N/A";$IP_Provision_Form.Close()}})
	
	$Next_Available_IP.Add_Click({$Host_Name_Gen_Dict["IP_Provision_Method"] = "Next_Available_IP"; [void]$IP_Provision_Form.Close(); [void]$IP_Provision_Form.Dispose(); })
	$Provide_IP.Add_Click({$Host_Name_Gen_Dict["IP_Provision_Method"] = "Provide_IP"; [void]$IP_Provision_Form.Close(); [void]$IP_Provision_Form.Dispose(); })
	
	[void]$IP_Provision_Form.ShowDialog()
}

Function SubNet()
{
	
	$SubNet_Form = Create_Form 'Host Name Generation' #Main Form (Choice Between Search and Enter Value)
	$Search_SubNet_Form = Create_Form 'Host Name Generation'
	$Enter_SubNet_Form = Create_Form 'Host Name Generation'
	
	## Form Setup ##
	
	$SubNet_Form.KeyPreview = $True
	$SubNet_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
	{$Host_Name_Gen_Dict["SubNet_Method"] = "N/A";$SubNet_Form.Close()}})
	
	$Search_SubNet_Form.KeyPreview = $True
	$Search_SubNet_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
	{$Host_Name_Gen_Dict["SubNet"] = "N/A";$Search_SubNet_Form.Close()}})
	
	$Enter_SubNet_Form.KeyPreview = $True
	$Enter_SubNet_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
	{$Host_Name_Gen_Dict["SubNet"] = "N/A";$Enter_SubNet_Form.Close()}})
	
	
	
	## Form Setup ##
	
	## SubNet Form ##
		$SubNet_Form_Label = Create_Label 'Choose to Search for a SubNet or Enter one in Directly' 80 60 225 60 "12"
		
		#Button One
		$Search_SubNets = Create_Button 'Search SubNets' 100 175 150 50
		
		#Button two
		$Provide_SubNet = Create_Button 'Provide SubNet' 350 175 150 50
		
		$Search_SubNets.Add_Click({$Host_Name_Gen_Dict["SubNet_Method"] = "Search SubNets"; [void]$SubNet_Form.Close(); [void]$SubNet_Form.Dispose(); })
		$Provide_SubNet.Add_Click({$Host_Name_Gen_Dict["SubNet_Method"] = "Provide SubNet"; [void]$SubNet_Form.Close(); [void]$SubNet_Form.Dispose(); })

		$SubNet_Form.Controls.AddRange(@($SubNet_Form_Label,$Search_SubNets,$Provide_SubNet))
		
		[void]$SubNet_Form.ShowDialog()
		
		Script_Status
	## SubNet Form ##
	
	
	If($Host_Name_Gen_Dict["SubNet_Method"] -eq "Search SubNets")
	{
		## Search SubNet Form ##
			$SubNet_Form_Label = Create_Label 'Choose a Region' 200 60 225 60 "12"
			
			#Button One
			$North_America = Create_Button 'North America' 100 107 150 50
			
			#Button Two
			$Latin_America = Create_Button 'Latin America' 350 107 150 50
			
			#Button Three
			$EMEA = Create_Button 'EMEA' 100 204 150 50
			
			#Button Four
			$Asia_Pacific = Create_Button 'Asia Pacific' 350 204 150 50
			
			#Button Five
			$Other = Create_Button 'Other' 225 301 150 50
			
			$Search_SubNet_Form.Controls.AddRange(@($SubNet_Form_Label,$North_America,$Latin_America,$EMEA,$Asia_Pacific,$Other))
			
			$North_America.Add_Click({$Host_Name_Gen_Dict["SubNet_Region"] = "North America"; Search_SubNets; [void]$Search_SubNet_Form.Close(); [void]$Search_SubNet_Form.Dispose(); })
			$Latin_America.Add_Click({$Host_Name_Gen_Dict["SubNet_Region"] = "Latin America"; Search_SubNets; [void]$Search_SubNet_Form.Close(); [void]$Search_SubNet_Form.Dispose(); })
			$EMEA.Add_Click({$Host_Name_Gen_Dict["SubNet_Region"] = "EMEA"; Search_SubNets; [void]$Search_SubNet_Form.Close(); [void]$Search_SubNet_Form.Dispose(); })
			$Asia_Pacific.Add_Click({$Host_Name_Gen_Dict["SubNet_Region"] = "Asia Pacific"; Search_SubNets; [void]$Search_SubNet_Form.Close(); [void]$Search_SubNet_Form.Dispose(); })
			$Other.Add_Click({$Host_Name_Gen_Dict["SubNet_Region"] = "Other"; Search_SubNets; [void]$Search_SubNet_Form.Close(); [void]$Search_SubNet_Form.Dispose(); })

			[void]$Search_SubNet_Form.ShowDialog()
			Script_Status
		## Search SubNet Form ##
	}
	ElseIf($Host_Name_Gen_Dict["SubNet_Method"] -eq "Provide SubNet")
	{
		## Enter SubNet Form ##
		
		
		
		
		
		
		## Enter SubNet Form ##
	}
}
Function Search_SubNets()
{
	## Search SubNet Sub Form ##
	$Host_Name_Gen_Dict["SubNets_Loop_Check"] = $True

	While($Host_Name_Gen_Dict["SubNets_Loop_Check"])
	{
		$Search_SubNet_Sub_Form = Create_Form 'Host Name Generation'
		$Search_SubNet_Sub_Form.KeyPreview = $True

		$Search_SubNet_Sub_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
		{$Host_Name_Gen_Dict["SubNets_Loop_Check"] = $False;$Search_SubNet_Sub_Form.Close()}})
		$SubNet_Label = Create_Label 'Enter Search Criteria' 200 60 225 60 "12"
		$Country_Combo_Box = Create_ComboBox "Country" 50 100 200 30 "12"
		$Site_Combo_Box = Create_ComboBox "Site" 50 150 200 30 "12"
		$VLAN_Combo_Box = Create_ComboBox "VLAN" 50 200 200 30 "12"
		$Search_Button = Create_Button "Search" 50 250 150 50

		##
		$Select_Button = Create_Button "Select" 350 250 150 50
		$SubNet_List_Combo_Box = Create_ComboBox "SubNets" 350 150 200 30 "12"
		##

		$Temp_Data = (Get-Variable ( (($Host_Name_Gen_Dict["SubNet_Region"]).Replace(' ','_')) + "_Data")).Value

		$Unique_Country_List = @("None")
		$Unique_Site_List = @("None")
		$Unique_VLAN_List = @("None")

		Foreach($Network in $Temp_Data)
		{
			Try{$Temp_Country = ($Network.extattrs.Country.Value).ToLower()}
			Catch{}
			Try{$Temp_Site = ($Network.extattrs.Site.Value).ToLower()}
			Catch{}
			Try{$Temp_VLAN = ($Network.extattrs.VLAN.Value).ToLower()}
			Catch{}

			If((-Not($Unique_Country_List -Contains $Temp_Country)) -AND ($Temp_Country -ne $NULL))
			{
				$Unique_Country_List += $Temp_Country
			}
			If((-Not($Unique_Site_List -Contains $Temp_Site)) -AND ($Temp_Site -ne $NULL))
			{
				$Unique_Site_List += $Temp_Site
			}
			If((-Not($Unique_VLAN_List -Contains $Temp_VLAN)) -AND ($Temp_VLAN -ne $NULL))
			{
				$Unique_VLAN_List += $Temp_VLAN
			}
		}

		$Unique_Country_List = $Unique_Country_List | Sort
		$Unique_Site_List = $Unique_Site_List | Sort
		$Unique_VLAN_List = $Unique_VLAN_List | Sort
		
		Foreach($Country in $Unique_Country_List)
		{
			[void]$Country_Combo_Box.Items.Add($Country)
		}
		Foreach($Site in $Unique_Site_List)
		{
			[void]$Site_Combo_Box.Items.Add($Site)
		}
		Foreach($VLAN in $Unique_VLAN_List)
		{
			[void]$VLAN_Combo_Box.Items.Add($VLAN)
		}

		$Label_Array = @()
		for($i = 100; $i -lt 388; $i += 15)
		{
			$Label_Array += (Create_Label "|" 275 $i 25 10 "12")
		}

		$Search_Button.Add_Click({ 
		$Host_Name_Gen_Dict["SubNet_Country"] = $Country_Combo_Box.Text;
		$Host_Name_Gen_Dict["SubNet_Site"] = $Site_Combo_Box.Text;
		$Host_Name_Gen_Dict["SubNet_VLAN"] = $VLAN_Combo_Box.Text;
		$Search_Button_Pressed["SubNet"] = $True
		[void]$Search_SubNet_Sub_Form.Close();
		[void]$Search_SubNet_Sub_Form.Dispose();
		})
		$Select_Button.Add_Click({ 
		$Host_Name_Gen_Dict["SubNet"] = $SubNet_List_Combo_Box.Text;
		Grab_SubNet_Data($SubNet_List_Combo_Box.Text)
		$Search_Button_Pressed["SubNet"] = $True;
		If(($SubNet_List_Combo_Box.Text -ne "SubNets") -AND ($SubNet_List_Combo_Box.Text -ne "No SubNets Found")){$Host_Name_Gen_Dict["SubNets_Loop_Check"] = $False};
		[void]$Search_SubNet_Sub_Form.Close();
		[void]$Search_SubNet_Sub_Form.Dispose();
		})

		If($Host_Name_Gen_Dict["SubNet_Country"] -ne $Null)
		{
			$Country_Combo_Box.text = $Host_Name_Gen_Dict["SubNet_Country"]
		}
		If($Host_Name_Gen_Dict["SubNet_Site"] -ne $Null)
		{
			$Site_Combo_Box.text = $Host_Name_Gen_Dict["SubNet_Site"]
		}
		If($Host_Name_Gen_Dict["SubNet_VLAN"] -ne $Null)
		{
			$VLAN_Combo_Box.text = $Host_Name_Gen_Dict["SubNet_VLAN"]
		}

		$Search_SubNet_Sub_Form.Controls.AddRange(@($SubNet_Label,$Country_Combo_Box,$Site_Combo_Box,$VLAN_Combo_Box,$Search_Button))
		$Search_SubNet_Sub_Form.Controls.AddRange($Label_Array)

		If($Search_Button_Pressed["SubNet"] -eq $True)
		{
			$Network_List = @()
			Foreach($Network in $Temp_Data)
			{
				Try{$Temp_Country = ($Network.extattrs.Country.Value).ToLower()}
				Catch{}
				Try{$Temp_Site = ($Network.extattrs.Site.Value).ToLower()}
				Catch{}
				Try{$Temp_VLAN = ($Network.extattrs.VLAN.Value).ToLower()}
				Catch{}

				$Country_Check = (($Host_Name_Gen_Dict["SubNet_Country"] -ne "None") -AND ($Host_Name_Gen_Dict["SubNet_Country"] -ne "Country"))
				$Site_Check = (($Host_Name_Gen_Dict["SubNet_Site"] -ne "None") -AND ($Host_Name_Gen_Dict["SubNet_Site"] -ne "Site"))
				$VLAN_Check = (($Host_Name_Gen_Dict["SubNet_VLAN"] -ne "None") -AND ($Host_Name_Gen_Dict["SubNet_VLAN"] -ne "VLAN"))

				$Country_Data_Check = ($Temp_Country -eq $Host_Name_Gen_Dict["SubNet_Country"])
				$Site_Data_Check = ($Temp_Site -eq $Host_Name_Gen_Dict["SubNet_Site"])
				$VLAN_Data_Check = ($Temp_VLAN -eq $Host_Name_Gen_Dict["SubNet_VLAN"])
				
				If(((-Not(($Country_Check -eq $True) -And ($Country_Data_Check -eq $False)))) -And ((-Not(($Site_Check -eq $True) -And ($Site_Data_Check -eq $False)))) -And ((-Not(($Vlan_Check -eq $True) -And ($Vlan_Data_Check -eq $False)))))
				{
					$Network_List += $Network.Network
				}
			}
			$Network_List = $Network_List | Sort
			If($Network_List.length -gt 0)
			{
				Foreach($Network_Value in $Network_List)
				{
					$SubNet_List_Combo_Box.Items.Add($Network_Value)
				}
			}
			Else
			{
				$SubNet_List_Combo_Box.Items.Add("No SubNets Found")
			}
			$Search_SubNet_Sub_Form.Controls.AddRange(@($Select_Button, $SubNet_List_Combo_Box))
		}
		[void]$Search_SubNet_Sub_Form.ShowDialog()
	}
## Search SubNet Sub Form ##
}

Function Provide_IP()
{
	$Provide_IP_Check = $True
	While(($Provide_IP_Check -eq $True) -AND ($Host_Name_Gen_Dict["IP"] -ne "N/A"))
	{
		$Provide_IP_Form = Create_Form 'Host Name Generation'

		$Provide_IP_Text_Box = Create_Text_Box 250 150 200 20 15


		$Provide_IP_Label = Create_Label 'Enter a Valid IP' 25 150 100 50 "12"

		#Submit Button 
		$Submit_Button = Create_Button "Submit" 400 310 150 40

		$Provide_IP_Form.Controls.AddRange(@($Submit_Button,$Provide_IP_Label,$Provide_IP_Text_Box))
		$Provide_IP_Form.KeyPreview = $True
		$Provide_IP_Form.Add_KeyDown({if ($_.KeyCode -eq "Enter")
		{$Host_Name_Gen_Dict["IP_Request_Type"] = "Provide_IP_Form";$Provide_IP_Form.Close()}})
		$Provide_IP_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
		{$Host_Name_Gen_Dict["IP_Request_Type"] = "N/A";$Provide_IP_Form.Close()}})
		
		$Submit_Button.Add_Click({$Host_Name_Gen_Dict["IP"] = $Provide_IP_Text_Box.Text; $Host_Name_Gen_Dict["IP"] = $Provide_IP_Text_Box.Text; [void]$Provide_IP_Form.Close(); [void]$Provide_IP_Form.Dispose(); })
		
		[void]$Provide_IP_Form.ShowDialog()
		
		If(($Provide_IP_Check -eq $True) -AND (IP_Check -eq $True))
		{
			$Provide_IP_Check = $False
		}
	}
}

Function Display_Info_Form()
{
	$Host_Name_Gen_Dict["Validation"] = $False
	While(-Not($Host_Name_Gen_Dict["Validation"]))
	{
		If($Host_Name_Gen_Dict["Request_Type"] -eq "IP")
		{
			$Request_Type_IP_Form = Create_Form "IP Validation"
			
			$Request_Type_IP_Form.KeyPreview = $True
			$Request_Type_IP_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
			{$Host_Name_Gen_Dict["Validation"] = "N/A";$Request_Type_IP_Form.Close()}})
			
			## Header Label
			
			
			If($Host_Name_Gen_Dict["IP_Request_Type"] -eq "Fixed")
			{
				#IP / MAC / Subnet
				
				## IP Label
				## Current IP Label
				## IP Textbox
				## IP Update button
				
				## Mac Label
				## Current Mac Label
				## Mac textbox
				## Mac update button
				
				## Subnet Label
				## Current Subnet label
				## Subnet Site Label
				## Subnet Vlan label
				## Subnet Country
				## Subnet update button
				
			}
			Else
			{
				
				
				
			#Deprioritized before completion	
				
				
				
				
			}
			[void]$Request_Type_IP_Form.ShowDialog()
		}
		ElseIf($Host_Name_Gen_Dict["Request_Type"] -eq "IP/DNS")
		{
			$Request_Type_IP_DNS_Form = Create_Form "IP/DNS Validation"
			
			$Request_Type_IP_DNS_Form.KeyPreview = $True
			$Request_Type_IP_DNS_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
			{$Host_Name_Gen_Dict["Validation"] = "N/A";$Request_Type_IP_DNS_Form.Close()}})
			
			
			
			[void]$Request_Type_IP_DNS_Form.ShowDialog()
		}
		ElseIf($Host_Name_Gen_Dict["Request_Type"] -eq "DNS")
		{
			$Request_Type_DNS_Form = Create_Form "DNS Validation"
			
			$Request_Type_DNS_Form.KeyPreview = $True
			$Request_Type_DNS_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
			{$Host_Name_Gen_Dict["Validation"] = "N/A";$Request_Type_DNS_Form.Close()}})
			
			
			
			[void]$Request_Type_DNS_Form.ShowDialog()
		}
		Else
		{
			Exit
		}
		Script_Status
	}
}

## End Form Creation Functions ##


## Begin Supporting Functions ##

Function Grab_SubNet_Data($SubNet)
{
	$Temp_Data = (Get-Variable ( (($Host_Name_Gen_Dict["SubNet_Region"]).Replace(' ','_')) + "_Data")).Value
	Foreach($Network in $Temp_Data)
	{
		If($Network.Network -eq $SubNet)
		{
			Try{$Host_Name_Gen_Dict["SubNet_Country"] = ($Network.extattrs.Country.Value).ToLower()}
			Catch{$Host_Name_Gen_Dict["SubNet_Country"] = "None Available"}
			Try{$Host_Name_Gen_Dict["SubNet_Site"] = ($Network.extattrs.Site.Value).ToLower()}
			Catch{$Host_Name_Gen_Dict["SubNet_Site"] = "None Available"}
			Try{$Host_Name_Gen_Dict["SubNet_VLAN"] = ($Network.extattrs.VLAN.Value).ToLower()}
			Catch{$Host_Name_Gen_Dict["SubNet_VLAN"] = "None Available"}
		}
	}
}

Function Script_Status()
{
	If($Host_Name_Gen_Dict.Values -Contains "N/A")
	{
		Exit
	}
}

Function Call_Infoblox_Subnet_Check([string]$SubNet)
{
	$Method = "GET"
	$URI = "################"
	$Response = Invoke-RestMethod -Method $Method -Uri $URI -Credential $Creds
	Return $Response
}
Function Call_Infoblox_Network_Pull([string]$Region)
{
	$Method = "GET"
	$URI = "################" + $Region
	$Response = Invoke-RestMethod -Method $Method -Uri $URI -Credential $Creds
	Return $Response
}

Function Output_Loading_Status([int]$Status_Percent)
{
	$Percents_Graphs = @("|------------------","---|---------------","-------|-----------","----------|--------","--------------|----")
	Clear
	If($Status_Percent -eq 5)
	{
		Write-Host "----- Loading Data Complete -----"
		Write-Host "------------------|"
		Write-Host "100%"
	}
	Else
	{
	$Percent_Value = $Status_Percent * 20
	Write-Host "----- Loading Data In Progress -----"
	Write-Host $Percents_Graphs[$Status_Percent]
	Write-Host ("$Percent_Value" + "%")
	}
}

## End Supporting Functions ##

## Begin Main Function ##

Function Main_Function()
{
	Request_Type_Form
	Script_Status
	&$Host_Name_Gen_Dict["Request_Type"]
	Display_Info_Form
}

## End Main Function ##

## Begin Setup Network Catalog ##

Output_Loading_Status 0
Try{$Asia_Pacific_Data = Call_Infoblox_Network_Pull "Asia Pacific"}
Catch{Clear;Write-Host "You have entered the wrong Password or Username"; Sleep 10;Exit}
Output_Loading_Status 1
$Latin_America_Data = Call_Infoblox_Network_Pull "Latin America"
Output_Loading_Status 2
$EMEA_Data = Call_Infoblox_Network_Pull "EMEA"
Output_Loading_Status 3
$North_America_Data = Call_Infoblox_Network_Pull "North America"
Output_Loading_Status 4
$Other_Data = Call_Infoblox_Network_Pull "Other"
Output_Loading_Status 5

## End Setup Network Catalog ##

#Call Main Function
Main_Function

#Display Built Dictionary
$Host_Name_Gen_Dict

Sleep 10
