<#
Template Made By Nicholas Schneider
#>

<#
Author: Nicholas Schneider
Date: 2/15/2019
Purpose: Clean up the GDE folder on users desktops, to delete folders older than 7 days. Pushed by SCCM
#>

<# Global Variables #> 

# Declare all variables from templates in here

$today = (Get-Date)
$previousWeek = (Get-Date).AddDays(-7)

$GDE_Folder = "####################"

<# Global Variables #> 

<# Function Declarations #>

# Paste all function delcarations into this section

Function Delete_Folder([string]$path)
{
	Remove-Item -Path $path -Recurse
}
<# Function Declarations #>

<# Main Program Start #>

# Place all of the function calls, in order, into this section
# Note that functions can be called from within other functions, for instance a log function can be called from other functions

Foreach($item in (Get-ChildItem -Path $GDE_Folder | Where-Object {$_.CreationTime -le $previousWeek}))
{
	Delete_Folder ($GDE_Folder + "\" + $item.Name)
}

<# Main Program End #>

