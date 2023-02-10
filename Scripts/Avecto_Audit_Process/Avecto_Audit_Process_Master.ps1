############# Author  Information #############
# Name: Nicholas Schneider                    #
# Org: SC Johnson - End User Productivity     #
# Date: 9/25/2018                             #
# Purpose:                                    #
#	Pull Avecto license info from             #
#	SQL database, and compare that with       #
#	data from a database for decommissioned   #
#	computers, to get an accurate count of    #
#	needed licenses.                          #
#                                             #
############# Author  Information #############

#### Global Variables ####
$today = Get-Date -Format yyyy-MM-dd
$fileToday = Get-Date -Format MM-dd-yyyy
$dayMinus30 = (Get-Date).AddDays(-30)
$fileTodayMinus30 = Get-Date $dayMinus30 -Format MM-dd-yyyy
$dayMinus30Formatted = Get-Date $dayMinus30 -Format yyyy-MM-dd
$formattedDate = "'" + $dayMinus30Formatted + "'"
$avectoCountTracking = "###########"
$Script_Output_Location = "###########"
# SQL instances #
$avectoInstance = "###########,###########" #Located on server ###########
$cmdbInstance = "###########,###########" #Located on server ###########
# End SQL Instances #


# Start CSV File Pathways #
$csvFolder = "###########" + $fileToday

$notFoundPath = $csvFolder + "\" + $fileToday + "-NotInCMDB.csv"

$notFoundVDIPath = $csvFolder + "\" + $fileToday + "-NotInCMDBButVDI.csv"

$valueFoundPath = $csvFolder + "\" + $fileToday + "-ValueFound.csv"

$valueFoundUncounted = $csvFolder + "\" + $fileToday + "-ValueFoundUncounted.csv"

# End CSV File Pathways #

# Start Log File Paths #
$logFolderName = "Logs"
$logFileName = $fileToday + "-logFile.log"
$logFolderPath = $csvFolder + "\" + $logFolderName
$logFilePath = $logFolderPath + "\" +  $logFileName

# End Log File Paths #

#### End Global Variables ####

## Start Functions ##

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

Function Log
{
	Param([string]$logData)
	#Checks to make sure that the log folder exists, if not, it creates it
	Check_Folder_Exists $logFolderPath
	#Checks to make sure the log file exists, if not it creates it
	Check_File_Exists $logFilePath
	#Appends Data ($logData) to a File located at $logFilePath
	$logData >> $logFilePath

}

Function Add_To_File
{
	Param([String]$csvPath, [String]$csvData)
	
	Check_File_Exists $csvPath
	
	$csvData >> $csvPath
	
}

#Accepts 2 strings, the server instance and the SQL query, and returns the values called from the database
Function QueryDatabase
{
	Param([String]$SQLInstance, [String]$SqlQuery)

	$databaseValues = Invoke-Sqlcmd -query $SqlQuery -ServerInstance $SqlInstance
	#Write-Output $SqlInstance, $SqlQuery
	Return $databaseValues
}

## End Functions ##


## Start of Main Function ##

Function Main
{

	Param([String]$cmdbInstance,[String]$avectoInstance,[String]$date)
	
	## Begin Variables ##
	$avectoQuery = "SELECT DISTINCT Name FROM [###########].[dbo].[###########] session left join [###########].[dbo].[###########] host on host.HostID = session.HostID WHERE SessionStartTime > $date Order By Name ASC"
	Log ("Avecto Query Used: " + $avectoQuery)
	$cmdbQuery = "SELECT * FROM ###########.dbo.########### Order By Serial_Number ASC"
	Log("CMDB Query Used: " + $cmdbQuery)
	
	$loopLimit = 500
	Log("Loop Limit set to: " +$loopLimit)
	$index = $indexStart = $objectsToRemove = $notFoundVDI = $notFound = 0
	## End Variables ##
	
	#Queries both of the SQL databases and pulls the data from them.
	$avectoValues = QueryDatabase $avectoInstance $avectoQuery
	$cmdbValues = QueryDatabase $cmdbInstance $cmdbQuery
	Log "Successfully queried the SQL databases"
	
	ForEach($object In $avectoValues)
	{
		#Defaults the value for each object as false, true is reserved for if it is found and needs to be removed
		$valueFound = "False"
		#This resets the loop limit counter, which stop the script from checking every object afterwards every time it doesnt find a match
		$loopCounter = 0
		While(($index -lt $cmdbValues.Count) -And ($valueFound -eq "False") -And ($loopCounter -lt $loopLimit))
		{
			If($object.Name -eq $cmdbValues[$index].Serial_Number)
			{
				If(($cmdbValues[$index].Status -eq "In - Stock") -Or ($cmdbValues[$index].Status -eq "Dispose") -Or ($cmdbValues[$index].Status -eq "Decommission") -Or ($cmdbValues[$index].Status -eq "Retired"))
				{
					#This means it was found in the CMDB, and its value was that of a computer NOT needing to be counted
					$objectsToRemove++
					$csvData = $object.Name + "`t" + $cmdbValues[$index].Status
					$csvData >> $valueFoundUncounted
				}
				$valueFound = "True"
			}
			$index++
			$loopcounter++
		}
		
		If($valueFound -eq "True")
		{
			$object.Name >> $valueFoundPath
			$indexStart = $index
		}
		ElseIf(($valueFound -eq "False") -And -Not (($object.Name[0] -eq "X") -And ($object.Name[1] -eq "D") -And ($object.Name[4] -eq "-") -And ($object.Name[5] -eq "U") -And ($object.Name[6] -eq "-")))
		{
			$objectsToRemove++
			$notFound++
			$object.Name >> $notFoundPath
			$index = $indexStart
		}
		Else
		{
			$object.Name >> $notFoundVDIPath
			$notFoundVDI++
			$index = $indexStart
		}
	}
	$avectoCount = $avectoValues.Count
	$totalCount = $avectoCount - $objectsToRemove
	Log "The report was run from $date until $today"
	Log "Not in CMDB - In Avecto List: $notFound"
	Log "Not in CMDB - In Avecto List - VDI: $notFoundVDI"
	Log "Number of devices in Avecto List: $avectoCount" 
	Log "Total Devices in Avecto List without license: $objectsToRemove" 
	Log "Total Count of Licensed devices: $totalCount"
	
	$excel = new-object -comobject excel.application
	
	$workbook = $excel.workbooks.open($avectoCountTracking)
	
	$worksheet = $workbook.worksheets.item(1)
	
	$excel.Run("'AvectoCountTracking.xlsm'!Module1.Avecto_Audit_Process",$fileTodayMinus30,$totalCount)
	
	$Workbook.Save()

	$Workbook.close()

	$excel.quit()
	
	Remove-Item -Path ($Script_Output_Location + "\AvectoCountTracking.xlsm")
	Copy-Item -Path ($avectoCountTracking) -Destination ($Script_Output_Location + "\AvectoCountTracking.xlsm")
}
## End of Main Function ##



# Start File Checks #

Check_Folder_Exists $csvFolder
Check_File_Exists $notFoundPath
Check_File_Exists $notFoundVDIPath
Check_File_Exists $valueFoundPath
Check_File_Exists $valueFoundUncounted

# End File Checks #

## Main Function Call - Program Start ##

Main $cmdbInstance $avectoInstance $formattedDate

## Main Function Call - Program End ##

















