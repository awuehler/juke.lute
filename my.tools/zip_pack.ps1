<#
.SYNOPSIS
    Script to package a tune folder into a zip file.

.DESCRIPTION
    Automate the steps to include any updated files in the
    compressed package for upload to target.

    Run this script after each and every music modification
    to maintain an up to date zip file of tunes.

        e.g. ".\zip_pack.ps1"
    
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
#>

<#
.SYNOPSIS
    Global static parameters used for Cmdlets, Functions, & etc.
#>
[string]$MyWorkingDirectory = $(Get-Location)
[string]$MyParentDirectory  = Split-Path -Path $MyWorkingDirectory -Parent
[string]$MyLeafDirectory    = Split-Path -Path $MyParentDirectory -Leaf

# TODO: Change this path as per the local navigation between the GitHub and Music folders
[string]$MyMusicDirectory   = "$MyParentDirectory\..\..\Documents\The Lord of the Rings Online\Music\juke.lute\"

[string]$MyCompression      = "NoCompression" # Fastest / NoCompression / Optimal
[string]$MyZipFile          = "$MyParentDirectory\999.songs\$MyLeafDirectory.zip"

<#
.SYNOPSIS
    Purge previous version of zip file.
#>
Remove-Item -Path $MyZipFile -Force

<#
.SYNOPSIS
    As per:
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.archive/compress-archive?view=powershell-7.3

    Assumptions:
        - an up to date PowerShell environment is in use
        - overwrite the existing zip file when present
#>
$compress = @{
    Path             = "$MyMusicDirectory"
    CompressionLevel = "$MyCompression"
    DestinationPath  = "$MyZipFile"
    }
Compress-Archive @compress -Update

<#
.SYNOPSIS
    Standard output for user confirmation.
#>
Write-Host
Write-Host $compress
Get-ItemProperty -Path $MyZipFile
Write-Host
