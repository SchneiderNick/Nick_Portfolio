$Data = Import-CSV -path "$PSScriptroot\Server_Data.csv"

$OutputFileName = "$PSScriptroot\Exported_Data.csv"

"Server`tPrint and Document Services`tPrint Server`tInternet Printing`tLPD Service" > $OutputFileName

Foreach($Server in $Data.Server)
{
	$PDS = ""
	$PS = ""
	$IP = ""
	$LPD = ""

	$Server_Data = Get-WindowsFeature -ComputerName $Server Print* -ErrorAction silentlycontinue
	If( -not $?)
	{
		$Error_Message = $Error[0].Exception.Message
		If($Error_Message -Match "Access is denied")
		{
			$PDS = "Access is denied"
			$PS = "Access is denied"
			$IP = "Access is denied"
			$LPD = "Access is denied"
		}
		ElseIf($Error_Message -Match "Cannot find the computer")
		{
			$PDS = "No Connection"
			$PS = "No Connection"
			$IP = "No Connection"
			$LPD = "No Connection"
		}
		Else
		{
			$PDS = "Unknown Error"
			$PS = "Unknown Error"
			$IP = "Unknown Error"
			$LPD = "Unknown Error"
		}
	}
	Else
	{
		Foreach($Object in $Server_Data)
		{
			If($Object.Count -eq 0)
			{
				$PDS = ""
				$PS = ""
				$IP = ""
				$LPD = ""
			}
			Else
			{
				Foreach($Feature in $Object)
				{
					If(($Feature.Name -eq "Print-Services") -And ($Feature.InstallState -eq "Installed"))
					{
						$PDS = "Installed"
					}
					If(($Feature.Name -eq "Print-Server") -And ($Feature.InstallState -eq "Installed"))
					{
						$PS = "Installed"
					}
					If(($Feature.Name -eq "Print-Internet") -And ($Feature.InstallState -eq "Installed"))
					{
						$IP = "Installed"
					}
					If(($Feature.Name -eq "Print-LPD-Service") -And ($Feature.InstallState -eq "Installed"))
					{
						$LPD = "Installed"
					}
				}
				If($PDS -eq "")
				{
					$PDS = "Not Installed"
				}
				If($PS -eq "")
				{
					$PS = "Not Installed"
				}
				If($IP -eq "")
				{
					$IP = "Not Installed"
				}
				If($LPD -eq "")
				{
					$LPD = "Not Installed"
				}
			}
		}
	}
	$Output = $Server + "`t" + $PDS + "`t" + $PS + "`t" + $IP+ " `t" + $LPD
	$Output >> $OutputFileName
}
