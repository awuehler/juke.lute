<#
.SYNOPSIS
    Script to package a tune folder into a zip file.

.DESCRIPTION
    Automate the steps to include any updated files in the
    compressed package for upload to target.

.EXAMPLE
    Run this script after each and every music modification
    to maintain an up to date zip file of tunes.

        e.g. ".\zip_pack.ps1"

.NOTES
    If PowerShell script execution is blocked by the local
    security policy, then try the following steps to allow:

        Start a new Powershell session as admin  i.e. "Run as administrator"
        Run the following commands:
            Get-ExecutionPolicy -List
            Set-ExecutionPolicy Unrestricted
            Get-ExecutionPolicy -List

    TODO:
        - Add option to submit the actual path to the Music folder
            to remove the assumption for user edits to fix pathing issues
        - Support multiple juke.* folders
        - Rewrite to use an array of sub folders to generate zip files
#>

<#
.SYNOPSIS
    Global static parameters used for Cmdlets, Functions, & etc.
#>
# Initial compression parameters.
[string]$MyCompression          = "NoCompression" # Fastest / NoCompression / Optimal
[string]$MyWorkingDirectory     = $(Get-Location)
[string]$MyParentDirectory      = Split-Path -Path $MyWorkingDirectory -Parent
[string]$MyAbcDirectory         = "$MyParentDirectory\..\..\Documents\The Lord of the Rings Online\Music\"

# Setup each folder.
[string]$MyDuetDirectory        = "$MyParentDirectory\..\..\Documents\The Lord of the Rings Online\Music\juke.duet\"
[string]$MyDuetLeafDirectory    = Split-Path -Path $MyDuetDirectory -Leaf
[string]$MyDuetZipFile          = "$MyParentDirectory\999.songs\$MyDuetLeafDirectory.zip"

[string]$MyFiddleDirectory      = "$MyParentDirectory\..\..\Documents\The Lord of the Rings Online\Music\juke.fiddle\"
[string]$MyFiddleLeafDirectory  = Split-Path -Path $MyFiddleDirectory -Leaf
[string]$MyFiddleZipFile        = "$MyParentDirectory\999.songs\$MyFiddleLeafDirectory.zip"

[string]$MyFluteDirectory       = "$MyParentDirectory\..\..\Documents\The Lord of the Rings Online\Music\juke.flute\"
[string]$MyFluteLeafDirectory   = Split-Path -Path $MyFluteDirectory -Leaf
[string]$MyFluteZipFile         = "$MyParentDirectory\999.songs\$MyFluteLeafDirectory.zip"

[string]$MyLuteDirectory        = "$MyParentDirectory\..\..\Documents\The Lord of the Rings Online\Music\juke.lute\"
[string]$MyLuteLeafDirectory    = Split-Path -Path $MyLuteDirectory -Leaf
[string]$MyLuteZipFile          = "$MyParentDirectory\999.songs\$MyLuteLeafDirectory.zip"

[string]$MyViolinDirectory      = "$MyParentDirectory\..\..\Documents\The Lord of the Rings Online\Music\juke.violin\"
[string]$MyViolinLeafDirectory  = Split-Path -Path $MyViolinDirectory -Leaf
[string]$MyViolinZipFile        = "$MyParentDirectory\999.songs\$MyViolinLeafDirectory.zip"

<#
.SYNOPSIS
    Purge previous version of zip files.
#>
function PurgePrevious {
    param (
        $target_folder
    )

    # Catch the file extension name.
    $ZipFiles = Get-ChildItem -Path $target_folder
    foreach ($jukebox in $ZipFiles) {
        $fileZip = Get-ChildItem -Path $jukebox | Select-Object -ExpandProperty Extension
        if ($fileZip -eq ".zip") {
            # Remove each *.zip file beforehand.
            try {
                Remove-Item -Path $jukebox -Force -erroraction SilentlyContinue
            }
            catch {
                <# Do this if a terminating exception happens... #>
            }
        }
    }
}

PurgePrevious $MyParentDirectory\999.songs\

<#
.SYNOPSIS
    As per:
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.archive/compress-archive?view=powershell-7.3

    Assumptions:
        - an up to date PowerShell environment is in use
        - overwrite the existing zip file when present
#>
# juke.duet
$compressDUET = @{
    Path             = "$MyDuetDirectory"
    CompressionLevel = "$MyCompression"
    DestinationPath  = "$MyDuetZipFile"
    }
Compress-Archive @compressDUET -Update
# juke.fiddle
$compressFIDDLE = @{
    Path             = "$MyFiddleDirectory"
    CompressionLevel = "$MyCompression"
    DestinationPath  = "$MyFiddleZipFile"
    }
Compress-Archive @compressFIDDLE -Update
# juke.flute
$compressFLUTE = @{
    Path             = "$MyFluteDirectory"
    CompressionLevel = "$MyCompression"
    DestinationPath  = "$MyFluteZipFile"
    }
Compress-Archive @compressFLUTE -Update
# juke.lute
$compressLUTE = @{
    Path             = "$MyLuteDirectory"
    CompressionLevel = "$MyCompression"
    DestinationPath  = "$MyLuteZipFile"
    }
Compress-Archive @compressLUTE -Update
# juke.violin
$compressVIOLIN = @{
    Path             = "$MyViolinDirectory"
    CompressionLevel = "$MyCompression"
    DestinationPath  = "$MyViolinZipFile"
    }
Compress-Archive @compressVIOLIN -Update

<#
.SYNOPSIS
    Standard output for user confirmation.
#>
Write-Host
Write-Host $compressDUET
Get-ItemProperty -Path $MyDuetZipFile
Write-Host
Write-Host
Write-Host $compressFIDDLE
Get-ItemProperty -Path $MyFiddleZipFile
Write-Host
Write-Host
Write-Host $compressFLUTE
Get-ItemProperty -Path $MyFluteZipFile
Write-Host
Write-Host
Write-Host $compressLUTE
Get-ItemProperty -Path $MyLuteZipFile
Write-Host
Write-Host
Write-Host $compressVIOLIN
Get-ItemProperty -Path $MyViolinZipFile
Write-Host

