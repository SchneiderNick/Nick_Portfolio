## Import AD Module if Does not Exist
if(!(get-Module ActiveDirectory))
{
Write-Host "Importing AD Module....." -Fore green 
Import-Module ActiveDirectory 
Write-Host "Completed..............." -Fore green 
}

## Reading list of computers from csv and loading into variable
$path = "###########"

## verification
try
{
	$computers = Get-Content $Path
}
Catch
{
	Write-Host "$Path | Was not found, exiting the script" -Fore red
	Sleep(5)
	exit
}


## Defining Target Path
$TargetOU = "OU=###########,OU=###########,OU=###########,DC=###########,DC=###########,DC=###########"
$Unprotected_OU = "OU=###########,OU=###########,OU=###########,DC=###########,DC=###########,DC=###########"
$Physical_Computer_List = Get-ADComputer -Filter * -SearchBase $Unprotected_OU | select name
$countPC = ($computers).count
$Moved = 0
Write-Host "This Script will move Computer Accounts" -Fore green
Write-Host "Destination location is (Win2012)     " -Fore green
 
 
## Provide details
Write-Host "List of Computers............." -Fore green
$computers
Write-Host ".............................." -Fore green
Sleep(3) 
ForEach( $computer in $computers){
	Write-Host "Moving $computer"
	try{
		$Temp = Get-ADComputer $Computer
		If($Physical_Computer_List -Match $computer)
		{
			Get-ADComputer $computer | 
			Move-ADObject -TargetPath $TargetOU
			$Moved++
			Write-Host "$computer successfully moved"
		}
		Else
		{
			Write-Host "$Computer Failed to move - Not in Unprotected OU"
		}
	}
	Catch{
		Write-Host "Failed to move $computer" -Fore red
	}
}
Sleep(3)
Write-Host "Completed....................." -Fore green
Write-Host "Moved $Moved Machines of $countPC ........"
Write-Host "Destination OU $TargetOU......"
