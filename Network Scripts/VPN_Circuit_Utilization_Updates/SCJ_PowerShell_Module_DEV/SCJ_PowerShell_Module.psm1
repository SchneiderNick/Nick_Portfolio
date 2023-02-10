<#

Author: Nicholas Schneider
Date: 1/31/2020
Purpose: Module for Internal SCJ use, for easy to use functions

#>

<#
 .Synopsis
	Used to send an email over an SMTP connection
 .Description
	Use this function to send an email to one or more email address using an SMTP server connection
 .Parameter Server
	String value to identify the SMTP server used to send emails
 .Parameter From
	String value for where the email is from
 .Parameter To
	Array of String, used to send to a single address or multiple
 .Parameter Subject
	String variable used to fill the Subject of the email
 .Parameter Body
	String value used to fill the BODY of the email
 .Parameter CC
	String array for emails to be CC'd on the email
 .Parameter BCC
	String array for emails to be BCC'd to the email
 .Parameter Priority
	Value of either 1 or 2, to set the priority of the email
 .Parameter BodyAsHTML
	Boolean value for the style the body takes, either True for an HTML structured body, or False for a text structured body
 .Parameter Attachments
	Array of strings filled with the path of each attachment (Used when attaching pictures in an HTML body)
 .Example

	Send-SCJEmail -Server "appSMTP.global.DOMAIN.loc" -From "EmailAddress@DOMAIN.com" -To @(Email1@DOMAIN.com, Email2@DOMAIN.com) -BodyAsHTML $False -Attachments @("PATH1","PATH2")
	
#>

Function Send-SCJEmail
{
	param(
	[Parameter(Mandatory=$True)][string]$Server,
	[Parameter(Mandatory=$True)][string]$From,
	[Parameter(Mandatory=$True)][string[]]$To,
	[Parameter(Mandatory=$True)][string]$Subject,
	[Parameter(Mandatory=$True)][string]$Body,
	[Parameter(Mandatory=$False)][string[]]$CC,
	[Parameter(Mandatory=$False)][string[]]$BCC,
	[Parameter(Mandatory=$False)][int]$Priority,
	[Parameter(Mandatory=$False)][boolean]$BodyAsHTML,
	[Parameter(Mandatory=$False)][string[]]$Attachments
	)
	Write-Verbose "Beginning to Send Email"
	$Msg = @{
		To                    = $To
		From                  = $From
		Body                  = $Body
		Subject               = $Subject
		smtpserver            = $Server
		BodyAsHTML            = $False
	}
		If($CC)
		{
			Write-Verbose "CC Address Found: $CC"
			$msg.CC           = $CC
		}
		If($BCC)
		{
			Write-Verbose "BCC Address Found: $BCC"
			$msg.BCC          = $BCC
		}
		If($Priority)
		{
			Write-Verbose "Priority Value Found: $Priority"
			$msg.Priority     = $Priority
		}
		If($BodyAsHTML)
		{
			Write-Verbose "BodyAsHTML Found: $BodyAsHTML"
			$msg.BodyAsHTML   = $BodyAsHTML
		}
		If($Attachments)
		{
			Write-Verbose "Attachments Found: $Attachments"
			$msg.Attachments  = $Attachments
		}
	
	Write-Verbose "Sending Email"
	Send-Mailmessage @Msg
	Write-Verbose "Email Sent To: $To"
}

<#
 .Synopsis
  Adds data to a log file

 .Description
  Adds a string of data to a log file. 

 .Parameter Data
  String value for the data to be added to a file.

 .Parameter Path
  Path of the log folder from the ROOT
 
 .Parameter PartialPath
  Path of the log folder FROM the location of the script

 .Parameter Action
  Determines if the CMDlet will overwrite the current data, or append it

 .Example

	SCJ-AddLog -Data "This is data to be logged" -Path "C:\Temp\Log\LogFile.log" -Action "Append"

 .Example 

	SCJ-AddLog -Data "This is data to be logged" -PartialPath "\Log\LogFile.log" -Action "New"
#>

Function Add-SCJLog
{
	param(
		[Parameter(Mandatory=$True)][string]$Data,
		[Parameter(Mandatory=$False, ParameterSetName = 'ByPath')][string]$Path,
		[Parameter(Mandatory=$False, ParameterSetName = 'ByPartialPath')][string]$PartialPath,
		[Parameter(Mandatory=$True)][ValidateSet('Append','New')][string]$Action,
		[Parameter(Mandatory=$False)][boolean]$AddDate
		)
	Write-Verbose "Beginning Log Function"
	If($Path)
	{
		Write-Verbose "Full Path Used"
		$Split_Path = $Path.Split("\")
		$Temp_Path = ""
		Write-Verbose "Path Split Into Folders"
		Foreach($Part in $Split_Path)
		{
			Write-Verbose "Working on: $Part"
			If($Part.Contains("."))
			{
				Write-Verbose "File Path Detected"
				$Temp_Path += $Part
				Write-Verbose "Checking if File Exists: $Temp_Path"
				$Result = Get-SCJFileExists -Path $Temp_Path -Create "Yes"
				Write-Verbose "Path Created Result: $Result"
			}
			Else
			{
				Write-Verbose "Folder Path Detected"
				$Temp_Path += ($Part + "\")
				Write-Verbose "Checking if Folder Exists: $Temp_Path"
				$Result = Get-SCJFolderExists -Path $Temp_Path -Create "Yes"
				Write-Verbose "Path Created Result: $Result"
			}
		}
	}
	ElseIf($PartialPath)
	{
		Write-Verbose "Partial Path Found" 
		
		Try{$Base_Path = ($global:PSScriptRoot)}
		Catch{
		Write-Verbose "Partial Path used from CLI - Needs to Run From File"
		Return $False
		}
		If($PartialPath[0] -eq "\")
		{
			Write-Verbose "Partial Path w/ Correct formatting found"
			$Path = ($Base_Path + $PartialPath)
		}
		Else
		{
			Write-Verbose 'Missing "\" at start of partial path, "\" being added to path'
			$Path = ($Base_Path + "\" + $PartialPath)
		}
		$Split_Path = $Path.Split("\")
		Write-Verbose "Path Split Into Parts"
		$Temp_Path = ""
		Foreach($Part in $Split_Path)
		{
			Write-Verbose  "Working on Part: $Part"
			If($Part.Contains("."))
			{
				Write-Verbose "File Path Detected"
				$Temp_Path += $Part
				Write-Verbose "Checking if File Exists: $Temp_Path"
				$Result = Get-SCJFileExists -Path $Temp_Path -Create "Yes"
				Write-Verbose "Path Created Result: $Result"
			}
			Else
			{
				Write-Verbose "Folder Path Detected"
				$Temp_Path += ($Part + "\")
				Write-Verbose "Checking if Folder Exists: $Temp_Path"
				$Result = Get-SCJFolderExists -Path $Temp_Path -Create "Yes"
				Write-Verbose "Path Created Result: $Result"
			}
		}		
	}
	Else
	{
		Write-Verbose "Error With Pathway"
	}
	If($AddDate)
	{
		$Time = (Get-Date -Format yyyy/MM/dd-HH:mm:ss)
		$Data = $Time + " | " + $Data
	}
	If($Action -eq "Append")
	{
		Write-Verbose "Appending Data: $Data"
		Write-Verbose "To Path: $Path"
		try{$Data >> $Path}
		Catch{
			Write-Verbose "Failed to Write Data"
			Return $False
		}
		Write-Verbose "Successfully Wrote Data to File"
		Return $True
	}
	ElseIf($Action -eq "New")
	{
		try{$Data > $Path}
		catch{
			Write-Verbose "Failed to Write Data"
			Return $False
		}
		Write-Verbose "Successfully Wrote Data to File"
		Return $True
	}
	Else
	{
		Return $False
	}
	Write-Verbose "Log Function Completed"
}
<#
 .Synopsis
  Checks if a file at a specific location exists

 .Description
	Check the availability of a file at a specific location
	- Optionally Creates that file if it does not exist
	
 .Parameter Create
  Yes or No that determines if the CMDlet creates the file at said location

 .Parameter Path
  Path of the file
 
 .Parameter PartialPath
  Path of the file FROM the location of the script

 .Example
	
	$Result = Get-SCJFileExists -Path "C:\Temp\Log\LogFile.log" -Create "yes"

 .Example 

	$Result = Get-SCJFileExists -Path "Log\LogFile.log"

#>

Function Get-SCJFileExists
{
	param(
		[Parameter(Mandatory=$True, ParameterSetName = 'ByPath')][string]$Path,
		[Parameter(Mandatory=$True, ParameterSetName = 'ByPartialPath')][string]$PartialPath,
		[Parameter(Mandatory=$False)][ValidateSet('Yes','yes')][string]$Create
		)
	
	If($Path)
	{
		Write-Verbose "Full File Path FOund: $Path"
		If(-Not (Test-Path $Path))
		{
			Write-Verbose "File Not Found"
			If(($Create.ToLower()) -eq "yes")
			{
				try{New-Item -ItemType "file" -Path $Path}
				catch{
					Write-Verbose "Failed to Create File: $Path"
					Return $False
				}
				Write-Verbose "Successfully Created file at Path: $Path"
				Return $True
			}
			Write-Verbose "File Not Created Due To User Input"
			Return $False
		}
		Write-Verbose "File Found, so no new file was created"
		Return $True
	}
	ElseIf($PartialPath)
	{
		Try{$Base_Path = ($global:PSScriptRoot)}
		Catch{
		Write-Verbose "Partial Path used from CLI - Needs to Run From File"
		Return $False
		}
		If($PartialPath[0] -eq "\")
		{
			Write-Verbose "Partial Path w/ Correct formatting found"
			$Path = ($Base_Path + $PartialPath)
		}
		Else
		{
			Write-Verbose 'Missing "\" at start of partial path, "\" being added to path'
			$Path = ($Base_Path + "\" + $PartialPath)
		}
		If(-Not (Test-Path $Path))
		{
			If(($Create.ToLower()) -eq "yes")
			{
				try{New-Item -ItemType "file" -Path $Path}
				catch{
					Write-Verbose "Failed to Create File: $Path"
					Return $False
				}
				Write-Verbose "Successfully Created File at path: $Path"
				Return $True
			}
			Write-Verbose "File Not Found, File Not Created Due To User Input"
			Return $False
		}
		Write-Verbose "File Found, so no new file created"
		Return $True
	}
	Else
	{
		Write-Verbose "Error With Path or PartialPath"
		Return $False
	}
}
<#
 .Synopsis
  Checks if a folder at a specific location exists

 .Description
	Check the availability of a folder at a specific location
	- Optionally Creates that folder if it does not exist
	
 .Parameter Create
  Yes or No that determines if the CMDlet creates the folder at said location

 .Parameter Path
  Path of the folder
 
 .Parameter PartialPath
  Path of the folder FROM the location of the script

 .Example
	
	$Result = Get-SCJFolderExists -Path "C:\Temp\Log\" -Create "yes"

 .Example 

	$Result = Get-SCJFolderExists -Path "Log\Log\"
#>

Function Get-SCJFolderExists
{
	param(
		[Parameter(Mandatory=$True, ParameterSetName = 'ByPath')][string]$Path,
		[Parameter(Mandatory=$True, ParameterSetName = 'ByPartialPath')][string]$PartialPath,
		[Parameter(Mandatory=$False)][ValidateSet('Yes','yes')][string]$Create
		)
	
	If($Path)
	{	
		Write-Verbose "Full Path Detected"
		If(-Not (Test-Path $Path))
		{
			Write-Verbose "Path Not Found: $Path"
			If(($Create.ToLower()) -eq "yes")
			{
				try{New-Item -ItemType "directory" -Path $Path}
				catch{
					Write-Verbose "Failed to Create Folder: $Path"
					Return $False
				}
				Write-Verbose "Successfully Created Folder: $Path"
				Return $True
			}
			Write-Verbose "Failed to Create Folder Due to User Input"
			Return $False
		}
		Write-Verbose "Folder found, so no new folder created"
		Return $True
	}
	ElseIf($PartialPath)
	{
		Write-Verbose "Partial Path Found"
		Try{$Base_Path = ($global:PSScriptRoot)}
		Catch{
		Write-Verbose "Partial Path used from CLI - Needs to Run From File"
		Return $False
		}
		If($PartialPath[0] -eq "\")
		{
			Write-Verbose "Partial Path w/ Correct formatting found"
			$Path = ($Base_Path + $PartialPath)
		}
		Else
		{
			Write-Verbose 'Missing "\" at start of partial path, "\" being added to path'
			$Path = ($Base_Path + "\" + $PartialPath)
		}
		If(-Not (Test-Path $Path))
		{
			Write-Verbose "Path Not Found: $Path"
			If(($Create.ToLower()) -eq "yes")
			{
				try{New-Item -ItemType "directory" -Path $Path}
				catch{
					Write-Verbose "Failed to Create Folder: $Path"
					Return $False
				}
				Write-Verbose "Successfully Created FOlder: $Path"
				Return $True
			}
			Write-Verbose "Failed to Create Folder due to User Input"
			Return $False
		}
		Write-Verbose "No folder was created, folder was found"
		Return $True
	}
	Else
	{
		Write-Verbose "Error With Path or PartialPath"
		Return $False
1	}
}
