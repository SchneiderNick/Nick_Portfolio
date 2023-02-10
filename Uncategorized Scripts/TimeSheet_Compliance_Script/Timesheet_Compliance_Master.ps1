######## Author Info ########
#
#Author: Nicholas Schneider
#Date: 7/5/2018
#Owner: ####################
#Company: ####################
#
######## Author Info ########

## Start of Variables ##

$today = Get-Date
$DayOfWeek = (Get-Date).DayOfWeek
[int]$hour = Get-Date -Format HH
$lastWeekMonday = (Get-Date).AddDays(-7)
$lastWeekMondayFormatted = Get-Date $LastWeekMonday -Format MM-dd-yyyy
$lastWeekFriday = (Get-Date).AddDays(-4)
$lastWeekFridayFormatted = Get-Date $LastWeekFriday -Format MM-dd-yyyy
$dateCounter = -1
While(((Get-Date).AddDays($dateCounter).DayOfWeek.ToString()) -ne "Monday")
{
	$dateCounter--
}
$mondayAddDate = (Get-Date).AddDays($dateCounter)
$sundayAddDate = (Get-Date).AddDays($dateCounter + 6)

If($mondayAddDate.Month -lt 10)
{
	$firstMonthString = "0" + ($mondayAddDate.Month).ToString()
}
If($mondayAddDate.Month -ge 10)
{
	$firstMonthString = ($mondayAddDate.Month).ToString()
}
If($sundayAddDate.Month -lt 10)
{
	$secondMonthString = "0" + ($sundayAddDate.Month).ToString()
}
If($sundayAddDate.month -ge 10)
{
	$secondMonthString = ($sundayAddDate.month).ToString()
}

If($mondayAddDate.day -lt 10)
{
	$firstDayString = "0" + ($mondayAddDate.Day).ToString()
}
If($mondayAddDate.day -ge 10)
{
	$firstDayString = ($mondayAddDate.Day).ToString()
}

If($sundayAddDate.day -lt 10)
{
	$secondDayString = "0" + ($sundayAddDate.day).ToString()
}
If($sundayAddDate.day -ge 10)
{
	$secondDayString = ($sundayAddDate.day).ToString()
}

$formattedDate = $firstMonthString + "/" + $firstDayString + "-" + $secondMonthString + "/" + $secondDayString

$resourceManagersName = @("####################", "####################","####################","####################","####################","####################","####################")
$resourceManagersPrimaryEmail = @("####################","J####################","####################","####################","V####################","####################","####################")
$resourceManagersCCEmail = @("####################","####################","####################","####################","####################","####################","####################")
$resourceManagersTower = @("####################","####################","####################","####################","####################","####################","####################")
$threeUpdates = @("False","False","False","False","False","False","False")
$fridayUpdates  = @("False","False","False","False","False","True","False")
$MondayTimeZoneUpdates  = @("False","False","False","False","True","False","False")

$timesheetComplianceFile = "####################"
$timesheetComplianceUsers = "####################"

$fileToday = (Get-Date -Format yyy-MM-dd)

$logFolderName = "Logs"
$logFileName = $fileToday + ".log"
$logFolderPath = "####################" + "\" + $logFolderName
$logFilePath = "####################" + "\" + $logFolderName + "\" + $logFileName


## End of Variables ##

## Start Of Functions ##


Function Check_File_Exists
{
	Param([String]$filePath)
	#Test the path of the file to see if it exists
	If(-Not (Test-Path $filePath))
	{
		 New-Item -ItemType "file" -Path $filePath
	}
}

Function Check_Folder_Exists
{
	Param([String]$folderPath)
	#Test the path of the file to see if it exists
	If(-Not (Test-Path $folderPath))
	{
		 New-Item -ItemType "directory" -Path $folderPath
	}
}

Function Log()
{
	Param([string]$logData)

	Check_Folder_Exists $logFolderPath
	
	Check_File_Exists $logFilePath
	
	$logData >> $logFilePath

}

Function Run_Excel_Macro()
{
	# Variables #
	$loopCounter = 0
	$ClearFile = ""
	# Variables #
	$logData = "#################### Script Started: " + $today + " ####################"
	Log $logData

	$excel = new-object -comobject excel.application
	
	$workbook = $excel.workbooks.open($timesheetComplianceFile)
	
	$excel.Run("'Timesheet Compliance 1.xlsm'!Module1.Refresh_Data")
	
	ForEach($manager in $resourceManagersName)
	{
		$logData = "Started Processing for: " + $manager
		Log $logData
		If(($DayOfWeek -eq "Monday") -And ($hour -lt 9) -And ($threeUpdates[$loopCounter] -eq "True"))
		{
			$logData = "Criteria met, starting search process on. Day: " + $DayOfWeek + " Hour: " + $hour
			Log $logData
			$missingTimesheetUsers = ""
		
			$excel.Run("'Timesheet Compliance 1.xlsm'!Module1.Timesheet_Compliance",$resourceManagersTower[$loopCounter],$manager, $formattedDate)
		
			Foreach($line in (Get-Content $timesheetComplianceUsers))
			{
				$line = $line.Replace('"',"")
				$missingTimesheetUsers = $missingTimesheetUsers + $line + "`r`n"
			}
			If((Get-Content $timesheetComplianceUsers -First 1) -eq '""')
			{
				$emailBody = "All users have submitted their timesheet at this time!" + "`r`n`r`nThis is an automated email, please do not respond. For information, please contact Nicholas Schneider at NDSchnei@scj.com"
			}
			Else
			{
				$emailBody = "These users have yet to submit their timesheet: `r`n`r`n" + $missingTimesheetUsers + "`r`n`r`nThis is an automated email, please do not respond. For information, please contact Nicholas Schneider at NDSchnei@scj.com"
			}
			$logData = "This is the Body of the email sent to: " + $manager
			Log $logData
			Log $emailBody

			Send_Mail $emailBody $resourceManagersPrimaryEmail[$loopCounter] $resourceManagersCCEmail[$loopCounter] $lastWeekMondayFormatted

			$logData =  "Email sent to: " + $resourceManagersPrimaryEmail[$loopCounter] + " With CC: " + $resourceManagersCCEmail[$loopCounter] 
			Log $logData
			$ClearFile > $timesheetComplianceUsers
			Log "Timesheet file cleared"
		}
		ElseIf(($DayOfWeek -eq "Monday") -And ($hour -eq 9))
		{
			$logData = "Criteria met, starting search process on. Day: " + $DayOfWeek + " Hour: " + $hour
			Log $logData
			$missingTimesheetUsers = ""
		
			$excel.Run("'Timesheet Compliance 1.xlsm'!Module1.Timesheet_Compliance",$resourceManagersTower[$loopCounter],$manager, $formattedDate)
		
			Foreach($line in (Get-Content $timesheetComplianceUsers))
			{
				$line = $line.Replace('"',"")
				$missingTimesheetUsers = $missingTimesheetUsers + $line + "`r`n"
			}
			If((Get-Content $timesheetComplianceUsers -First 1) -eq '""')
			{
				$emailBody = "All users have submitted their timesheet at this time!" + "`r`n`r`nThis is an automated email, please do not respond. For information, please contact Nicholas Schneider at NDSchnei@scj.com"
			}
			Else
			{
				$emailBody = "These users have yet to submit their timesheet: `r`n`r`n" + $missingTimesheetUsers + "`r`n`r`nThis is an automated email, please do not respond. For information, please contact Nicholas Schneider at NDSchnei@scj.com"
			}
			$logData = "This is the Body of the email sent to: " + $manager
			Log $logData
			Log $emailBody

			Send_Mail $emailBody $resourceManagersPrimaryEmail[$loopCounter] $resourceManagersCCEmail[$loopCounter] $lastWeekMondayFormatted

			$logData =  "Email sent to: " + $resourceManagersPrimaryEmail[$loopCounter] + " With CC: " + $resourceManagersCCEmail[$loopCounter] 
			Log $logData
			$ClearFile > $timesheetComplianceUsers
			Log "Timesheet file cleared"		
		}
		ElseIf((($DayOfWeek -eq "Friday") -And ($hour -eq 13) -And ($fridayUpdates[$loopCounter] -eq "True")))
		{
			$column = "W"
			$logData = "Criteria met, starting search process on. Day: " + $DayOfWeek + " Hour: " + $hour
			Log $logData
			$missingTimesheetUsers = ""
		
			$excel.Run("'Timesheet Compliance 1.xlsm'!Module1.Timesheet_Compliance",$resourceManagersTower[$loopCounter],$manager, $formattedDate)
		
			Foreach($line in (Get-Content $timesheetComplianceUsers))
			{
				$line = $line.Replace('"',"")
				$missingTimesheetUsers = $missingTimesheetUsers + $line + "`r`n"
			}
			If((Get-Content $timesheetComplianceUsers -First 1) -eq '""')
			{
				$emailBody = "All users have submitted their timesheet at this time!" + "`r`n`r`nThis is an automated email, please do not respond. For information, please contact Nicholas Schneider at NDSchnei@scj.com"
			}
			Else
			{
				$emailBody = "These users have yet to submit their timesheet: `r`n`r`n" + $missingTimesheetUsers + "`r`n`r`nThis is an automated email, please do not respond. For information, please contact Nicholas Schneider at NDSchnei@scj.com"
			}
			$logData = "This is the Body of the email sent to: " + $manager
			Log $logData
			Log $emailBody

			Send_Mail $emailBody $resourceManagersPrimaryEmail[$loopCounter] $resourceManagersCCEmail[$loopCounter] $lastWeekFridayFormatted

			$logData =  "Email sent to: " + $resourceManagersPrimaryEmail[$loopCounter] + " With CC: " + $resourceManagersCCEmail[$loopCounter]
			Log $logData
			$ClearFile > $timesheetComplianceUsers
			Log "Timesheet file cleared"
		}
		ElseIf((($DayOfWeek -eq "Monday") -And ($hour -eq 0) -And ($MondayTimeZoneUpdates[$loopCounter] -eq "True")))
		{
			$logData = "Criteria met, starting search process on. Day: " + $DayOfWeek + " Hour: " + $hour
			Log $logData
			$missingTimesheetUsers = ""
		
			$excel.Run("'Timesheet Compliance 1.xlsm'!Module1.Timesheet_Compliance",$resourceManagersTower[$loopCounter],$manager, $formattedDate)
		
			Foreach($line in (Get-Content $timesheetComplianceUsers))
			{
				$line = $line.Replace('"',"")
				$missingTimesheetUsers = $missingTimesheetUsers + $line + "`r`n"
			}
			If((Get-Content $timesheetComplianceUsers -First 1) -eq '""')
			{
				$emailBody = "All users have submitted their timesheet at this time!" + "`r`n`r`nThis is an automated email, please do not respond. For information, please contact Nicholas Schneider at NDSchnei@scj.com"
			}
			Else
			{
				$emailBody = "These users have yet to submit their timesheet: `r`n`r`n" + $missingTimesheetUsers + "`r`n`r`nThis is an automated email, please do not respond. For information, please contact Nicholas Schneider at NDSchnei@scj.com"
			}
			$logData = "This is the Body of the email sent to: " + $manager
			Log $logData
			Log $emailBody

			Send_Mail $emailBody $resourceManagersPrimaryEmail[$loopCounter] $resourceManagersCCEmail[$loopCounter] $lastWeekMondayFormatted

			$logData =  "Email sent to: " + $resourceManagersPrimaryEmail[$loopCounter] + " With CC: " + $resourceManagersCCEmail[$loopCounter]
			Log $logData
			$ClearFile > $timesheetComplianceUsers
			Log "Timesheet file cleared"
		}
	$loopCounter = $loopCounter + 1
	Log "Loop counter increased."
	}
	$Workbook.Save()
	Log "Workbook saved"
	$Workbook.close()
	Log "Workbook Closed"
	$excel.quit()
	Log "Excel Quit"
}

Function Send_Mail
{
	Param([string]$body, [string]$emailRecipient, [string]$emailCC, [string]$lastWeekFormatted)

	
	$smtpServer = "####################"
	$msg = new-object Net.Mail.MailMessage 
	$smtp = new-object Net.Mail.SmtpClient($smtpServer) 
	$msg.From = "####################"
	$msg.To.Add($emailRecipient)
	$msg.Cc.Add($emailCC)
	$msg.BCc.Add("####################")
	$msg.Subject = "TimeSheet Compliance - Week Of : " + $lastWeekFormatted
	$msg.Body = $body 
	$smtp.Send($msg)

}
## End of Functions ##

Check_File_Exists $timesheetComplianceUsers

Run_Excel_Macro
