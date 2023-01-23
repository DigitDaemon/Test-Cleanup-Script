#Problem: Running apps stopping test browsers from running
#Propossed Solution: Get all running apps on computer and then close apps that are known
#to cause issues.
#Implementation notes: Want to get problem apps from a .csv file outside of script in order to 
#avoid having to update script for new apps.

#Get the source csv file onto the computer
$FileName = "TestCleanupApps.csv"
Write-Host "FileName: " $FileName
$FileSource = Get-Content .\FileSource.config
Write-Host "File Source: " $FileSource
$FullSourceFilePath = $FileSource + "\" + $FileName
Write-Host "FullSourceFile: " $FullSourceFile
Copy-Item $FullSourceFilePath $PSScriptRoot
Write-Host "Source Copy Complete"
#Read-Host "Press Enter to Continue"

#Read the source file into the script
$LocalSource = $PSScriptRoot + "\" + $FileName
Write-Host "LocalSource: " $LocalSource
$Apps = Import-Csv -Path $LocalSource -Header 'ProcessName', 'DateAdded', 'Description' 

#Time to kill...processes
foreach ($App in $Apps){
	Write-Host "App ProcessName: " $App.ProcessName
	$Target = Get-Process -Name $App.ProcessName -ErrorAction SilentlyContinue
	if ($Target) {
		Stop-Process -Name $Target.ProcessName -Force
		Write-Host "Killed " $Target.ProcessName
	}
}
#For testing purposes
#Read-Host "Press Enter to Exit"

Remove-Item $LocalSource