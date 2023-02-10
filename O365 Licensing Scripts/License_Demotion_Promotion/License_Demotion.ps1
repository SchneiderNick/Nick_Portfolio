<#
Template Made By Nicholas Schneider
#>

<#
Author: Nicholas Schneider
Date: 10/15/2022
Purpose: Remove E5 licenses from group and assign f3
###########
###########
#>

<# Global Variables #> 

# Declare all variables from templates in here

$E5_Licenses = "###########"

$F3_Licenses = "###########"

$Log_Folder = "###########"

$Date = Get-Date -format "yyyy-MM-dd-HH-mm-ss"

$Log_File_Name = $Date + ".log"

$Log_Path = $Log_Folder + $Log_File_Name

$Backup_Folder = "###########"

$Backup_File_Name = $Date + "_Backup.txt"

$Backup_Path = $Backup_Folder + $Backup_File_Name

<# Global Variables #> 


<# Function Declarations #>

# Paste all function delcarations into this section
Function Log([String]$Log_Input)
{
	$Full_Log_Data = (Get-Date -Format HH-mm-ss) + ":    " + $Log_Input
	
	$Full_Log_Data >> $Log_Path
}
Function Backup([string]$Backup_Input)
{
	$Backup_Input >> $Backup_Path
}

Function Check([string]$Check_Input)
{
	If(-Not (Test-Path $Check_Input))
	{
		If($Check_Input[$Check_Input.Length -1] -ne "\")
		{
			New-Item -Path $Check_Input -ItemType File
		}
		Else
		{
			New-Item -Path $Check_Input -ItemType Directory
		}
	}
}

Function Move_Users()
{
	Log ("Pulling users from $E5_Licenses")
	$E5_Users = Get-ADUser -Filter "memberof -eq 'CN=$E5_Licenses,OU=###########,OU=###########,DC=###########,DC=###########,DC=###########'"
	
	Foreach($GUID in $E5_Users.SamAccountName)
	{
		Log ("Checking: $GUID to see if disabled")
		try
		{
			$User = (Get-ADUser $GUID -properties Enabled,LastLogonDate,DisplayName,UserPrincipalName,extensionAttribute3 | Select Enabled,LastLogonDate,DisplayName,UserPrincipalName,extensionAttribute3)
			$Enabled = $User.Enabled
			$LastLogon = $User.LastLogonDate
			$Display_Name = $User.DisplayName
			$Email_Address = $User.UserPrincipalName
			$Employee_Status = $User.extensionAttribute3
			Log ("$GUID is: $Enabled")
			Log ("They Last logged in on: $LastLogon")
			If((-Not ($Enabled)) -and ($Employee_Status -ne "E"))
			{
				Log ("$GUID is: $Enabled")
				Log ("They Last logged in on: $LastLogon")
				If($LastLogon -lt (Get-Date).AddDays(-30))
				{
					Backup ($GUID + "; " + $Display_Name + "; " + $Email_Address)
					Add-ADGroupMember -Identity $F3_Licenses -Members $GUID
					Remove-ADGroupMember -Identity $E5_Licenses -Members $GUID -Confirm:$false
					Log ("Moved $GUID to $F3_Licenses")
				}
			}
		}
		Catch
		{
			Log "Failed to find $GUID"
		}
	}
}

<# Function Declarations #>




<# Main Program Start #>

# Place all of the function calls, in order, into this section
# Note that functions can be called from within other functions, for instance a log function can be called from other functions
Write-Host $Log_Folder
Write-Host $Log_Path
Write-Host $Backup_Folder
Write-Host $Backup_Path

Try{
	Check $Log_Folder
	Check $Log_Path
	Check $Backup_Folder
	Check $Backup_Path
}
Catch
{
	Log "Folder/File Paths Failed"
	exit
}


Try
{
	Log ("Starting the Move_Users function")
	Move_Users
}
Catch
{
	Log ("Failed to start Move_Users function")
	Exit
}
<# Main Program End #>

