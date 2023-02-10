<#
	Author: Nicholas Schneider
	Company: SC Johnson and Son Inc.
	Script Name: CAM (Cherwell Agent) Install and Uninstall Script
	Language: PowerShell
	Modules: None
	Parameters:
		0: Destination_IP - String - IP or DNS for target server (Software is being installed here)
		1: Source_Path - String - Full path to the 
		2: Install_Name - String - Name found in Windows to identify the program (Name displayed in "Programs and Features")
		3: Install_Exe - String - File name for EXE that is used in the install process (Must include the ".exe" or ".msi")
		4: AP_URL - String - Access Point URL used in the install process.
			Current URL: "##########"
		5: $Install - Boolean - $True -> Install $False -> UnInstall

	Purpose:

	Example Call: powershell -file ""##########"" -Destination_IP ""##########"" -Source_Path ""##########"" -Install_Name ""##########"" -Install_Exe ""##########"" -Install $False -AP_URL ""##########""
 
#>

param($Destination_IP,$Source_Path,$Install_Name,$Install_Exe,$AP_URL,$Install)

#Temp Logging#
$Log_Folder_Path = ""##########""
$fileToday = Get-Date -Format yyyy-MM-dd-HH-mm-ss
$Log_File = $fileToday.ToString() + "_Log.log"
$Log_Path = $Log_Folder_Path + $Log_File
New-Item -Path $Log_Path | Out-Null
#Temp Logging#


Function Check_Params()
{
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
	If( -Not (Test-Path $Source_Path) )
	{
		Log "Source Path could not be found"
		Exit
	}
	If($Install_Name -eq $NULL)
	{
		Log "Install Name Variable is NULL"
		Exit
	}
	If($Install_Exe -eq $Null)
	{
		Log "Install_Exe is Null and cannot be."
		Exit
	}
	If($AP_URL -eq $Null)
	{
		Log "AP_URL is Null and cannot be"
	}
	If($Install -eq $True)
	{
		Return "Install"
	}
	Elseif($Install -eq $False)
	{
		Return "Uninstall"
	}
	Else
	{
		Log "The Install Variable was no Boolean"
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
        $Destination_Path = ("\\" + $Destination_IP + "\C$\Temp")
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
        Log "Building Arugment List"
        $Argument_List = '/UA=' + $AP_URL + ' /S /v/qn'
        #Start-Process -FilePath "C:\Temp\CamAgent\setup.exe" -ArgumentList '/UA="##########" /S /v/qn'
        Log "Running the Executable on the destination server"
        Invoke-Command -Session $Install_Session {Start-Process -FilePath $args[0] -ArgumentList $args[1]} -ArgumentList $Executable_Path $Arugment_List
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