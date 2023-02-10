## Begin Navigation Functions ##

Function IP_DNS()
{
	
	IP_Form
	Script_Status
	&$Host_Name_Gen_Dict["IP_Request_Type"]
	Script_Status
	DNS_Form
	Script_Status
	
}

Function DNS_IP()
{
	
	DNS_Form
	Script_Status
	IP_Form
	Script_Status
	&$Host_Name_Gen_Dict["IP_Request_Type"]
	Script_Status
	
}


Function Reserved()
{
	IP_Provision_Method
	Script_Status
	&$Host_Name_Gen_Dict["IP_Provision_Method"]
	Script_Status
}



Function Next_Available_IP()
{
	SubNet
	Script_Status
	
}

## End Navigation Functions ##