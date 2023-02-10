#Author: Nicholas Schneider
#Date: 03/30/2020

Import-Module -Name "$PSScriptRoot\SCJ_PowerShell_Module_DEV\SCJ_PowerShell_Module.psm1"

## Email Info ##
$From = "####################"
$To = @("####################","####################","####################","####################","####################","####################","####################","####################","####################","####################","####################","####################","####################","####################")
$Subject = "Hourly VPN and Circuits Utilization"
$CC = @("####################","####################","####################","####################")
$Server = "####################"

## Error email Info ##
$To_Error = @("####################","####################")
$CC_Error =  @("####################")

## Uncomment for Testing ##
<#
$To = @("####################")
$CC = "####################"
$To_Error = @("####################")
$CC_Error =  @("####################")
#>
## Uncomment for Testing ##

$Body_Error = '<html>'`
+ '<body>'`
+ "<p>Hello All,</p>"`
+ "<p>Looks like the format of the document is throwing an error. Please fix it and reupload to the folder</p>"`
+ "<p>Thanks,</p>"`
+ "<p>Network Automation</p>"`
+ "<p><b>**This is an auto-generated email. If you have any questions about the message you are receiving, please contact Nicholas Schneider ( #################### ) (Call #################### if after 3:30 PM CST)**</b></p>"

 

## Email Info ##
Function Check_Circuit_Color([int]$val1,[int]$val2,[int]$val3)
{
	$Temp_High_Val = $Val1
	If($Val2 -gt $Temp_High_Val)
	{
		$Temp_High_Val = $Val2
	}
	If($Val3 -gt $Temp_High_Val)
	{
		$Temp_High_Val = $Val3
	}
	
	If($Temp_High_Val -ge 90)
	{
		$Color = "Red"
	}
	ElseIf($Temp_High_Val -ge 70)
	{
		$Color = "Orange"
	}
	Else
	{
		$Color = "Black"
	}
	Return $Color
}
Function Check_VPN_Color([int]$val1)
{
	If($val1 -ge 90)
	{
		$Color = "Red"
	}
	ElseIf($val1 -ge 70)
	{
		$Color = "Orange"
	}
	Else
	{
		$Color = "Black"
	}
	Return $Color
}
Function Check_File()
{
	
	$File_Path = "####################"
	#Get-SCJFolderExists $File_Path -Path $File_Path -Create "yes"
	
	$Files = Get-Childitem $File_Path | Where-Object {-Not $_.Name.Contains("PlaceHolder.txt")}	
	
	$Time = (((Get-Date | Out-String).Split(" ")[4]).Split(":"))[0]
	$Time_String = (((Get-Date | Out-String).Split(" ")[5]))[0] + 'M'
	$Formatted_Time_String = $Time + $Time_String
	$Next_Time = ((((Get-Date).AddHours(1) | Out-String).Split(" ")[4]).Split(":"))[0]
	$Next_Time_String = ((((Get-Date).AddHours(1) | Out-String).Split(" ")[5]))[0] + 'M'
	$Formatted_Next_Time_String = $Next_Time + $Next_Time_String
	
	
	
	
	If($Files.Count -gt 0)
	{
		$Single_File_Path = $Files.FullName
		
		$Child_Path = "VPN_Circuit_Util_" + [string](((Get-Date -Format yyyy-MM-dd-hh-mm)).Replace("`n",""))  + "_"  + $Formatted_Time_String + ".xlsx"
		
		$Path = "####################\" + $Child_Path
		
		Copy-Item -Path $Single_File_Path -Destination $Path
		
		Remove-Item -Path $Single_File_Path
				
		$objExcel = New-Object -ComObject Excel.Application
		$objExcel.Visible = $True #$false
		$Work_Book = $objExcel.workbooks.open($Path)
		
		$APAC_Used_Range = ($Work_Book.sheets.item("####################")).usedrange
		$EMEA_Used_Range = ($Work_Book.sheets.item("####################")).usedrange
		$NA_Used_Range = ($Work_Book.sheets.item("####################")).usedrange
		
		$APAC_Row_Count = ($APAC_Used_Range.Rows).Count
		$EMEA_Row_Count = ($EMEA_Used_Range.Rows).Count
		$NA_Row_Count = ($NA_Used_Range.Rows).Count


		For($i = $APAC_Row_Count; $i -gt 0; $i--)
		{
			If(($APAC_Used_Range.Rows)[$i].Value2[1,1] -ne $NULL)
			{
				$APAC_Row_Count = $i
				Break
			}
		}
		For($i = $EMEA_Row_Count; $i -gt 0; $i--)
		{
			If(($EMEA_Used_Range.Rows)[$i].Value2[1,1] -ne $NULL)
			{
				$EMEA_Row_Count = $i
				Break
			}
		}
		For($i = $NA_Row_Count; $i -gt 0; $i--)
		{
			If(($NA_Used_Range.Rows)[$i].Value2[1,1] -ne $NULL)
			{
				$NA_Row_Count = $i
				Break
			}
		}
		
		$APAC_Data = ($APAC_Used_Range.Rows)[$APAC_Row_Count - 1].Value2
		$China_Data = ($APAC_Used_Range.Rows)[$APAC_Row_Count].Value2
		$EMEA_Data_1 = ($EMEA_Used_Range.Rows)[$EMEA_Row_Count - 1].Value2
		$EMEA_Data_2 = ($EMEA_Used_Range.Rows)[$EMEA_Row_Count].Value2
		$NA_Data_1 = ($NA_Used_Range.Rows)[$NA_Row_Count - 1].Value2
		$NA_Data_2 = ($NA_Used_Range.Rows)[$NA_Row_Count].Value2
		
		
		## Check if v4 or V6
		$V6_Check = $False
		If($APAC_Data[1,13] -ne $Null)
		{
			$V6_Check = $True
		}
		
		
		$Temp_Data = [string](($APAC_Data[1,3].Split("/")[1]) + "/" + ($APAC_Data[1,3].Split("/")[0]))
		$Temp_Percent = [string]([Math]::Round(([int]$Temp_Data.Split("/")[0] / [int]$Temp_Data.Split("/")[1] * 100 + .005),2)) + "%"
		$APAC_VPN_Color = Check_VPN_Color ([Math]::Round(([int]$Temp_Data.Split("/")[0] / [int]$Temp_Data.Split("/")[1] * 100 + .005),2))
		$APAC_VPN_Data = @(($Temp_Data),($Temp_Percent),$APAC_VPN_Color)
		If($V6_Check)
		{
			$APAC_VPN_ST = [string]$APAC_Data[1,4]
			$APAC_VPN_Data = @(($Temp_Data),($Temp_Percent),$APAC_VPN_Color,$APAC_VPN_ST)
		}
		
		$Temp_Data = [string](($China_Data[1,3].Split("/")[1]) + "/" + ($China_Data[1,3].Split("/")[0]))
		$Temp_Percent = [string]([Math]::Round(([int]$Temp_Data.Split("/")[0] / [int]$Temp_Data.Split("/")[1] * 100 + .005),2)) + "%"
		$China_VPN_Color = Check_VPN_Color ([Math]::Round(([int]$Temp_Data.Split("/")[0] / [int]$Temp_Data.Split("/")[1] * 100 + .005),2))
		$China_VPN_Data = @(($Temp_Data),($Temp_Percent),$China_VPN_Color)
		If($V6_Check)
		{
			$China_VPN_ST = [string]$China_Data[1,4]
			$China_VPN_Data = @(($Temp_Data),($Temp_Percent),$China_VPN_Color,$China_VPN_ST)
		}
		
		$Temp_Data = [string]([int]($EMEA_Data_1[1,3].Split("/")[1]) + [int]($EMEA_Data_2[1,3].Split("/")[1])) + "/" + [string]([int]($EMEA_Data_1[1,3].Split("/")[0]) + [int]($EMEA_Data_2[1,3].Split("/")[0]))
		$Temp_Percent = [string]([Math]::Round(([int]$Temp_Data.Split("/")[0] / [int]$Temp_Data.Split("/")[1] * 100 + .005),2)) + "%"
		$EMEA_VPN_Color = Check_VPN_Color ([Math]::Round(([int]$Temp_Data.Split("/")[0] / [int]$Temp_Data.Split("/")[1] * 100 + .005),2))
		$EMEA_VPN_Data = @(($Temp_Data),($Temp_Percent),$EMEA_VPN_Color)
		If($V6_Check)
		{
			$EMEA_VPN_ST_1 = [string]$EMEA_Data_1[1,4]
			$EMEA_VPN_ST_2 = [string]$EMEA_Data_2[1,4]
			$EMEA_VPN_Data = @(($Temp_Data),($Temp_Percent),$EMEA_VPN_Color,$EMEA_VPN_ST_1,$EMEA_VPN_ST_2)
		}
		
		$Temp_Data = [string]([int]($NA_Data_1[1,3].Split("/")[1]) + [int]($NA_Data_2[1,3].Split("/")[1])) + "/" + [string]([int]($NA_Data_1[1,3].Split("/")[0]) + [int]($NA_Data_2[1,3].Split("/")[0]))
		$Temp_Percent = [string]([Math]::Round(([int]$Temp_Data.Split("/")[0] / [int]$Temp_Data.Split("/")[1] * 100 + .005),2)) + "%"
		$NA_VPN_Color = Check_VPN_Color ([Math]::Round(([int]$Temp_Data.Split("/")[0] / [int]$Temp_Data.Split("/")[1] * 100 + .005),2))
		$NA_VPN_Data = @(($Temp_Data),($Temp_Percent),$NA_VPN_Color)
		If($V6_Check)
		{
			$NA_VPN_ST_1 = [string]$NA_Data_1[1,4]
			$NA_VPN_ST_2 = [string]$NA_Data_2[1,4]
			$NA_VPN_Data = @(($Temp_Data),($Temp_Percent),$NA_VPN_Color,$NA_VPN_ST_1,$NA_VPN_ST_2)
		}

		
		$Temp_Data = @([int]$APAC_Data[1,4],[int]$APAC_Data[1,5],[int]$APAC_Data[1,7],[int]$APAC_Data[1,8],[int]$APAC_Data[1,10],[int]$APAC_Data[1,11])
		If($V6_Check)
		{
			$Temp_Data = @([int]$APAC_Data[1,5],[int]$APAC_Data[1,6],[int]$APAC_Data[1,8],[int]$APAC_Data[1,9],[int]$APAC_Data[1,11],[int]$APAC_Data[1,12])
		}
		
		$APAC_Internet_Peak = $Temp_Data[0]
		If($Temp_Data[1] -gt $Temp_Data[0])
		{
			$APAC_Internet_Peak = $Temp_Data[1]
		}
		$APAC_Primary_Peak = $Temp_Data[2]
		If($Temp_Data[3] -gt $Temp_Data[2])
		{
			$APAC_Primary_Peak = $Temp_Data[3]
		}
		$APAC_Secondary_Peak = $Temp_Data[4]
		If($Temp_Data[5] -gt $Temp_Data[4])
		{
			$APAC_Secondary_Peak = $Temp_Data[5]
		}
		
		$Temp_Data = @([int]$China_Data[1,4],[int]$China_Data[1,5],[int]$China_Data[1,7],[int]$China_Data[1,8],[int]$China_Data[1,10],[int]$China_Data[1,11])
		If($V6_Check)
		{
			$Temp_Data = @([int]$China_Data[1,5],[int]$China_Data[1,6],[int]$China_Data[1,8],[int]$China_Data[1,9],[int]$China_Data[1,11],[int]$China_Data[1,12])
		}
		
		$China_Internet_Peak = $Temp_Data[0]
		If($Temp_Data[1] -gt $Temp_Data[0])
		{
			$China_Internet_Peak = $Temp_Data[1]
		}
		$China_Primary_Peak = $Temp_Data[2]
		If($Temp_Data[3] -gt $Temp_Data[2])
		{
			$China_Primary_Peak = $Temp_Data[3]
		}
		$China_Secondary_Peak = $Temp_Data[4]
		If($Temp_Data[5] -gt $Temp_Data[4])
		{
			$China_Secondary_Peak = $Temp_Data[5]
		}
		
		$Temp_Data = @([int]$EMEA_Data_1[1,4],[int]$EMEA_Data_1[1,5],[int]$EMEA_Data_2[1,4],[int]$EMEA_Data_2[1,5],[int]$EMEA_Data_1[1,7],[int]$EMEA_Data_1[1,8],[int]$EMEA_Data_1[1,10],[int]$EMEA_Data_1[1,11])
		If($V6_Check)
		{
			$Temp_Data = @([int]$EMEA_Data_1[1,5],[int]$EMEA_Data_1[1,6],[int]$EMEA_Data_2[1,5],[int]$EMEA_Data_2[1,6],[int]$EMEA_Data_1[1,8],[int]$EMEA_Data_1[1,9],[int]$EMEA_Data_1[1,11],[int]$EMEA_Data_1[1,12])
		}
		
		$Temp_Internet_Data = @($Temp_Data[0],$Temp_Data[1],$Temp_Data[2],$Temp_Data[3])
		$EMEA_Internet_Peak = 0
		Foreach($Value in $Temp_Internet_Data)
		{
			If($Value -gt $EMEA_Internet_Peak)
			{
				$EMEA_Internet_Peak = $Value
			}
		}
		$EMEA_Primary_Peak = $Temp_Data[4]
		If($Temp_Data[5] -gt $Temp_Data[4])
		{
			$EMEA_Primary_Peak = $Temp_Data[5]
		}
		$EMEA_Secondary_Peak = $Temp_Data[6]
		If($Temp_Data[7] -gt $Temp_Data[6])
		{
			$EMEA_Secondary_Peak = $Temp_Data[7]
		}

		$Temp_Data = @([int]$NA_Data_1[1,4],[int]$NA_Data_1[1,5],[int]$NA_Data_2[1,4],[int]$NA_Data_2[1,5],[int]$NA_Data_1[1,7],[int]$NA_Data_1[1,8],[int]$NA_Data_2[1,10],[int]$NA_Data_2[1,11])
		If($V6_Check)
		{
			$Temp_Data = @([int]$NA_Data_1[1,5],[int]$NA_Data_1[1,6],[int]$NA_Data_2[1,5],[int]$NA_Data_2[1,6],[int]$NA_Data_1[1,8],[int]$NA_Data_1[1,9],[int]$NA_Data_2[1,11],[int]$NA_Data_2[1,12])
		}
		
		$Temp_Internet_Data = @($Temp_Data[0],$Temp_Data[1],$Temp_Data[2],$Temp_Data[3])
		$NA_Internet_Peak = 0
		Foreach($Value in $Temp_Internet_Data)
		{
			If($Value -gt $NA_Internet_Peak)
			{
				$NA_Internet_Peak = $Value
			}
		}
		$NA_Primary_Peak = $Temp_Data[4]
		If($Temp_Data[5] -gt $Temp_Data[4])
		{
			$NA_Primary_Peak = $Temp_Data[5]
		}
		$NA_Secondary_Peak = $Temp_Data[6]
		If($Temp_Data[7] -gt $Temp_Data[6])
		{
			$NA_Secondary_Peak = $Temp_Data[7]
		}
		
		$APAC_Circuit_Color = Check_Circuit_Color $APAC_Internet_Peak $APAC_Primary_Peak $APAC_Secondary_Peak
		$China_Circuit_Color = Check_Circuit_Color $China_Internet_Peak $China_Primary_Peak $China_Secondary_Peak
		$EMEA_Circuit_Color = Check_Circuit_Color $EMEA_Internet_Peak $EMEA_Primary_Peak $EMEA_Secondary_Peak
		$NA_Circuit_Color = Check_Circuit_Color $NA_Internet_Peak $NA_Primary_Peak $NA_Secondary_Peak
		
		
		$Current_Time = $NA_Data_1[1,1] * 24
		If($Current_Time -gt 12)
		{
			$Current_Time = $Current_Time - 12
			If($Current_Time -eq 8)
			{
				$Next_Time = "12:00"
				$Current_AM_PM = "PM"
				$Next_AM_PM = "AM"
			}
			Else
			{
				$Next_Time = $Current_Time + 4
				$Current_AM_PM = $Next_AM_PM = "PM"
			}
		}
		Else
		{
			If($Current_Time -eq 8)
			{
				$Next_Time = "12:00"
				$Current_AM_PM = "AM"
				$Next_AM_PM = "PM"				
			}
			Else
			{
				$Next_Time = $Current_Time + 4
				$Current_AM_PM = $Next_AM_PM = "AM"
			}
		}
		
		$Work_Book.close()
		$objExcel.quit()
		$Modified_Path = "####################"
		$Modified_Child_Path = "VPN_Circuit_Util_" + [string](((Get-Date -Format yyyy-MM-dd)).Replace("`n","")) + "-" + [string]$Current_Time + "-" + [string](((Get-Date -Format mm)).Replace("`n","")) + "_" + [string]$Current_Time + $Current_AM_PM + ".xlsx"

		Copy-Item -Path $Path -Destination ($Modified_Path + $Modified_Child_Path)
		
		Remove-Item -Path $Path
		
		If($V6_Check -eq $False)
		{
			$Body = '<html>'`
			+ '<body>'`
			+ "<p>Hello All,</p>"`
			+ "<p>Attached is the hourly report for " + [string]$Current_Time + ":00 " + $Current_AM_PM + " Central. Next report will be sent at " + [string]$Next_Time + ":00 " + $Next_AM_PM + " Central.</p>"`
			+ "<p><b>SUMMARY:</b></p>"`
			+ "<p><b>&emsp;&emsp;VPN Utilization:</b></p>"`
			+ "<p><Font color = `"" + $APAC_VPN_Data[2] +  "`">&emsp;&emsp;&emsp;&emsp;Top Utilization at Manila VPN Gateway approx. <b>" + $APAC_VPN_Data[0] + " (approx. " + $APAC_VPN_Data[1] + ")</b></font></p>"`
			+ "<p><Font color = `"" + $China_VPN_Data[2] +  "`">&emsp;&emsp;&emsp;&emsp;Top Utilization at China VPN Gateway approx. <b>" + $China_VPN_Data[0] + " (approx. " + $China_VPN_Data[1] + ")</b></font></p>"`
			+ "<p><Font color = `"" + $EMEA_VPN_Data[2] +  "`">&emsp;&emsp;&emsp;&emsp;Top Utilization at Frimley VPN Gateway approx. <b>" + $EMEA_VPN_Data[0] + " (approx. " + $EMEA_VPN_Data[1] + ")</b></font></p>"`
			+ "<p><Font color = `"" + $NA_VPN_Data[2] +  "`">&emsp;&emsp;&emsp;&emsp;Top Utilization at NA VPN Gateway approx. <b>" + $NA_VPN_Data[0] + " (approx. " + $NA_VPN_Data[1] + ")</b></font></p>"`
			+ "<p><b>&emsp;&emsp;Circuit Utilization:</b></p>"`
			+ "<p><Font color = `"" + $APAC_Circuit_Color +  "`">&emsp;&emsp;&emsp;&emsp;Utilization on Internet <b>(" + $APAC_Internet_Peak + "%)</b>, Primary  MPLS of Manila <b>(" + $APAC_Primary_Peak + "%)</b>, and on Secondary  MPLS of Manila <b>(" + $APAC_Secondary_Peak + "%)</b> in the last hour.</font></p>"`
			+ "<p><Font color = `"" + $China_Circuit_Color +  "`">&emsp;&emsp;&emsp;&emsp;Utilization on Internet <b>(" + $China_Internet_Peak + "%)</b>, Primary  MPLS of China <b>(" + $China_Primary_Peak + "%)</b>, and on Secondary  MPLS of China <b>(" + $China_Secondary_Peak + "%)</b> in the last hour.</font></p>"`
			+ "<p><Font color = `"" + $EMEA_Circuit_Color +  "`">&emsp;&emsp;&emsp;&emsp;Utilization on Internet <b>(" + $EMEA_Internet_Peak + "%)</b>, Primary  MPLS of Frimley <b>(" + $EMEA_Primary_Peak + "%)</b>, and on Secondary  MPLS of Frimley <b>(" + $EMEA_Secondary_Peak + "%)</b> in the last hour.</font></p>"`
			+ "<p><Font color = `"" + $NA_Circuit_Color +  "`">&emsp;&emsp;&emsp;&emsp;Utilization on Internet <b>(" + $NA_Internet_Peak + "%)</b>, Primary  MPLS of NA <b>(" + $NA_Primary_Peak + "%)</b>, and on Secondary  MPLS of NA <b>(" + $NA_Secondary_Peak + "%)</b> in the last hour.</font></p>"`
			+ "<p>Thanks,</p>"`
			+ "<p>Network Automation</p>"`
			+ "<p><b>**This is an auto-generated email. If you have any questions about the message you are receiving, please contact Nicholas Schneider ( #################### ) (Call #################### if after 3:30 PM CST)**</b></p>"
		}
		If($V6_Check)
		{
			$Body = '<html>'`
			+ '<body>'`
			+ "<p>Hello All,</p>"`
			+ "<p>Attached is the hourly report for " + [string]$Current_Time + ":00 " + $Current_AM_PM + " Central. Next report will be sent at " + [string]$Next_Time + ":00 " + $Next_AM_PM + " Central.</p>"`
			+ "<p><b>SUMMARY:</b></p>"`
			+ "<p><b>&emsp;&emsp;VPN Utilization:</b></p>"`
			+ "<p><Font color = `"" + $APAC_VPN_Data[2] +  "`">&emsp;&emsp;&emsp;&emsp;Top Utilization at Manila VPN Gateway approx. <b>" + $APAC_VPN_Data[0] + " (approx. " + $APAC_VPN_Data[1] + ")</b></font></p>"`
			+ "<p><Font color = `"" + $China_VPN_Data[2] +  "`">&emsp;&emsp;&emsp;&emsp;Top Utilization at China VPN Gateway approx. <b>" + $China_VPN_Data[0] + " (approx. " + $China_VPN_Data[1] + ")</b></font></p>"`
			+ "<p><Font color = `"" + $EMEA_VPN_Data[2] +  "`">&emsp;&emsp;&emsp;&emsp;Top Utilization at Frimley VPN Gateway approx. <b>" + $EMEA_VPN_Data[0] + " (approx. " + $EMEA_VPN_Data[1] + ")</b></font></p>"`
			+ "<p><Font color = `"" + $NA_VPN_Data[2] +  "`">&emsp;&emsp;&emsp;&emsp;Top Utilization at NA VPN Gateway approx. <b>" + $NA_VPN_Data[0] + " (approx. " + $NA_VPN_Data[1] + ")</b></font></p>"`
			+ "<p><b>&emsp;&emsp;Split Tunnel VPN Utilization:</b></p>"`
			+ "<p>&emsp;&emsp;&emsp;&emsp;Top Utilization at Manila Split Tunnel VPN Gateway: <b>" + $APAC_VPN_Data[3] + "</b> Users</p>"`
			+ "<p>&emsp;&emsp;&emsp;&emsp;Top Utilization at China Split Tunnel VPN Gateway: <b>" + $China_VPN_Data[3] + "</b> Users</p>"`
			+ "<p>&emsp;&emsp;&emsp;&emsp;Top Utilization at Frimley Split Tunnel VPN Gateways: Frimley 1: <b>" + $EMEA_VPN_Data[3] + "</b> Users / Frimley 2: <b>" + $EMEA_VPN_Data[4] + "</b> Users</p>"`
			+ "<p>&emsp;&emsp;&emsp;&emsp;Top Utilization at NA Split Tunnel VPN Gateways: Racine: <b>" + $NA_VPN_Data[3] + " Users</b> / Waxdale: <b>" + $NA_VPN_Data[4] + "</b> Users</p>"`
			+ "<p><b>&emsp;&emsp;Circuit Utilization:</b></p>"`
			+ "<p><Font color = `"" + $APAC_Circuit_Color +  "`">&emsp;&emsp;&emsp;&emsp;Utilization on Internet <b>(" + $APAC_Internet_Peak + "%)</b>, Primary  MPLS of Manila <b>(" + $APAC_Primary_Peak + "%)</b>, and on Secondary  MPLS of Manila <b>(" + $APAC_Secondary_Peak + "%)</b> in the last hour.</font></p>"`
			+ "<p><Font color = `"" + $China_Circuit_Color +  "`">&emsp;&emsp;&emsp;&emsp;Utilization on Internet <b>(" + $China_Internet_Peak + "%)</b>, Primary  MPLS of China <b>(" + $China_Primary_Peak + "%)</b>, and on Secondary  MPLS of China <b>(" + $China_Secondary_Peak + "%)</b> in the last hour.</font></p>"`
			+ "<p><Font color = `"" + $EMEA_Circuit_Color +  "`">&emsp;&emsp;&emsp;&emsp;Utilization on Internet <b>(" + $EMEA_Internet_Peak + "%)</b>, Primary  MPLS of Frimley <b>(" + $EMEA_Primary_Peak + "%)</b>, and on Secondary  MPLS of Frimley <b>(" + $EMEA_Secondary_Peak + "%)</b> in the last hour.</font></p>"`
			+ "<p><Font color = `"" + $NA_Circuit_Color +  "`">&emsp;&emsp;&emsp;&emsp;Utilization on Internet <b>(" + $NA_Internet_Peak + "%)</b>, Primary  MPLS of NA <b>(" + $NA_Primary_Peak + "%)</b>, and on Secondary  MPLS of NA <b>(" + $NA_Secondary_Peak + "%)</b> in the last hour.</font></p>"`
			+ "<p>Thanks,</p>"`
			+ "<p>Network Automation</p>"`
			+ "<p><b>**This is an auto-generated email. If you have any questions about the message you are receiving, please contact Nicholas Schneider ( #################### ) (Call #################### if after 3:30 PM CST)**</b></p>"
		}
		Send-SCJEmail -Server $Server -From $From -To $To -Subject $Subject -Body $Body -CC $CC -BodyAsHTML $True -Attachments ($Modified_Path + $Modified_Child_Path)

		Remove-Item -Path ($Modified_Path + $Modified_Child_Path)
	}
}
While($True)
{
	for($i = 0; $i -lt 300; $i++)
	{
		try{Check_File}
		catch
		{
			Write-Host $Error
			Send-SCJEmail -Server $Server -From $From -To $To_Error -Subject $Subject -Body $Body_Error -CC $CC_Error -BodyAsHTML $True
		}
		Write-Host ("Pausing for 5 Minutes - " + [string](Get-Date))
		Sleep 300
	}
}
