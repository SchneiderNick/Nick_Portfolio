## Begin Form Creation Functions ##

Function Fixed()
{
	$Mac_Addr_Check = $True
	
	While(($Mac_Addr_Check -eq $True) -AND ($Host_Name_Gen_Dict["Mac Address"] -ne "N/A"))
	{
		$Mac_Addr_Form = Create_Form
		
		#Text Box
		$Fixed_Text_Box	= Create_Text_Box -Location_Width 250 -Location_Height 150 -Size_Width 200 -Size_Height 20 -Font_Size 15
		
		#Submit Button
		$Fixed_Button = Create_Button -Text 'Enter Mac Address' -Location_Width 500 -Location_Height 150 -Size_Width 150 -Size_Height 50
		
		$Fixed_Button.Add_Click({$Host_Name_Gen_Dict["Mac Address"] = $Fixed_Text_Box.Text; [void]$Mac_Addr_Form.Close(); [void]$Mac_Addr_Form.Dispose(); })
		
		#Add Label
		$Fixed_Label1 = Create_Label -Text 'Enter a Valid Mac Address' -Location_Width 25 -Location_Height 150 -Size_Width 100 -Size_Height 50 -Bold $True
		$Fixed_Label2 = Create_Label -Text 'Valid Formats:' -Location_Width 250 -Location_Height 200 -Size_Width 100 -Size_Height 50 -Font_Size "10" -Bold $True
		$Fixed_Label3 = Create_Label -Text '##:##:##:##:##:##' -Location_Width 250 -Location_Height 225 -Size_Width 100 -Size_Height 50 -Font_Size "10" -Bold $True
		$Fixed_Label4 = Create_Label -Text '####.####.####' -Location_Width 250 -Location_Height 250 -Size_Width 100 -Size_Height 50 -Font_Size "10" -Bold $True
		$Fixed_Label5 = Create_Label -Text '##-##-##-##-##-##' -Location_Width 250 -Location_Height 275 -Size_Width 100 -Size_Height 50 -Font_Size "10" -Bold $True
		
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
	
	$IP_Provision_Form = Create_Form
	
	$IP_Label = Create_Label -Text 'Enter an IP Provision Type' -Location_Width 80 -Location_Height 60 -Size_Width 225 -Size_Height 60 -Bold $True
	
	#Button One
	$Next_Available_IP = Create_Button -Text 'Next Available IP' -Location_Width 100 -Location_Height 175 -Size_Width 150 -Size_Height 50
	
	#Button two
	$Provide_IP = Create_Button -Text 'Provide IP' -Location_Width 350 -Location_Height 175 -Size_Width 150 -Size_Height 50
		
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
	
	$SubNet_Form = Create_Form
	$Search_SubNet_Form = Create_Form
	$Enter_SubNet_Form = Create_Form
	
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
		$SubNet_Form_Label = Create_Label -Text 'Choose to Search for a SubNet or Enter one in Directly' -Location_Width 80 -Location_Height 60 -Size_Width 225 -Size_Height 60 -Bold $True
		
		#Button One
		$Search_SubNets = Create_Button -Text 'Search SubNets' -Location_Width 100 -Location_Height 175 -Size_Width 150 -Size_Height 50
		
		#Button two
		$Provide_SubNet = Create_Button -Text 'Provide SubNet' -Location_Width 350 -Location_Height 175 -Size_Width 150 -Size_Height 50
		
		$Search_SubNets.Add_Click({$Host_Name_Gen_Dict["SubNet_Method"] = "Search SubNets"; [void]$SubNet_Form.Close(); [void]$SubNet_Form.Dispose(); })
		$Provide_SubNet.Add_Click({$Host_Name_Gen_Dict["SubNet_Method"] = "Provide SubNet"; [void]$SubNet_Form.Close(); [void]$SubNet_Form.Dispose(); })

		$SubNet_Form.Controls.AddRange(@($SubNet_Form_Label,$Search_SubNets,$Provide_SubNet))
		
		[void]$SubNet_Form.ShowDialog()
		
		Script_Status
	## SubNet Form ##
	
	
	If($Host_Name_Gen_Dict["SubNet_Method"] -eq "Search SubNets")
	{
		## Search SubNet Form ##
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
		
		
		
		#Deprioritized before completion
		
		
		## Enter SubNet Form ##
	}
}
Function Search_SubNets()
{
	## Search SubNet Sub Form ##
	$Host_Name_Gen_Dict["SubNets_Loop_Check"] = $True
	$Search_Button_Pressed = @{}
	$Search_Button_Pressed["SubNet"] = $False
	While($Host_Name_Gen_Dict["SubNets_Loop_Check"])
	{
		$Search_SubNet_Sub_Form = Create_Form
		$Search_SubNet_Sub_Form.KeyPreview = $True

		$Search_SubNet_Sub_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
		{$Host_Name_Gen_Dict["SubNets_Loop_Check"] = $False;$Search_SubNet_Sub_Form.Close()}})
		$SubNet_Label = Create_Label -Text 'Enter Search Criteria' -Location_Width 200 -Location_Height 60 -Size_Width 225 -Size_Height 60 -Bold $True
		$Country_Combo_Box = Create_ComboBox -Text "Country" -Location_Width 50 -Location_Height 100 -Size_Width 200 -Size_Height 30
		$Site_Combo_Box = Create_ComboBox -Text "Site" -Location_Width 50 -Location_Height 150 -Size_Width 200 -Size_Height 30
		$VLAN_Combo_Box = Create_ComboBox -Text "VLAN" -Location_Width 50 -Location_Height 200 -Size_Width 200 -Size_Height 30
		$Search_Button = Create_Button -Text "Search" -Location_Width 50 -Location_Height 250 -Size_Width 150 -Size_Height 50

		##
		$Select_Button = Create_Button -Text "Select" -Location_Width 350 -Location_Height 250 -Size_Width 150 -Size_Height 50
		$SubNet_List_Combo_Box = Create_ComboBox -Text "SubNets" -Location_Width 350 -Location_Height 150 -Size_Width 200 -Size_Height 30
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
			$Label_Array += (Create_Label -Text "|" -Location_Width 275 -Location_Height $i -Size_Width 25 -Size_Height 10 -Bold $True)
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
		Grab_SubNet_Data -SubNet $SubNet_List_Combo_Box.Text
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
		$Provide_IP_Form = Create_Form

		$Provide_IP_Text_Box = Create_Text_Box -Location_Width 250 -Location_Height 150 -Size_Width 200 -Size_Height 20 -Font_Size 15


		$Provide_IP_Label = Create_Label -Text 'Enter a Valid IP' -Location_Width 25 -Location_Height 150 -Size_Width 100 -Size_Height 50 -Bold $True

		#Submit Button 
		$Submit_Button = Create_Button -Text "Submit" -Location_Width 400 -Location_Height 310 -Size_Width 150 -Size_Height 40

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
