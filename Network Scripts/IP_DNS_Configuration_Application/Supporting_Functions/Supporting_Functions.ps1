## Begin Supporting Functions ##

Function Grab_SubNet_Data()
{
	param(
	[Parameter(Mandatory=$True)][string]$SubNet
	)

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

Function Call_Infoblox_Subnet_Check()
{
	param(
	[Parameter(Mandatory=$True)][string]$SubNet
	)

	$Method = "GET"
	$URI = "##############"
	try{$Response = Invoke-RestMethod -Method $Method -Uri $URI -Credential $Creds}
	catch{
	Add-SCJLog -Data "" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data "Error Information" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data ($Error) -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data "Process Ending" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Exit
	}

	Return $Response
}
Function Call_Infoblox_Network_Pull()
{
	param(
	[Parameter(Mandatory=$True)][string]$Region
	)

	$Method = "GET"
	$URI = "##############" + $Region
	try{$Response = Invoke-RestMethod -Method $Method -Uri $URI -Credential $Creds}
	catch{
	Add-SCJLog -Data "Failed to Pull Region Based Network Data" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data "Error Information" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data ($Error) -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data "Process Ending" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Exit
	}

	Return $Response
}

Function Call_Infoblox_IP_Pull()
{
	param(
	[Parameter(Mandatory=$True)][string]$IP_Address
	)

	$Method = "GET"
	$URI = "##############" + $IP_Address
	try{$Response = Invoke-RestMethod -Method $Method -Uri $URI -Credential $Creds}
	catch{
	Add-SCJLog -Data "Failed to Pull IP Data" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data "Error Information" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data ($Error) -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Add-SCJLog -Data "Process Ending" -PartialPath $Log_Path -Action "Append" -AddDate $True | Out-Null;
	Exit
	}

	Return $Response.Status
}

Function Output_Loading_Status()
{
	param(
	[Parameter(Mandatory=$True)][int]$Status_Percent
	)

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
