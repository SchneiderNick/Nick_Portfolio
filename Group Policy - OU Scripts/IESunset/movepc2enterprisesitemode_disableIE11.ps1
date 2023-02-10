
 
 
#>
## Import AD Module if Does not Exist 
if (! (get-Module ActiveDirectory)) 
{ 
Write-Host "Importing AD Module....." -Fore green 
Import-Module ActiveDirectory 
Write-Host "Completed..............." -Fore green 
} 
 
 
## Adding Varibles 
$Space   =  Write-Host "" 
$Sleep   =  Start-Sleep -Seconds 3 
 
## Reading list of computers from csv and loading into variable  
$computers = Get-Content "###########" 
## verification 
if (! (Test-Path $Path)) { 
     
    Write-Host "List of computers  List txt does not exist" 
 
} 
 
 
## Defining Target Path  
$TargetOU   =  "OU=###########,OU=###########,OU=###########,DC=###########,DC=###########,DC=###########"  
$countPC    = ($computers).count  
 
$Space   =  Write-Host "" 
$Sleep   =  Start-Sleep -Seconds 3 
write-host "This Script will move Computer Accounts" -Fore green 
write-host "Destination location is (Win2012 )     " -Fore green 
 
 
## Provide details 
write-host "List of Computers............." -Fore green 
$computers 
write-host ".............................." -Fore green 
$Space   
$Sleep 
ForEach( $computer in $computers){ 
    write-host "moving computers..." 
    Get-ADComputer $computer | 
    Move-ADObject -TargetPath $TargetOU 
} 
 
$Space   
$Sleep 
write-host "Completed....................." -Fore green 
Write-Host "Moved $countPC Servers........" 
Write-Host "Destination OU $TargetOU......"