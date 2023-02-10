######## Author Info ########
#
#Author: Nicholas Schneider
#Date: 7/5/2018
#Owner: Dave Shellberg
#Company: SC Johnson
#
######## Author Info ########

######## Program Info ########
#
#Functions: Public_Cleanup and Check_Folder
#Purpose: Semi-Recursively search folder and delete files that have not been edited in a specific number of days and delete any empty folders
#Run Time: Varies based on number of Files/Folders (Without Log File)
	# 11000 Files 1211 Folders: 2 Minutes 45 Seconds 215 Milliseconds OR 1,652,156,363 Ticks
	# 22,000 Files 2422 Folders: 5 Minutes 36 Seconds 495 Milliseconds OR 3,364,958,153 Ticks
	# 110,000 Files 12,000 Folders: 26 Minutes 48 Seconds 441 Milliseconds OR 16,084,410,535 Ticks
#Run Time: Varies based on number of Files/Folders (With Log File)
	# 11000 Files 1211 Folders: 2 Minutes 51 Seconds 855 Milliseconds OR 1,718,559,497
	# 22,000 Files 2422 Folders: 5 Minutes 54 Seconds 407 Milliseconds OR 3,544,071,363
	# 110,000 Files 12,000 Folders: 29 Minutes 46 Seconds 100 Milliseconds OR 17,861,000,503
	# 220,000 Files 12,000 Folders: 1 Hour 11 Minutes 27 Seconds 14 Milliseconds OR 42,870,143,581
######## Program Info ########


######## Variable Start ########
#Root folder that you want to clean (Make sure to put the entire file path AS WELL AS a "\" at the end to indicate it's a folder)
$publicFolderPath = "###########"
$Root_Folders = @("###########","###########","###########","###########","###########","###########","###########","###########","###########","###########","###########","###########","###########","###########","###########","###########","###########","###########")
$Root_File = "EUP-File_Share-Quick_Guide.docx"
#Number of days since a file has been edited that is deleted (5 means that any file that has not been edited in 5 days will be removed)
$daysOfInactivity = 30
#Variables to store the start time of the script, the end time of the script, and the total run time of the script
$startTime = 0
$endTime = 0
$runTime = 0

# Log Variables #
$logFolderName = "Logs"
$logFileName = "logFile.log"
$logFolderPath = (Split-Path -parent $PSCommandPath) + "\" + $logFolderName
$logFilePath = (Split-Path -parent $PSCommandPath) + "\" + $logFolderName + "\" + $logFileName
$script:foldersDel = 0
$script:foldersSkip = 0
$script:filesDel = 0
# Log Variables #


######## Variable End ########

##### Functions #####
Function Check_File_Exists
{
	Param([String]$filePath)
	#Test the path of the file to see if it exists
	If(-Not (Test-Path $filePath))
	{
		 New-Item -ItemType "file" -Path $filePath
	}
}
#Check_Folder_Exists
Function Check_Folder_Exists
{
	Param([String]$folderPath)
	#Test the path of the file to see if it exists
	If(-Not (Test-Path $folderPath))
	{
		 New-Item -ItemType "directory" -Path $folderPath
	}
}

<# Needed Functions #>

#Log Function
Function Log()
{
	Param([string]$logData)

	Check_Folder_Exists $logFolderPath
	
	Check_File_Exists $logFilePath
	
	$logData >> $logFilePath

}

##### Functions #####



########## Public_Cleanup ##########
# Purpose: Main function that goes through the items in the root of the public folder
# and seperates the files from the folders. It throws the folders through the Check_Folder Function
# and removes any file in the root that is too old
# Parameteres: $publicFolder is a string containing the pathway to the root (ends with a \ to indicate its a folder)
# $daysOfInactivity is an Int32, and represents the number of days of inactivity before a file is deleted
########## Public_Cleanup ##########

Function Public_Cleanup()
{
	#publicFolder is the path to the public Folders
	#daysOfInactivity is the time with which a file has to be updated in to be saved
	Param([string[]]$publicFolder, [int32]$daysOfInactivity)
	#loop through object list of items in the root of the public folder
	ForEach($publicItem in Get-ChildItem -Path $publicFolder)
	{
		#If the object is a directory (folder) execute the if statement's block of code
		If((Get-Item $publicItem.FullName) -Is [System.IO.DirectoryInfo])
		{
			If($Root_Folders -Contains $publicItem.Name)
			{
				#Send the folders path to the "Check_Folder" function
				Check_Folder $publicItem.FullName
				#When it comes back to this function, check the folder to see if it is empty, if it is, delete it
				If(Test-Path $publicItem.FullName) {
					If(((Get-ChildItem $publicItem.FullName).Count -eq 0) -And (!($Root_Folders -Contains $publicItem.Name)))
					{
						Log "Delete folder: $($publicItem.FullName)"
						Remove-Item $publicItem.FullName -Confirm:$false -Force
						$script:foldersDel++
					}
				}
			}
			Else
			{
				#If it is a root folder, recursively remove all files from the 
				Remove-Item $publicItem.FullName -Confirm:$false -Recurse -Force
			}
		}
		#If the object is not a folder, check its last write time
		Else
		{
			If(!($Root_File -Match $publicItem.Name))
			{
				#If its last write time is lt the time given, then remove that file
				If((Get-Item $publicItem.FullName).LastWriteTime -lt (Get-Date).AddDays(-$daysOfInactivity))
				{
					Log "Delete file: $($publicItem.FullName)"
					#Log "Last write: $($publicItem.LastWriteTime)"
					Remove-Item $publicItem.FullName -Force
					$script:filesDel++
				}
			}
		}
		
	}
}
########## Check_Folder ##########
# Purpose: Semi - Recursively loops through items in subfolders, deleting any files that are too old and removing empty folders as it makes its way out of the recusrion
# Parameters: $folderPath is a string containing the pathway to the folder being checked (ends with a \ to indicate its a folder)
########## Check_Folder ##########
Function Check_Folder()
{
	Param([string[]]$folderPath)
	#If the folder is empty, immediately delete the folder
	$Folder_Name = ($folderPath.Split("\"))[$folderPath.Split("\").Count - 1]
	If(((Get-ChildItem $folderPath).Count -eq 0) -And (!($Root_Folders -Contains $Folder_Name)))
	{
		Log "Delete folder: $folderPath"
		Remove-Item $folderPath -Recurse -Confirm:$false -Force
		$script:foldersDel++
	}
	Elseif((Get-Item $folderPath).LastWriteTime -gt (Get-Date).AddDays(-$daysOfInactivity)){
		Log "Skip folder: $folderPath"
		$script:foldersSkip++
	}
	Else #If the folder has at least one item in it
	{
		#Process each item inside of that sub folder
		ForEach($item in Get-ChildItem -Path $folderPath)
		{
			#If the sub-item is a folder, check what is in it
			If((Get-Item $item.FullName) -Is [System.IO.DirectoryInfo])
			{
				#If it has items in it, send it back through the Check_Folder function
				If((Get-ChildItem $item.FullName).Count -ne 0)
				{
					Check_Folder $item.FullName
				}
				#If after running through Check_Folder, it is empty, delete it
				If((Get-ChildItem $item.FullName).Count -eq 0)
				{
					Log "Delete folder: $($item.FullName)"
					Remove-Item $item.FullName -Recurse -Confirm:$false -Force
					$script:foldersDel++
				}
			}
			Else #If the item is a file, checks its last write time and if it is too old, delete it
			{
				If((Get-Item $item.FullName).LastWriteTime -lt (Get-Date).AddDays(-$daysOfInactivity))
				{
					Log "Delete file: $($item.FullName)"
					#Log "Last write 2: $($item.LastWriteTime)"
					Remove-Item $item.FullName -Force
					$script:filesDel++
				}
			}
		}
	}
}
#Grab the start time of the script for speed
$startTime = Get-Date


#Calls the function "Public_Cleanup" with the variables you specify in the beginning of the program (This line starts the program)
Public_Cleanup $publicFolderPath $daysOfInactivity


#Grab the end time of the script
$endTime = Get-Date
#Subtract the start date from the end date, and get the run time
$runTime = $endTime - $startTime
#Display the run time
Log "**** Start Time: $startTime ****"
Log "The Run Time was: $runTime"
Log "**** End Time: $endTime ****"
Log "**** Folders deleted: $script:foldersDel ****"
Log "**** Folders skipped: $script:foldersSkip ****"
Log "**** Files deleted: $script:filesDel ****"


