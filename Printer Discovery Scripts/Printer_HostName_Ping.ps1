$Data = Import-CSV -path "$PSScriptroot\All_Non_Ricoh_PL.csv"

foreach($Item in $Data)
{
		$IP = $Item.Port_Address
		If($IP -ne $NULL)
		{
			Write-Host ("Pinging " + $IP)
			$Ping_Results = Ping $IP
			If($Ping_Results -Match "100% Loss")
			{
				$Item.Ping_Status = "Ping without response"
			}
			ElseIf($Ping_Results -Match 'Received = 4')
			{
				$Item.Ping_Status = "Ping with response"
			}
			Else
			{
				$Item.Ping_Status = "Unpingable"
			}
		}
		Else
		{
			$Item.Port_Address = "N/A"
		}
	#}
}

$Data | Export-CSV -Path "$PSScriptroot\All_Non_Ricoh_PL.csv"