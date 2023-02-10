<#
Template Made By Nicholas Schneider
#>

<#
Author: Nicholas Schneider
Date: 12/17/2019
Purpose:
#>


[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client")
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Client.Runtime")
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

<# Global Variables #> 

# Declare all variables from templates in here

## Pathway Information ##
$Excel_File_Path = "$PSScriptRoot\File_Download\SHOUT OUT TRACKER.xlsx"
$Sheet_Name = "Shout_Out_Data"
$Download_Path = "$PSScriptRoot\File_Download"
$Employee_Data_Path = "$PSScriptRoot\Data\Employee_Configs.json"
$Config_Data_Path = "$PSScriptRoot\Data\Script_Configs.json"
$File_Path_Sharepoint = '###########'

#Set parameter values 




## Pathway Information ##

## Username and Password ##
$UserName = "###########"
$Password = '###########'
## Username and Password ##
 

<# Global Variables #>



<# Function Declarations #>

#Paste all function delcarations into this section
Function Download-File([string]$UserName,[string]$Password,[string]$FileUrl,[string]$DownloadPath)
{
    if([string]::IsNullOrEmpty($Password)) {
      $SecurePassword = Read-Host -Prompt "Enter the password" -AsSecureString 
    }
    else{
      $SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
    }
    $fileName = [System.IO.Path]::GetFileName($FileUrl)
    $downloadFilePath = [System.IO.Path]::Combine($DownloadPath,$fileName)
	
	Write-Host $downloadFilePath

    $client = New-Object System.Net.WebClient 
    $client.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName, $SecurePassword)
    $client.Headers.Add("X-FORMS_BASED_AUTH_ACCEPTED", "f")
    $client.DownloadFile($FileUrl, $downloadFilePath)
    $client.Dispose()
}


Function Get_Updated_Data()
{
	## Check For Old file ##
	## Delete Old File if it exists ##
	If(Test-Path $Excel_File_Path)
	{
		Remove-Item $Excel_File_Path
	}
	## Download New File ##
	Download-File -UserName $UserName -Password $Password -FileUrl $File_Path_Sharepoint -DownloadPath $Download_Path

}
Function Backup_Config_Data()
{
	$Employee_Config_Backup_Size = ((Get-Content "$PSScriptRoot\Backup_Data\Employee_Configs_Backup.json") | Out-String).length
	$Script_Config_Backup_Size = ((Get-Content "$PSScriptRoot\Backup_Data\Script_Configs_Backup.json") | ConvertFrom-Json).Number_Of_Lines
	
	$Employee_Config_Size = ((Get-Content "$PSScriptRoot\Data\Employee_Configs.json") | Out-String).length
	$Script_Config_Size = ((Get-Content "$PSScriptRoot\Data\Script_Configs.json") | ConvertFrom-Json).Number_Of_Lines
	
	If($Employee_Config_Size -gt $Employee_Config_Backup_Size)
	{
		(Get-Content "$PSScriptRoot\Data\Employee_Configs.json") > "$PSScriptRoot\Backup_Data\Employee_Configs_Backup.json"
	}
	If($Script_Config_Size -gt $Script_Config_Backup_Size)
	{
		(Get-Content "$PSScriptRoot\Data\Script_Configs.json") > "$PSScriptRoot\Backup_Data\Script_Configs_Backup.json"
	}
}
Function Pull_Script_Config_Data()
{
	If(Test-Path $Config_Data_Path)
	{
		$Temp_Data = Get-Content $Config_Data_Path
		$Config_Data = ($Temp_Data | ConvertFrom-Json)
	}
	Return $Config_Data
}

Function Pull_Old_Employee_Data()
{
	$Contents_Empty = $True
	If(Test-Path $Employee_Data_Path)
	{
		While($Contents_Empty)
		{
			$Temp_Data = Get-Content $Employee_Data_Path
			If($Temp_Data -ne "Data Used By Other Script")
			{
				Break
			}
		}
		$Old_Employee_Data = ($Temp_Data | ConvertFrom-Json)
	}
	Return $Old_Employee_Data
}

Function Pull_Shout_Out_Data([int]$Skipped_Lines)
{
	$Local_Shout_Out_Data = @()
	$First_Row = $True
	
	$objExcel = New-Object -ComObject Excel.Application
	$objExcel.Visible = $false
	$Work_Book = $objExcel.Workbooks.Open($Excel_File_Path)
	$Work_Sheet = $Work_Book.sheets.item($Sheet_Name)
	$Used_Range = $Work_Sheet.usedrange
	ForEach($Row in ($Used_Range.Rows | Select -skip $Skipped_Lines))
	{
		If($First_Row)
		{
			If($Row.Cells.Item(1).Value2 -eq "")
			{
				$Work_Book.Close($false)
				$objExcel.quit()
				Return $Local_Shout_Out_Data
			}
			$First_Row = $False
		}
		If($Row.Cells.Item(1).Value2 -ne "")
		{
			$Temp_Object = New-Object PSObject -Property @{
				'ID' = $Row.Cells.Item(1).Value2
				'Date' = $Row.Cells.Item(2).Value2
				'To' = $Row.Cells.Item(3).Value2
				'Division' = $Row.Cells.Item(4).Value2
				'Department' = $Row.Cells.Item(5).Value2
				'Region' = $Row.Cells.Item(6).Value2
				'Appreciation' = $Row.Cells.Item(7).Value2
				'From_Name' = $Row.Cells.Item(8).Value2
				'From_GUID' = $Row.Cells.Item(9).Value2
				'Recorded_By' = $Row.Cells.Item(10).Value2
			}
			$Local_Shout_Out_Data += $Temp_Object
		}
	}
	$Work_Book.Close($false)
	$objExcel.quit()
	Return $Local_Shout_Out_Data
}
Function Add_Shout_Out_Data($Temp_Employee_Data, $Temp_Shout_Out_Data)
{
	If($Temp_Employee_Data.Length -eq 0)
	{
		$Temp_Employee_Data = @()
	}
	Foreach($Shout_Out in $Temp_Shout_Out_Data)
	{
		# This determines if it is a new employee # 
		$New_Employee = $True
		$Employee_Count = 0
		ForEach($Employee in $Temp_Employee_Data)
		{
			If($Employee.GUID -eq $Shout_Out.From_GUID)
			{
				$Employee_Location = $Employee_Count
				$New_Employee = $False
				Break
			}
			$Employee_Count++
		}
		If($New_Employee)
		{
			$Should_Create = $True
			If((($Shout_Out.From_Name -eq $Null) -And ($Shout_Out.From_GUID -eq $Null)))
			{
				$Should_Create = $False
			}
			ElseIf($Shout_Out.From_GUID -eq $Null)
			{
				If((($Shout_Out.From_Name).Split(",")).Length -eq 1)
				{
					$Should_Create = $False
				}
				Else
				{
					$Name = ($Shout_Out.From_Name).Split(",")
					$First_Name = $Name[1]
					$Last_Name = $Name[0]
					$Users = Get-ADUser -filter "surname -eq $($Last_Name) -and givenname -eq $($First_Name)" -Properties * | Select SamAccountName
					If($Users.Length -eq 0)
					{
						$Users = Get-ADUser -filter "surname -eq $($Last_Name)" -Properties * | Select SamAccountName
					}
					If($Users.Length -eq 1)
					{
						$Shout_Out.From_GUID = $User.SamAccountName
					}
					Else
					{
						$Should_Create = $False
					}
				}
			}
			Else
			{
				try{$Employee_AD_Info = Get-ADUser $Shout_Out.From_GUID -Properties * | Select *}
				catch{
					$Should_Create = $False
					$Name = ($Shout_Out.From_Name).Split(",")
					$First_Name = $Name[1]
					$Last_Name = $Name[0]
					$Users =  Get-ADUser -filter "surname -eq $($Last_Name)" -Properties * | Select SamAccountName
					If($Users.Length -eq 1)
					{
						$Should_Create = $True
						$Shout_Out.From_GUID = $User.SamAccountName
					}
					Else
					{
						Foreach($User in $Users)
						{
							If($User.SamAccountName -contains ($Shout_Out.From_GUID).SubString(0,6))
							{
								$Should_Create = $True
								$Shout_Out.From_GUID = $User.SamAccountName
							}
						}
					}
				}
			}
			If($Should_Create)
			{
				$Temp_Region = ((Get-ADUser $Shout_Out.From_GUID | Select DistinguishedName).DistinguishedName).Split(",")
				$User = Get-ADUser $Shout_Out.From_GUID -Properties MemberOf
				If(($Temp_Region -Contains "OU=NA") -AND (($User.MemberOf -Match "dl us raci BPT North America") -OR ($User.MemberOf -Match "dl us raci SSC NA")))
				{
					$Temp_Object = New-Object PSObject -Property @{
						'GUID' = $Shout_Out.From_GUID
						'Number_Of_Shouts' = 1
						'Shout_Out_ID_Array' = @($Shout_Out.ID)
						'Sent_12_Mail' = $False
						'Sent_24_Mail' = $False
						'Sent_52_Mail' = $False
						'Sent_100_Mail' = $False
						'Confirmed_52' = 0
					}
					$Temp_Employee_Data += $Temp_Object
				}
			}
		}
		Else
		{
			$Temp_Array = $Temp_Employee_Data[$Employee_Location].Shout_Out_ID_Array
			If(-Not ($Temp_Array -Contains $Shout_Out.ID))
			{
				$Temp_Employee_Data[$Employee_Location].Number_Of_Shouts += 1
				$Temp_Array += $Shout_Out.ID
				$Temp_Employee_Data[$Employee_Location].Shout_Out_ID_Array = $Temp_Array
			}
		}
	}
	Return $Temp_Employee_Data
}
Function Push_Hold_String()
{
	"Data Used By Other Script" > $Employee_Data_Path
}

Function Push_Employee_Config_Data($Employee_Config_Data)
{
	($Employee_Config_Data | ConvertTo-JSON) > $Employee_Data_Path
}

Function Push_Script_Config_Data($Temp_Config_Data)
{
	($Temp_Config_Data | ConvertTo-JSON) > $Config_Data_Path
}

<# Function Declarations #>

<# Main Program Start #>

# Place all of the function calls, in order, into this section
# Note that functions can be called from within other functions, for instance a log function can be called from other functions

	# Pulls a new Data file #
	Get_Updated_Data
	#Create Backup of Config Data
	Backup_Config_Data
	# Pulls the data for the config of the script #
	$Script_Config = Pull_Script_Config_Data
	# Pulls the list of employees found in the config files #
	$Current_Employee_Data = Pull_Old_Employee_Data
	# Pushes a hold string to the Employee Data file, so no other script pulls old data while running #
	Push_Hold_String
	# Pulls the data from the shoutout document pulled off of sharepoint #
	$Shout_Out_Data = Pull_Shout_Out_Data $Script_Config.Number_Of_Lines
	# Sets the config value for "Number of Lines to Skip" as the current number + number of new shoutout #	
	$Script_Config.Number_Of_Lines += $Shout_Out_Data.Length
	# Adds the Shout Out Data to the Employee List, to create an updated list of employees and shout outs#
	$New_Employee_Data = Add_Shout_Out_Data $Current_Employee_Data $Shout_Out_Data
	# Write the New Employee Data to the Config file#
	Push_Employee_Config_Data $New_Employee_Data
	# Write the new Script Config Data to the Config Data file#
	Push_Script_Config_Data $Script_Config
	#Create Backup of Config Data
	Backup_Config_Data
	
<# Main Program End #>
