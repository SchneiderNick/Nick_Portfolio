$Data = Import-CSV -path "$PSScriptroot\Server_Data.csv"

$OutputFileName = "$PSScriptroot\Exported_Data.csv"

"Server`tPrint and Document Services`tPrint Server`tInternet Printing`tLPD Service" > $OutputFileName

Foreach($Server in $Data.Server)
{
	$PDS = ""
	$PS = ""
	$IP = ""
	$LPD = ""
	$Server_Data = Get-WindowsFeature -ComputerName $Server Print* | Where-Object {$_.InstallState -eq 'Installed'}
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
		}
	}
	$Output = $Server + "`t" + $PDS + "`t" + $PS + "`t" + $IP+ " `t" + $LPD
	$Output >> $OutputFileName
}
