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

$Employee_Data_Path = "$PSScriptRoot\Historical Data\2022\Data\Employee_Configs.json"

$Runoff_Data = "###########"
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

<# Function Declarations #>



<# Main Program Start #>

$Data = Pull_Employee_Record_Data
$First = ""
$First_Shouts = 0
$Second = ""
$Second_Shouts = 0
$Third = ""
$Third_Shouts = 0

$Overall_Shouts = 0
$Total_People = 0

$Total_Level1 = 0
$Total_Level2 = 0
$Total_Level3 = 0

Foreach($User in $Data)
{
	$Level1 = $False
	$Level2 = $False
	$Level3 = $False
	
	$GUID = $User.GUID
	$Total_Shouts = $User.Number_Of_Shouts
	$Overall_Shouts += $Total_Shouts
	$Total_People++
	
	If(($Total_Shouts -ge 12) -AND ($Total_Shouts -lt 24))
	{
		$Level1 = $True
		#$Data = "GUID: " + $GUID + " Shouts: " + $Total_Shouts + "Level 1"
		$Total_Level1++
	}
	ElseIf(($Total_Shouts -ge 24) -And ($Total_Shouts -lt 52))
	{
		$Level1 = $True
		$Level2 = $True
		#$Data = "GUID: " + $GUID + " Shouts: " + $Total_Shouts + "Level 2"
		$Total_Level2++
	}
	ElseIf(($Total_Shouts -ge 52))
	{
		$Level1 = $True
		$Level2 = $True
		$Level3 = $True
		#$Data = "GUID: " + $GUID + " Shouts: " + $Total_Shouts + "Level 3"
		$Total_Level3++
	}
	
	If($Total_Shouts -gt $First_Shouts)
	{
		$Third_Shouts = $Second_Shouts
		$Third = $Second
		$Second_Shouts = $First_Shouts
		$Second = $First
		$First_Shouts = $Total_Shouts
		$First = $GUID
	}
	ElseIf($Total_Shouts -eq $First_Shouts)
	{
		$First += (", " + $GUID)
	}
	ElseIf($Total_Shouts -gt $Second_Shouts)
	{
		$Third_Shouts = $Second_Shouts
		$Third = $Second
		$Second_Shouts = $Total_Shouts
		$Second = $GUID
	}
	ElseIf($Total_Shouts -eq $Second_Shouts)
	{
		$Second += (", " + $GUID)
	}
	ElseIf($Total_Shouts -gt $Third_Shouts)
	{
		$Third_Shouts = $Total_Shouts
		$Third = $GUID
	}
	ElseIf($Total_Shouts -eq $Third_Shouts)
	{
		$Third += (", " + $GUID)
	}
	
}

Write-Host ("First Place: " + $First)
Write-Host ("# Of Shouts: " + $First_Shouts)
Write-Host ("First Place: " + $Second)
Write-Host ("# Of Shouts: " + $Second_Shouts)
Write-Host ("First Place: " + $Third)
Write-Host ("# Of Shouts: " + $Third_Shouts)
Write-Host ("Total Level 1: " + $Total_Level1)
Write-Host ("Total Level 2: " + $Total_Level2)
Write-Host ("Total Level 3: " + $Total_Level3)
Write-Host ("Total # Of Shouts: " + $Overall_Shouts)
Write-Host ("Total # Of Participants: " + $Total_People)

<# Main Program End #>



