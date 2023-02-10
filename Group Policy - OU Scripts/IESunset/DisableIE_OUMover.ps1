## Import AD Module if Does not Exist
if(!(get-Module ActiveDirectory))
{
Write-Host "Importing AD Module....." -Fore green 
Import-Module ActiveDirectory 
Write-Host "Completed..............." -Fore green 
}

## Reading list of computers from csv and loading into variable
$path = "$PSScriptRoot\list1.txt"

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
$TargetOU = "OU=Enterprise Site Mode,OU=EUP Test Container,OU=Physical,OU=ECD,DC=global,DC=scj,DC=loc" 
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
	Get-ADComputer $computer | 
    Move-ADObject -TargetPath $TargetOU
	$Moved++
	Write-Host "$computer successfully moved"
	}
	Catch{
		Write-Host "Failed to move $computer" -Fore red
	}
}
Sleep(3)
Write-Host "Completed....................." -Fore green
Write-Host "Moved $Moved Machines of $countPC ........"
Write-Host "Destination OU $TargetOU......"
