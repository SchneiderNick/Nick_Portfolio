<#

$Display_Info = @{}
$Supporting_Info = @{}

Loop 1
	
	If First_Run Or Reset
		Load Blank Form
	If Search_Selected
		Load updated form with limited selection and IP's
	If Selected_Subnet
		Save value and move forward
	
End Loop 1
#>

Function SubNet_Filter_Form()
{
	
	$Supporting_Info["First_Run"] = $True
	$Display_Info["SubNet"] = ""
	$Supporting_Info["SubNet_Loop_Check"] = $True
	$Supporting_Info["SubNet_Reset"] = $False
	$Label_Array = @()
	for($i = 100; $i -lt 388; $i += 15)
	{
		$Label_Array += (Create_Label -Text "|" -Location_Width 275 -Location_Height $i -Size_Width 25 -Size_Height 10 -Bold $True)
	}
		#Grab Region Info
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
	
	While($Supporting_Info["SubNet_Loop_Check"])
	{
		If($Supporting_Info["First_run"] -OR $Supporting_Info["SubNet_Reset"])
		{
			$Supporting_Info["First_Run"] = $False
			$Supporting_Info["SubNet_Reset"] = $False


			$SubNet_First_Run_Form = Create_Form -Text "SubNet Filter Form"
			$SubNet_First_Run_Form.KeyPreview = $True

			$SubNet_First_Run_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
			{$Supporting_Info["SubNet_Loop_Check"] = $False;$SubNet_First_Run_Form.Close()}})
			$SubNet_Label_Fr = Create_Label -Text 'Enter Search Criteria' -Location_Width 200 -Location_Height 60 -Size_Width 225 -Size_Height 60 -Bold $True
			$Country_Combo_Box_Fr = Create_ComboBox -Text "Country" -Location_Width 50 -Location_Height 100 -Size_Width 200 -Size_Height 30
			$Site_Combo_Box_Fr = Create_ComboBox -Text "Site" -Location_Width 50 -Location_Height 150 -Size_Width 200 -Size_Height 30
			$VLAN_Combo_Box_Fr = Create_ComboBox -Text "VLAN" -Location_Width 50 -Location_Height 200 -Size_Width 200 -Size_Height 30
			$Search_Button_Fr = Create_Button -Text "Search" -Location_Width 50 -Location_Height 250 -Size_Width 75 -Size_Height 50
			$Reset_Button_Fr = Create_Button -Text "Reset" -Location_Width 175 -Location_Height 250 -Size_Width 75 -Size_Height 50
			
			Foreach($Country in $Unique_Country_List)
			{
				[void]$Country_Combo_Box_Fr.Items.Add($Country)
			}
			Foreach($Site in $Unique_Site_List)
			{
				[void]$Site_Combo_Box_Fr.Items.Add($Site)
			}
			Foreach($VLAN in $Unique_VLAN_List)
			{
				[void]$VLAN_Combo_Box_Fr.Items.Add($VLAN)
			}
			
			$Search_Button_Fr.Add_Click({ 
			$Supporting_Info["SubNet_Country"] = $Country_Combo_Box_Fr.Text;
			$Supporting_Info["SubNet_Site"] = $Site_Combo_Box_Fr.Text;
			$Supporting_Info["SubNet_VLAN"] = $VLAN_Combo_Box_Fr.Text;
			$Supporting_Info["SubNet_Search_Selected"] = $True
			[void]$SubNet_First_Run_Form.Close();
			[void]$SubNet_First_Run_Form.Dispose();
			})
			$Reset_Button_Fr.Add_Click({ 
			$Supporting_Info["SubNet_Country"] = "";
			$Supporting_Info["SubNet_Site"] = "";
			$Supporting_Info["SubNet_VLAN"] = "";
			$Supporting_Info["SubNet_Search_Selected"] = $False;
			$Supporting_Info["SubNet_Reset"] = $True;
			[void]$SubNet_First_Run_Form.Close();
			#[void]$SubNet_First_Run_Form.Dispose();
			})
			$SubNet_First_Run_Form.Controls.AddRange(@($SubNet_Label_Fr,$Country_Combo_Box_Fr,$Site_Combo_Box_Fr,$VLAN_Combo_Box_Fr,$Search_Button_Fr,$Reset_Button_Fr))
			$SubNet_First_Run_Form.Controls.AddRange($Label_Array)
			[void]$SubNet_First_Run_Form.ShowDialog()
		}
		If($Supporting_Info["SubNet_Search_Selected"])
		{
			$Temp_Selected_Country = ""
			$Temp_Selected_Site = ""
			$Temp_Selected_VLAN = ""
			$Country_Selected = $False
			$Site_Selected = $False
			$VLAN_Selected = $False
			
			If(($Supporting_Info["SubNet_Country"] -eq "") -OR ($Supporting_Info["SubNet_Country"] -eq "Country"))
			{
				$Temp_Selected_Country = $Supporting_Info["SubNet_Country"].ToLower()
				$Country_Selected = $True
			}
			If(($Supporting_Info["SubNet_Site"] -eq "") -OR ($Supporting_Info["SubNet_Site"] -eq "Site"))
			{
				$Temp_Selected_Site = $Supporting_Info["SubNet_Site"].ToLower()
				$Site_Selected = $True
			}
			If(($Supporting_Info["SubNet_VLAN"] -eq "") -OR ($Supporting_Info["SubNet_VLAN"] -eq "VLAN"))
			{
				$Temp_Selected_VLAN = $Supporting_Info["SubNet_VLAN"].ToLower()
				$Site_Selected = $True
			}
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		}
		If($Supporting_Info["SubNet_Selected"])
		{
			
		}	
	}
}