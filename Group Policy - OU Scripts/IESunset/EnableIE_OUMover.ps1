## Reading list of computers from csv and loading into variable
$DropBox = "###########"
$Temp_Folder = "###########"
$LogFolder = "###########"
## Defining Target Path
$TargetOU = "OU=###########,OU=###########,OU=###########,OU=###########,DC=###########,DC=###########,DC=###########" 
$Date_Format = (Get-Date -Format yyyy-MM-dd-HH-mm-ss).tostring()

$New_Lists = Get-ChildItem $DropBox

Foreach($List_Item in $New_Lists)
{
	$Temp_Name = $List_Item.Name
	$Temp_Name_N_Ext = ($Temp_Name.split("."))[0]
	If(($Temp_Name.split("."))[1] -eq "txt")
	{
		Move-Item -Path ($DropBox + $Temp_Name) -Destination $Temp_Folder
		New-Item -Type File -Path ($LogFolder + $Date_Format + "-" + $Temp_Name_N_Ext + ".log")
	}
	
}

$Temp_Lists = Get-ChildItem $Temp_Folder

Foreach($Temp_List in $Temp_Lists)
{
	## Grab Custom Log File ##
	$Current_Log_Path = $LogFolder + $Date_Format + "-" + (($Temp_List.Name).Split(".")[0]) + ".log"
	## Grab Custom Log File ##
	$List_Content = Get-Content $Temp_List.FullName
	$Total_Computers = $List_Content.Count
	$Moved_Computers = 0
	Foreach($Computer in $List_Content)
	{
		$CleanComputer = $Computer -Replace "[^a-zA-Z0-9]"
		("Attempting to add $CleanComputer to the Activate IE11") >> $Current_Log_Path
		try
		{
			Get-ADComputer $CleanComputer | Move-ADObject -TargetPath $TargetOU
			$Moved_Computers++
			("Added $CleanComputer") >> $Current_Log_Path
		}
		Catch
		{
			("Failed to add $CleanComputer") >> $Current_Log_Path
		}
	}
	("Moved: $Moved_Computers / $Total_Computers Computers") >> $Current_Log_Path
	Remove-Item -Path $Temp_List.FullName
}


