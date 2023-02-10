## This File is part of the IP_DNS_Provision_Application ##

<#

## Author   : Nicholas Schneider
## File #   : 
## Owner    : 
## Type     :

## Comments :

#>

<# Start Of Function #>

Function IP_Request_Form()
{
	$IP_Form = Create_Form -Text "IP Request Form"
	
	$IP_Label = Create_Label -Text 'Enter an IP Request Type' -Location_Width 206 -Location_Height 60 -Size_Width 225 -Size_Height 60 -Bold $True
	
	#Button One
	$Reserved = Create_Button -Text 'Reserved' -Location_Width 150 -Location_Height 175 -Size_Width 100 -Size_Height 50
	
	#Button 2
	$Fixed = Create_Button -Text 'Fixed' -Location_Width 350 -Location_Height 175 -Size_Width 100 -Size_Height 50

    $IP_Form.Controls.AddRange(@($Reserved,$Fixed,$IP_Label))
	$IP_Form.KeyPreview = $True
	$IP_Form.Add_KeyDown({if ($_.KeyCode -eq "Enter")
	{$Supporting_Info["IP_Request_Type"] = "Reserved_Navigation";$IP_Form.Close()}})
	$IP_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
	{$Supporting_Info["IP_Request_Type"] = "N/A";$IP_Form.Close()}})
	
	$Reserved.Add_Click({$Supporting_Info["IP_Request_Type"] = "Reserved_Navigation"; [void]$IP_Form.Close(); [void]$IP_Form.Dispose(); })
	$Fixed.Add_Click({$Supporting_Info["IP_Request_Type"] = "Fixed_Navigation"; [void]$IP_Form.Close(); [void]$IP_Form.Dispose(); })
	
	[void]$IP_Form.ShowDialog()
	
	Return $Supporting_Info["IP_Request_Type"]

}
Function IP_Provision_Form()
{
	$IP_Provision_Form = Create_Form -Text "IP Provision Form"
	
	$IP_Label = Create_Label -Text 'Enter an IP Provision Type' -Location_Width 200 -Location_Height 60 -Size_Width 225 -Size_Height 60 -Bold $True
	
	#Button One
	$Next_Available_IP = Create_Button -Text 'Next Available IP' -Location_Width 100 -Location_Height 175 -Size_Width 150 -Size_Height 50
	
	#Button two
	$Provide_IP = Create_Button -Text 'Provide IP' -Location_Width 350 -Location_Height 175 -Size_Width 150 -Size_Height 50
		
    $IP_Provision_Form.Controls.AddRange(@($Next_Available_IP,$Provide_IP,$IP_Label))
	$IP_Provision_Form.KeyPreview = $True
	$IP_Provision_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
	{$Supporting_Info["IP_Provision_Type"] = "N/A";$IP_Provision_Form.Close()}})
	
	$Next_Available_IP.Add_Click({$Supporting_Info["IP_Provision_Type"] = "Next_Available_IP_Form"; [void]$IP_Provision_Form.Close(); [void]$IP_Provision_Form.Dispose(); })
	$Provide_IP.Add_Click({$Supporting_Info["IP_Provision_Type"] = "Provide_IP_Form"; [void]$IP_Provision_Form.Close(); [void]$IP_Provision_Form.Dispose(); })
	
	[void]$IP_Provision_Form.ShowDialog()
	
	Return $Supporting_Info["IP_Provision_Type"]
}
Function DNS_Form()
{
	$Temp_DNS_Array = @("",$False,"No Value Submitted")
	$Provide_DNS_First_Run = $True
	While(($Temp_DNS_Array[1] -eq $False) -AND ($Supporting_Info["IP"] -ne "N/A"))
	{
		$Provide_DNS_Form = Create_Form -Text "DNS Form"

		$Provide_DNS_Text_Box = Create_Text_Box -Location_Width 250 -Location_Height 150 -Size_Width 200 -Size_Height 20 -Font_Size 15

		$Provide_DNS_Label = Create_Label -Text 'Enter a Valid Hostname' -Location_Width 25 -Location_Height 150 -Size_Width 100 -Size_Height 50 -Bold $True

		$DNS_Error_Label = Create_Label -Text $Temp_DNS_Array[2] -Location_Width 250 -Location_Height 200 -Size_Width 100 -Size_Height 50 -Bold $True -Color "#FF0000"
		
		#Submit Button 
		$Submit_Button = Create_Button -Text "Submit" -Location_Width 400 -Location_Height 310 -Size_Width 150 -Size_Height 40

		If($Provide_DNS_First_Run)
		{
			$Provide_DNS_Form.Controls.AddRange(@($Submit_Button,$Provide_DNS_Label,$Provide_DNS_Text_Box))
		}
		Else
		{
			$Provide_DNS_Form.Controls.AddRange(@($Submit_Button,$Provide_DNS_Label,$Provide_DNS_Text_Box,$DNS_Error_Label))
		}
		
		$Provide_DNS_Form.KeyPreview = $True
		$Provide_DNS_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
		{$Supporting_Info["DNS"] = "N/A";$Provide_DNS_Form.Close()}})

		$Submit_Button.Add_Click({$Supporting_Info["DNS"] = $Provide_DNS_Text_Box.Text; [void]$Provide_DNS_Form.Close(); [void]$Provide_DNS_Form.Dispose(); })

		[void]$Provide_DNS_Form.ShowDialog()
		
		$Temp_DNS_Array = Check_DNS $Supporting_Info["DNS"]
		
		If($Temp_DNS_Array[1])
		{
			Return $Temp_DNS_Array[0]
		}
		$Provide_DNS_First_Run = $False
	}
}
Function Mac_Address_Form()
{
	$Mac_Addr_Check = $True
	$Mac_Address_First_Run = $True
	$Temp_Mac_Address_Array = @("",$False,"No Value Submitted")
	While(($Temp_Mac_Address_Array[1] -eq $False) -AND ($Supporting_Info["Mac Address"] -ne "N/A"))
	{
		$Mac_Addr_Form = Create_Form -Text "Mac Address Form"
		
		#Text Box
		$Mac_Address_Text_Box	= Create_Text_Box -Location_Width 250 -Location_Height 150 -Size_Width 200 -Size_Height 20 -Font_Size 15
		
		#Submit Button
		$Mac_Address_Button = Create_Button -Text 'Enter Mac Address' -Location_Width 400 -Location_Height 310 -Size_Width 150 -Size_Height 40
		
		$Mac_Address_Button.Add_Click({$Supporting_Info["Mac Address"] = $Mac_Address_Text_Box.Text; [void]$Mac_Addr_Form.Close(); [void]$Mac_Addr_Form.Dispose(); })
		
		#Add Label
		$Mac_Address_Label1 = Create_Label -Text 'Enter a Valid Mac Address' -Location_Width 25 -Location_Height 150 -Size_Width 100 -Size_Height 50 -Bold $True
		$Mac_Address_Label2 = Create_Label -Text 'Valid Formats:' -Location_Width 250 -Location_Height 225 -Size_Width 100 -Size_Height 50 -Font_Size "10" -Bold $True
		$Mac_Address_Label3 = Create_Label -Text '##:##:##:##:##:##' -Location_Width 250 -Location_Height 250 -Size_Width 100 -Size_Height 50 -Font_Size "10" -Bold $True
		$Mac_Address_Label4 = Create_Label -Text '####.####.####' -Location_Width 250 -Location_Height 275 -Size_Width 100 -Size_Height 50 -Font_Size "10" -Bold $True
		$Mac_Address_Label5 = Create_Label -Text '##-##-##-##-##-##' -Location_Width 250 -Location_Height 300 -Size_Width 100 -Size_Height 50 -Font_Size "10" -Bold $True
		$Error_Label = Create_Label -Text $Temp_Mac_Address_Array[2] -Location_Width 250 -Location_Height 185 -Size_Width 100 -Size_Height 50 -Font_Size "12" -Bold $True -Color "#FF0000"
		If($Mac_Address_First_Run)
		{
			$Mac_Addr_Form.Controls.AddRange(@($Mac_Address_Button,$Mac_Address_Text_Box,$Mac_Address_Label1,$Mac_Address_Label2,$Mac_Address_Label3,$Mac_Address_Label4,$Mac_Address_Label5))
		}
		Else
		{
			$Mac_Address_Text_Box.Text = $Temp_Mac_Address_Array[0]
			$Mac_Addr_Form.Controls.AddRange(@($Mac_Address_Button,$Mac_Address_Text_Box,$Mac_Address_Label1,$Mac_Address_Label2,$Mac_Address_Label3,$Mac_Address_Label4,$Mac_Address_Label5,$Error_Label))
		}
		
		$Mac_Addr_Form.KeyPreview = $True
		$Mac_Addr_Form.Add_KeyDown({if ($_.KeyCode -eq "Enter")
		{$Supporting_Info["Mac Address"] = $Mac_Address_Text_Box.Text;$Mac_Addr_Form.Close()}})
		$Mac_Addr_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
		{$Supporting_Info["Mac Address"] = "N/A";$Mac_Addr_Form.Close()}})

		[void]$Mac_Addr_Form.ShowDialog()

		try{$Temp_Mac_Address_Array = Check_Mac_Address $Supporting_Info["Mac Address"]}
		catch{
		Add-SCJLog -Data "Failed to run *Check Mac Address*" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
		Add-SCJLog -Data "Error Information" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
		Add-SCJLog -Data ($Error) -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
		Add-SCJLog -Data "Process Ending" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
		$Temp_Mac_Address_Array = @($Supporting_Info["Mac Address"],$False,"Failed to Begin Mac Address Check")		
		}

		$Mac_Address_First_Run = $False
	}
	Return $Temp_Mac_Address_Array[0]
}

Function Next_Available_IP_Form()
{
	$Next_Available_IP_Form = Create_Form -Text "Next Available IP Form"
	
	## Form Setup ##
	
	$Next_Available_IP_Form.KeyPreview = $True
	$Next_Available_IP_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
	{$Supporting_Info["SubNet_Navigation_Method"] = "N/A";$Next_Available_IP_Form.Close()}})
	
	## Form Setup ##
	
	## SubNet Form ##
		$Next_Available_IP_Form_Label = Create_Label -Text 'Choose to Search for a SubNet or Enter one in Directly' -Location_Width 80 -Location_Height 60 -Size_Width 225 -Size_Height 60 -Bold $True
		
		#Button One
		$Search_SubNets = Create_Button -Text 'Search SubNets' -Location_Width 100 -Location_Height 175 -Size_Width 150 -Size_Height 50
		
		#Button two
		$Provide_SubNet = Create_Button -Text 'Provide SubNet' -Location_Width 350 -Location_Height 175 -Size_Width 150 -Size_Height 50
		
		$Search_SubNets.Add_Click({$Supporting_Info["SubNet_Navigation_Method"] = "Search_SubNet_Navigation"; [void]$Next_Available_IP_Form.Close(); [void]$Next_Available_IP_Form.Dispose(); })
		$Provide_SubNet.Add_Click({$Supporting_Info["SubNet_Navigation_Method"] = "Provide_SubNet_Navigation"; [void]$Next_Available_IP_Form.Close(); [void]$Next_Available_IP_Form.Dispose(); })

		$Next_Available_IP_Form.Controls.AddRange(@($Next_Available_IP_Form_Label,$Search_SubNets,$Provide_SubNet))
		
		[void]$Next_Available_IP_Form.ShowDialog()
}

Function Provide_IP_Form()
{
	$Temp_IP_Array = @("",$False,"No Value Submitted")
	$Provide_IP_First_Run = $True
	While(($Temp_IP_Array[1] -eq $False) -AND ($Supporting_Info["IP"] -ne "N/A"))
	{
		$Provide_IP_Form = Create_Form -Text "Provide IP Form"

		$Provide_IP_Text_Box = Create_Text_Box -Location_Width 250 -Location_Height 150 -Size_Width 200 -Size_Height 20 -Font_Size 15

		$Provide_IP_Label = Create_Label -Text 'Enter a Valid IP' -Location_Width 25 -Location_Height 150 -Size_Width 100 -Size_Height 50 -Bold $True

		$IP_Error_Label = Create_Label -Text $Temp_IP_Array[2] -Location_Width 250 -Location_Height 175 -Size_Width 100 -Size_Height 50 -Bold $True -Color "#FF0000"
		
		#Submit Button 
		$Submit_Button = Create_Button -Text "Submit" -Location_Width 400 -Location_Height 310 -Size_Width 150 -Size_Height 40

		If($Provide_IP_First_Run)
		{
			$Provide_IP_Form.Controls.AddRange(@($Submit_Button,$Provide_IP_Label,$Provide_IP_Text_Box))
		}
		Else
		{
			$Provide_IP_Form.Controls.AddRange(@($Submit_Button,$Provide_IP_Label,$Provide_IP_Text_Box,$IP_Error_Label))
		}
		
		$Provide_IP_Form.KeyPreview = $True
		$Provide_IP_Form.Add_KeyDown({if ($_.KeyCode -eq "Enter")
		{$Supporting_Info["IP_Request_Type"] = "Provide_IP_Form";$Provide_IP_Form.Close()}})
		$Provide_IP_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
		{$Supporting_Info["IP_Request_Type"] = "N/A";$Provide_IP_Form.Close()}})

		$Submit_Button.Add_Click({$Supporting_Info["IP"] = $Provide_IP_Text_Box.Text; [void]$Provide_IP_Form.Close(); [void]$Provide_IP_Form.Dispose(); })

		[void]$Provide_IP_Form.ShowDialog()
		
		$Temp_IP_Array = Check_IP $Supporting_Info["IP"]
		
		If($Temp_IP_Array[1])
		{
			Return $Temp_IP_Array[0]
		}
		$Provide_IP_First_Run = $False
	}
}

Function Select_Region_Form()
{
	$Select_Region_Form = Create_Form -Text "Select Region Form"
	
	$Select_Region_Form.KeyPreview = $True
	$Select_Region_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
	{$Supporting_Info["Region"] = "N/A";$Select_Region_Form.Close()}})

	$SubNet_Form_Label = Create_Label -Text 'Choose a Region' -Location_Width 200 -Location_Height 60 -Size_Width 225 -Size_Height 60 -Bold $True
	
	#Button One
	$North_America = Create_Button -Text 'North America' -Location_Width 100 -Location_Height 107 -Size_Width 150 -Size_Height 50
	
	#Button Two
	$Latin_America = Create_Button -Text 'Latin America' -Location_Width 350 -Location_Height 107 -Size_Width 150 -Size_Height 50
	
	#Button Three
	$EMEA = Create_Button -Text 'EMEA' -Location_Width 100 -Location_Height 204 -Size_Width 150 -Size_Height 50
	
	#Button Four
	$Asia_Pacific = Create_Button -Text 'Asia Pacific' -Location_Width 350 -Location_Height 204 -Size_Width 150 -Size_Height 50
	
	#Button Five
	$Other = Create_Button -Text 'Other' -Location_Width 225 -Location_Height 301 -Size_Width 150 -Size_Height 50
	
	$Select_Region_Form.Controls.AddRange(@($SubNet_Form_Label,$North_America,$Latin_America,$EMEA,$Asia_Pacific,$Other))
	
	$North_America.Add_Click({$Supporting_Info["Region"] = "North America"; [void]$Select_Region_Form.Close(); [void]$Select_Region_Form.Dispose(); })
	$Latin_America.Add_Click({$Supporting_Info["Region"] = "Latin America"; [void]$Select_Region_Form.Close(); [void]$Select_Region_Form.Dispose(); })
	$EMEA.Add_Click({$Supporting_Info["Region"] = "EMEA"; [void]$Select_Region_Form.Close(); [void]$Select_Region_Form.Dispose(); })
	$Asia_Pacific.Add_Click({$Supporting_Info["Region"] = "Asia Pacific"; [void]$Select_Region_Form.Close(); [void]$Select_Region_Form.Dispose(); })
	$Other.Add_Click({$Supporting_Info["Region"] = "Other"; [void]$Select_Region_Form.Close(); [void]$Select_Region_Form.Dispose(); })

	[void]$Select_Region_Form.ShowDialog()
}

<#Function SubNet_Filter_Form()
{
	## Search SubNet Sub Form ##
	$Supporting_Info["SubNets_Loop_Check"] = $True
	$Search_Button_Pressed = @{}
	$Search_Button_Pressed["SubNet"] = $False
	While($Supporting_Info["SubNets_Loop_Check"])
	{
		$Search_SubNet_Sub_Form = Create_Form -Text "SubNet Filter Form"
		$Search_SubNet_Sub_Form.KeyPreview = $True

		$Search_SubNet_Sub_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
		{$Supporting_Info["SubNets_Loop_Check"] = $False;$Search_SubNet_Sub_Form.Close()}})
		$SubNet_Label = Create_Label -Text 'Enter Search Criteria' -Location_Width 200 -Location_Height 60 -Size_Width 225 -Size_Height 60 -Bold $True
		$Country_Combo_Box = Create_ComboBox -Text "Country" -Location_Width 50 -Location_Height 100 -Size_Width 200 -Size_Height 30
		$Site_Combo_Box = Create_ComboBox -Text "Site" -Location_Width 50 -Location_Height 150 -Size_Width 200 -Size_Height 30
		$VLAN_Combo_Box = Create_ComboBox -Text "VLAN" -Location_Width 50 -Location_Height 200 -Size_Width 200 -Size_Height 30
		$Search_Button = Create_Button -Text "Search" -Location_Width 50 -Location_Height 250 -Size_Width 150 -Size_Height 50

		##
		$Select_Button = Create_Button -Text "Select" -Location_Width 350 -Location_Height 250 -Size_Width 150 -Size_Height 50
		$SubNet_List_Combo_Box = Create_ComboBox -Text "SubNets" -Location_Width 350 -Location_Height 150 -Size_Width 200 -Size_Height 30
		##

		$Temp_Data = (Get-Variable ((($Supporting_Info["Region"]).Replace(' ','_')) + "_Data")).Value

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
			$Label_Array += (Create_Label -Text "|" -Location_Width 275 -Location_Height $i -Size_Width 25 -Size_Height 10 -Bold $True)
		}

		$Search_Button.Add_Click({ 
		$Supporting_Info["SubNet_Country"] = $Country_Combo_Box.Text;
		$Supporting_Info["SubNet_Site"] = $Site_Combo_Box.Text;
		$Supporting_Info["SubNet_VLAN"] = $VLAN_Combo_Box.Text;
		$Search_Button_Pressed["SubNet"] = $True
		[void]$Search_SubNet_Sub_Form.Close();
		[void]$Search_SubNet_Sub_Form.Dispose();
		})
		$Select_Button.Add_Click({ 
		$Supporting_Info["SubNet"] = $SubNet_List_Combo_Box.Text;
		Grab_SubNet_Data -SubNet $SubNet_List_Combo_Box.Text
		$Search_Button_Pressed["SubNet"] = $True;
		If(($SubNet_List_Combo_Box.Text -ne "SubNets") -AND ($SubNet_List_Combo_Box.Text -ne "No SubNets Found")){$Supporting_Info["SubNets_Loop_Check"] = $False};
		[void]$Search_SubNet_Sub_Form.Close();
		[void]$Search_SubNet_Sub_Form.Dispose();
		})

		If($Supporting_Info["SubNet_Country"] -ne $Null)
		{
			$Country_Combo_Box.text = $Supporting_Info["SubNet_Country"]
		}
		If($Supporting_Info["SubNet_Site"] -ne $Null)
		{
			$Site_Combo_Box.text = $Supporting_Info["SubNet_Site"]
		}
		If($Supporting_Info["SubNet_VLAN"] -ne $Null)
		{
			$VLAN_Combo_Box.text = $Supporting_Info["SubNet_VLAN"]
		}

		If($Search_Button_Pressed["SubNet"] -eq $True)
		{
			$Network_List = @()
			
			$Country_Combo_Box = Create_ComboBox -Text "Country" -Location_Width 50 -Location_Height 100 -Size_Width 200 -Size_Height 30
			$Site_Combo_Box = Create_ComboBox -Text "Site" -Location_Width 50 -Location_Height 150 -Size_Width 200 -Size_Height 30
			$VLAN_Combo_Box = Create_ComboBox -Text "VLAN" -Location_Width 50 -Location_Height 200 -Size_Width 200 -Size_Height 30
			
			$Unique_Country_List_Interior = @()
			$Unique_Site_List_Interior = @()
			$Unique_VLAN_List_Interior = @()
			
			
			Foreach($Network in $Temp_Data)
			{
				Try{$Temp_Country = ($Network.extattrs.Country.Value).ToLower()}
				Catch{}
				Try{$Temp_Site = ($Network.extattrs.Site.Value).ToLower()}
				Catch{}
				Try{$Temp_VLAN = ($Network.extattrs.VLAN.Value).ToLower()}
				Catch{}

				$Country_Check = (($Supporting_Info["SubNet_Country"] -ne "None") -AND ($Supporting_Info["SubNet_Country"] -ne "Country"))
				$Site_Check = (($Supporting_Info["SubNet_Site"] -ne "None") -AND ($Supporting_Info["SubNet_Site"] -ne "Site"))
				$VLAN_Check = (($Supporting_Info["SubNet_VLAN"] -ne "None") -AND ($Supporting_Info["SubNet_VLAN"] -ne "VLAN"))

				$Country_Data_Check = ($Temp_Country -eq $Supporting_Info["SubNet_Country"])
				$Site_Data_Check = ($Temp_Site -eq $Supporting_Info["SubNet_Site"])
				$VLAN_Data_Check = ($Temp_VLAN -eq $Supporting_Info["SubNet_VLAN"])
				
				If(((-Not(($Country_Check -eq $True) -And ($Country_Data_Check -eq $False)))) -And ((-Not(($Site_Check -eq $True) -And ($Site_Data_Check -eq $False)))) -And ((-Not(($Vlan_Check -eq $True) -And ($Vlan_Data_Check -eq $False)))))
				{
					$Network_List += $Network.Network
				}
				
				If(($Country_Check) -AND (-Not $Site_Check) -AND (-Not $Vlan_Check))
				{
					
					If($Temp_Country -eq $Supporting_Info["SubNet_Country"])
					{
						If(-Not ($Unique_Site_List_Interior -Contains $Temp_Site))
						{
							$Unique_Site_List_Interior += $Temp_Site
						}
						If(-Not ($Unique_VLAN_List_Interior -Contains $Temp_VLAN))
						{
							$Unique_VLAN_List_Interior += $Temp_VLAN
						}
					}
				}
				ElseIf(($Country_Check) -AND ($Site_Check) -AND (-Not $Vlan_Check))
				{
					
				}
				ElseIf((-Not $Country_Check) -AND ($Site_Check) -AND (-Not $Vlan_Check))
				{
					
				}
				ElseIf((-Not $Country_Check) -AND ($Site_Check) -AND ($Vlan_Check))
				{
					
				}
				ElseIf((-Not $Country_Check) -AND (-Not $Site_Check) -AND ($Vlan_Check))
				{
					
				}
			}
			
			$Network_List = $Network_List | Sort
			If($Network_List.length -gt 0)
			{
				Foreach($Network_Value in $Network_List)
				{
					[void]$SubNet_List_Combo_Box.Items.Add($Network_Value)
				}
			}
			Else
			{
				[void]$SubNet_List_Combo_Box.Items.Add("No SubNets Found")
			}
			$Search_SubNet_Sub_Form.Controls.AddRange(@($Select_Button, $SubNet_List_Combo_Box))
		}
		$Search_SubNet_Sub_Form.Controls.AddRange(@($SubNet_Label,$Country_Combo_Box,$Site_Combo_Box,$VLAN_Combo_Box,$Search_Button))
		$Search_SubNet_Sub_Form.Controls.AddRange($Label_Array)
		[void]$Search_SubNet_Sub_Form.ShowDialog()
	}

	Return $Supporting_Info["SubNet"]
## Search SubNet Sub Form ##
}#>

Function Provide_SubNet_Form()
{
	$Temp_SubNet_Array = @("",$False,"No Value Submitted")
	$Provide_SubNet_First_Run = $True
	While(($Temp_SubNet_Array[1] -eq $False) -AND ($Supporting_Info["IP"] -ne "N/A"))
	{
		$Provide_SubNet_Form = Create_Form -Text "Provide SubNet Form"

		$Provide_SubNet_Text_Box = Create_Text_Box -Location_Width 250 -Location_Height 150 -Size_Width 200 -Size_Height 20 -Font_Size 15

		$Provide_SubNet_Label = Create_Label -Text 'Enter a Valid SubNet' -Location_Width 25 -Location_Height 150 -Size_Width 100 -Size_Height 50 -Bold $True

		$SubNet_Error_Label = Create_Label -Text $Temp_SubNet_Array[2] -Location_Width 250 -Location_Height 187 -Size_Width 100 -Size_Height 50 -Bold $True -Color "#FF0000"
		
		#Submit Button 
		$Submit_Button = Create_Button -Text "Submit" -Location_Width 400 -Location_Height 310 -Size_Width 150 -Size_Height 40

		If($Provide_SubNet_First_Run)
		{
			$Provide_SubNet_Form.Controls.AddRange(@($Submit_Button,$Provide_SubNet_Label,$Provide_SubNet_Text_Box))
		}
		Else
		{
			$Provide_SubNet_Form.Controls.AddRange(@($Submit_Button,$Provide_SubNet_Label,$Provide_SubNet_Text_Box,$SubNet_Error_Label))
		}

		$Provide_SubNet_Form.KeyPreview = $True
		$Provide_SubNet_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
		{$Supporting_Info["IP_Request_Type"] = "N/A";$Provide_SubNet_Form.Close()}})

		$Submit_Button.Add_Click({$Supporting_Info["SubNet"] = $Provide_SubNet_Text_Box.Text; [void]$Provide_SubNet_Form.Close(); [void]$Provide_SubNet_Form.Dispose(); })

		[void]$Provide_SubNet_Form.ShowDialog()
		
		$Temp_SubNet_Array = Check_SubNet $Supporting_Info["SubNet"]
		
		If($Temp_SubNet_Array[1])
		{
			Return $Temp_SubNet_Array[0]
		}
		$Provide_SubNet_First_Run = $False
	}
	
}
<# End Of Function #>