$Server_Name = Hostname
$Print_Status = ""
Try{
	$Temp_Features = Get-WindowsFeature -ComputerName $Server_Name -erroraction stop
		Foreach($Feature in $Temp_Features)
		{
			If($Feature.DisplayName -eq "Print Server")
			{
				$Print_Status = $Feature.InstallState
				Write-Host ("Server Success: " + $Server_Name)
				Break
			}
		}
	}
	Catch{
		$Print_Status = "N/A"
		Write-Host ("Server failed: " + $Server_Name)
	}



