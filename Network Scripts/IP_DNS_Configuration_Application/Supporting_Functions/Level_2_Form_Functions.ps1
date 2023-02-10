# Begin Level 2 Form Functions #

Function DNS_Solo_Form()
{
	$Hostname_Check = $False
	$IP_Check = $False
	$DNS_First_Run = $True
	$Temp_IP_Check_Array = @("",$False,"")
	$Temp_Hostname_Check_Array = @("",$False,"")
	While(($Hostname_Check -eq $False) -or ($IP_Check -eq $False))
	{

		
		$DNS_Form = Create_Form

		$DNS_Form.KeyPreview = $True
		<#$DNS_Form.Add_KeyDown({if ($_.KeyCode -eq "Enter")
		{$Host_Name_Gen_Dict["DNS_Request_Type"] = "DNS_Form";$DNS_Form.Close()}})#>
		$DNS_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
		{$Host_Name_Gen_Dict["DNS_Request_Type"] = "N/A";$DNS_Form.Close()}})

		$DNS_Text_Box = Create_Text_Box -Location_Width 250 -Location_Height 125 -Size_Width 200 -Size_Height 20 -Font_Size 15
		$IP_Text_Box = Create_Text_Box -Location_Width 250 -Location_Height 225 -Size_Width 200 -Size_Height 20 -Font_Size 15
		
		
		If($Host_Name_Gen_Dict["Hostname"] -ne "")
		{
			$DNS_Text_Box.Text = $Host_Name_Gen_Dict["Hostname"]
		}
		If($Host_Name_Gen_Dict["IP"] -ne "")
		{
			$IP_Text_Box.Text = $Host_Name_Gen_Dict["IP"]
		}
		$DNS_Label = Create_Label -Text 'Enter a Valid Hostname' -Location_Width 25 -Location_Height 125 -Size_Width 100 -Size_Height 50 -Bold $True
		$IP_Label = Create_Label -Text 'Enter a Valid IP' -Location_Width 25 -Location_Height 225 -Size_Width 100 -Size_Height 50 -Bold $True

		#Submit Button 
		$Submit_Button = Create_Button -Text "Submit" -Location_Width 400 -Location_Height 310 -Size_Width 150 -Size_Height 40
		
		If($DNS_First_Run)
		{
			$DNS_Form.Controls.AddRange(@($Submit_Button,$DNS_Label,$IP_Text_Box,$IP_Label,$DNS_Text_Box))
		}
		ElseIf(($Hostname_Check -eq $False) -AND ($IP_Check -eq $False))
		{
			$DNS_Error_Label = Create_Label -Text $Temp_Hostname_Check_Array[2] -Location_Width 250 -Location_Height 160 -Size_Width 100 -Size_Height 50 -Color "#FF0000" -Bold $True
			$IP_Error_Label = Create_Label -Text $Temp_IP_Check_Array[2] -Location_Width 250 -Location_Height 260 -Size_Width 100 -Size_Height 50 -Color "#FF0000" -Bold $True

			$DNS_Form.Controls.AddRange(@($Submit_Button,$DNS_Label,$IP_Text_Box,$IP_Label,$DNS_Text_Box,$DNS_Error_Label,$IP_Error_Label))
		}
		ElseIf(($Hostname_Check -eq $False))
		{
			$DNS_Error_Label = Create_Label -Text $Temp_Hostname_Check_Array[2] -Location_Width 250 -Location_Height 160 -Size_Width 100 -Size_Height 50 -Color "#FF0000" -Bold $True
			$IP_Error_Label = Create_Label -Text $Temp_IP_Check_Array[2] -Location_Width 250 -Location_Height 260 -Size_Width 100 -Size_Height 50 -Color "#00FF00" -Bold $True

			$DNS_Form.Controls.AddRange(@($Submit_Button,$DNS_Label,$IP_Text_Box,$IP_Label,$DNS_Text_Box,$DNS_Error_Label,$IP_Error_Label))
		}
		Else
		{
			$DNS_Error_Label = Create_Label -Text $Temp_Hostname_Check_Array[2] -Location_Width 250 -Location_Height 160 -Size_Width 100 -Size_Height 50 -Color "#00FF00" -Bold $True
			$IP_Error_Label = Create_Label -Text $Temp_IP_Check_Array[2] -Location_Width 250 -Location_Height 260 -Size_Width 100 -Size_Height 50 -Color "#FF0000" -Bold $True

			$DNS_Form.Controls.AddRange(@($Submit_Button,$DNS_Label,$IP_Text_Box,$IP_Label,$DNS_Text_Box,$IP_Error_Label,$DNS_Error_Label))
		}

		$Submit_Button.Add_Click({$Host_Name_Gen_Dict["Hostname"] = $DNS_Text_Box.Text; $Host_Name_Gen_Dict["IP"] = $IP_Text_Box.Text; [void]$DNS_Form.Close(); [void]$DNS_Form.Dispose(); })

		[void]$DNS_Form.ShowDialog()

		try{$Temp_IP_Check_Array = Check_IP -IP_Address $Host_Name_Gen_Dict["IP"]}
		catch{
		Add-SCJLog -Data "Failed to run *Check_IP*" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
		Add-SCJLog -Data "Error Information" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
		Add-SCJLog -Data ($Error) -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
		Add-SCJLog -Data "Process Ending" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
		$Temp_IP_Check_Array = @($Host_Name_Gen_Dict["IP"],$False,"Failed to Begin Checking IP")
		}
		
		try{$Temp_Hostname_Check_Array = Check_Hostname -Hostname $Host_Name_Gen_Dict["Hostname"]}
		catch{
		Add-SCJLog -Data "Failed to run *Check Hostname*" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
		Add-SCJLog -Data "Error Information" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
		Add-SCJLog -Data ($Error) -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
		Add-SCJLog -Data "Process Ending" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
		$Temp_Hostname_Check_Array = @($Host_Name_Gen_Dict["Hostname"],$False,"Could not Run Host Name Check")
		}
		
		If(($Temp_IP_Check_Array[1]) -AND ($Temp_Hostname_Check_Array[1]))
		{
			$Hostname_Check = $True
			$IP_Check = $True
		}
		ElseIf(($Temp_IP_Check_Array[1]))
		{
			$Hostname_Check = $False
			$IP_Check = $True
		}
		ElseIf($Temp_Hostname_Check_Array[1])
		{
			$Hostname_Check = $True
			$IP_Check = $False
		}
		Else
		{
			$Hostname_Check = $False
			$IP_Check = $False
		}
		$DNS_First_Run = $False
		
		$Host_Name_Gen_Dict["Hostname"] = $Temp_Hostname_Check_Array[0]
		$Host_Name_Gen_Dict["IP"] = $Temp_IP_Check_Array[0]
	}
}

Function IP_DNS_Form()
{
	$IP_DNS_Form = Create_Form
	
	$IP_DNS_Label = Create_Label -Text 'Choose to Enter an IP or Hostname' -Location_Width 80 -Location_Height 60 -Size_Width 225 -Size_Height 60 -Bold $True
	
	#Button One
	$IP = Create_Button -Text 'IP' -Location_Width 150 -Location_Height 175 -Size_Width 100 -Size_Height 50
	
	#Button 2
	$DNS = Create_Button -Text 'DNS' -Location_Width 350 -Location_Height 175 -Size_Width 100 -Size_Height 50

    $IP_DNS_Form.Controls.AddRange(@($IP,$DNS,$IP_DNS_Label))
	$IP_DNS_Form.KeyPreview = $True
	$IP_DNS_Form.Add_KeyDown({if ($_.KeyCode -eq "Enter")
	{$Host_Name_Gen_Dict["IP_DNS_Request_Type"] = "IP/DNS";$IP_DNS_Form.Close()}})
	$IP_DNS_Form.Add_KeyDown({if ($_.KeyCode -eq "Escape")
	{$Host_Name_Gen_Dict["IP_DNS_Request_Type"] = "N/A";$IP_DNS_Form.Close()}})
	
	$IP.Add_Click({$Host_Name_Gen_Dict["IP_DNS_Request_Type"] = "IP_DNS"; [void]$IP_DNS_Form.Close(); [void]$IP_DNS_Form.Dispose();})
	$DNS.Add_Click({$Host_Name_Gen_Dict["IP_DNS_Request_Type"] = "DNS_IP"; [void]$IP_DNS_Form.Close(); [void]$IP_DNS_Form.Dispose();})
	
	[void]$IP_DNS_Form.ShowDialog()
}

Function IP_Form()
{
	$IP_Form = Create_Form
	
	$IP_Label = Create_Label -Text 'Enter an IP Request Type' -Location_Width 80 -Location_Height 60 -Size_Width 225 -Size_Height 60 -Bold $True
	
	#Button One
	$Reserved = Create_Button -Text 'Reserved' -Location_Width 150 -Location_Height 175 -Size_Width 100 -Size_Height 50
	
	#Button 2
	$Fixed = Create_Button -Text 'Fixed' -Location_Width 350 -Location_Height 175 -Size_Width 100 -Size_Height 50

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

# Begin Level 2 Form Functions #