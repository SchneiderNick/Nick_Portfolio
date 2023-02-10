## This File is part of the IP_DNS_PRovision_Application ##

<#

## Author   : Nicholas Schneider
## File #   : 
## Owner    : 
## Type     :

## Comments :

#>

<# Start Of Function #>
## Begin Form Setup Functions ##

Function Create_Form()
{
	param(
	[Parameter(Mandatory=$False)][string]$Text = 'Host Name Generation',
	[Parameter(Mandatory=$False)][int]$Width = 600,
	[Parameter(Mandatory=$False)][int]$Height = 400 + 39,
	[Parameter(Mandatory=$False)][boolean]$AutoSize = $true,
	[Parameter(Mandatory=$False)][string]$StartPosition = "CenterScreen",
	[Parameter(Mandatory=$False)][string]$BackColor = "#282828",
	[Parameter(Mandatory=$False)][boolean]$TopMost = $True,
	[Parameter(Mandatory=$False)][boolean]$AddLogo = $False
	)
	
	$Form_Object = New-Object System.Windows.Forms.Form
	$Form_Object.Text = $Text
	$Form_Object.Width = $Width
	$Form_Object.Height = $Height
	$Form_Object.AutoSize = $AutoSize
	$Form_Object.StartPosition = $StartPosition
	$Form_Object.BackColor = $BackColor
	$Form_Object.Topmost = $Topmost
	
	If(-Not $AddLogo)
	{
		$Image_Object = Create_Image -Image_Location ($Script_Path + "\Images\scj_logo_New.png") -Location_Width 10 -Location_Height 300 -Size_Width 150 -Size_Height 100 
		$Form_Object.Controls.AddRange(@($Image_Object))
	}
	
	Return $Form_Object
}

Function Create_Button()
{
	param(
	[Parameter(Mandatory=$True)][string]$Text,
	[Parameter(Mandatory=$True)][int]$Location_Width,
	[Parameter(Mandatory=$True)][int]$Location_Height,
	[Parameter(Mandatory=$True)][int]$Size_Width,
	[Parameter(Mandatory=$True)][int]$Size_Height,
	[Parameter(Mandatory=$False)][string]$BackColor = "#808080",
	[Parameter(Mandatory=$False)][string]$ForeColor = "#ffffff"
	)
	$Button_Object = New-Object System.Windows.Forms.Button
	$Button_Object.Text = $text
    $Button_Object.Location = New-Object System.Drawing.Size($Location_Width,$Location_Height)
    $Button_Object.Size = New-Object System.Drawing.Size($Size_Width,$Size_Height)
	$Button_Object.BackColor = $BackColor
	$Button_Object.ForeColor = $ForeColor
	
	
	Return $Button_Object
}
	
Function Create_Text_Box()
{
	param(
	[Parameter(Mandatory=$True)][int]$Location_Width,
	[Parameter(Mandatory=$True)][int]$Location_Height,
	[Parameter(Mandatory=$True)][int]$Size_Width,
	[Parameter(Mandatory=$True)][int]$Size_Height,
	[Parameter(Mandatory=$False)][int]$Font_Size = 12,
	[Parameter(Mandatory=$False)][string]$Font = 'Microsoft Sans Serif'
	)

	$Text_Box_Object = New-Object System.Windows.Forms.TextBox
    $Text_Box_Object.Location = New-Object System.Drawing.Size($Location_Width,$Location_Height)
    $Text_Box_Object.Size = New-Object System.Drawing.Size($Size_Width,$Size_Height)
	$Text_Box_Object.Font = ($Font + ',' + $Font_Size)
	
	Return $Text_Box_Object
	
	}

Function Create_Label()
{
	param(
	[Parameter(Mandatory=$True)][string]$Text,
	[Parameter(Mandatory=$True)][int]$Location_Width,
	[Parameter(Mandatory=$True)][int]$Location_Height,
	[Parameter(Mandatory=$True)][int]$Size_Width,
	[Parameter(Mandatory=$True)][int]$Size_Height,
	[Parameter(Mandatory=$False)][int]$Font_Size = 12,
	[Parameter(Mandatory=$False)][string]$Font = "Microsoft Sans Serif",
	[Parameter(Mandatory=$False)][int]$Color = "#ffffff",
	[Parameter(Mandatory=$False)][boolean]$Bold = $False,
	[Parameter(Mandatory=$False)][boolean]$Italic = $False,
	[Parameter(Mandatory=$False)][boolean]$Strikeout = $False,
	[Parameter(Mandatory=$False)][boolean]$Underline = $False,
	[Parameter(Mandatory=$False)][boolean]$Autosize = $true
	)
	$Label_Object = New-Object system.Windows.Forms.Label
	
	$Label_Object.text = $Text
	$Label_Object.width = $Size_Width
	$Label_Object.height = $Size_Height
	$Label_Object.location = New-Object System.Drawing.Point($Location_Width,$Location_Height)
	$Label_Object.ForeColor = $Color
	$Label_Object.AutoSize = $AutoSize
	
	$Styles = @()
	
	If(-Not $Bold)
	{
		$Styles += "Bold"
	}
	If(-Not $Strikeout)
	{
		$Styles += "Strikeout"
	}
	If(-Not $Underline)
	{
		$Styles += "Underline"
	}
	If(-Not $Italic)
	{
		$Styles += "Italic"
	}
	
	If($Styles.Count -eq 0)
	{
		$Label_Object.Font = ($Font + ',' + $Font_Size)
	}
	Else
	{
		For($i = 0; $i -lt $Styles.Count;$i++)
		{
			If($i -eq 0)
			{
				$Styles_Value = (",style=" + $Styles[$i])
			}
			Else
			{
				$Styles_Value += ("," + $Styles[$i])
			}
		}
		$Label_Object.Font = ($Font + ',' + $Font_Size + $Style_Value)
	}
	Return $Label_Object
}

Function Create_Image()
{
	param(
	[Parameter(Mandatory=$True)][string]$Image_Location,
	[Parameter(Mandatory=$True)][int]$Location_Width,
	[Parameter(Mandatory=$True)][int]$Location_Height,
	[Parameter(Mandatory=$True)][int]$Size_Width,
	[Parameter(Mandatory=$True)][int]$Size_Height
	)
	$Image_Object = New-Object system.Windows.Forms.PictureBox
	$Image_Object.width = $Size_Width 
	$Image_Object.height = $Size_Height
	$Image_Object.location = New-Object System.Drawing.Point($Location_Width,$Location_Height)
	$Image_Object.imageLocation = $Image_Location
	$Image_Object.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::zoom
	Return $Image_Object
}

Function Create_ComboBox()
{
	param(
	[Parameter(Mandatory=$True)][string]$Text,
	[Parameter(Mandatory=$True)][int]$Location_Width,
	[Parameter(Mandatory=$True)][int]$Location_Height,
	[Parameter(Mandatory=$True)][int]$Size_Width,
	[Parameter(Mandatory=$True)][int]$Size_Height,
	[Parameter(Mandatory=$False)][int]$Font_Size = 12,
	[Parameter(Mandatory=$False)][string]$Font = "Microsoft Sans Serif"
	)

	$ComboBox_Object = New-Object system.Windows.Forms.ComboBox
	
	$ComboBox_Object.text = $Text
	$ComboBox_Object.width = $Size_Width
	$ComboBox_Object.height = $Size_Height
	$ComboBox_Object.location = New-Object System.Drawing.Point($Location_Width,$Location_Height)
	$ComboBox_Object.Font = "$Font,$Font_Size"
	
	Return $ComboBox_Object
}


## End Form Setup Functions ##

<# End Of Function #>