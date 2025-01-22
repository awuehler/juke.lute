<#
.SYNOPSIS
    Script to package each instrument folder into a separate zip file.

.DESCRIPTION
    Automate the steps to add the updated *.abc files into compressed
    packages for upload to a target i.e. GitHub.

.EXAMPLE
    Run this script after each and every music modification to maintain
    an up to date zip file of tunes from CWD: ..\juke.lute\my.tools

        e.g. ".\zip_loop.ps1"

.NOTES
    WARNING:
    If PowerShell script execution is blocked by the local security
    policy, then try the following steps to allow:

        Start a new Powershell session as admin  i.e. "Run as administrator"
        Run the following commands:
            Get-ExecutionPolicy -List
            Set-ExecutionPolicy Unrestricted
            Get-ExecutionPolicy -List

    ASSUMPTION:
        - Using the latest version of Powershell (i.e. version 7 or above)
            - PowerShell ISE will also work (as per Execution Policy above)
            - Default MSW PowerShell should work too (e.g. version 3 or 5)
        - Cloned: https://github.com/awuehler/juke.lute (i.e. this repository)
        - Default LOTRO Music folder is located under the C:\ drive
        - ...

    TODO:
        - Add option to submit the actual path to the LOTRO Music folder
            to remove the assumption for user edits to fix pathing issues
        - ...
#>

<#
.SYNOPSIS
    Global static parameters used for Cmdlets, Functions, & etc.
#>
# Initial compression parameters.
[string]$MyCompression          = "NoCompression" # Fastest / NoCompression / Optimal
[string]$MyWorkingDirectory     = $(Get-Location)
[string]$MyParentDirectory      = Split-Path -Path $MyWorkingDirectory -Parent
[string]$MyAbcDirectory         = "C:\Users\$Env:UserName\Documents\The Lord of the Rings Online\Music"

<#
.SYNOPSIS
    Discover available juke folders.
#>
function JukeFolders {
    # Collect all juke music folders.
    $AbcFolders = Get-ChildItem -Path $MyAbcDirectory
    # Iterate through each child object.
    foreach ($JukeInstrument in $AbcFolders) {
        # Limit to folders that begin with "juke".
        if ((Split-Path -Path $JukeInstrument -Leaf) -like "juke*") {
            # Compression parameters.
            $SourcePath            = "$MyParentDirectory\..\..\Documents\The Lord of the Rings Online\Music\$(Split-Path -Path $JukeInstrument -Leaf)\"
            $TargetDestinationPath = "$MyParentDirectory\999.songs\$(Split-Path -Path $JukeInstrument -Leaf).zip"
            $ZipCompressionLevel   = "$MyCompression"
            # Create a new ZIP archive.
            Compress-Archive -Path $SourcePath -DestinationPath $TargetDestinationPath -CompressionLevel $ZipCompressionLevel -Update
        }
    }
}

<#
.SYNOPSIS
    Target the previous version of ZIP files.
#>
function TargetPrevious {
    param (
        $target_folder,
        $target_action     # "console" or "purge"
    )
    # Collect all files contained within the folder.
    $ZipFiles = Get-ChildItem -Path $target_folder
    foreach ($jukebox in $ZipFiles) {
        $fileZip = Get-ChildItem -Path $jukebox | Select-Object -ExpandProperty Extension
        # Limit to ZIP files.
        if ($fileZip -eq ".zip") {
            # Check for which action to process.
            if ($target_action -eq "purge") {
                # Remove each ZIP file beforehand.
                try {
                    Remove-Item -Path $jukebox -Force -erroraction SilentlyContinue
                }
                catch {
                    <# Do this if a terminating exception happens... #>
                }
            } elseif ($target_action -eq "console") {
                 Get-ItemProperty -Path $jukebox
            }
        }
    }
}

########################################################################
################ Main Body (Console, Data, User Input) #################
########################################################################

# Clear the PowerShell console window.
Clear-Host

# Display summary of the ZIP files. (before)
Write-Host "BEFORE:"
TargetPrevious "$MyParentDirectory\999.songs\" "console"

# Remove current ZIP files.
Write-Host
TargetPrevious "$MyParentDirectory\999.songs\" "purge"

# Generate new ZIP files.
JukeFolders

# Display summary of the ZIP files. (after)
Write-Host "AFTER:`n"
TargetPrevious "$MyParentDirectory\999.songs\" "console"
