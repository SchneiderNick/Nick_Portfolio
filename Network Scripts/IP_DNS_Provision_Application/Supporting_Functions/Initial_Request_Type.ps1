## This File is part of the IP_DNS_Provision_Application ##

<#

## Author   : Nicholas Schneider
## File #   : 
## Owner    : 
## Type     :

## Comments :

#>

<# Start Of Function #>

Function Request_Type_Form()
{
	
    # Build Form
	$Request_Type_Form = Create_Form -Text "Request Type Form"
	#Build label
	
	$Request_Label = Create_Label -Text 'Please Select The Request Type' -Location_Width 180 -Location_Height 60 -Size_Width 225 -Size_Height 60 -Bold $True
	
    # Add Buttons
	$IP = Create_Button -Text 'IP' -Location_Width 150 -Location_Height 175 -Size_Width 100 -Size_Height 50
    $IP_DNS = Create_Button -Text 'IP/DNS' -Location_Width 350 -Location_Height 175 -Size_Width 100 -Size_Height 50
	
	#Add To Form
    $Request_Type_Form.Controls.AddRange(@($IP_DNS,$IP,$Request_Label,$Form_Button_Object))

	#Add Button Functionality
    $IP.Add_Click({$Supporting_Info["Initial_Request_Type"] = "IP_Navigation"; [void]$Request_Type_Form.Close(); [void]$Request_Type_Form.Dispose();})
	$IP_DNS.Add_Click({$Supporting_Info["Initial_Request_Type"] = "IP_DNS_Navigation"; [void]$Request_Type_Form.Close(); [void]$Request_Type_Form.Dispose();})
	
	#Display the GUI
    [void]$Request_Type_Form.ShowDialog()
	
	Return $Supporting_Info["Initial_Request_Type"]
}

<# End Of Function #>