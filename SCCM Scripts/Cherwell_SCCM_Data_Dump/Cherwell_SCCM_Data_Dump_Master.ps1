####################################
# Author: Nicholas Schneider       #
# Owner: EUC Team - Krystal Powell #
# Purpose: Grab data from Cherwell #
#	Using API Call, and dump into  #
# 	SQL Database for SCCM          #
####################################


## Global Variables ##

#Full path to the file where the output is generated and stored (Also used when writing data to SCCM Database)
$path = "###########"

# SQL instances #

$cmdbInstance = "###########,###########" #Located on server ###########

# End SQL Instances #


## Global Variables ##

############ Functions ############

# This function generates an Authentication Token and returns it
Function Get_Authentication_Token()
{
	#Necessary information to create an API token
	$authMode = "Internal"
	$apiKey = "###########"
	$userName = "###########"
	$password = "###########"
	$serverName = "###########"
	$baseUri = "https://${serverName}/CherwellAPI/"
	$tokenUri = $baseUri + "token"
	#This is the JSON body you send to the API to recieve a key
	$tokenRequestBody =
	@{
		"Accept" = "application/json";
		"grant_type" = "password";
		"client_id" = $apiKey;
		"username" = $userName;
		"password"= $password
	}
	#Call being placed to the API for a key, where the key is returned as a JSON object
	$tokenResponse = Invoke-RestMethod -Method POST -Uri "${tokenUri}?auth_mode=${authMode}&api_key=${apiKey}" -Body $tokenRequestBody
	#Pulls just the API key value out of the JSON object and returns it to where the function was called
	return $tokenResponse.access_token
}

# This function pulls data based on the input Auth token and pageUrl
Function Output_Cherwell_Data()
{
	Param([string]$authToken, [String]$pageUrl)
	#Using the Auth key passed to this function, creates a request header
	$requestHeader = @{ Authorization = "Bearer $($authToken)" }
	#Sends the page URL and the request header to the API and saves the return JSOn (The values found on that page) to a variable
	$DataFromCherwell = Invoke-RestMethod -Method GET -Uri $pageUrl -ContentType application/json -Header $requestHeader
	#Returns the variable to where the function is called
	Return $DataFromCherwell
}

Function Check_File_Exists
{
	Param([String]$filePath)
	#Test the path of the file to see if it exists
	If(-Not (Test-Path $filePath))
	{	
		#Creates the item if it does not exist
		New-Item -ItemType "file" -Path $filePath
	}
	Else
	{
		#Deletes the file if it already exists (It would be filled with the previous day's data)
		Remove-Item -Path $filePath
		#Creates a new file that is empty, to store that day's data.
		New-Item -ItemType "file" -Path $filePath
	}
}
#Check_Folder_Exists
Function Check_Folder_Exists
{
	Param([String]$folderPath)
	#Test the path of the file to see if it exists
	If(-Not (Test-Path $folderPath))
	{
		#Creates the folder the path points to if it does not exist
		New-Item -ItemType "directory" -Path $folderPath
	}
}
#Function used to clear the database of out of date values
Function Clear_SCCM_Database()
{
	#This is a variable that stores the SQL command to elette all values from a table in a database
	$clear_Database_Query = "DELETE FROM [###########].[dbo].[###########]"
	Invoke-Sqlcmd -query $clear_Database_Query -ServerInstance $cmdbInstance


}

Function Input_Cherwell_Data()
{
	#These are the column names for everything that comes out of the CSV file. These are omnly tied to the variables when pulling out of the $line variable.
	$columns = 'Serial_Number', 'Status', 'Country', 'Site', 'Assignee', 'Assignee_GUID', 'Device_Role', 'Model', 'TimeStamp'
	$importedCherwellData = Import-CSV $path -Header $columns
	
	#For each line in the CSV we are pulling in, the values are seperated into variables based on the column they came from.
	ForEach($line in $importedCherwellData)
	{
		#If there is an invalid character in the return (') replace it with a double single quote ('')
		$SerialNumber = $line.("Serial_Number").Replace("'","''")
		$Status = $line.("Status").Replace("'","''")
		$DeviceRole = $line.("Device_Role").Replace("'","''")
		$LocationCountry = $line.("Country").Replace("'","''")
		$LocationName = $line.("Site").Replace("'","''")
		$AssignedToFullName = $line.("Assignee").Replace("'","''")
		$AssignedToUserId = $line.("Assignee_GUID").Replace("'","''")
		$ModelName = $line.("Model").Replace("'","''")
		$TimeStamp = $line.("TimeStamp").Replace("'","''")
		#SQL Query to input a line of data into the database
		$Input_Data_SQL_Query = "INSERT INTO [SCCM_STAGING].[dbo].[CherwellStaging] (SerialNumber,Status,SubStatus,DeviceRole,LocationCountry,LocationName,AssignedToFullName,AssignedToUserId,ModelName,TimeStamp) VALUES ('$SerialNumber','$Status','','$DeviceRole','$LocationCountry','$LocationName','$AssignedToFullName','$AssignedToUserId','$ModelName','$TimeStamp')"
		#SQL invoke command that sends the request to the server and inputs the 
		Invoke-Sqlcmd -query $Input_Data_SQL_Query -ServerInstance $cmdbInstance
	}

}

Function Main_Function()
{
	#This is the base URL - which is the URL needed to make the call without the specific page number. Thta page number is appended to the end of the string to pull specific pages
	$baseUrl = "###########/CherwellAPI/api/V1/getsearchresults/association/###########/scope/Global/scopeowner/None/searchname/All%20Computers?pagesize=200&pagenumber="
	#URL for the first page
	$firstPage = $baseUrl + "1"
	#Number of results pulled per page
	$pageSize = 200
	$currentPage = ""
	# Gets an authenticatino token from Cherwell
	$requestToken = Get_Authentication_Token
	#Pulls data from Cherwell for the first page in the list (For info like # of entries per page) etc.
	$firstPageData = Output_Cherwell_Data $requestToken $firstPage
	#Grabs the total number of assets in the list, so I can calulate the 
	$totalRows = $firstPageData.TotalRows
	[decimal]$totalPages = [math]::floor(($totalRows / $pageSize) + 1)
	#Check put in place to determine if the first page has been processed - used to add headers to the output CSV
	$firstObj = "True"
	#For loop that loops through all of the pages, so you get all of the assets
	For($counter = 1; $counter -le $totalPages; $counter++)
	{
		#Creates the URL for the current page, by appending the page number to the end of the URL
		$currentPage = $baseUrl + $Counter
		#Makes the call to the Output_Cherwell_Data function, which returns the data as a json object
		$tempCherwellData = Output_Cherwell_Data $requestToken $currentPage
		#Loops through all of the business objects returned by the search call
		ForEach($tier1Object in $tempCherwellData.businessObjects)
		{
			#Pulls in all of the field values for the current object selected
			$fields = $tier1Object.Fields
			$cherwellValues = ""
			#Creates a string and appends all of the field values seperated by a "tab" so they seperate in the CSV
			For($fieldsCounter = 0; $fieldsCounter -lt $fields.count; $fieldsCounter++)
			{

				#If the field value is Primary User... it splits the value into 2 seperate columns (Name and GUID)
				If((($fields[$fieldsCounter].DisplayName) -eq "Primary User Customer Full Name" ) -And ((($fields[$fieldsCounter].Value).length) -gt 7 ))
				{
					#This means that the Field where a name would be was found. This line splits the value into two fields (Name and GUID)
					$cherwellValues += (($fields[$fieldsCounter].Value) -Replace ".{8}$") + "," + (($fields[$fieldsCounter].Value).Substring(($fields[$fieldsCounter].Value.Length) - 7)) + ","
				}
				ElseIf((($fields[$fieldsCounter].DisplayName) -eq "Primary User Customer Full Name" ) -And ((($fields[$fieldsCounter].Value).length) -lt 7 ))
				{
					#This function hits if the value is empty, since there needs to be 2 empty values, not just 1 (Since it gets split)
					$cherwellValues += "" + "," + "" + ","
				}
				Else
				{
					#This is for every value that is not the name field. No checks need to be done, so they just get added to the list.
					$cherwellValues += $fields[$fieldsCounter].Value + ","
				}
			}
			#Outputs the fields to the file (Appends them)
			$cherwellValues >> $path
		}
	}
}





############ Functions ############


#This function call makes sure that the path specificed in the $path variable exists
Check_File_Exists $path

#This call runs the initial function for the script
Main_Function

#Calls the function to clear the database of any data previously stored. 
Clear_SCCM_Database

Input_Cherwell_Data
#This is the end of the script

