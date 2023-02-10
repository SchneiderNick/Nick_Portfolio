
<#
Author: Nicholas Schneider
Date: 1/16/2019
Purpose:
This script was a single time run where it pulled in the information for all users in AD, whether they were DEB users or SCJ users.
This script allows the main script to work faster by compiling a list of already known users. 
As the main script runs, it will update te lists to allow faster run times for the next time it is run.
#>

#These are the paths to the different lists of users
$Known_SCJ_Emails = "####################"
$Known_DEB_Emails = "####################"
$Known_No_Company_Code = "####################"
$Known_Non_SCJ_DEB_Emails = "####################"
#This clears the files for the new data to be input
"" > $Known_SCJ_Emails
"" > $Known_DEB_Emails
"" > $Known_No_Company_Code
"" > $Known_Non_SCJ_DEB_Emails
#This loops through all users in AD, l;ooking for their extensionAttribute11 (Their Company Tag) and sorting them by it
Foreach($user in (Get-ADUser -Filter * -Properties userPrincipalName, extensionAttribute11 | Select userPrincipalName, extensionAttribute11))
{
	Write-Output ("Processing: " + $user.userPrincipalName)
	#They go into this list if they are SCJ employees
	If($user.extensionAttribute11 -eq "SCJ")
	{
		$user.userPrincipalName >> $Known_SCJ_Emails
	}
	#This list if they are DEB group employees
	ElseIf($user.extensionAttribute11 -eq "DEB")
	{
		$user.userPrincipalName >> $Known_DEB_Emails
	}
	#This group if they have a company code that does not fall in SCJ or DEB
	ElseIf(($user.extensionAttribute11).length -gt 0 )
	{
		($user.userPrincipalName + "," + $user.extensionAttribute11) >> $Known_Non_SCJ_DEB_Emails
	}
	#This group is for users who do not have anything in their company code field. 
	Else
	{
		$user.userPrincipalName >> $Known_No_Company_Code
	}
}

