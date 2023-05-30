#Test Cleanup Script 
#A configurable solution to shut down applications that would interfere withtesting software. 
#Project availible at https://github.com/DigitDaemon/Test-Cleanup-Script
#----------------------------------<LICENSE>--------------------------------#
#   Copyright (C) 2023 Thomas Landry                                        #
#                                                                           #
#   This program is free software: you can redistribute it and/or modify    #
#   it under the terms of the GNU General Public License as published by    #
#   the Free Software Foundation, either version 3 of the License, or       #
#   (at your option) any later version.                                     #
#                                                                           #
#   This program is distributed in the hope that it will be useful,         #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of          #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           #
#   GNU General Public License for more details.                            #
#                                                                           #
#   You should have received a copy of the GNU General Public License       #
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.   #
#---------------------------------------------------------------------------#

#Problem: Running apps stopping test browsers from running
#Propossed Solution: Get all running apps on computer and then close apps that are known
#to cause issues.
#Implementation notes: Want to get problem apps from a .csv file outside of script in order to 
#avoid having to update script for new apps.

param (
	[switch]$DebugOutput = $false,
	[switch]$Suppress = $false,
	[switch]$License = $false,
	[switch]$Instructions = $false,
	[string]$Directory = "",
	[switch]$Help = $false,
	[string]$Launch = ""
	#[switch]$? = $false
)

Function Get-Instructions{
	Write-Host "The TestCleanupUtility instruction will be written to the folder that the utility is currently located in or the specified Directory."
	$Instructions = "Test Cleanup Utility" +
			"`r`nWritten by Thomas Landry for use and distrubution under the GNUv3 License" +
			"`r`n-----" +
			"`r`nCopyright (C) 2023 Thomas Landry"+
			"`r`n"+
			"`r`nThis program is free software: you can redistribute it and/or modify"+
			"`r`nit under the terms of the GNU General Public License as published by"+
			"`r`nthe Free Software Foundation, either version 3 of the License, or"+
			"`r`n(at your option) any later version."+
			"`r`n"+
			"`r`nThis program is distributed in the hope that it will be useful,"+
			"`r`nbut WITHOUT ANY WARRANTY; without even the implied warranty of"+
			"`r`nMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the"+
			"`r`nGNU General Public License for more details."+
			"`r`n"+
			"`r`nYou should have received a copy of the GNU General Public License"+
			"`r`nalong with this program.  If not, see <http://www.gnu.org/licenses/>."+
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
			"`r`nThe FileSource.config file should be placed in the ProgramData/TestCleanupScript folder and should only contain" +
			"`r`nthe path to the TestCleanupApps.csv file on the network. For example:" +
			"`r`n" +
			"`r`n\\School-Server\softwarepush\TestCleanupUtility" +
			"`r`n" +
			"`r`nDo not include TestCleanupApps.csv in the path." +
			"`r`n-----"
	if($Directory -like ""){
		Out-File -FilePath .\Instructions.txt -InputObject $Instructions
		$ExampleConfig = "\\School-Server\softwarepush\TestCleanupUtility"
		Out-File -FilePath .\EXAMPLE_FileSource.config -InputObject $ExampleConfig
		$ExampleCleanupAppsCSV = "Teams,05/08/1945,The Teams client in windows"
		Out-File -FilePath .\EXAMPLE_TestCleanupApps.csv -InputObject $ExampleCleanupAppsCSV
	}
	else
	{
		try{
			$path = $Directory + "\Instructions.txt"
			Out-File -FilePath $path -InputObject $Instructions
			$ExampleConfig = "\\School-Server\softwarepush\TestCleanupUtility"
			$path = $Directory + "\EXAMPLE_FileSource.config"
			Out-File -FilePath $path -InputObject $ExampleConfig
			$ExampleCleanupAppsCSV = "Teams,05/08/1945,The Teams client in windows"
			$path = $Directory + "\EXAMPLE_TestCleanupApps.csv"
			Out-File -FilePath $path -InputObject $ExampleCleanupAppsCSV
		}
		catch [System.IO.IOException] {
			$message = "The -Directory input `"" + $Directory + "`" is not valid." 
			Write-Host $message
			Write-Host $_
		}
	}
}
Function Get-License{
	Write-Host "Test Cleanup Script" + 
	"`r`nA configurable solution to shut down applications that would interfere withtesting software." + 
	"`r`nProject availible at https://github.com/DigitDaemon/Test-Cleanup-Script" +
	"`r`n" +
	"`r`nCopyright (C) 2023 Thomas Landry" +
	"`r`n" +
	"`r`nThis program is free software: you can redistribute it and/or modify" +
	"`r`nit under the terms of the GNU General Public License as published by" +
	"`r`nthe Free Software Foundation, either version 3 of the License, or" +
	"`r`n(at your option) any later version." +
	"`r`n" +
	"`r`nThis program is distributed in the hope that it will be useful," +
	"`r`nbut WITHOUT ANY WARRANTY; without even the implied warranty of" +
	"`r`nMERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the" +
	"`r`nGNU General Public License for more details." +
	"`r`n" +
	"`r`nYou should have received a copy of the GNU General Public License" +
	"`r`nalong with this program.  If not, see <http://www.gnu.org/licenses/>."
}
Function Get-Arguments{
	Write-Host "The availible arguments for this application are:"+
		"`r`n`"-DebugOutput`" : Shows the debug text in the console."+
		"`r`n`"-Suppress`" : Stops this app from closing other apps when run."+
		"`r`n`"-Lincense`" : Displays the license information."+
		"`r`n`"-Instructions`" : Generates the Instructions and Example documents."+
		"`r`n`"-Directory`" : Optionally targets different directory for -Instructions command."+
		"`r`n`"-Help`" : Distplays this screen."
}

if($Help){
	Get-Arguments
	Exit 0
}

if($Instructions)
{
	Get-Instructions
	Exit 0
}

if($License)
{
	Get-License
	Read-Host "Press enter to exit"
	Exit 0
}
#Output License Disclaimer
if($DebugOutput){
	Write-Host "Test Cleanup Script Copyright (C) 2023 Thomas Landry"
    Write-Host "This program comes with ABSOLUTELY NO WARRANTY;For details visit "
    Write-Host "This is free software, and you are welcome to redistribute it"
    Write-Host "under certain conditions; type `show c' for details."
}

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
		if (-not $Suppress) {Stop-Process -Name $Target.ProcessName -Force}
		if ($DebugOutput) { Write-Host "Killed " $Target.ProcessName }
	}
}
Remove-Item $LocalSource

if ( -not ($Launch -like "")){
	try{
		Start-Process -FilePath $Launch
	}
	catch{
		Write-Host "There was an issue launching `""$Launch"`". Please check the file path or contact your IT admin for more help."
		Write-Host $message
		Write-Host $_
	}
}

if ($DebugOutput) { Read-Host "Press Enter to Exit" }
Exit 0