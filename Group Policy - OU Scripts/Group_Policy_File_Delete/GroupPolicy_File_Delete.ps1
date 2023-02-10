<#
Template Made By Nicholas Schneider
#>

<#
Author: Nicholas Schneider
Date: 10/12/2022
Purpose: Replace Group Policy File using SCCM

Return Values:

1: Script Ran Successfully
2: File was not older than 3 days
3: Script couldnt update the file
4: File not found after update
5: Script errored out. 


#>

<# Global Variables #> 

# Declare all variables from templates in here

$GroupPolicy_FilePath = "C\Windows\System32\GroupPolicy\Machine\Registry.pol"





<# Global Variables #> 


<# Function Declarations #>

# Paste all function delcarations into this section

Function Check_File
{

	If(Test-Path -Path $GroupPolicy_FilePath -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)
	{
		$RegistryPol = Get-Childitem $GroupPolicy_FilePath
		If($RegistryPol.LastWriteTime -lt (Get-Date).AddDays(-3))
		{
			Remove-Item $RegistryPol
			
			gpupdate.exe /force
			
			If(Test-Path -Path $GroupPolicy_FilePath -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)
			{
				$RegistryPol = Get-Childitem $GroupPolicy_FilePath
				If($RegistryPol.LastWriteTime -lt (Get-Date).AddDays(-3))
				{
					Return 3 # Script Couldnt Update 
				}
				Else
				{
					Return 1 #Script Ran Successfully
				}
			}
			Else
			{
				Return 4 #File not found after gpupdate
			}
		}
		Else
		{
			Return 2 #File was not older than 3 days 
		}
	}
	Else
	{
		gpupdate.exe /force
		
		If(Test-Path -Path $GroupPolicy_FilePath -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)
		{
			If($RegistryPol.LastWriteTime -ge (Get-Date).AddDays(-3))
			{
				Return 2 #File initially not found, but gpupdate created it
			}
		}
		Return 4 #File not found after update
	}
}

<# Function Declarations #>




<# Main Program Start #>

# Place all of the function calls, in order, into this section
# Note that functions can be called from within other functions, for instance a log function can be called from other functions

try
{
	$Check_Value = $Check_File
	
	Return $Check_Value
}
Catch
{
	Return 5 #Script Errored Out
}

<# Main Program End #>

