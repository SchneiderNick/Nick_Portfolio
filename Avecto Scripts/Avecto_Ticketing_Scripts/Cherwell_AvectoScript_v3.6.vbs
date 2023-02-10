' Author: Nicholas Schneider
' Owner: BPT - I&O - Automations & Innovations
' Organization: SCJohnson
' Purpose:
	' Script is run through the Avecto Defendpoint client when a user attempts to download a program not white listed
	' This script generates a Service Request in Cherwell and sends it to the "RG-SCJ-GBL-SRB"
'---------'
'Functions'
'---------'

'This appends whatever string is sent to the Log function to a log file (Path found in Global Variables)
Function Log(logData)
	dim fsObj
	'Creates a File System Object - Used in writing to a file
	Set fsObj = CreateObject("Scripting.FileSystemObject")
	'Checks if the file already exists, or if it needs to be created
	'(Append = 8, Read Only = 1, Write = 2)
	If fsObj.FileExists(logFilePath) then
		'If it exists, open the file to Append
		Set fileObj = fsObj.OpenTextFile(logFilePath,8,true)
	Else
		'If the file did not exist, create it. (This action also opens it to write, and it doesn't need to append since it is a new file)
		Set fileObj = fsObj.CreateTextFile(logFilePath,true)
	End If
	'Writes the string to the file with date and time added to the strings
	fileObj.writeline(FormatDateTime(Date()) & " " & TimeValue(Now()) & ": " & logData)
	'Closed the file that was opened
	fileObj.close
	'Clears the variables used in working with the file
	Set fileObj = Nothing
	Set fsObj = Nothing
End Function

Function LogSuccess(jsonResponse)
	On Error Resume Next
	'Splits the response from Cherwell into parts, divided by a " (Also knows as chr(34))
	jsonResponseArray = Split(jsonResponse, chr(34))

	If jsonResponseArray(16) <> ":null," Then
		Log("Error Code: " & jsonResponseArray(16) & " Cherwell Request Failed: User = " & PG_USER_DOMAIN & "\\" & PG_USER_NAME & _
		" application= " & PG_PROG_NAME & " challenge= " & PG_MSG_CHALLENGE & _
		" reason= " & PG_USER_REASON)
	Else
		Log("Cherwell Request Created: request_number=" & jsonResponseArray(3) & _
		" initiated_by= " & PG_USER_DOMAIN & "\\" & PG_USER_NAME & _
		" challenge code= " & PG_MSG_CHALLENGE & _
		" reason= " & PG_USER_REASON)
	End If
End Function
'This function pulls data from Avecto Defendpoint when a user utilizes the Avecto code pop-up
Function GetAvectoPGValue(name)
	'Checks the availability of the PGScript object
	If Not IsObject(PGScript) Then
		'If it is not available, it logs this and changes the return value to Not_Available
		Log("PGScript object not available: GetAvectoPGValue cant retrieve " & name)
		returnValue = "Not_Available"
	Else
		'If it is an object, it logs this and pulls value from the object and stores it in the returnValue variable	
		returnValue = PGScript.GetParameter("[" + name + "]")
		Log("GetAvectoPGValue retrieved value:" & returnValue & " for parameter:" & name)
	End If
	'Changes characters that break JSON formatting to the in text version \ -> \\ or " -> "" (Meaning a single quote becomes null)
	returnValue = Replace(returnValue,"\","\\")
	returnValue = Replace(returnValue,chr(34),"")
	If (returnValue = "[" + name + "]") then
        returnValue = "Not_Available"
    end If
	'Returns this value to the place where this function is called
	GetAvectoPGValue = returnValue
End Function
'Function that first calls the API for a token, then calls the BuildJSONRequest() to build the data to send, then sends the JSON to create a ticket
Function SendRestAPICall()
	'Creates two objects, to first send the information needed to get an access token, and another to send the data to build the ticket
	Log("Creating the token XmlHttp object")
	set tokenObj = CreateObject("Microsoft.XmlHttp")
	Log("Opening tokenObj")
	'Opens the token object using the Cherwell token URL, given to SCJ by Cherwell
	tokenObj.Open "POST", CherwellTokenUrl, false
	Log("Using Cherwell Token URL: " & CherwellTokenUrl)
	Log("Creating Token Body")
	'Creates a string with the appropriate information to send to Cherwell to generate an access token
	CherwellTokenBody = "grant_type=password&client_id=###########f&username=" & CherwellUsername & "&password=" & CherwellPassword
	Log("Setting the request header")
	'Preparation for sending the token information to Cherwell 
	tokenObj.setRequestHeader "Content-Type", "application/json"
	Log("Sending the Cherwell Token Body")
	'Call to send the information to Cherwell to generate an access token for the user
	tokenObj.send CherwellTokenBody
	
	If (tokenObj.status = 200) Then
		'If the call returns a status of 200, it means that the call was received in the correct format
		Log("Token Call was Successful")
		'Stores the response into a variable
		tokenResponse = tokenObj.ResponseText
		Log("Cherwell API responded to the token request with: " & tokenResponse)
		'Splits the response variable up into an array of pieces, split by chr(34) or "
		tokenResponseArray = Split(tokenResponse,chr(34))
		'Pulls the access token out of the array (which is stored in 4th array block and 3rd indexed slot)
		accessToken = tokenResponseArray(3)
		Log("Parsed Response Token: " & accessToken)
		Log("Creating the data XmlHttp object")
		'Creates a new xmlHttp object to use in sending the data
		set dataObj = CreateObject("Microsoft.XmlHttp")
		Log("Opening dataObj")
		'Opens the object using the Cherwell API Url
		dataObj.Open "POST", CherwellApiUrl, false
		Log("Setting Request Header")
		'sets the 3 different settings for the Request Header
		dataObj.setRequestHeader "Content-Type", "application/json"
		dataObj.setRequestHeader "Accept", "application/json"
		dataObj.setRequestHeader "Authorization", "Bearer " & accessToken		
		Log("Creating JSON Data")
		'Calls the function that builds the JSON body that builds the ticket on the Cherwell side
		JSONData = BuildJSONRequest()
		Log("JSON data created")
		Log("Sending JSON formatted Data")
		'Call to send the data
		dataObj.Send JSONData
		Log("JSON formatted data sent")
		If (dataObj.status = 200) Then
			'If the call was successful, store the response text into a variable
			Log("Data Call was Successful")
			dataResponse = dataObj.ResponseText
			Log("Cherwell API responded to the data request with: " & dataResponse)
			'Call the LogSuccess() function, to initiate the data deconstruction on the response
			LogSuccess(dataResponse)
		Else
		'If the call does not return a 200 status code, it either returns a 500 or a 400 code.
		'A 500 code means that the call was successful in being called, but on the server side, something was unable to be processed.
		'A 400 call means that the call was unsuccessful and not sent in the correct format.
		Log("Issue with Data - Http Response Code: " & dataObj.status & ". Request JSON Payload was: " & vbCrlf & JSONData)
		End If
	Else
		'If the call does not return a 200 status code, it either returns a 500 or a 400 code.
		'A 500 code means that the call was successful in being called, but on the server side, something was unable to be processed.
		'A 400 call means that the call was unsuccessful and not sent in the correct format. 
		Log("Issue with Token - Http Response Code: " & tokenObj.status & _
		". Request JSON Payload was: grant_type=password&client_id=###########&username=CherwellUsername&password=CherwellPassword")
	End If
End Function

Function BuildJSONRequest()
	'Accounts for the differences some .GR accounts have by forcing full caps on the name
	If (Ucase(Left(PG_USER_DISPLAY_NAME,3)) = ".GR") Then
		'If the account is a group account, give it a different name
		Log("Group Account found: " & PG_USER_DISPLAY_NAME)
		customerDisplayName = "EndUserComputing"
		Log("customerDisplayName set to: " & customerDisplayName)
	Else
		'If is a user account, pass the GUID as the identifier
		customerDisplayName = PG_USER_NAME
		Log("customerDisplayName set to: " & PG_USER_NAME)
	End If
	JSONHeader = "" & _ 
	"{" & vbCrLf & _
	chr(34) & "busObId" & chr(34) & ": " & chr(34) & "###########" & chr(34) & "," & vbCrLf & _
	chr(34) & "fields" & chr(34) & ": [" & vbCrLf & _
	"{" & vbCrLf
	JSONDescription = "" & _
	chr(34) & "dirty" & chr(34) & ": true" & ","  & vbCrLf & _
	chr(34) & "displayName" & chr(34) & ": " & chr(34) & "Description" & chr(34) & "," & vbCrLf & _
	chr(34) & "fieldId" & chr(34) & ": " & chr(34) & "###########" & chr(34) & "," & vbCrLf & _
	chr(34) & "value" & chr(34) & ": " & chr(34) & _ 
	"<font size = -3>---------------- REQUEST SUMMARY ---------------------------" & "<br />" & vbCrLf & _
	"The account name of the user: " & PG_USER_NAME & "<br />" & vbCrLf & _
	"The display name of the user: " & PG_USER_DISPLAY_NAME & "<br />" & vbCrLf & _
	"The NetBIOS name of the host computer: " & PG_COMPUTER_NAME  & "<br />"   & vbCrLf & _
	"The reason entered by the user: " & PG_USER_REASON  & "<br />" & vbCrLf & _
	"The date / time that the Policy matched: " & PG_EVENT_TIME  & "<br />" & vbCrLf & _
	"The action which the user performed from an End User Message: " & PG_ACTION  & "<br />" & vbCrLf & _
	"The Program Name of the application: " & PG_PROG_NAME  & "<br />" & vbCrLf & _
	"The Product version of the application being run: " & PG_PROG_PROD_VERSION  & "<br />" & vbCrLf & _
	"The file version of the application being run: " & PG_PROG_FILE_VERSION  & "<br />" & vbCrLf & _
	"The full path of the application file: " & PG_PROG_PATH  & "<br />" & vbCrLf & _
	"The Publisher of the application: " & PG_PROG_PUBLISHER  & "<br />"  & vbCrLf & _
	"The 8 digit challenge code presented to the user: " & PG_MSG_CHALLENGE  & "<br />" & vbCrLf & vbCrLf & _
	"---------------- All request details ---------------------" & "<br />" & vbCrLf & _
	"The name of the Policy which matched the application: " & PG_POLICY_NAME  & "<br />" & vbCrLf & _
	"The name of the Application Group that contained a matching Application Rule: " & PG_APP_GROUP  & "<br />" & vbCrLf & _
	"The name of the Application Rule that matched the application: " & PG_APP_DEF  & "<br />" & vbCrLf & _
	"The name of the built-in Token or Custom Token that was applied: " & PG_TOKEN_NAME  & "<br />" & vbCrLf & _
	"The name of the Custom Message that was applied: " & PG_MESSAGE_NAME  & "<br />" & vbCrLf & _
	"The name of the Group Policy Object which contained the matching Policy: " & PG_GPO_NAME  & "<br />" & vbCrLf & _
	"The version number of the Group Policy Object which contained the matching Policy: " & PG_GPO_VERSION  & "<br />" & vbCrLf & _
	"The account name of the user: " & PG_USER_NAME  & "<br />" & vbCrLf & _
	"The name of the domain that the user is a member of: " & PG_USER_DOMAIN  & "<br />" & vbCrLf & _
	"The display name of the user: " & PG_USER_DISPLAY_NAME  & "<br />" & vbCrLf & _
	"The NetBIOS name of the host computer: " & PG_COMPUTER_NAME  & "<br />" & vbCrLf & _
	"The name of the domain that the host computer is a member of: " & PG_COMPUTER_DOMAIN  & "<br />" & vbCrLf & _
	"The date / time that the Policy matched: " & PG_EVENT_TIME  & "<br />" & vbCrLf & _
	"The Program Name of the application: " & PG_PROG_NAME  & "<br />" & vbCrLf & _
	"The full path of the application file: " & PG_PROG_PATH  & "<br />" & vbCrLf & _
	"The Publisher of the application: " & PG_PROG_PUBLISHER  & "<br />" + vbCrLf & _
	"The Process Identifier of the application: " & PG_PROG_PID  & "<br />" & vbCrLf & _
	"The Process Identifier of the parent of the application: " & PG_PROG_PARENT_PID  & "<br />" &vbCrLf & _
	"The file name of the parent application: " & PG_PROG_PARENT_NAME  & "<br />" & vbCrLf &_
	"The ClassID of the ActiveX control: " & PG_PROG_CLASSID  & "<br />" & vbCrLf & _
	"The URL of the ActiveX control: " & PG_PROG_URL  & "<br />" & vbCrLf & _
	"The type of application being run: " & PG_PROG_TYPE  & "<br />" & vbCrLf & _
	"The command line of the application being run: " & PG_PROG_CMD_LINE  & "<br />" & vbCrLf & _
	"The SHA-1 hash of the application being run: " & PG_PROG_HASH  & "<br />" & vbCrLf & _
	"The Product version of the application being run: " & PG_PROG_PROD_VERSION  & "<br />" & vbCrLf & _
	"The file version of the application being run: " & PG_PROG_FILE_VERSION  & "<br />" & vbCrLf & _
	"The CLSID of the COM component being run: " & PG_COM_CLSID  & "<br />" & vbCrLf & _
	"The APPID of the COM component being run: " & PG_COM_APPID  & "<br />" & vbCrLf & _
	"The name of the COM component being run: " & PG_COM_NAME  & "<br />" & vbCrLf & _
	"The type of execution method ? Application Rule or Shell Rule: " & PG_EXEC_TYPE  & "<br />" & vbCrLf & _
	"The reason entered by the user: " & PG_USER_REASON  & "<br />" & vbCrLf & _
	"The account name of the designated user who authorized the application: " & PG_AUTH_USER_NAME  & "<br />" & vbCrLf & _
	"The domain of the designated user who authorized the application: " & PG_AUTH_USER_DOMAIN  & "<br />" & vbCrLf & _
	"The 8 digit challenge code presented to the user: " & PG_MSG_CHALLENGE  & "<br />" & vbCrLf & _
	"The 8 digit response code: " & PG_MSG_RESPONSE  & "<br />" & vbCrLf & _
	"The full URL from which an application was downloaded: " & PG_DOWNLOAD_URL  & "<br />" & vbCrLf & _
	"The version of the Privilege Guard Client: " & PG_DOWNLOAD_URL_DOMAIN  & "<br />" & vbCrLf & _
	"The version of the Privilege Guard Client: " & PG_AGENT_VERSION  & "<br />" & vbCrLf & _
	"The package name of the Windows Store App: " & PG_STORE_PACKAGE_NAME  & "<br />" & vbCrLf & _
	"The package publisher of the Windows Store App: " & PG_STORE_PUBLISHER  & "<br />" & vbCrLf & _
	"The package version of the Windows Store App: " & PG_STORE_VERSION  & "<br />" & vbCrLf & _
	"The type of drive where application is being executed: " & PG_PROG_DRIVE_TYPE  & "<br />" & vbCrLf & _
	"The name of the Windows service: " & PG_SERVICE_NAME  & "<br />" & vbCrLf & _
	"The display name of the Windows service: " & PG_SERVICE_DISPLAY_NAME  & "<br />" & vbCrLf & _
	"The action which the user performed from an End User Message: " & PG_ACTION  & "<br />" & "</font>" & _
	chr(34) & vbCrLf
	JSONService = "" & _
	chr(34) & "dirty" & chr(34) & ": true" & ","  & vbCrLf & _
	chr(34) & "displayName" & chr(34) & ": " & chr(34) & "Service" & chr(34) & "," & vbCrLf & _
	chr(34) & "fieldId" & chr(34) & ": " & chr(34) & "###########" & chr(34) & "," & vbCrLf & _
	chr(34) & "value" & chr(34) & ": " & chr(34) & "Computers, Devices & Software" & chr(34) & vbCrLf
	JSONCategory = "" & _
	chr(34) & "dirty" & chr(34) & ": true" & ","  & vbCrLf & _
	chr(34) & "displayName" & chr(34) & ": " & chr(34) & "Category" & chr(34) & "," & vbCrLf & _
	chr(34) & "fieldId" & chr(34) & ": " & chr(34) & "###########" & chr(34) & "," & vbCrLf & _
	chr(34) & "value" & chr(34) & ": " & chr(34) & "Software" & chr(34) & vbCrLf
	JSONSubCategory = "" & _
	chr(34) & "dirty" & chr(34) & ": true" & ","  & vbCrLf & _
	chr(34) & "displayName" & chr(34) & ": " & chr(34) & "Subcategory" & chr(34) & "," & vbCrLf & _
	chr(34) & "fieldId" & chr(34) & ": " & chr(34) & "###########" & chr(34) & "," & vbCrLf & _
	chr(34) & "value" & chr(34) & ": " & chr(34) & "Avecto Code Request" & chr(34) & vbCrLf
	JSONPriority = "" & _
	chr(34) & "dirty" & chr(34) & ": true" & ","  & vbCrLf & _
	chr(34) & "displayName" & chr(34) & ": " & chr(34) & "Priority" & chr(34) & "," & vbCrLf & _
	chr(34) & "fieldId" & chr(34) & ": " & chr(34) & "###########" & chr(34) & "," & vbCrLf & _
	chr(34) & "value" & chr(34) & ": " & chr(34) & "4" & chr(34) & vbCrLf
	JSONCustomerDisplayName = "" & _
	chr(34) & "dirty" & chr(34) & ": true" & ","  & vbCrLf & _
	chr(34) & "displayName" & chr(34) & ": " & chr(34) & "Customer SAMAccountName" & chr(34) & "," & vbCrLf & _
	chr(34) & "fieldId" & chr(34) & ": " & chr(34) & "###########" & chr(34) & "," & vbCrLf & _
	chr(34) & "value" & chr(34) & ": " & chr(34) & customerDisplayName & chr(34) & vbCrLf
	JSONOwnedByTeam = "" & _
	chr(34) & "dirty" & chr(34) & ": true" & ","  & vbCrLf & _
	chr(34) & "displayName" & chr(34) & ": " & chr(34) & "Owned By Team" & chr(34) & "," & vbCrLf & _
	chr(34) & "fieldId" & chr(34) & ": " & chr(34) & "###########" & chr(34) & "," & vbCrLf & _
	chr(34) & "value" & chr(34) & ": " & chr(34) & "RG-SCJ-GBL-SRB" & chr(34) & vbCrLf
	JSONShortDescription = "" & _
	chr(34) & "dirty" & chr(34) & ": true" & ","  & vbCrLf & _
	chr(34) & "displayName" & chr(34) & ": " & chr(34) & "Short Description" & chr(34) & "," & vbCrLf & _
	chr(34) & "fieldId" & chr(34) & ": " & chr(34) & "###########" & chr(34) & "," & vbCrLf & _
	chr(34) & "value" & chr(34) & ": " & chr(34) & "Elevation request for " & PG_USER_DISPLAY_NAME & " " & PG_USER_NAME & " for " & PG_PROG_NAME & " on " & PG_COMPUTER_NAME & " computer" & chr(34) & vbCrLf
	JSONContactValue = "" & _
	chr(34) & "dirty" & chr(34) & ": true" & ","  & vbCrLf & _
	chr(34) & "displayName" & chr(34) & ": " & chr(34) & "" & chr(34) & "," & vbCrLf & _
	chr(34) & "fieldId" & chr(34) & ": " & chr(34) & "" & chr(34) & "," & vbCrLf & _
	chr(34) & "value" & chr(34) & ": " & chr(34) & "" & chr(34) & vbCrLf
	JSONConnector = "}," & vbCrLf & "{" & vbCrLf
	JSONTrailer = 	"}" & vbCrLf & "]," & vbCrLf & "}"
	'Put all parts together to create the data string being sent
	'Start with JSONHeader, followed by your first parameter. Then add a JSONConnector in between each subsequent parameter. After the last parameter, add the JSONTrailer
	JSONRequest = JSONHeader & JSONDescription & JSONConnector & JSONService & JSONConnector & JSONCategory & JSONConnector & JSONSubCategory & JSONConnector & JSONPriority & JSONConnector & JSONCustomerDisplayName & JSONConnector & JSONOwnedByTeam & JSONConnector & JSONShortDescription & JSONTrailer
	Log("JSON Data Created: " & vbCrLf & JSONRequest)
	'Returns the data to where the call originated
	BuildJSONRequest = JSONRequest
End Function

Function Main()
	'Logs the users action and reasons
	Log("    Action: " & PG_ACTION)
	Log("    Reason: " & PG_USER_REASON)
	'Goes to the "Then" if the user either hits "Submit Request" or Closes out of the dialogue box
	If(PG_ACTION = "Cancel" AND PG_USER_REASON <> "Not_Available") OR (PG_ACTION = "Not_Available") Then
		'Function that first calls the BuildJSONRequest() to build the data to send, then calls the API for a token, then send the JSON to create a ticket
		SendRestAPICall()
	Else
		Log("Challenge dialogue cancelled - no reason provided - by user: " & PG_USER_DOMAIN & "\" & PG_USER_NAME & " with challenge code = " & PG_MSG_CHALLENGE & " action = " & action)
	End If
	'Logs the ending of the Script
	Log("Script Ran Successfully")
	Log("Processing done for PG_ACTION: " & PG_ACTION & " with business reason " & PG_USER_REASON)
	Log("----------------------------------------------------------------")
End Function
'----------------'
'End Of Functions'
'----------------'

'--------------------------'
'-----Global-Variables-----'
'--------------------------'

'Path to the log file (It is created if it doesn't exist when it is written to first)
const logFilePath = "C:\\Windows\\scjgde\\GDELogs\CherwellAvectoIntegration.log"
Log("After log file is created")
'URL used to send the JSON formatted data used in ticket 
const CherwellApiUrl = "###########CherwellAPI/api/V1/savebusinessobject"
const CherwellTokenUrl = "###########/CherwellAPI/token?api_key=###########&api_key=###########"
Log("After Cherwell Variables are created")
'Log on credentials for Cherwell Services
const CherwellUsername = "###########"
const CherwellPassword = "###########"
Log("After passwords are created")
'Avecto DefendPoint Values'
PG_ACTION = GetAvectoPGValue("PG_ACTION") 'The action which the user performed from an End User Message
PG_USER_REASON = GetAvectoPGValue("PG_USER_REASON") 'The reason entered by the user
PG_USER_DOMAIN = GetAvectoPGValue("PG_USER_DOMAIN") 'The name of the domain that the user is a member of
PG_USER_NAME = GetAvectoPGValue("PG_USER_NAME") 'The account name of the user
PG_MSG_CHALLENGE = GetAvectoPGValue("PG_MSG_CHALLENGE") 'The 8 digit challenge code presented to the user
PG_USER_DISPLAY_NAME = GetAvectoPGValue("PG_USER_DISPLAY_NAME") 'The display name of the user
PG_PROG_PATH = GetAvectoPGValue("PG_PROG_PATH") 'The full path of the application file
PG_COMPUTER_NAME = GetAvectoPGValue("PG_COMPUTER_NAME") 'The NetBIOS name of the host computer
PG_EVENT_TIME = GetAvectoPGValue("PG_EVENT_TIME") 'The date / time that the Policy matched
PG_PROG_NAME = GetAvectoPGValue("PG_PROG_NAME") 'The Program Name of the application
PG_PROG_PROD_VERSION = GetAvectoPGValue("PG_PROG_PROD_VERSION") 'The Product version of the application being run
PG_PROG_FILE_VERSION = GetAvectoPGValue("PG_PROG_FILE_VERSION") 'The file version of the application being run
PG_PROG_PUBLISHER = GetAvectoPGValue("PG_PROG_PUBLISHER") 'The Publisher of the application
PG_POLICY_NAME = GetAvectoPGValue("PG_POLICY_NAME") 'The name of the Policy which matched the application
PG_APP_GROUP = GetAvectoPGValue("PG_APP_GROUP") 'The name of the Application Group that contained a matching Application Rule
PG_APP_DEF = GetAvectoPGValue("PG_APP_DEF") 'The name of the Application Rule that matched the application
PG_TOKEN_NAME = GetAvectoPGValue("PG_TOKEN_NAME") 'The name of the built-in Token or Custom Token that was applied
PG_MESSAGE_NAME = GetAvectoPGValue("PG_MESSAGE_NAME") 'The name of the Custom Message that was applied
PG_GPO_NAME = GetAvectoPGValue("PG_GPO_NAME") 'The name of the Group Policy Object which contained the matching Policy
PG_GPO_VERSION = GetAvectoPGValue("PG_GPO_VERSION") 'The version number of the Group Policy Object which contained the matching Policy
PG_COMPUTER_DOMAIN = GetAvectoPGValue("PG_COMPUTER_DOMAIN") 'The name of the domain that the host computer is a member of
PG_PROG_PID = GetAvectoPGValue("PG_PROG_PID") 'The Process Identifier of the application
PG_PROG_PARENT_PID = GetAvectoPGValue("PG_PROG_PARENT_PID") 'The Process Identifier of the parent of the application
PG_PROG_PARENT_NAME = GetAvectoPGValue("PG_PROG_PARENT_NAME") 'The file name of the parent application
PG_PROG_CLASSID = GetAvectoPGValue("PG_PROG_CLASSID") 'The ClassID of the ActiveX control
PG_PROG_URL = GetAvectoPGValue("PG_PROG_URL") 'The URL of the ActiveX control
PG_PROG_TYPE = GetAvectoPGValue("PG_PROG_TYPE") 'The type of application being run
PG_PROG_CMD_LINE = GetAvectoPGValue("PG_PROG_CMD_LINE") 'The command line of the application being run
PG_PROG_HASH = GetAvectoPGValue("PG_PROG_HASH") 'The SHA-1 hash of the application being run
PG_COM_CLSID = GetAvectoPGValue("PG_COM_CLSID") 'The CLSID of the COM component being run
PG_COM_APPID = GetAvectoPGValue("PG_COM_APPID") 'The APPID of the COM component being run
PG_COM_NAME = GetAvectoPGValue("PG_COM_NAME") 'The name of the COM component being run
PG_EXEC_TYPE = GetAvectoPGValue("PG_EXEC_TYPE") 'The type of execution method ? Application Rule or Shell Rule
PG_AUTH_USER_NAME = GetAvectoPGValue("PG_AUTH_USER_NAME") 'The account name of the designated user who authorized the application
PG_AUTH_USER_DOMAIN = GetAvectoPGValue("PG_AUTH_USER_DOMAIN") 'The domain of the designated user who authorized the application
PG_MSG_RESPONSE = GetAvectoPGValue("PG_MSG_RESPONSE") 'The 8 digit response code
PG_DOWNLOAD_URL = GetAvectoPGValue("PG_DOWNLOAD_URL") 'The full URL from which an application was downloaded
PG_DOWNLOAD_URL_DOMAIN = GetAvectoPGValue("PG_DOWNLOAD_URL_DOMAIN") 'The domain from which an application was downloaded
PG_AGENT_VERSION = GetAvectoPGValue("PG_AGENT_VERSION") 'The version of the Privilege Defendpoint
PG_STORE_PACKAGE_NAME = GetAvectoPGValue("PG_STORE_PACKAGE_NAME") 'The package name of the Windows Store App
PG_STORE_PUBLISHER = GetAvectoPGValue("PG_STORE_PUBLISHER") 'The package publisher of the Windows Store App
PG_STORE_VERSION = GetAvectoPGValue("PG_STORE_VERSION") 'The package version of the Windows Store App
PG_PROG_DRIVE_TYPE = GetAvectoPGValue("PG_PROG_DRIVE_TYPE") 'The type of drive where application is being executed
PG_SERVICE_NAME = GetAvectoPGValue("PG_SERVICE_NAME") 'The name of the Windows service
PG_SERVICE_DISPLAY_NAME = GetAvectoPGValue("PG_SERVICE_DISPLAY_NAME") 'The display name of the Windows service
'-----------------------------'
'End Avecto DefendPoint Values'
'-----------------------------'
Log("After variables are saved")
'------------------------------'
'-----End-Global-Variables-----'
'------------------------------'

Main()

