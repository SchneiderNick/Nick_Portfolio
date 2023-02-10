## This File is part of the IP_DNS_Provision_Application ##

<#

## Author   : Nicholas Schneider
## File #   : 
## Owner    : 
## Type     :

## Comments :

#>

<# Start Of Function #>

Function Main_Navigation()
{
	$Supporting_Info["Initial_Request_Type"] = Request_Type_Form
	Script_Status
	&($Supporting_Info["Initial_Request_Type"])
	Script_Status
}

Function IP_Navigation()
{
	$Supporting_Info["IP_Request_Type"] = IP_Request_Form
	Script_Status
	&($Supporting_Info["IP_Request_Type"])
	Script_Status
}

Function IP_DNS_Navigation()
{
	$Display_Info["DNS_Entry"] = DNS_Form
	Script_Status
	Reserved_Navigation
	Script_Status
}

Function Reserved_Navigation()
{
	#Returns Either - Next_Available_IP_Form - Or - Provide_IP_Form
	$Supporting_Info["IP_Provision_Type"] = IP_Provision_Form
	Script_Status
	&($Supporting_Info["IP_Provision_Type"])
	Script_Status
	If($Supporting_Info["SubNet_Navigation_Method"] -ne "")
	{
		&$Supporting_Info["SubNet_Navigation_Method"]
	}
}

Function Fixed_Navigation()
{

	$Display_Info["Mac_Address"] = Mac_Address_Form
	Script_Status
	Reserved_Navigation
	Script_Status
}

Function Search_SubNet_Navigation()
{
	Select_Region_Form
	Script_Status
	$Display_Info["SubNet"] = SubNet_Filter_Form
	Script_Status
	$Display_Info["IP"] = Get_Next_IP
}

Function Provide_SubNet_Navigation()
{
	$Display_Info["SubNet"] = Provide_SubNet_Form
	Script_Status
	$Display_Info["IP"] = Get_Next_IP
}


<# End Of Function #>