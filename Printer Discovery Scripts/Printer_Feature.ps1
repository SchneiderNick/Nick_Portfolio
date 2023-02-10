$Data = Import-CSV -path "$PSScriptroot\All Servers.csv"

foreach($Server in $Data)
{

	Try{
	$Temp_Features = Get-WindowsFeature -ComputerName $Server.Name -erroraction stop
		Foreach($Feature in $Temp_Features)
		{
			If($Feature.DisplayName -eq "Print Server")
			{
				$Server.Available = $Feature.InstallState
				Write-Host ("Server Success: " + $Server.Name)
				Break
			}
		}
	}
	Catch{
		$Server.Available = "N/A"
		Write-Host ("Server failed: " + $Server.Name)
	}
}

$Data | Export-CSV -Path "$PSScriptroot\All Servers_Print.csv"