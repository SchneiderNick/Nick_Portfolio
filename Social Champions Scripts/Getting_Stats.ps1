<#
Template Made By Nicholas Schneider
#>

<#
Author: Nicholas Schneider
Date: 2/4/2020
Purpose: Give some stats on Shout outs
#>

<# Global Variables #> 

# Declare all variables from templates in here

$Employee_Data_Path = "$PSScriptRoot\###########"

$Shout_Out_Tracker_Path = "$PSScriptRoot\###########"

$Sheet_Name = "Shout_Out_Data"
<# Global Variables #>


<# Function Declarations #>

# Paste all function delcarations into this section

Function Pull_Employee_Record_Data()
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
Function Pull_Shout_Out_Data()
{
	$Local_Shout_Out_Data = @()

	$objExcel = New-Object -ComObject Excel.Application
	$objExcel.Visible = $false
	$Work_Book = $objExcel.Workbooks.Open($Shout_Out_Tracker_Path)
	$Work_Sheet = $Work_Book.sheets.item($Sheet_Name)
	$Used_Range = $Work_Sheet.usedrange
	ForEach($Row in ($Used_Range.Rows | Select -skip 1))
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


	Return $Local_Shout_Out_Data

}
<# Function Declarations #>



<# Main Program Start #>

$Data = Pull_Employee_Record_Data
$Shout_Out_Data = Pull_Shout_Out_Data

$Data_Dict = @{}
$Data_Dict["Top_3_Employees"] = @{"Employee_1"=@{"GUID"="###########";"Shout_Outs"=0};"Employee_2"=@{"GUID"="###########";"Shout_Outs"=0};"Employee_3"=@{"GUID"="###########";"Shout_Outs"=0}}

For($i = 1; $i -lt 13; $i++)
{
	$Month = ([cultureinfo]::InvariantCulture).DateTimeFormat.GetMonthName($i)
	$Data_Dict["Monthly_Stats"] += @{"$Month"=@{"Shout_Outs"=0;"Employees"=0;"Delta_Shouts"=0;"Delta_Employees"=0}}
	$Unique_Employees = @()
	Foreach($Shout_Out in $Shout_Out_Data)
	{
		$Temp_Month = ([cultureinfo]::InvariantCulture).DateTimeFormat.GetMonthName([datetime]::FromOADate($Shout_Out.Date).Month)
		If($Month -eq $Temp_Month)
		{
			$Data_Dict["Monthly_Stats"][$Month]["Shout_Outs"] += 1
			If(-Not ($Unique_Employees -Contains $Shout_Out.From_GUID))
			{
				$Data_Dict["Monthly_Stats"][$Month]["Employees"] += 1
				$Unique_Employees += $Shout_Out.From_GUID
			}
		}
	}
	$Data_Dict["Monthly_Stats"][$Month]["Employees"] = $Unique_Employees.Count
	If($i -gt 1)
	{
		$Previous_Month = ([cultureinfo]::InvariantCulture).DateTimeFormat.GetMonthName($i - 1)
		$Data_Dict["Monthly_Stats"][$Month]["Delta_Shouts"] = ($Data_Dict["Monthly_Stats"][$Month]["Shout_Outs"] - $Data_Dict["Monthly_Stats"][$Previous_Month]["Shout_Outs"])
		$Data_Dict["Monthly_Stats"][$Month]["Delta_Employees"] = ($Data_Dict["Monthly_Stats"][$Month]["Employees"] - $Data_Dict["Monthly_Stats"][$Previous_Month]["Employees"])
	}
}

$Total_Shouts = 0
$Total_Emails_Sent = 0
#Find Top 3 Shouters

Foreach($Employee in $Data)
{
	If($Employee.Number_Of_Shouts -gt $Data_Dict["Top_3_Employees"]["Employee_1"]["Shout_Outs"])
	{
		$Data_Dict["Top_3_Employees"]["Employee_3"]["Shout_Outs"] = $Data_Dict["Top_3_Employees"]["Employee_2"]["Shout_Outs"]
		$Data_Dict["Top_3_Employees"]["Employee_3"]["GUID"] = $Data_Dict["Top_3_Employees"]["Employee_2"]["GUID"]
		$Data_Dict["Top_3_Employees"]["Employee_2"]["Shout_Outs"] = $Data_Dict["Top_3_Employees"]["Employee_1"]["Shout_Outs"]
		$Data_Dict["Top_3_Employees"]["Employee_2"]["GUID"] = $Data_Dict["Top_3_Employees"]["Employee_1"]["GUID"]
		$Data_Dict["Top_3_Employees"]["Employee_1"]["Shout_Outs"] = $Employee.Number_Of_Shouts
		$Data_Dict["Top_3_Employees"]["Employee_1"]["GUID"] = $Employee.GUID
	}
	ElseIf($Employee.Number_Of_Shouts -gt $Data_Dict["Top_3_Employees"]["Employee_2"]["Shout_Outs"])
	{
		$Data_Dict["Top_3_Employees"]["Employee_3"]["Shout_Outs"] = $Data_Dict["Top_3_Employees"]["Employee_2"]["Shout_Outs"]
		$Data_Dict["Top_3_Employees"]["Employee_3"]["GUID"] = $Data_Dict["Top_3_Employees"]["Employee_2"]["GUID"]
		$Data_Dict["Top_3_Employees"]["Employee_2"]["Shout_Outs"] = $Employee.Number_Of_Shouts
		$Data_Dict["Top_3_Employees"]["Employee_2"]["GUID"] = $Employee.GUID
	}
	ElseIf($Employee.Number_Of_Shouts -gt $Data_Dict["Top_3_Employees"]["Employee_3"]["Shout_Outs"])
	{
		$Data_Dict["Top_3_Employees"]["Employee_3"]["Shout_Outs"] = $Employee.Number_Of_Shouts
		$Data_Dict["Top_3_Employees"]["Employee_3"]["GUID"] = $Employee.GUID

	}
	$Total_Shouts += $Employee.Number_Of_Shouts
	
	If($Employee.Sent_12_Mail -eq $True)
	{
		$Total_Emails_Sent++
	}
	If($Employee.Sent_24_Mail -eq $True)
	{
		$Total_Emails_Sent++
	}
	If($Employee.Sent_52_Mail -eq $True)
	{
		$Total_Emails_Sent++
	}
	If($Employee.Sent_100_Mail -eq $True)
	{
		$Total_Emails_Sent++
	}
	
}

Write-Host "Year To Date Stats"

Write-Host ("#1 Employee: " + $Data_Dict["Top_3_Employees"]["Employee_1"]["GUID"])
Write-Host ("# Of Shouts: " + $Data_Dict["Top_3_Employees"]["Employee_1"]["Shout_Outs"])
Write-Host ("#2 Employee: " + $Data_Dict["Top_3_Employees"]["Employee_2"]["GUID"])
Write-Host ("# Of Shouts: " + $Data_Dict["Top_3_Employees"]["Employee_2"]["Shout_Outs"])
Write-Host ("#3 Employee: " + $Data_Dict["Top_3_Employees"]["Employee_3"]["GUID"])
Write-Host ("# Of Shouts: " + $Data_Dict["Top_3_Employees"]["Employee_3"]["Shout_Outs"])

Write-Host ("Total # Of Shouts (Year to Date): " + $Total_Shouts)

Write-Host ("Total # Of Emails Sent: " + $Total_Emails_Sent)

Write-Host ("Total # Of Employees to Give Shout Outs: " + $Data.Count)

Write-Host "Month to Month Stats"

For($i = 1; $i -lt 13; $i++)
{
	$Month = ([cultureinfo]::InvariantCulture).DateTimeFormat.GetMonthName($i)
	
	If($Data_Dict["Monthly_Stats"][$Month]["Shout_Outs"] -gt 0)
	{
		Write-Host "Stats for $Month"
		
		Write-Host ("Total Number of Shouts: " + $Data_Dict["Monthly_Stats"][$Month]["Shout_Outs"])
		Write-Host ("Total Number of Unique Employees: " + $Data_Dict["Monthly_Stats"][$Month]["Employees"])
		If($i -gt 1)
		{
			$Previous_Month = ([cultureinfo]::InvariantCulture).DateTimeFormat.GetMonthName($i - 1)
			Write-Host ("Change in Total Shouts from " + $Previous_Month + " To " + $Month + ": " + $Data_Dict["Monthly_Stats"][$Month]["Delta_Shouts"])
			Write-Host ("Change in Total Employees from " + $Previous_Month + " To " + $Month + ": " + $Data_Dict["Monthly_Stats"][$Month]["Delta_Employees"])
		}
	}
}

<# Main Program End #>



