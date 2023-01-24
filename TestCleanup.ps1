#Problem: Running apps stopping test browsers from running
#Propossed Solution: Get all running apps on computer and then close apps that are known
#to cause issues.
#Implementation notes: Want to get problem apps from a .csv file outside of script in order to 
#avoid having to update script for new apps.

#Printing the instructions
Function Get-Instructions{
	Write-Host "The TestCleanupUtility instruction will be written to the folder that the utility is currently located in."
	$Instructions = "Test Cleanup Utility" +
			"`r`nWritten by Thomas Landry for use and distrubution by the Orange Unified School District" +
			"`r`n-----" +
			"`r`nThe purpose of this utility is to automatically close any apps that may interfer with the ability for" +
			"`r`ntesting browser to run. The goal is to be able to have students simple click on the utility before taking" +
			"`r`na test and not have to close processes themselves." +
			"`r`n-----" +
			"`r`nTo use this utility, three seperate files are needed." +
			"`r`nThe utility executable itself." +
			"`r`nAnd a .csv file named 'TestCleanupApps.csv'" +
			"`r`nA .config file named 'FileSource.config'" +
			"`r`n`-----" +
			"`r`nThe TestCleanupApps.csv file will serve as a master record of the apps that the program will close and" +
			"`r`nshould be placed in a central location on the network where anyone has access privilages. The file should" +
			"`r`nconatain the name of the process AS IT APPEARS IN POWERSHELL when using the Get-Process cmdlt, the date it" +
			"`r`nwas added to the record, and a description of it. For example a single row might look like:" +
			"`r`n" +
			"`r`nTeams,05/08/1945,The Teams client in windows" +
			"`r`n" +
			"`r`nThis utility will not be able to correctly close an application if the Porcess Name is not correct." +
			"`r`n-----" +
			"`r`nThe FileSource.config file should be placed in the same folder as the executable file and should only contain" +
			"`r`nthe path to the TestCleanupApps.csv file on the network. For example:" +
			"`r`n" +
			"`r`n\\School-Server\softwarepush\TestCleanupUtility" +
			"`r`n" +
			"`r`nDo not include TestCleanupApps.csv in the path." +
			"`r`n-----"
	Out-File -FilePath .\Instructions.txt -InputObject $Instructions
	$ExampleConfig = "\\School-Server\softwarepush\TestCleanupUtility"
	Out-File -FilePath .\EXAMPLE_FileSource.config -InputObject $ExampleConfig
	$ExampleCleanupAppsCSV = "Teams,05/08/1945,The Teams client in windows"
	Out-File -FilePath .\EXAMPLE_TestCleanupApps.csv -InputObject $ExampleCleanupAppsCSV
}

#Turn on Debug lines
$DebugOutput = $false

#Set up some variables
$SourceFileName = "TestCleanupApps.csv"
$ConfigFileName = "FileSource.config"
$DataPath = "C:\ProgramData\TestCleanupScript"

#check for config file
$ConfigFilePath = $DataPath + "\" + $ConfigFileName
if ($DebugOutput)
{
	Write-Host $ConfigFilePath
	Read-Host "Press Enter to Continue"
}

$ConfigPresent = Test-Path -Path $ConfigFilePath
if (!$ConfigPresent){
	$ValidChoice = $false
	Do
	{	
		$ConfigChoice = Read-Host "Configuration file not present, would you like to output the utility instructions? Yes [Y] or No [N]"
		$ConfigChoice = $ConfigChoice.ToLower()
		if ($ConfigChoice[0] -Match "[y]"){
			Get-Instructions
			$ValidChoice = $true
		}
		elseif(!$ConfigChoice[0] -Match "[n]"){
			Write-Host "Not a valid input"
		}
		else{
			$ValidChoice = $true
		}
	}while($ValidChoice = $false)
	Read-Host "Press enter to exit"
	Exit 3
}

#build path to the source file
$FileSource = Get-Content $ConfigFilePath

if ($DebugOutput) { Write-Host $FileSource }
$FullSourceFilePath = $FileSource + "\" + $SourceFileName

if ($DebugOutput)
{
	Write-Host $FullSourceFilePath
	Read-Host "Press enter to continue"
}

#check for source file
$SourcePresent = Test-Path $FullSourceFilePath
if (!$SourcePresent){
	$ValidChoice = $false
	Do
	{	
		$SourceChoice = Read-Host "Source File not present, would you like to output the utility instructions? Yes [Y] or No [N]"
		$SourceChoice = $SourceChoice.ToLower()
		if ($SourceChoice[0] -Match "[y]"){
			Get-Instructions
			$ValidChoice = $true
		}
		elseif(!$SourceChoice[0] -Match "[n]"){
			Write-Host "Not a valid input"
		}
		else{
			$ValidChoice = $true
		}
	}while($ValidChoice = $false)
	Read-Host "Press enter to exit"
	Exit 3
}

#Get the source csv file onto the computer
Copy-Item $FullSourceFilePath -Destination $DataPath
#Read-Host "Press Enter to Continue"

#Read the source file into the script
$LocalSource = $DataPath + "\" + $SourceFileName

if ($DebugOutput)
{
	Write-Host "LocalSource: " $LocalSource
	Read-Host "Press Enter to Continue"
}

$Apps = Import-Csv -Path $LocalSource -Header 'ProcessName', 'DateAdded', 'Description' 

#Time to kill...processes
foreach ($App in $Apps){
	if ($DebugOutput) { Write-Host "App ProcessName: " $App.ProcessName }
	$Target = Get-Process -Name $App.ProcessName -ErrorAction SilentlyContinue
	if ($Target) {
		Stop-Process -Name $Target.ProcessName -Force
		if ($DebugOutput) { Write-Host "Killed " $Target.ProcessName }
	}
}
Remove-Item $LocalSource

if ($DebugOutput) { Read-Host "Press Enter to Exit" }