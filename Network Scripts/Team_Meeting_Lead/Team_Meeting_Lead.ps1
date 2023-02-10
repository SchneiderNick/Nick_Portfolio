<#
Template Made By Nicholas Schneider
#>

<#
Author: Nicholas Schneider
Date: 12/19/2019
Purpose: Choose and email a new Team Lead for monthly connects
#>

<# Global Variables #> 

# Declare all variables from templates in here

$Network_Group_Name = ".DL Global Network"
$Email_List = @()
$GUID_List = @()

$Primary_User = 0
$Secondary_User = 0

<# Global Variables #> 


<# Function Declarations #>

# Paste all function delcarations into this section


Function Send_Email([string]$Primary, [string]$Secondary, $CC, $Subject)
{
		# Necessary Settings #
	$To = @($Primary, $Secondary)
	
	$Msg = @{
    to          = $To
    from        = "##############"
	CC          = $CC
    Body        = ""
    subject     = $Subject
    smtpserver  = "##############"
	
	}

	# Necessary Settings #
	Send-MailMessage @Msg
}
<# Function Declarations #>




<# Main Program Start #>

# Place all of the function calls, in order, into this section
# Note that functions can be called from within other functions, for instance a log function can be called from other functions


$Team_Members = (Get-ADGroup $Network_Group_Name -Properties * | Select member).member

ForEach($Member in $Team_Members)
{
	$Temp_Data = $Member.Split(",")
	$Temp_Data = $Temp_Data[0].Split(" ")
	$GUID = $Temp_Data[-1]
	
	$Email_Address = (Get-ADUser $GUID | Select UserPrincipalName).UserPrincipalName
	
	$Email_List += $Email_Address
	$GUID_List += $GUID
}

While($Primary_User -eq $Secondary_User)
{
	$Primary_User = (Get-Random -Minimum 0 -Maximum $Email_List.Length)
	$Secondary_User = (Get-Random -Minimum 0 -Maximum $Email_List.Length)
}
$Emails_CC = @()
Foreach($Email in $Email_List)
{
	If(($Email -ne $Email_List[$Primary_User]) -AND ($Email -ne $Email_List[$Secondary_User]))
	{
		$Emails_CC += $Email
	}
}

$Primary_First_Name = (Get-ADUser $GUID_List[$Primary_User] | Select GivenName).GivenName
$Secondary_First_Name = (Get-ADUser $GUID_List[$Secondary_User] | Select GivenName).GivenName

$Email_Subject = ("Congratulations " + $Primary_First_Name + ", you are the Primary for the next team meeting, and " + $Secondary_First_Name + " is the secondary!")
Send_Email $Email_List[$Primary_User] $Email_List[$Secondary_User] $Emails_CC $Email_Subject


<# Main Program End #>

