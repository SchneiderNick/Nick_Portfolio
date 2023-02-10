<#
Template Made By Nicholas Schneider
#>

<#
Author: Nicholas Schneider
Date: 4/1/2022
Purpose: Searching the users file systems for pst files. Once found, each of these files is unmounted from Outlook, moved to a folder, renamed and hidden. 
#>

<# Global Variables #> 

Try { Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop' } Catch {}

# Declare all variables from templates in here

$SCJGDE_Flag = "###########"
$SCJGDE_Log = "###########"
$Warning_Base_Duration = 300 #5 minutes
$ProjectADGroup = "###########"
$Global:Outlook_Closed = $False

<# Global Variables #> 

<# Function Declarations #>

Function Check_Outlook()
{
	$Outlook_PopUP = New-Object -ComObject WScript.Shell
	Log "Running the Find_Outlook Function"
	If(Find_Outlook)
	{
		$Outlook_Warning = $True
		$Start_Time = Get-Date
		Log "Start time set to: $Start_Time"
		$Current_Time = Get-Date
		Log "Current time set to: $Current_Time"
		While(((($Current_Time-$Start_Time).Minutes * 60) + (($Current_Time-$Start_Time).Seconds)) -le $Warning_Base_Duration)
		{
			
			$Time_Left = $Warning_Base_Duration - ((($Current_Time-$Start_Time).Minutes * 60) + (($Current_Time-$Start_Time).Seconds))
			Log "Time Left to reboot: $Time_Left"
			$Minutes_Left = [Math]::floor($Time_Left/60)
			Log "Minutes left calculated as: $Minutes_Left"
			$Seconds_Left = $Time_Left % 60
			Log "Seconds left calculated as: $Seconds_Left"
			If(($Seconds_Left -gt 0) -and ($Minutes_Left -ne 0))
			{
				Log "Setting About_Symbol to ~"
				$About_Symbol = "~"
			}
			Else
			{
				Log "Clearing About_Symbol"
				$About_Symbol = ""
			}
			If($Minutes_Left -eq 0)
			{
				$Time_Designation = "seconds"
				Log "Time Designation set to seconds"
				$Minutes_Left = $Seconds_Left
				Log "Minutes_Left set to Seconds_Left"
			}
			Else
			{
				$Time_Designation = "minutes"
				Log "Time Designation set to minutes"
			}
			$PopUp_Dynamic_Title = "OUTLOOK .PST RETENTION RULES RESTART"
			If($Time_Left -eq 0)
			{
				$Time_Left = 1
			}
			$PopUp_Dynamic_Body = "Outlook will shut down in " + $About_Symbol + $Minutes_Left + " " + $Time_Designation + " to apply email retention rules. Outlook will restart automatically once the rules are implemented. For most people, this will take 2-5 minutes.`n`nThis required process may not be postponed more than 5 minutes.`nDo you want to close Outlook now?`nSelect YES to close Outlook automatically (Drafts are saved)`nSelect NO to postpone"
			Log "Creating the Outlook Pop-Up"
			$Outlook_Popups_Result = $Outlook_PopUP.Popup($PopUp_Dynamic_Body,$Time_Left,$PopUp_Dynamic_Title,4) #6 = Yes #7 = No -1 = Timeout
			
			If($Outlook_Popups_Result -eq 6)
			{
				Log "User clicked YES and Outlook will now attempt to close"
				Break
			}
			ElseIf($Outlook_Popups_Result -eq 7)
			{
				Log ("User clicked NO and the script will now sleep for " + ($Time_Left/2).ToString())
				Sleep($Time_Left/2)
			}
			Else
			{
				Log "Popup has timed out. Outlook will now close"
				Break
			}
			
			$Current_Time = Get-Date
			Log "New Current_Time: $Current_Time"
		}
		Log "Running the Close_Outlook function"
		Close_Outlook
		$Global:Outlook_Closed = $True
		Log "Log Outlook_Closed set to True"
	}
	Else
	{
		Log "Running the Close_Outlook function"
		Close_Outlook
		$Global:Outlook_Closed = $True
		Log "Log Outlook_Closed set to True"
	}
}

Function Close_Outlook()
{
	Try{
	If(Find_Outlook)
		{
			Log "Outlook process found"
			Log "Attempting to Stop the process: Outlook"
			Stop-Process -Name "Outlook"
			Log "Process successfully stopped"
		}
	}
	Catch{
		Exit 60001
	}
}
Function Find_Outlook()
{
	If((Get-Process outlook -ErrorAction SilentlyContinue) -eq $NULL)
	{
		Log "Outlook not found"
		Return $False
	}
	Else
	{
		Log "Outlook process found"
		Return $True
	}
}
Function Check_Flag_File()
{
	If((Test-Path $SCJGDE_Flag -PathType Leaf))
	{
		Log "Flag file found"
		Return $True
	}
	Log "Flag file not found"
	Return $False
}

Function Create_Flag_File()
{
	$Results = Check_Flag_File
	If($Results -eq $False)
	{
		Log "Creating Flag file here: $SCJGDE_Flag"
		New-Item -Path $SCJGDE_Flag -itemtype "File"
	}
}

Function Create_Log_File()
{
	If((Test-Path $SCJGDE_Log)-eq $False)
	{
		New-Item -Path $SCJGDE_Log -itemtype "File"
	}
	
}

Function Log([string]$Log_Data)
{
	Create_Log_File
	$Formatted_Log_Date = (Get-Date -Format yyyy-MM-dd-HH-mm-ss).ToString()
	($Formatted_Log_Date + " | " + $Log_Data) >> $SCJGDE_Log
}

Function Check_VPN_Connection()
{
	$logonServer = $env:logonServer
	Log "Checking LogonServer: $logonServer"
	If ($logonServer) {
		If (Test-Connection $logonServer.substring(2) -Quiet) {
			Log "Login server found and connection test was positive"
			Return $true
		}
	}
	Log "No logon server found"
	Return $False
}

<# Function Declarations #>

<# Main Program Start #>
Try{
	
	# Place all of the function calls, in order, into this section
	# Note that functions can be called from within other functions, for instance a log function can be called from other functions
	Create_Log_File

	If(Check_Flag_File)
	{
		Log "Flag file was found, so script is exiting"
		Exit 60001
	}

	If(-Not (Check_VPN_Connection))
	{
		Log "VPN Connection not found, so script is exiting"
		Exit 60001
	}
	Log "Running the Check_Outlook function"
	Check_Outlook

	#Only check for outlook to be open once the PST has been searched 

	try {
		# Call the Outlook COM object (runs an Outlook.exe without UI)
		$Outlook = New-Object -ComObject Outlook.Application
		$Namespace = $Outlook.getNamespace("MAPI")
		# Get all namespace stores of the user
		$allNamespaceStores = $Namespace.Stores
		Log "Found $($allNamespaceStores.count) namespace stores"
		# Filter namespace stores to get relevant information only
		$filteredNamespaceStores = $allNamespaceStores | select ExchangeStoreType,FilePath,IsDataFileStore
		foreach ($namespaceStore in $filteredNamespaceStores) {
			Log "Exchange Store Type: $($namespaceStore.ExchangeStoreType)"
			Log "File Path: $($namespaceStore.FilePath)" -Severity 1
			Log "Is Data File Store: $($namespaceStore.IsDataFileStore)"
			if ($namespaceStore.ExchangeStoreType -eq '3'){ # 3 = PST store
				if ($namespaceStore.FilePath) { # if the filepath is not blank
					if (Test-Path $namespaceStore.FilePath) { # check if the PST file actually exists
						Log "$($namespaceStore.FilePath) exists locally"
					} else { # the PST store is corrupted and the script should terminate as it will cause problems later
						Log "Error on checking PST stores - $($namespaceStore.FilePath) does not exist"
						Exit 60001
					}
				} else {
					Log "The filepath of this namespace store is blank. Skipping..."
				}
			}
		}
		# Filter namespace stores to only PSTs ($allNamespaceStores must be used to retrieve all object properties)
		$all_psts = $allNamespaceStores | Where-Object {($_.ExchangeStoreType -eq '3') -and ($_.FilePath -like '*.pst') -and ($_.IsDataFileStore -eq $true)}
	} catch {
		$ErrorMessage = $_.Exception.Message
		Log "Error on querying Outlook datastore - $ErrorMessage"
		for($i = 1; $i -le $all_psts.count; $i++) {
			try {
				$all_psts[$i] | Out-Null
			} catch {
				$ErrorMessage = $_.Exception.Message
				Log $ErrorMessage
			}
		}
		Exit 60001
	}

	if ($all_psts) {
		# Unmount PSTs attached to Outlook. Script will exit if it encountered any errors
		Log "Unmounting PSTs attached to Outlook"
		$files = @()
		foreach ($pst in $all_psts){
			try {
				$files += $pst.FilePath
				$Outlook.Session.RemoveStore($pst.GetRootFolder())
			} catch {
				$ErrorMessage = $_.Exception.Message
				Log "Error unmounting $($pst.FilePath) - $ErrorMessage"
				Exit 60001
			}
		}
	} else {
		Log "No PSTs attached to Outlook"
	}

	# Retrieve the user logged in to the machine
	$user = (Get-WMIObject -class Win32_ComputerSystem).UserName
	Log "User is $user"

	# Change the ACL of the unmounted files
	if ($files){
		Log "Found $($files.count) PST file(s) on Outlook"
		foreach ($file in $files){
			Log "PST file: $file"
		}
		
		# Force close Outlook (COM object)
		Close_Outlook
		# Change ACL of each PST file
		foreach ($file in $files){
			try {		
				if (Test-Path $file) {
					$pst = Get-Item $file -force
					$Temp_Parent = (Get-Item $pst -force).Directory.Fullname + "\"
					
					
					Log "$($pst.FullName) exists. Proceeding with changes"
					
					# Set project AD group as owner and remove user permissions. Script will exit if it encountered any errors
					Log "Setting $ProjectADGroup as owner of $($pst.FullName)"
					$log = cmd /c "2>&1" icacls $pst.FullName /setowner $ProjectADGroup
					if (($log | % { $_ -like "*Failed processing 1*"}) -contains $true) { 
						Log "$($pst.FullName) setowner failed"
						Log $log -Severity 3 -Source $deployAppScriptFriendlyName
						Exit 60001
					}
					
					Log "Disabling permission inheritance on $($pst.FullName)"
					$log = cmd /c "2>&1" icacls $pst.FullName /inheritance:d
					if (($log | % { $_ -like "*Failed processing 1*"}) -contains $true) { 
						Log "$($pst.FullName) disable inheritance failed"
						Log $log
						Exit 60001
					}
					
					Log "Removing permissions of $user on $($pst.FullName)"
					$log = cmd /c "2>&1" icacls $pst.FullName /remove:g $user
					if (($log | % { $_ -like "*Failed processing 1*"}) -contains $true) {
						Log "$($pst.FullName) remove $user failed"
						Log $log
						Exit 60001
					}
					
					Log "Granting $ProjectADGroup modify rights on $($pst.FullName)"
					$log = cmd /c "2>&1" icacls $pst.FullName /grant "$ProjectADGroup`:(M)"
					if (($log | % { $_ -like "*Failed processing 1*"}) -contains $true) {
						Log "$($pst.FullName) grant $ProjectADGroup access failed"
						Log $log
						Exit 60001
					}
											
					# Rename to *.<date>pst.emlrrp
					Log "Changing $($pst.FullName) file extension to .emlrrp"
					$dateFileExt = get-date -Format "ddMMyyHHmmssfff"
					$pst | Rename-Item -newname { [io.path]::ChangeExtension($_.name, $dateFileExt+"pst.emlrrp") } -force -ea Stop
					$Temp_Pst = Get-Item ($Temp_Parent + [io.path]::GetFileNameWithoutExtension($pst.Name) + "." + $dateFileExt + "pst.emlrrp")
					
				} else {
					Log "$file does not exist. Skipping..."
				}
				Log "Testing for OutlookFiles Folder"
				If(-Not (Test-Path "C:\OutlookFiles\"))
				{
					Log "Folder did not exist, creating folder directory"
					New-Item -Path "c:\" -Name "OutlookFiles" -ItemType "directory"
					Log "Moving $($pst.FullName) to C:\Outlookfiles\"
					$Temp_Pst | Move-Item -Destination "C:\OutlookFiles\"
				}
				Else
				{
					Log "Moving $($pst.FullName) to C:\Outlookfiles\"
					$Temp_Pst | Move-Item -Destination "C:\OutlookFiles\"
				}
				$Temp_Pst = Get-Item ("C:\OutlookFiles\" + $Temp_Pst.Name) -force
				# Set PST file to Hidden
				Log "Setting $($Temp_Pst.FullName) to Hidden"
				if ($Temp_Pst.attributes -notmatch 'Hidden') {
					$Temp_Pst.attributes += 'Hidden'
				}
			} catch {
				$ErrorMessage = $_.Exception.Message
				Log "Error on $($pst.FullName) - $ErrorMessage"
				Exit 60001
			}
		}
	}

	# Look for other PSTs on the C drive and soft-delete
	Log "Looking for other PSTs on the C drive" -Severity 1 -Source $deployAppScriptFriendlyName
	#$pstList = gci C:\ -file -ea silent -recurse -force | ? { $_.extension -eq ".pst"}
	$pstList = (robocopy c:\ c:\temp *.pst /s /b /l /fp /xj /ndl /njh /njs /nc /ns /np /mt:128).trim()
	# Remove first element from robocopy output (empty)
	$pstList = $pstList[1..($pstList.Length-1)]

	# Change the ACL of the PST files
	if ($pstList) {
		Log "Found $($pstList.count) PST file(s) on C: drive"
		foreach ($file in $pstList){
			Log "PST file: $file"
		}
		
		# Force close Outlook (COM object)
		Close_Outlook
		
		# Change ACL of each PST file
		foreach ($pst in $pstList){
			try {
				if (Test-Path $pst) {
					$Temp_Parent = (Get-Item $pst -force).Directory.Fullname + "\"
					$pst = Get-Item $pst -force
					Log "$($pst.FullName) exists. Proceeding with changes"
					
					# Set project AD group as owner and remove user permissions. Script will exit if it encountered any errors
					Log "Setting $ProjectADGroup as owner of $($pst.FullName)"
					$log = cmd /c "2>&1" icacls $pst.FullName /setowner $ProjectADGroup
					if (($log | % { $_ -like "*Failed processing 1*"}) -contains $true) { 
						Log "$($pst.FullName) setowner failed"
						Log $log
						Exit 60001
					}
					
					Log "Disabling permission inheritance on $($pst.FullName)"
					$log = cmd /c "2>&1" icacls $pst.FullName /inheritance:d
					if (($log | % { $_ -like "*Failed processing 1*"}) -contains $true) { 
						Log "$($pst.FullName) disable inheritance failed"
						Log $log
						Exit 60001
					}
					
					Log "Removing permissions of $user on $($pst.FullName)"
					$log = cmd /c "2>&1" icacls $pst.FullName /remove:g $user
					if (($log | % { $_ -like "*Failed processing 1*"}) -contains $true) {
						Log "$($pst.FullName) remove $user failed"
						Log $log
						[int32]$mainExitCode = 60001
						Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
						Exit-Script -ExitCode $mainExitCode
					}
					
					Log "Granting $ProjectADGroup modify rights on $($pst.FullName)"
					$log = cmd /c "2>&1" icacls $pst.FullName /grant "$ProjectADGroup`:(M)"
					if (($log | % { $_ -like "*Failed processing 1*"}) -contains $true) {
						Log "$($pst.FullName) grant $ProjectADGroup access failed"
						Log $log
						Exit 60001
					}
					
					# Rename to *.<date>pst.emlrrp
					Log "Changing $($pst.FullName) file extension to .emlrrp"
					$dateFileExt = get-date -Format "ddMMyyHHmmssfff"
					$pst | Rename-Item -newname { [io.path]::ChangeExtension($_.name, $dateFileExt+"pst.emlrrp") } -force -ea Stop
					$Temp_Pst = Get-Item ($Temp_Parent + [io.path]::GetFileNameWithoutExtension($pst.Name) + "." + $dateFileExt + "pst.emlrrp")
				} else {
					Log "$pst does not exist. Skipping..."
				}
				
				Log "Testing for OutlookFiles Folder"
				if (-Not (Test-Path "C:\OutlookFiles\")) {
					Log "Folder did not exist, creating folder directory"
					New-Item -Path "c:\" -Name "OutlookFiles" -ItemType "directory"
					Log "Moving $($Temp_Pst.FullName) to C:\Outlookfiles\"
					$Temp_Pst | Move-Item -Destination "C:\OutlookFiles\"
				}
				else {
					Log "Moving $($Temp_Pst.FullName) to C:\Outlookfiles\"
					$Temp_Pst | Move-Item -Destination "C:\OutlookFiles\"
				}
				$Temp_Pst = Get-Item ("C:\OutlookFiles\" + $Temp_Pst.Name) -force
				# Set PST file to Hidden
				Log "Setting $($Temp_Pst.FullName) to Hidden"
				if ($Temp_Pst.attributes -notmatch 'Hidden') {
					$Temp_Pst.attributes += 'Hidden'
				}
			} catch {
				$ErrorMessage = $_.Exception.Message
				Log "Error on $pst - $ErrorMessage"
				Exit 60001
			}
		}
	} else {
		Log "No PSTs found"
	}
	
	If($Outlook_Closed)
	{
		Log "Outlook was closed, restarting the application"
		start outlook.exe
	}

	Log "Creating the Flag File"
	Create_Flag_File
}
Catch
{
	$ErrorMessage = $_.Exception.Message
	Log "Error on $pst - $ErrorMessage"
	Exit 60001
}
<# Main Program End #>