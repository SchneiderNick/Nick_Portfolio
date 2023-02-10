<#
Template Made By Nicholas Schneider
#>

<#
Author: Nicholas Schneider
Date:
Purpose:
#>

<# Global Variables #> 

# Declare all variables from templates in here

$Employee_Data_Path = "$PSScriptRoot\Data\Employee_Configs.json"


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

Function Push_Hold_String()
{
	"Data Used By Other Script" > $Employee_Data_Path
}

Function Push_Employee_Record_Data($Employee_Config_Data)
{
	($Employee_Config_Data | ConvertTo-JSON) > $Employee_Data_Path
}

Function Analyze_Record_Data($Temp_Employee_Data)
{
	Foreach($Employee in $Temp_Employee_Data)
	{
		$Email_Address = Get_User_Email $Employee.GUID
		$Shouts_Over_Set = ($Employee.Number_Of_Shouts - (52 * $Employee.Confirmed_52))
		#$Employee_Level = ($Employee.Confirmed_52 * 3)
		If(($Shouts_Over_Set -ge 12) -And ($Employee.Sent_12_Mail -eq $False))
		{
			$Employee_Level = 1
			$Email_Subject = ("Congratulations! You have reached level " + $Employee_Level + "!")
			$Email_Body = '<html>'`
			+ '<body>'`
			+ "<p>Thank you for participating in the ########### program and showing your appreciation to those you work with! As part of the new Rewards and Recognition portion of this program, please select one item from the ########### merchandise store.</p>`n"`
			+ "<p>" + '<img src="cid:Image1.png">' +  '<img src="cid:Image2.png">' + '<img src="cid:Image3.png">' +"</p>`n"`
			+ "<p>" + '<img src="cid:Image4.png">' + '<img src="cid:Image5.png">' + '<img src="cid:Image6.png">' +"</p>`n"`
			+ "<p>Please reply to this email with the ID or Name of the item you would like to claim! ID's are listed below!</p>`n"`
			+ "<p>1 | Fingerprint Tote Bag - PlasticBank</p>"`
			+ "<p>2 | Ocean Bracelet - 4Ocean</p>"`
			+ "<p>3 | Reusable Water Bottle - 4Ocean</p>"`
			+ "<p>4 | Reusable Metal Straws - Hiware</p>"`
			+ "<p>5 | Compact SCJ Umbrella</p>"`
			+ "<p>6 | SCJ Hoodie</p>"`
			+ "<p>Please allow 3 working days for processing.</p>"`
			+ "<p>" + "We hope you will challenge yourself to continue acknowledging the good work and good deeds of your peers. Genuine expressions of appreciation have a deeper impact than you may realize. Informal ########### are personal and have amazing effects that develope an environment of camaraderie and fellowship throughout our department." + "</p>"`
			+ "<p>Keep ########### gratitude!</p>"`
			+ "<p>########### " + '<img src="cid:SCJLogo.png">' + "</p>"`
			+ "<p>Disclaimer | You have recieved this email as part of an automated email system. Replies are monitored; however, if you have received this email and do not think you should have, please forward it to ###########</p>`n"`
			+ "</body></html>"
			$Email_Attachments = @("$PSScriptRoot\Images\Image1.png","$PSScriptRoot\Images\Image2.png","$PSScriptRoot\Images\Image3.png","$PSScriptRoot\Images\Image4.png","$PSScriptRoot\Images\Image5.png","$PSScriptRoot\Images\Image6.png","$PSScriptRoot\Images\SCJLogo.png") #Add 6 Pictures! Plus Logo picture
			Send_Email $Email_Address $Email_Subject $Email_Body $Email_Attachments
			#Write-Host ("Would have Emailed: " + $Employee.GUID + " With Email Address: " + $Email_Address)
			$Employee.Sent_12_Mail = $True
		}
		If(($Shouts_Over_Set -ge 24) -And ($Employee.Sent_24_Mail -eq $False))
		{
			$Employee_Level = 2
			$Email_Subject = ("Congratulations! You have reached level " + $Employee_Level + "!")
			$Email_Body = '<html>'`
			+ '<body>'`
			+ "<p>Thank you for participating in the ########### program and showing your appreciation to those you work with! As part of the new Rewards and Recognition portion of this program, please select one item from the ########### merchandise store.</p>`n"`
			+ "<p>" + '<img src="cid:Image1.png">' +  '<img src="cid:Image2.png">' + '<img src="cid:Image3.png">' +"</p>`n"`
			+ "<p>" + '<img src="cid:Image4.png">' + '<img src="cid:Image5.png">' + '<img src="cid:Image6.png">' +"</p>`n"`
			+ "<p>Please reply to this email with the ID or Name of the item you would like to claim! ID's are listed below!</p>`n"`
			+ "<p>1 | Fingerprint Tote Bag - PlasticBank</p>"`
			+ "<p>2 | Ocean Bracelet - 4Ocean</p>"`
			+ "<p>3 | Reusable Water Bottle - 4Ocean</p>"`
			+ "<p>4 | Reusable Metal Straws - Hiware</p>"`
			+ "<p>5 | Compact SCJ Umbrella</p>"`
			+ "<p>6 | SCJ Hoodie</p>"`
			+ "<p>Please allow 3 working days for processing.</p>"`
			+ "<p>" + "We hope you will challenge yourself to continue acknowledging the good work and good deeds of your peers. Genuine expressions of appreciation have a deeper impact than you may realize. Informal ########### are personal and have amazing effects that develope an environment of camaraderie and fellowship throughout our department." + "</p>"`
			+ "<p>Keep SHOUTING gratitude!</p>"`
			+ "<p>GBS Social Champions " + '<img src="cid:SCJLogo.png">' + "</p>"`
			+ "<p>Disclaimer | You have recieved this email as part of an automated email system. Replies are monitored; however, if you have received this email and do not think you should have, please forward it to ###########</p>`n"`
			+ "</body></html>"
			$Email_Attachments = @("$PSScriptRoot\Images\Image1.png","$PSScriptRoot\Images\Image2.png","$PSScriptRoot\Images\Image3.png","$PSScriptRoot\Images\Image4.png","$PSScriptRoot\Images\Image5.png","$PSScriptRoot\Images\Image6.png","$PSScriptRoot\Images\SCJLogo.png") #Add 6 Pictures! Plus Logo picture
			Send_Email $Email_Address $Email_Subject $Email_Body $Email_Attachments
			#Write-Host ("Would have Emailed: " + $Employee.GUID + " With Email Address: " + $Email_Address)
			$Employee.Sent_24_Mail = $True
		}
		If(($Shouts_Over_Set -ge 52) -And ($Employee.Sent_52_Mail -eq $False))
		{
			$Employee_Level = 3
			$Email_Subject = ("Congratulations! You have reached level " + $Employee_Level + "!")
			$Email_Body = '<html>'`
			+ '<body>'`
			+ "<p>Thank you for participating in the ########### program and showing your appreciation to those you work with! As part of the new Rewards and Recognition portion of this program, please select one item from the ########### merchandise store.</p>`n"`
			+ "<p>" + '<img src="cid:Image1.png">' +  '<img src="cid:Image2.png">' + '<img src="cid:Image3.png">' +"</p>`n"`
			+ "<p>" + '<img src="cid:Image4.png">' + '<img src="cid:Image5.png">' + '<img src="cid:Image6.png">' +"</p>`n"`
			+ "<p>Please reply to this email with the ID or Name of the item you would like to claim! ID's are listed below!</p>`n"`
			+ "<p>1 | Fingerprint Tote Bag - PlasticBank</p>"`
			+ "<p>2 | Ocean Bracelet - 4Ocean</p>"`
			+ "<p>3 | Reusable Water Bottle - 4Ocean</p>"`
			+ "<p>4 | Reusable Metal Straws - Hiware</p>"`
			+ "<p>5 | Compact SCJ Umbrella</p>"`
			+ "<p>6 | SCJ Hoodie</p>"`
			+ "<p>Please allow 3 working days for processing.</p>"`
			+ "<p>" + "We hope you will challenge yourself to continue acknowledging the good work and good deeds of your peers. Genuine expressions of appreciation have a deeper impact than you may realize. Informal ########### are personal and have amazing effects that develope an environment of camaraderie and fellowship throughout our department." + "</p>"`
			+ "<p>Keep SHOUTING gratitude!</p>"`
			+ "<p>GBS Social Champions " + '<img src="cid:SCJLogo.png">' + "</p>"`
			+ "<p>Disclaimer | You have recieved this email as part of an automated email system. Replies are monitored; however, if you have received this email and do not think you should have, please forward it to ###########</p>`n"`
			+ "</body></html>"
			$Email_Attachments = @("$PSScriptRoot\Images\Image1.png","$PSScriptRoot\Images\Image2.png","$PSScriptRoot\Images\Image3.png","$PSScriptRoot\Images\Image4.png","$PSScriptRoot\Images\Image5.png","$PSScriptRoot\Images\Image6.png","$PSScriptRoot\Images\SCJLogo.png") #Add 6 Pictures! Plus Logo picture
			Send_Email $Email_Address $Email_Subject $Email_Body $Email_Attachments
			#Write-Host ("Would have Emailed: " + $Employee.GUID + " With Email Address: " + $Email_Address)
			$Employee.Sent_52_Mail = $True
			#$Employee.Confirmed_52 = ($Employee.Confirmed_52 + 1)
		}
		If(($Shouts_Over_Set -ge 100) -And ($Employee.Sent_100_Mail -eq $False))
		{
			$Email_Subject = "CONGRATULATIONS! You have reached SUPER STAR LEVEL!"
			$Email_Body = ""
			$Email_Attachments = @("$PSScriptRoot\Images\Image1.png","$PSScriptRoot\Images\Image2.png","$PSScriptRoot\Images\Image3.png","$PSScriptRoot\Images\Image4.png","$PSScriptRoot\Images\Image5.png","$PSScriptRoot\Images\Image6.png","$PSScriptRoot\Images\SCJLogo.png") #Add 6 Pictures! Plus Logo picture
			Send_Email $Email_Address $Email_Subject $Email_Body $Email_Attachments
			#Write-Host ("Would have Emailed: " + $Employee.GUID + " With Email Address: " + $Email_Address)
			$Employee.Sent_100_Mail = $True
		}
	}
	Return $Temp_Employee_Data
}

Function Get_User_Email($User_GUID)
{
	$User_Email = (Get-ADUser $User_GUID | Select UserPrincipalName).UserPrincipalName 
	
	Return $User_Email
}
Function Send_Email($To,[string]$Subject,[string]$Body,$Attachments)
{
	# Necessary Settings #
	$Msg = @{
    to          = $To
    from        = "###########"
	CC          = "###########"
	BCC         = "###########"
    Body        = $Body
    subject     = $Subject
    smtpserver  = "###########"
	Attachments = $Attachments
	BodyAsHtml  = $True
	}

	# Necessary Settings #
	Send-MailMessage @Msg
}
<# Function Declarations #>




<# Main Program Start #>

# Place all of the function calls, in order, into this section
# Note that functions can be called from within other functions, for instance a log function can be called from other functions
	## Pulls the employee record data ##
	$Employee_Record_Data = Pull_Employee_Record_Data
	# Pushes a hold string to the Employee Data file, so no other script pulls old data while running #
	Push_Hold_String
	## Analyzes the Record data and sends emails out accordingly, updates employee records ##
	$Updated_Employee_Data = Analyze_Record_Data $Employee_Record_Data
	## Pushes the employee data to the config file for use in other programs ##
	Push_Employee_Record_Data $Updated_Employee_Data
	
<# Main Program End #>



