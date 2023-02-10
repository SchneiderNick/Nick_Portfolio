Function Display_Info_Form()
{
	$Host_Name_Gen_Dict["Validation"] = $False
	While(-Not($Host_Name_Gen_Dict["Validation"]))
	{
		If($Host_Name_Gen_Dict["Request_Type"] -eq "IP")
		{
			$Request_Type_IP_Form = Create_Form -Text "IP Validation" -AddLogo $True
			
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
				
				
				
				
				#Deprioitized before completion
				
				
				
			}
			[void]$Request_Type_IP_Form.ShowDialog()
		}
		ElseIf($Host_Name_Gen_Dict["Request_Type"] -eq "IP/DNS")
		{
			$Request_Type_IP_DNS_Form = Create_Form -Text "IP/DNS Validation" -AddLogo $True
			
			$Request_Type_IP_DNS_Form.KeyPreview = $True
			$Request_Type_IP_DNS_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
			{$Host_Name_Gen_Dict["Validation"] = "N/A";$Request_Type_IP_DNS_Form.Close()}})
			
			
			
			[void]$Request_Type_IP_DNS_Form.ShowDialog()
		}
		ElseIf($Host_Name_Gen_Dict["Request_Type"] -eq "DNS")
		{
			$Request_Type_DNS_Form = Create_Form -Text "DNS Validation" -AddLogo $True
			
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
