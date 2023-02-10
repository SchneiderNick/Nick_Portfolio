$Script_Directory = Split-Path $script:MyInvocation.MyCommand.Path
## Infoblox API Credentials ##
$Password_File_Path = $Script_Directory + "\Credentials\Password.txt"
$Password = Get-Content $Password_File_Path | ConvertTo-SecureString
$creds = New-Object System.Management.Automation.PsCredential("############",$Password)

Function Post_A_Record([string]$DNS, [string]$IP)
{	
	$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
	$headers.Add("Content-Type", "application/json")
	$body = "{`n    `"name`":  `"$DNS`",`n    `"ipv4addr`":  `"$IP`"`n}"
	$response = Invoke-RestMethod '############' -Method 'POST' -Headers $headers -Body $body -Credential $Creds
	Return $response
}
Function Get_Host_Record([string]$DNS)
{
	$Method = "GET"
	$URI = "############" + $DNS
	$Response = Invoke-RestMethod -Method $Method -Uri $URI -Credential $Creds
	
	Return $Response
}
Function Check_DNS_Availability([string]$DNS)
{
	#Check Infoblox info for a DNS entry
	$Host_Record_Check = Get_Host_Record($DNS)
	Write-Host $Host_Record_Check
	#Ping DNS
	$PingResults = ping $DNS
	Write-Host $PingResults
	# If the host record is not found in infoblox and the script cannnot ping the DNS, it is an available address
	# The ping request is necessary to make sure that it is not a public (Non-SCJ value, like google) DNS entry
	If(($Host_Record_Check -eq $NULL) -And ($PingResults -eq ("Ping request could not find host " + $DNS + ". Please check the name and try again.")))
	{
		Return $True
	}
	Else
	{
		Return $False
	}
}
Function Get_IP_Record([string]$IP)
{
	$Method = "GET"
	$URI = "############" + $IP
	$Response = Invoke-RestMethod -Method $Method -Uri $URI -Credential $Creds
	
	Return $Response
}

Function Check_IP_Status([string]$IP)
{
	$Get_IP_Results = Get_IP_Record $IP
	Write-Host $Get_IP_Results.Error
	Write-Host $Get_IP_Results.types
	Write-Host $Get_IP_Results.lease_state
	If(($Get_IP_Results.Error -ne $NULL) -OR ($Get_IP_Results.types -Contains "HOST") -OR ($Get_IP_Results.types -Contains "Lease") -OR ($Get_IP_Results.lease_state -eq "Active") -OR ($Get_IP_Results.lease_state -eq "Backup") -OR ($Get_IP_Results.lease_state -eq "Abandoned"))
	{
		Return $False
	}
	Else
	{
		Return $True
	}
}
#$Results = Post_A_Record "############" "############"

#$Results = Get_Host_Record "############"

#Write-Host $Results

#$Results = Check_DNS_Availability "############"

$Results = Check_IP_Status "############"

Write-Host $Results