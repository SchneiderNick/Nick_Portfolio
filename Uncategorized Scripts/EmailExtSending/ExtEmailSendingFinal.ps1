# Purpose: Gather data on emails sent to an external emails
# Author: Nicholas Schneider & Jake Nitz
# Date: June 2018


####################Start Variables###########################
#Stores the server name in a variable $ServerName
$serverList = @("###########")
#Array to store the internal SCJ extensions
$intEmailExtensions = @("###########","###########","###########","###########","###########","###########")
#Variable to save the file location for the output
$fileLocation = "###########"
#Creates an empty variable, to store info you wish to output to the file
$fileInfo = ""
# Total Emails Sent (All Servers), Total External Emails Sent (All Servers), Total Emails (Per Server), Total External Emails
$totalSentAll = $totalExternalAll = $totalSent = $TotalExternal = 0
#Curren message ID
$messageIds = @()
#Array to store previous Message-Ids; This is to prevent the same message bouncing between servers to be counted twice
$individualRecipients = $messsageIds = @()
#Sets date range from the day this is run, to 30 days prior
$To = Get-Date 
$From = $To.AddDays(-30)
#Creates empty string variables to hold the formatted output from their respective object parameteres
$formattedMessageId = $formattedRecipients = ""
#Creates a variable that will be used to break out of the loop if a message ID matches one that has already been processed
$messageIdStatus = $recipientStatus = ""
#Creates counters for the two while loops in the program, and sets them to 0
$messageIdCounter = $recipientCounter = 0
####################End Variables###########################

#Check if the output file exists
$fileExists = Get-ChildItem $fileLocation
$fileInfo = "Server Name, Day From, Day To, # Total Emails Sent, # Total Emails Sent to External"
If($fileExists.Exists)
{
#If it exists, append the content
$fileInfo | Add-Content $fileLocation
}
Else
{
#If it doesn't exists, create the file and add content
$fileInfo | Set-Content $fileLocation
}
#Resets the value in $fileInfo
$fileInfo = ""
For($j = 0; $j -lt $serverList.length;$j++)
{
	$totalExternal = 0
	$totalSent = 0
	#Pulls data from the MessageTrackingLogs from the specified server
	Get-TransportServer $serverList[$j] | Get-MessageTrackingLog -ResultSize Unlimited -Start $From -End $To | ? {$_.MessageSubject -ne "Folder Content"} | ForEach {
		#Checks EventId value for "SEND" only (EventID  either -eq "RECIEVE" or "SEND")
		If ($_.EventId -eq "SEND" )
		{
			#Reformatts the MessageIds and Recipients that it pulls from the logs
			$formattedMessageId = ($_.MessageId | out-string).replace("`n","")
			$formattedRecipients = ($_.Recipients | out-string).replace("`n","")
			#Rests the status of messageID (Used in determining if the current message ID has been counted before)
			$messageIdStatus = "False"
			#resets messageIdCounter
			$messageIdCounter = 0
			#loops though the messageIds saves in the arrays
			While($messageIdCounter -lt $messageIds.length)
			{
				#Checks the current message ID with each stored value in the previous message id arrays
				If($messageIds[$messageIdCounter] -Match $formattedMessageId)
				{
					#If it finds a match, it sets the status to true and breaks from the while loop (No need to continue checking)
					$messageIdStatus = "True"
					Break
				}
			#Increments the messageIDCounter to continue the while loop
			$messageIdCounter++
			}
			#If the messageIdStatus is unchanged (Wasn't found) it is classified as a new email
			If($messageIdStatus -eq "False")
			{
				#Increments the total number of emails sent (They passed both tests)
				$totalSent++
				#Array to store the values of recipients for an individual message
				$individualRecipients = @()
				#Splits the $formattedRecipients list by the seperating character ";" and stores them in the array
				$individualRecipients = $formattedRecipients -split ";"
				#Resets the counter so that when it loops back around, it stats at 0
				$recipientCounter = 0

				#While loop that loops through the recipients for an email.
				While($recipientCounter -lt $individualRecipients.length)
				{
					#A for loop to loop through the different internal extensions
					For($i = 0; $i -lt $intEmailExtensions.length; $i++)
					{
						#Resets the status so that it defaults to false. In the case that the previous email was a duplicate
						$recipientStatus = "False"
						#If at any point a recipient is a match to an internal extension, change the status to true (meaning its internal)
						#and break out of the FOR loop
						If($individualRecipients[$recipientCounter] -Match $intEmailExtensions[$i])
						{
							$recipientStatus = "True"
							Break
						}
					}
					#If after checking a recipient for a match, one has not been found increment the external email counters
					#And break from the WHILE loop
					If($recipientStatus -eq "False")
					{
						$totalExternal++
						Break
					}
				#Increment counter for WHILE loop if an external recipient is not found
				$recipientCounter++
				}
			#Add the sent message's ID to the list of looked at message IDS
			$messageIds += $formattedMessageId
			}
		}
	}
	$totalSentAll += $totalSent
	$totalExternalAll += $totalSent
	$fileInfo = "$serverList[$j], $from, $to, $totalSent, $totalExternal"
	$fileInfo | Add-Content $fileLocation
}

$fileInfo = "All, $from, $to, $totalSentAll, $totalExternalAll"
$fileInfo | Add-Content $fileLocation



<#########TEST############
#Work in this environment to test interactions
#Use this to copy and paste into command line
#Do not remove the < and >
#Code below this point will not interact with the program running

$test = @(1,2,3,4,5)
$testCounter = 0
While($testCounter -lt 5)
{
	For($i = 0; $i -lt $test.length; $i++)
	{
		If($test[$i] -eq 3)
		{
			Write-Output "Hit Number $test[$i]"
			Break
		}
		Else
		{
			Write-Output "Number Hit $test[$i]"
		}
	}
$testCounter++
}
#########################>






}