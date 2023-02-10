#############Variables/Functions#############################
# Author: Nicholas Schneider
# Date: 7/12/2018
# LicenseSkuID - The license you want to check
# GroupName - Name of the AD group that contains users who should be licensed
# accountInfoFile - File that contains the service account password in secure string
# logFile - Name and location of the file to output logging info
# O365UserName - UPN of the admin account used to log in to O365
#############################################################

$LicenseSkuID = @("####################","####################","####################","####################")
$GroupName = @("####################","####################","####################","####################")
$accountInfoFile = "########################################"
$O365UserName="####################"
$logFile = $logDir + "####################." + [DateTime]::Now.ToString("yyyy_MM_dd H") + '.log'

# Gets the Credentials that were stored on disk
function Get-CredentialsFromDisk() {
	$credential = $null
	# Make sure the credentials exists before trying to open it.
	if (Test-Path $accountInfoFile) {
		# Strip the domain off the ID.
		$password = Get-Content $accountInfoFile | ConvertTo-SecureString -ErrorAction SilentlyContinue		
		
		if ( $password ) {
			$credential = New-Object System.Management.Automation.PsCredential $O365UserName,$password -ErrorAction SilentlyContinue 
		}
	}
	return $credential
}

#Function for writing to specified log file
Function LogWrite
{
   Param ([string]$logstring)
   Add-content $Logfile -value $logstring
}

################Main Program#################################
# ADGroupMembers - Array that contains all members of the group specified in the GroupName variable
# ADGroupMembersUPN - Array that contains the same members as ADGroupMembers but also includes the UPN property
# ADGroupMembersText - Text version of the ADGroupMembersUPN array
# LicensedUsers - All users who have the license type specified in the LicenseSkuID variable
# LicensedUsersText - Text version of the LicensedUsers variable
#############################################################

$counter = 0
$arrayLength = $LicenseSkuID.Length


$credential = Get-CredentialsFromDisk
#Connect to O365
Connect-MsolService -Credential $credential



DO{
#Clears all Variables used after each iteration
$ADGroupMembersUPN = @()
$ADGroupMembers = @()
$LicensedUsers = @()
$ADGroupMembersText = ""
$LicensedUsersText = ""
$LogInfo = ""
#Get all members of the specified group
$ADGroupMembers = Get-ADGroupMember -Identity $GroupName[$counter] | select samaccountname

#Get the UPN values for all members of the specified group
foreach ($ADUser in $ADGroupMembers){
    $UPN = Get-ADUser $ADUser.SamAccountName | select UserPrincipalName 
	$ADGroupMembersUPN += @($UPN)
}

#Get all users with the specified license
$LicensedUsers = Get-MsolUser -All | Where-Object {($_.licenses).AccountSkuId -match $LicenseSkuID[$counter]} | select UserPrincipalName

#Convert arrays to strings to allow look up using the NotMatch function
$ADGroupMembersText = $ADGroupMembersUPN | Out-String
$LicensedUsersText = $LicensedUsers | Out-String

#Check for any members of the AD group that do not have the desired license. Assign the license if any are found.
foreach ($GroupMember in $ADGroupMembersUPN){
    if ($LicensedUsersText -NotMatch $GroupMember.UserPrincipalName){
         $LogInfo = $GroupMember.UserPrincipalName + " does not have license and should, assigning " + $LicenseSkuID[$counter] + " license"
         LogWrite $LogInfo
    }
}

#Check for any users who have the specified license but are not a member of the AD group. Remove the license if any are found.
foreach ($LicensedMember in $LicensedUsers){
    if ($ADGroupMembersText -NotMatch $LicensedMember.UserPrincipalName){
         $LogInfo = $LicensedMember.UserPrincipalName + " has a license but is not a member of the " + $GroupName[$counter] + " group, removing " + $LicenseSkuID[$counter] + " license"
         LogWrite $LogInfo
    }
}
$counter++
}While($counter -lt $arrayLength)