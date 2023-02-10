$Output_Path = "$PSScriptRoot\Output.csv"

"DN`tCN`tObjectClass`tLastLogonTimestamp`tpwdLastSet`tUserAccountControl`tLocation`tOperatingSystem`tDisplayName" > $Output_Path

Foreach($Computer in (Get-ADComputer -Filter * -Properties * | Select *))
{
	Write-Host $Computer.CN
	$DN = $Computer.DistinguishedName
	$CN = $Computer.CN
	$ObjectClass = $Computer.ObjectClass
	$LastLogonTimestamp = $Computer.lastLogonTimestamp
	$pwdLastSet = $Computer.PasswordLastSet
	$UserAccountControl = $Computer.userAccountControl
	$Location = $Computer.Location
	$OperatingSystem = $Computer.OperatingSystem
	$DisplayName = $Computer.DisplayName
	
	$Output_String = $DN + "`t" + $CN + "`t" + $ObjectClass + "`t" + $LastLogonTimestamp + "`t" + $pwdLastSet + "`t" + $UserAccountControl + "`t" + $Location + "`t" + $OperatingSystem + "`t" + $DisplayName
	$Output_String >> $Output_Path
}

