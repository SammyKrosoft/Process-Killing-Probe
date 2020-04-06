
<#PSScriptInfo

.VERSION 1.0

.GUID 472aa155-a669-45e3-8bcc-c0b78a5f0a4f

.AUTHOR Sammy Krosoft

.COMPANYNAME

.COPYRIGHT None - this script is an example of PowerShell probing

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Probe to try to continuously kill a process, based on process name (test using Get-Process <Process_Name> to get the real process name, and use the script with the -ProcessNameToKill parameter and the process name as a value for this property. 

.EXAMPLE
.\Kill_PRocess_Probe.ps1 -ProcessNameToKill Notepad

This will query the Notepad process every 10 seconds (default for this probe) to check and kill if it exists

.EXAMPLE
.\Kill_Process_Probe.ps1 -ProcessNameToKill Notepad -ProbeSleep 5

This will query the Notepad process every 5 seconds to check and kill if it exists

.EXAMPLE

.\Kill_Process_Probe.ps1 -ProcessNameToKill AnnoyingProcess -ProbeSleep 2 -LogFile C:\temp\KillMyProcess.log

This will query the AnoyingProcess process every 2 seconds and store the probe logs into the C:\temp\KillMyProcess.log

#> 

[CmdletBinding()]
Param(
    [Parameter()][string]$ProcessNameToKill = "notepad",
    [Parameter()][string]$LogFile = "C:\temp\Kill_" + $ProcessNameToKill + ".log",
    [Parameter()][string]$ProbeSleep = 10
)

#Initializing counters values
$ProbeCounter = 0         # Counter to count number of times the probe
$KillsCounter = 0         # Counter to count how many kills in current probe run
$LastKillCounter = 0
$InitialDate = get-date   #Storing start date for reporting (LogFile)
#Starting Logging (or re-using an existing file using Add-Content with the -Force parameter instead of Set-Content)
Add-Content -Path $LogFile -Force -Value "------------ New probe started ----------"
Add-Content -Path $LogFile -Force -Value "Probe start date     : $InitialDate"
Add-Content -Path $LogFile -Force -Value "Process Name To Kill : $ProcessNameToKill"
Add-Content -Path $LogFile -Force -Value "Log file             : $LogFile"
Add-Content -Path $LogFile -Force -Value "Probe frequency      : $ProbeSleep"


#The probe itself: querying infinitely the process until user stops with CTRL+C or closes the PowerShell window
while ($True){
	$ProbeCounter++    #Incrementing probe counter to show how many times the loop ran
	$LastDate = $d
	$d = get-date
	cls
	Write-Host "$d -- Probe query number $ProbeCounter"
    Write-Host "$d -- Current probe started at : $InitialDate"
    Write-Host "$d -- Last query               : $LastDate"
	try{
		$P = get-process $ProcessNameToKill -ErrorAction stop
		kill $P -force
        $LastKillCounter = $ProbeCounter     #Sync $LastKillCounter with $ProbeCounter to show later which take was the last successfull kill
		$KillsCounter++         # Incrementing the kills counter to who how many times the probe killed the process in the current run
		$lastkill = $d          # Updating $LastKill with date of kill success, to later show when was the last successfull kill
		add-content $LogFile -Force -Value "Killed $ProcessNameToKill (total kills : $KillsCounter) at $d - take $ProbeCounter"
	}
	catch{
		write-host "$d -- No $ProcessNameToKill"    # If there is no process to kill (Get-Process fails with ErrorAction STOP, leading to the catch section)
	}
	if ($KillsCounter -eq 0){
		Write-Host "$d -- No $ProcessNameToKill kills as of now"
	} ElseIf ($KillsCounter -eq 1) {
		write-host "$d -- Killed $ProcessNameToKill $KillsCounter time, at $Lastkill, was on take $LastKillCounter"
	} Else {
		write-host "$d -- Killed $ProcessNameToKill $KillsCounter times, last time at $Lastkill, was on take $LastKillCounter"
    }
	Write-Host "Waiting for $ProbeSleep seconds before refresh..."
	sleep $ProbeSleep
}
