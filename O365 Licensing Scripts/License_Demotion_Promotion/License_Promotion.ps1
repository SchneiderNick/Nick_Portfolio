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

param (
  [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)] $Backup_Data_Path
)

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
	$Back_Data = Get-Content $Backup_Data_Path
	Foreach($User in $Back_Data)
	{
		
		$GUID = $User.Split(";")[0]
		If($GUID -ne $NULL)
		{
			Log ("Moved $GUID")
			Add-ADGroupMember -Identity $E5_Licenses -Members $GUID
			Remove-ADGroupMember -Identity $F3_Licenses -Members $GUID
		}
		Else
		{
			Log ("Failed to process $User")
		}
	}
}
<# Function Declarations #>




<# Main Program Start #>

# Place all of the function calls, in order, into this section
# Note that functions can be called from within other functions, for instance a log function can be called from other functions
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

