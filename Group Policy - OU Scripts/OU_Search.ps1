<#

How to use:

1) Create a CSV file named whatever you want (RandomName.csv)
	a) Change the File_Name variable to the name of the file you added to the root folder
	b) Open powershell and copy the below
		i) powershell -file "D:\EUC_Prod_Scripts\Tim_Prod\OU_Shizz\OU_Search.ps1"

2) Modify Computer_List.csv and remove all data except the headers (Computer / Folder)
	a) Add your data to the computer column and run the script
	b) Open powershell and copy the below
		i) powershell -file "D:\EUC_Prod_Scripts\Tim_Prod\OU_Shizz\OU_Search.ps1"

#>
$File_Name = "Computer_List"
$File_Path = "$PSScriptRoot\" + $File_Name + ".csv"

$Computer_List = Import-CSV -Path $File_Path

Foreach($Computer in $Computer_List)
{
	Try{
		$Temp_Comp = (Get-ADComputer $Computer.Computer | Select DistinguishedName)
		$Computer.Folder = ($Temp_Comp.DistinguishedName).Split(",")[1].Replace("OU=","")
	}
	Catch
	{
		$Computer.Folder = "Not in AD"
	}
	
}

$Computer_List | Export-CSV -path $File_Path


