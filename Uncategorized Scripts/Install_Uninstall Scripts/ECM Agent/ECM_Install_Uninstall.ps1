<#
	Author: Nicholas Schneider
	Company: SC Johnson and Son Inc.
	Script Name: SCCM/ECM Install and Uninstall Script
	Language: PowerShell
	Modules: None
	Parameters:
		0: Destination_IP - String - IP or DNS for target server (Software is being installed here)
		1: Source_Path - String - Full path to the 
		2: Install_Name - String - Name found in Windows to identify the program (Name displayed in "Programs and Features")
		3: Install_Exe - String - File name for EXE that is used in the install process (Must include the ".exe" or ".msi")
		4: $Install - Boolean - $True -> Install $False -> Uninstall
	Purpose: This script will have 2 basic functionalities. Depending on parameter 4, this script will either Install the SCCM/ECM agent on a target machine
		or it will Uninstall that same software. 

	Example Call: Powershell -file "Script Path" -Destination_IP "Target IP/Hostname" -Source_Path "Path to source folder" -Install_Name "Configuration Manager Client" -Install_Exe "Exe File Name" -Install $True/$False
#>

param($Destination_IP,$Source_Path,$Install_Name,$Install_Exe,$Install)

##
$Log_Folder_Path = ""##########""
$fileToday = Get-Date -Format yyyy-MM-dd-HH-mm-ss
$Log_File = $fileToday.ToString() + "_Log.log"
$Log_Path = $Log_Folder_Path + $Log_File
New-Item -Path $Log_Path
##


Function Check_Params()
{
	If( -Not (Test-Path $Source_Path) )
	{
		Log "Source Path could not be found"
		Exit
	}
	If($Destination_IP -eq $NULL)
	{
		Log "Destination IP value was NULL"
		Exit
	}
	Else
	{
		If(-Not (Test-Connection $Destination_IP -Count 1 -ErrorAction SilentlyContinue))
		{
			Log "Could not get a proper connection to Destination IP"
			Exit
		}
	}
	If($Install_Name -eq $NULL)
	{
		Log "Install Name Variable is NULL"
		Exit
	}
	If($Install)
	{
		If($Install_Exe -ne $NULL)
		{
			If($Source_Path.SubString($Source_Path.get_length()-1) -ne "\")
			{
				$Source_Path = $Source_Path + "\"
			}
			$Install_Path = $Source_Path + $Install_Exe
			If( -Not (Test-Path $Install_Path) )
			{
				Log "Could not confirm path to Installer"
				Exit
			}
			Return "Install"
		}
	}
	ElseIf(-Not $Install)
	{
		Return "Uninstall"
	}
	Else
	{
		Log "Unknown value input with Install/Uninstall command"
		Log ("Value Input: " + $Install)
		Log "Exiting Program - No Server Install/Uninstall Occurred"
		Exit
	}
}
Function Check_Install($Install_Name,$Destination)
{
    Log "Begin session with remote computer for Install Check"
    $Check_Session = New-PSSession -ComputerName $Destination
    Log "Running a command on the remote computer to pull a list of all applications installed on the machine"
    $Install_List = Invoke-Command -Session $Check_Session {Return Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName}
    Log "Kill Install Session"
    Invoke-Command -Session $Check_Session {Exit}
    Log "Looping through each of the installed on the computer and compare them to the install name variable"
    Foreach($Name in $Install_List.DisplayName)
    {
        If($Name -eq $Install_Name)
        {
			Log "Install Name Found, Returning TRUE"
            Return $True
        }
    }
    Log "Install NOT found, returning FALSE"
    Return $False
}
Function Log([string]$Log_Data)
{
	$Log_Data >> $Log_Path
}
Function Install()
{
	If(-Not (Check_Install $Install_Name $Destination_IP))
	{
		Log "Creating Destination Path"
        $Destination_Path = ("\\" + $Destination_IP + "\D$\Temp\")
		Log "Create Temp Folder on D Drive (If it doesn't exist)"
		If(-Not (Test-Path $Destination_Path))
		{
			New-Item -Path $Destination_Path -ItemType Directory
		}
        Log "Copying items from the source path to the destination"
		Copy-Item -Path $Source_Path -Destination $Destination_Path -Recurse
        Log "Session started with Computer"
        $Install_Session = New-PSSession -ComputerName $Destination_Ip
        Log "Building the new path into a variable"
        Log "Pulling the folder name from the Source Path"
        $Split_Source = $Source_Path.Split("\")
        $Split_Count = $Split_Source.Count
        $Folder_Name = $Split_Source[$Split_Count-1]
        Log "Building the Executable Path"
        $Executable_Path = $Destination_Path + "\" + $Folder_Name + "\" + $Install_Exe
        Log "Running the Executable on the destination server"
        Invoke-Command -Session $Install_Session {Start-Process -FilePath $args[0] -ArgumentList '/smssitecode=auto /Silent'} -ArgumentList $Executable_Path 
        Log "Sleeping Script to give install time before checking"
        Sleep 60
        Log "Ending Install Session"
        Invoke-Command -Session $Install_Session {Exit}
	}
	Else
	{
		Log "Install was found on the server"
		Log "Cancelling Install as software is present"
		Exit
		
	}
}

Function Uninstall()
{
	If((Check_Install $Install_Name $Destination_IP))
	{
        Log "Uninstall Session initiated"
        $Uninstall_Session = New-PSSession -ComputerName $Destination_IP
		Log "Running command to uninstall the application"
        Invoke-Command -Session $Uninstall_Session {(Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq $args[0]}).Uninstall()} -ArgumentList $Install_Name
        Log "Sleeping for 60 seconds to allow for the uninstall process"
		Sleep 60
		Log "Restarting target machine to perform uninstall properly"
		Invoke-Command -Session $Uninstall_Session {Restart-Computer}
		Log "Exiting Remote Sessions"
        Invoke-Command -Session $Uninstall_Session {Exit}
	}
	Else
	{
		Log "Install was not found"
		Log "Cancelling uninstall as software is not present"
		Exit
		
	}	
}

Function Main()
{
	Try{&(Check_Params)}
	Catch{
		Log "Variable Check returned something other than Install/Uninstall"
		Log "Exiting Script"
		Exit
	}
	
}



Main