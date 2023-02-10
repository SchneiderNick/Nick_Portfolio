<#
Template Made By Nicholas Schneider
#>

<#
Author: Nicholas Schneider
Date: 1/16/2019
Purpose:
This script will pull data from a CSV document located in the same folder. 
It will then query AD for each em,ail address and check if they are part of the DEB group or SCJ
It will then append a file with the counts for each group.
#>

<# Global Variables #> 

# Declare all variables from templates in here

$Previous_File = "####################"
$Known_SCJ_Emails = "$PSScriptRoot\Known_Emails\Known_SCJ_Email.csv"
$Known_DEB_Emails = "$PSScriptRoot\Known_Emails\Known_DEB_Emails.csv"
$Known_No_Company_Emails = "$PSScriptRoot\Known_Emails\Known_No_Company_Code.csv"
$Known_Non_SCJ_DEB_Emails = "$PSScriptRoot\Known_Emails\Known_Non_SCJ_DEB_Emails.csv"
$input_Folder = "####################"
$Script_Outputs_Folder = "####################"
$Email_Stats_Log = "####################"


# Email Attachments #

$Email_SCJ_Emails = "$PSScriptRoot\Email_Attachments\SCJ_Email.csv"
$Email_DEB_Emails = "$PSScriptRoot\Email_Attachments\DEB_Emails.csv"
$Email_No_Company_Emails = "$PSScriptRoot\Email_Attachments\No_Company_Code.csv"
$Email_Non_SCJ_DEB_Emails = "$PSScriptRoot\Email_Attachments\Non_SCJ_DEB_Emails.csv"

# This is the list of attachments sent in the email. The file locations are added to an array
$attachments = @()
$attachments += $Email_SCJ_Emails
$attachments += $Email_DEB_Emails
$attachments += $Email_No_Company_Emails
$attachments += $Email_Non_SCJ_DEB_Emails

"Email,Company Code" > $Email_SCJ_Emails
"Email,Company Code" > $Email_DEB_Emails
"Email,Company Code" > $Email_No_Company_Emails
"Email,Company Code" > $Email_Non_SCJ_DEB_Emails


# Email Attachments #
#This is the email SMTP server
$smtpServer = "####################"

<# Global Variables #> 


<# Function Declarations #>

# Paste all function delcarations into this section

Function Check_Folder_Exists
{
	Param([String]$folderPath)
	#Test the path of the file to see if it exists
	If(-Not (Test-Path $folderPath))
	{
		 New-Item -ItemType "directory" -Path $folderPath
	}
}

Function Check_File_Exists
{
	Param([String]$filePath)
	#Test the path of the file to see if it exists
	If(-Not (Test-Path $filePath))
	{
		 New-Item -ItemType "file" -Path $filePath
	}
}

Function Send_Email([string]$body)
{
	$Msg = @{
    to          = "####################"
    cc          = "####################"
    from        = "####################"
    Body        = $body
    subject     = "Deb Group Email Count"
    smtpserver  = $smtpServer
    Attachments = $attachments
	}
	Send-MailMessage @Msg
}

<# Function Declarations #>

<# Main Program Start #>

# Place all of the function calls, in order, into this section
# Note that functions can be called from within other functions, for instance a log function can be called from other functions
Check_Folder_Exists $Previous_File
Check_Folder_Exists $input_Folder
Check_Folder_Exists $Script_Outputs_Folder

Check_File_Exists $Known_SCJ_Emails
Check_File_Exists $Known_DEB_Emails
Check_File_Exists $Known_No_Company_Emails
Check_File_Exists $Email_Stats_Log
Check_File_Exists $Known_Non_SCJ_DEB_Emails


#This checks the folder to see if there is anything in it (Since the scripts runs often, but only fully runs when Shaheed drops his file inside)
If((Get-ChildItem -Path $Script_Outputs_Folder -Filter '*.xlsx').count -ne 0)
{
	ForEach($file in (Get-ChildItem -Path $Script_Outputs_Folder -Filter '*.xlsx'))
	{
		#Sets counts to 0
		$Deb_Group_Count = 0
		$SCJ_Group_Count = 0
		$No_Group_Count = 0
		$Non_SCJ_DEB_Group_Count = 0
		$tempFilePath = $Script_Outputs_Folder + "\" + $file.Name
		$extensionlessFileName = ($file.Name).SubString(0,($file.Name).Length - 5)
		$csvFileName = $extensionlessFileName + ".csv"
		
		$Excel = New-Object -ComObject Excel.Application
		$Excel.Visible = $false
		$Excel.DisplayAlerts = $false
		$wb = $Excel.Workbooks.Open($tempFilePath)
		
		foreach ($ws in $wb.Worksheets)
		{

			$ws.SaveAs($input_Folder + "\" + $csvFileName, 6)

		}
		$Excel.Quit()
		#This moves the item from the folder to the previous file location for storage after use
		Move-Item -Path $tempFilePath -Destination ($Previous_File + "\" + $file.Name)
		
		$newData = (Get-Content ($input_Folder + "\" + $csvFileName) | Select -skip 2 | ConvertFrom-Csv -Header "Email","LastLogin")
		$SCJ_Email_Data = (Get-Content $Known_SCJ_Emails)
		$DEB_Email_Data = (Get-Content $Known_DEB_Emails)
		$No_Company_Code_Data = (Get-Content $Known_No_Company_Emails)
		$Known_Non_SCJ_DEB_Data = (Get-Content $Known_Non_SCJ_DEB_Emails)
		#This seperates the users in SCJ/DEB based on if they are found in one of the premade documents
		ForEach($user in $newData)
		{
			Write-Output ("Processing User: " + $user.email)
			$tempUserName = "*" + (($user.email).SubString(0,($user.email).Length - 9)) + "*"
			If(($SCJ_Email_Data -like $tempUserName).length -ne 0)
			{
				$SCJ_Group_Count++
				($user.email + ",SCJ") >> $Email_SCJ_Emails
			}
			ElseIf(($DEB_Email_Data -like $tempUserName).length -ne 0)
			{
				$Deb_Group_Count++
				($user.email + ",DEB") >> $Email_DEB_Emails
			}
			ElseIf(($No_Company_Code_Data -like $tempUserName).length -ne 0)
			{
				$No_Group_Count++
				($user.email) >> $Email_No_Company_Emails
			}
			ElseIf(($Known_Non_SCJ_DEB_Data -like $tempUserName).length -ne 0)
			{
				$Non_SCJ_DEB_Group_Count++
				($user.email) >> $Email_Non_SCJ_DEB_Emails
				
			}
			#If they are not found in the docs, they will be pulled from AD
			Else
			{
				$CompanyCode = (Get-ADUser -filter * -properties userPrincipalName, extensionAttribute11 | where {$_.userprincipalname -eq $user.Email} | select extensionAttribute11)
				If($CompanyCode.extensionAttribute11 -eq "SCJ")
				{
					$SCJ_Group_Count++
					($user.email + "," + $CompanyCode.extensionAttribute11) >> $Known_SCJ_Emails
					($user.email + ",SCJ") >> $Email_SCJ_Emails
				}
				ElseIf($CompanyCode.extensionAttribute11 -eq "DEB")
				{
					$Deb_Group_Count++
					($user.email + "," + $CompanyCode.extensionAttribute11) >> $Known_DEB_Emails
					($user.email + ",DEB") >> $Email_DEB_Emails
				}
				ElseIf(($CompanyCode.extensionAttribute11).length -gt 0)
				{
					$Non_SCJ_DEB_Group_Count++
					($user.email + "," + $CompanyCode.extensionAttribute11) >> $Known_Non_SCJ_DEB_Emails
					($user.email) >> $Email_Non_SCJ_DEB_Emails
				}
				Else
				{
					$No_Group_Count++
					$user.email >> $Known_No_Company_Emails
					($user.email) >> $Email_No_Company_Emails
					
				}
			}
		}
		#This section builds the emails to shaheed
		$emailBody = "Number of Users in the Deb Group: " + ($Deb_Group_Count).ToString() + "`nNumber of Users in the SCJ Group: " + ($SCJ_Group_Count).ToString() + "`nNumber of Users In Group Other than SCJ/DEB Group: " + ($Non_SCJ_DEB_Group_Count).ToString() + "`nNumber of Users in No Group: " + ($No_Group_Count).ToString()
		Send_Email $emailBody
		
		$previousData = Get-Content $Email_Stats_Log
		"" > $Email_Stats_Log

		$tempData = (Get-Date -Format MM-dd-yyy).ToString() + " -- " + (Get-Culture).DateTimeFormat.GetMonthName((Get-Date).AddMonths(-1).Month) + " " + ((get-date).AddMonths(-1)).Year + " To " + (Get-Culture).DateTimeFormat.GetMonthName((Get-Date).Month) + " " + (Get-Date).Year
		$tempData >> $Email_Stats_Log

		$tempData = "Number of Users in the Deb Group: " + ($Deb_Group_Count).ToString()
		$tempData >> $Email_Stats_Log

		$tempData = "Number of Users in the SCJ Group: " + ($SCJ_Group_Count).ToString()
		$tempData >> $Email_Stats_Log
		
		$tempData = "Number of Users In Group Other than SCJ/DEB Group: " + ($Non_SCJ_DEB_Group_Count).ToString()
		$tempData >> $Email_Stats_Log
		
		$tempData = "Number of Users in No Group: " + ($No_Group_Count).ToString()
		$tempData >> $Email_Stats_Log

		$tempData = "####################################################################################################"
		$tempData >> $Email_Stats_Log
		
		$previousData >> $Email_Stats_Log
		#This deletes the CSV that was temporarily created for processing
		Remove-Item -Path ($input_Folder + "\" + $csvFileName)
		
	}
}
<# Main Program End #>

