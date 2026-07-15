<#
.SYNOPSIS
    Package each instrument folder into a separate jukebox ZIP archive.

.DESCRIPTION
    Scans the LOTRO Music folder for juke* directories, removes matching
    archives under 999.songs/, then creates fresh ZIP files for upload
    (GitHub, GitLab, Gitea, etc.).

.PARAMETER MusicPath
    Path to the LOTRO Music folder. Defaults to Documents\The Lord of the
    Rings Online\Music.

.PARAMETER Destination
    Folder where juke*.zip archives are written. Defaults to <repo>\999.songs.

.PARAMETER Compression
    Compress-Archive level: Fastest, Optimal, or NoCompression. Default Fastest.

.PARAMETER WhatIf
    Show what would be packaged without purging or writing ZIP files.

.EXAMPLE
    .\zip_loop.ps1

.EXAMPLE
    .\zip_loop.ps1 -MusicPath "D:\Games\LOTRO\Music" -Compression Optimal

.EXAMPLE
    .\zip_loop.ps1 -WhatIf

.NOTES
    WARNING:
    If Powershell script execution is blocked by the local security
    policy, then try the following steps to allow:

        Start a new Powershell session as admin  i.e. "Run as administrator"
        Run the following commands:
            Get-ExecutionPolicy -List
            Set-ExecutionPolicy Unrestricted
            Get-ExecutionPolicy -List

    ASSUMPTION:
        - Using the latest version of Powershell (i.e. version 7 or above)
            - Powershell ISE will also work (as per Execution Policy above)
            - Default MSW Powershell should work too (e.g. version 3 or 5)
        - Cloned: https://github.com/awuehler/juke.lute (i.e. this repository)
        - juke* folders exist under the LOTRO Music directory
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [string]$MusicPath,
    [string]$Destination,
    [ValidateSet('Fastest', 'Optimal', 'NoCompression')]
    [string]$Compression = 'Fastest'
)

########################################################################
################## End-User Modifications (if needed) ##################

# Defaults apply when -MusicPath / -Destination are omitted.
# Override from the command line, or edit these values if preferred.

# Before running this script; use "$env:MyVariable = "MyValue" to set
# and/or override defaults. See above e.g. $MusicPath or $Destination.

################## End-User Modifications (if needed) ##################
########################################################################

$RepoRoot = Split-Path -Path $PSScriptRoot -Parent

function Get-DefaultMusicPath {
    $documents = [Environment]::GetFolderPath('MyDocuments')
    return Join-Path $documents 'The Lord of the Rings Online\Music'
}

<#
.SYNOPSIS
    List the current set of zip files checked into the Git repo.
#>
function ShowJukeArchives {
    param (
        [string]$ArchiveFolder
    )

    $zipFiles = @(Get-ChildItem -LiteralPath $ArchiveFolder -File -Filter 'juke*.zip' -ErrorAction SilentlyContinue)
    if ($zipFiles.Count -eq 0) {
        Write-Host "  (none)"
        return
    }

    foreach ($zip in $zipFiles) {
        Get-ItemProperty -LiteralPath $zip.FullName
    }
}

<#
.SYNOPSIS
  Remove the current set of zip files soon to be replaced by new versions.  
#>
function RemoveJukeArchives {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [string]$ArchiveFolder,
        [string[]]$ArchiveNames
    )

    foreach ($name in $ArchiveNames) {
        $zipPath = Join-Path $ArchiveFolder "$name.zip"
        if (-not (Test-Path -LiteralPath $zipPath -PathType Leaf)) {
            continue
        }

        if ($PSCmdlet.ShouldProcess($zipPath, 'Remove existing juke archive')) {
            try {
                Remove-Item -LiteralPath $zipPath -Force -ErrorAction Stop
            }
            catch {
                Write-Host "Could not remove ${zipPath}: $_" -ForegroundColor Yellow
            }
        }
    }
}

<#
.SYNOPSIS
    Generate a new collection of *.zip files to be checked into the Git repo.
#>
function NewJukeArchives {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [System.IO.DirectoryInfo[]]$Folders,
        [string]$ArchiveFolder,
        [string]$CompressionLevel
    )

    $successCount = 0
    $failureCount = 0

    foreach ($folder in $Folders) {
        $destinationPath = Join-Path $ArchiveFolder "$($folder.Name).zip"

        if (-not $PSCmdlet.ShouldProcess($destinationPath, "Create archive from $($folder.FullName)")) {
            continue
        }

        Write-Host "Packaging $($folder.Name)..."
        try {
            Compress-Archive -LiteralPath $folder.FullName -DestinationPath $destinationPath `
                -CompressionLevel $CompressionLevel -Force -ErrorAction Stop
            $successCount++
        }
        catch {
            $failureCount++
            Write-Host "Failed to package $($folder.Name): $_" -ForegroundColor Red
        }
    }

    return [PSCustomObject]@{
        SuccessCount = $successCount
        FailureCount = $failureCount
    }
}

########################################################################
################ Main Body (Console, Data, User Input) #################
########################################################################

Clear-Host
Write-Host $('-' * 24) $MyInvocation.MyCommand.Name / $Env:UserName $('-' * 24)

if (-not $MusicPath) {
    $MusicPath = Get-DefaultMusicPath
}
else {
    $MusicPath = $MusicPath.TrimEnd('\')
}

if (-not $Destination) {
    $Destination = Join-Path $RepoRoot '999.songs'
}
else {
    $Destination = $Destination.TrimEnd('\')
}

if (-not (Test-Path -LiteralPath $MusicPath -PathType Container)) {
    Write-Host "LOTRO Music folder not found: $MusicPath" -ForegroundColor Red
    Write-Host "Pass -MusicPath if Documents or LOTRO folders were relocated." -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path -LiteralPath $Destination -PathType Container)) {
    Write-Host "Archive output folder not found: $Destination" -ForegroundColor Red
    Write-Host "Expected repository layout: <repo>\999.songs\ and <repo>\my.tools\zip_loop.ps1" -ForegroundColor Yellow
    exit 1
}

$discoveredJukeFolders = @(Get-ChildItem -LiteralPath $MusicPath -Directory -Filter 'juke*')
if ($discoveredJukeFolders.Count -eq 0) {
    Write-Host "No juke* folders found under: $MusicPath" -ForegroundColor Red
    Write-Host "Extract at least one juke.<instrument> archive into the Music folder first." -ForegroundColor Yellow
    exit 1
}

$archiveNames = @($discoveredJukeFolders | ForEach-Object { $_.Name })

Write-Host "Music path : $MusicPath" -ForegroundColor Blue
Write-Host "Output path: $Destination" -ForegroundColor Blue
Write-Host "Compression: $Compression" -ForegroundColor Blue
Write-Host "Found $($discoveredJukeFolders.Count) juke folder(s): $($archiveNames -join ', ')" -ForegroundColor Blue
Write-Host $('-' * 24) $MyInvocation.MyCommand.Name / $Env:UserName $('-' * 24)
Write-Host ""

Write-Host "BEFORE:"
ShowJukeArchives -ArchiveFolder $Destination
Write-Host ""

RemoveJukeArchives -ArchiveFolder $Destination -ArchiveNames $archiveNames
$result = NewJukeArchives -Folders $discoveredJukeFolders -ArchiveFolder $Destination -CompressionLevel $Compression

Write-Host "`nAFTER:"
ShowJukeArchives -ArchiveFolder $Destination

Write-Host ""
if ($WhatIfPreference) {
    Write-Host "WhatIf: no archives were removed or written." -ForegroundColor Yellow
}
else {
    Write-Host "Created $($result.SuccessCount) archive(s)." -ForegroundColor Green
    if ($result.FailureCount -gt 0) {
        Write-Host "Failed $($result.FailureCount) archive(s)." -ForegroundColor Red
        exit 1
    }
}
