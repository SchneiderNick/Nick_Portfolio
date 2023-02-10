## Begin Level 1 Functions ##

Function Request_Type_Form()
{
	
    # Build Form
	$Request_Type_Form = Create_Form
	#Build label
	
	$Request_Label = Create_Label -Text 'Please Select The Request Type' -Location_Width 80 -Location_Height 60 -Size_Width 225 -Size_Height 60 -Bold $True
	
    # Add Buttons
	$IP = Create_Button -Text 'IP' -Location_Width 100 -Location_Height 175 -Size_Width 100 -Size_Height 50
    $IP_DNS = Create_Button -Text 'IP/DNS' -Location_Width 250 -Location_Height 175 -Size_Width 100 -Size_Height 50
    $DNS = Create_Button -Text 'DNS' -Location_Width 400 -Location_Height 175 -Size_Width 100 -Size_Height 50
	
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
