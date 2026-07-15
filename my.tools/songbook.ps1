<#
.SYNOPSIS
    Build the Chiran Songbook MOD melody index (SongbookData.plugindata).

.DESCRIPTION
    PowerShell port of the Chiran Songbook songbook.hta index generator.
    Scans the LOTRO Music folder for ABC and text song files, parses track
    headers, and writes SongbookData.plugindata for the in-game Songbook MOD.

.PARAMETER UserName
    LOTRO login name used for PluginData folder naming. Prompted when omitted.

.PARAMETER MusicPath
    Path to the LOTRO Music folder. Defaults to the standard Documents location.

.PARAMETER LotroHome
  Path to "The Lord of the Rings Online" folder under Documents (parent of Music
  and PluginData). Used when Documents has been relocated.

.PARAMETER JukeOnly
    Index only files under juke.* folders (e.g. juke.lute, juke.fiddle).

.PARAMETER AllUsers
    Write SongbookData.plugindata for every LOTRO player account found on this
    computer (UserPreferences.ini entries and PluginData folder names). Cannot
    be combined with -UserName.

.PARAMETER WhatIf
    Scan and report counts without writing SongbookData.plugindata.

.EXAMPLE
    .\songbook.ps1

    .\songbook.ps1 -UserName "MyChar" -JukeOnly

    .\songbook.ps1 -AllUsers -JukeOnly

.NOTES
    Compatible with Chiran Songbook MOD (songbook.hta output format).
    See also: my.tools/songbook.hta (original Chiran HTA, unmodified reference).
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [string]$UserName,
    [string]$MusicPath,
    [string]$LotroHome,
    [switch]$JukeOnly,
    [switch]$AllUsers
)

########################################################################
################## End-User Modifications (if needed) ##################

# File extensions to index (matches songbook.hta).
$songbook_extensions = @('.abc', '.txt')

# Before running this script; use "$env:MyVariable = "MyValue" to set
# and/or override defaults. See above e.g. $MusicPath or $LotroHome.

################## End-User Modifications (if needed) ##################
########################################################################

<#
.SYNOPSIS
    Find the full path to the LOTRO home directory.
#>
function GetLotroHomePath {
    param ([string]$OverridePath)

    if ($OverridePath) {
        return $OverridePath.TrimEnd('\')
    }

    $documents = [Environment]::GetFolderPath('MyDocuments')
    return Join-Path $documents 'The Lord of the Rings Online'
}

<#
.SYNOPSIS
    Parse the LOTRO *.ini config file for in-game character(s).
#>
function GetLotroUserNames {
    param ([string]$HomeDir)

    $userFile = Join-Path $HomeDir 'UserPreferences.ini'
    if (-not (Test-Path -LiteralPath $userFile)) {
        return @()
    }

    $names = [System.Collections.Generic.List[string]]::new()
    foreach ($line in Get-Content -LiteralPath $userFile) {
        if ($line -match '^UserName=(.+)$') {
            $name = $Matches[1].Trim()
            if ($name -and ($names -notcontains $name)) {
                $names.Add($name)
            }
        }
    }
    return $names.ToArray()
}

<#
.SYNOPSIS
    Isolate the LOTRO game account(s).
#>
function GetLotroPlayerAccounts {
    param ([string]$HomeDir)

    $accounts = [System.Collections.Generic.List[string]]::new()

    foreach ($name in GetLotroUserNames -HomeDir $HomeDir) {
        if ($accounts -notcontains $name) {
            $accounts.Add($name)
        }
    }

    $pluginDataRoot = Join-Path $HomeDir 'PluginData'
    if (Test-Path -LiteralPath $pluginDataRoot) {
        foreach ($dir in Get-ChildItem -LiteralPath $pluginDataRoot -Directory) {
            if ($accounts -notcontains $dir.Name) {
                $accounts.Add($dir.Name)
            }
        }
    }
    return ,$accounts.ToArray()
}

<#
.SYNOPSIS
    Confirm UserName parameter input vs. LOTRO login name.
#>
function SelectLotroUserName {
    param (
        [string[]]$KnownUsers,
        [string]$PreferredUser
    )

    if ($PreferredUser) {
        return $PreferredUser
    }

    if ($KnownUsers.Count -eq 1) {
        return $KnownUsers[0]
    }

    if ($KnownUsers.Count -gt 1) {
        Write-Host "`nFound LOTRO user names on this computer:"
        for ($i = 0; $i -lt $KnownUsers.Count; $i++) {
            Write-Host "  [$i] $($KnownUsers[$i])"
        }
        $defaultIndex = 0
        $pick = Read-Host "Select user number (default is [$defaultIndex]$($KnownUsers[$defaultIndex]))"
        if (-not $pick) {
            return $KnownUsers[$defaultIndex]
        }
        if ($pick -match '^\d+$' -and [int]$pick -lt $KnownUsers.Count) {
            return $KnownUsers[[int]$pick]
        }
        Write-Host "Invalid selection; using $($KnownUsers[$defaultIndex])." -ForegroundColor Yellow
        return $KnownUsers[$defaultIndex]
    }

    $manual = Read-Host "LOTRO Username (login name for PluginData folder)"
    return $manual.Trim()
}

<#
.SYNOPSIS
    Remove extra forward slashses.
#>
function FormatSongbookLuaString {
    param ([string]$Value)

    if ($null -eq $Value) {
        return ''
    }
    return $Value.Replace('\', '\\').Replace('"', '\"')
}

<#
.SYNOPSIS
    Parse out the Title aka "T: ..." line.
#>
function GetAbcTrackInfo {
    param ([string]$FilePath)

    $tracks = ''
    $realNames = ''
    $xpos = 0
    $tpos = 0

    foreach ($line in [System.IO.File]::ReadLines($FilePath)) {
        if ($line.Length -lt 2 -or $line[1] -ne ':') {
            continue
        }

        if ($line.StartsWith('X')) {
            $xpos++
            $track = $line.Substring(2).Replace("`r", '')
            $commentPos = $track.IndexOf('%')
            if ($commentPos -ge 0) {
                $track = $track.Substring(0, $commentPos)
            }
            $track = $track.Trim()
            if ($tracks -eq '') {
                $tracks = $track
            }
            else {
                $tracks = "$tracks,$track"
            }
        }
        elseif ($line.StartsWith('T')) {
            $tpos++
            $realName = $line.Substring(2).Replace("`r", '')
            $commentPos = $realName.IndexOf('%')
            if ($commentPos -ge 0) {
                $realName = $realName.Substring(0, $commentPos)
            }
            $realName = (FormatSongbookLuaString $realName.Trim())

            if ($tpos -eq $xpos) {
                if ($realNames -eq '') {
                    $realNames = $realName
                }
                else {
                    $realNames = "$realNames||$realName"
                }
            }
            else {
                $realNames = "$realNames - $realName"
            }
        }
    }

    if ($tracks -eq '') {
        $tracks = '1'
    }

    $trackIds = $tracks.Split(',', [System.StringSplitOptions]::None)
    if ($realNames -eq '') {
        $trackNames = @('')
    }
    else {
        $trackNames = $realNames.Split('||', [System.StringSplitOptions]::None)
    }

    while ($trackNames.Count -lt $trackIds.Count) {
        $trackNames += ''
    }

    return [PSCustomObject]@{
        TrackIds   = $trackIds
        TrackNames = $trackNames
    }
}

<#
.SYNOPSIS
    Find the relative path to *.abc file.
#>
function GetSongbookRelativePath {
    param (
        [string]$DirectoryPath,
        [string]$MusicRoot
    )

    $relative = $DirectoryPath.Substring($MusicRoot.Length).TrimStart('\')
    if ($relative) {
        return '/' + ($relative.Replace('\', '/')) + '/'
    }
    return '/'
}

<#
.SYNOPSIS
    Build a path to each sub directory.
#>
function AddSongbookDirectory {
    param (
        [System.Collections.Generic.List[string]]$Directories,
        [string]$RelativePath
    )

    if ($Directories -notcontains $RelativePath) {
        $Directories.Add($RelativePath)
    }
}

<#
.SYNOPSIS
    Test for valid / accessiable path.
#>
function TestJukeSongPath {
    param (
        [string]$RelativePath,
        [bool]$JukeOnlyMode
    )

    if (-not $JukeOnlyMode) {
        return $true
    }
    return $RelativePath -match '^/juke[^/]*/'
}

<#
.SYNOPSIS
    Find all *.abc files.
#>
function ReadSongbookDirectory {
    param (
        [System.IO.DirectoryInfo]$Directory,
        [string]$MusicRoot,
        [System.Collections.Generic.List[string]]$Directories,
        [System.Collections.Generic.List[object]]$Songs,
        [bool]$JukeOnlyMode,
        [ref]$ParseErrors
    )

    $relativeDir = GetSongbookRelativePath -DirectoryPath $Directory.FullName -MusicRoot $MusicRoot
    AddSongbookDirectory -Directories $Directories -RelativePath $relativeDir

    foreach ($file in $Directory.GetFiles() | Sort-Object Name) {
        $extension = $file.Extension.ToLowerInvariant()
        if ($songbook_extensions -notcontains $extension) {
            continue
        }

        $relativeFileDir = GetSongbookRelativePath -DirectoryPath $file.DirectoryName -MusicRoot $MusicRoot
        if (-not (TestJukeSongPath -RelativePath $relativeFileDir -JukeOnlyMode $JukeOnlyMode)) {
            continue
        }

        try {
            $trackInfo = GetAbcTrackInfo -FilePath $file.FullName
        }
        catch {
            $ParseErrors.Value++
            Write-Verbose "Failed to parse: $($file.FullName) ($_)"
            continue
        }

        $fileName = $file.Name
        if ($fileName.Length -gt 4) {
            $fileName = $fileName.Substring(0, $fileName.Length - 4)
        }

        $Songs.Add([PSCustomObject]@{
            Filepath   = $relativeFileDir
            Filename   = $fileName
            TrackIds   = $trackInfo.TrackIds
            TrackNames = $trackInfo.TrackNames
        })
    }

    foreach ($subDir in $Directory.GetDirectories() | Sort-Object Name) {
        if ($JukeOnlyMode -and $relativeDir -eq '/' -and $subDir.Name -notlike 'juke*') {
            continue
        }
        ReadSongbookDirectory -Directory $subDir -MusicRoot $MusicRoot `
            -Directories $Directories -Songs $Songs -JukeOnlyMode $JukeOnlyMode `
            -ParseErrors $ParseErrors
    }
}

<#
.SYNOPSIS
    Get root directory of *.abc files.
#>
function GetSongbookLibrary {
    param (
        [string]$MusicRoot,
        [bool]$JukeOnlyMode
    )

    $directories = [System.Collections.Generic.List[string]]::new()
    $songs = [System.Collections.Generic.List[object]]::new()
    $parseErrors = 0

    $musicDir = Get-Item -LiteralPath $MusicRoot
    ReadSongbookDirectory -Directory $musicDir -MusicRoot $musicDir.FullName `
        -Directories $directories -Songs $songs -JukeOnlyMode $JukeOnlyMode `
        -ParseErrors ([ref]$parseErrors)

    return [PSCustomObject]@{
        Directories = $directories
        Songs       = $songs
        ParseErrors = $parseErrors
    }
}

<#
.SYNOPSIS
    Format songbook data (as per Chiran MOD).
#>
function WriteSongbookPluginData {
    param (
        [object]$Library,
        [string]$OutputPath
    )

    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine('return')
    [void]$sb.AppendLine('{')

    [void]$sb.AppendLine("`t[""Directories""] =")
    [void]$sb.AppendLine("`t{")

    for ($i = 0; $i -lt $Library.Directories.Count; $i++) {
        $dirLine = "`t`t[$($i + 1)] = ""$($Library.Directories[$i])"""
        if ($i -lt ($Library.Directories.Count - 1)) {
            $dirLine += ','
        }
        [void]$sb.AppendLine($dirLine)
    }

    [void]$sb.AppendLine("`t},")
    [void]$sb.AppendLine("`t[""Songs""] =")
    [void]$sb.AppendLine("`t{")

    for ($i = 0; $i -lt $Library.Songs.Count; $i++) {
        $song = $Library.Songs[$i]
        [void]$sb.AppendLine("`t`t[$($i + 1)] = ")
        [void]$sb.AppendLine("`t`t{")
        [void]$sb.AppendLine("`t`t`t[""Filepath""] = ""$($song.Filepath)"",")
        [void]$sb.AppendLine("`t`t`t[""Filename""] = ""$($song.Filename)"",")
        [void]$sb.AppendLine("`t`t`t[""Tracks""] =")
        [void]$sb.AppendLine("`t`t`t{")

        for ($j = 0; $j -lt $song.TrackIds.Count; $j++) {
            [void]$sb.AppendLine("`t`t`t`t[$($j + 1)] =")
            [void]$sb.AppendLine("`t`t`t`t{")
            [void]$sb.AppendLine("`t`t`t`t`t[""Id""] =""$($song.TrackIds[$j])"",")
            [void]$sb.AppendLine("`t`t`t`t`t[""Name""] =""$($song.TrackNames[$j])""")
            if ($j -lt ($song.TrackIds.Count - 1)) {
                [void]$sb.AppendLine("`t`t`t`t},")
            }
            else {
                [void]$sb.AppendLine("`t`t`t`t}")
            }
        }

        [void]$sb.AppendLine("`t`t`t}")

        if ($i -lt ($Library.Songs.Count - 1)) {
            [void]$sb.AppendLine("`t`t},")
        }
        else {
            [void]$sb.AppendLine("`t`t}")
        }
    }

    [void]$sb.AppendLine("`t}")
    [void]$sb.AppendLine('}')

    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($OutputPath, $sb.ToString(), $utf8NoBom)
}

<#
.SYNOPSIS
    Write the songbook file.
#>
function PublishSongbookLibrary {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [object]$Library,
        [string]$HomeDir,
        [string]$AccountName
    )

    $dataDir = Join-Path $HomeDir "PluginData\$AccountName\AllServers"
    $outputFile = Join-Path $dataDir 'SongbookData.plugindata'

    if ($PSCmdlet.ShouldProcess($outputFile, "Write Songbook index for $AccountName")) {
        if (-not (Test-Path -LiteralPath $dataDir)) {
            New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
        }

        WriteSongbookPluginData -Library $Library -OutputPath $outputFile
    }
    return $outputFile
}

########################################################################
################ Main Body (Console, Data, User Input) #################
########################################################################

Clear-Host
Write-Host $('-' * 24) $MyInvocation.MyCommand.Name / $Env:UserName $('-' * 24)

if ($AllUsers -and $UserName) {
    Write-Host "-AllUsers cannot be used with -UserName." -ForegroundColor Red
    exit 1
}

$lotroHome = GetLotroHomePath -OverridePath $LotroHome
if (-not $MusicPath) {
    $MusicPath = Join-Path $lotroHome 'Music'
}
else {
    $MusicPath = $MusicPath.TrimEnd('\')
}

if (-not (Test-Path -LiteralPath $MusicPath)) {
    Write-Host "Music folder not found: $MusicPath" -ForegroundColor Red
    if (-not $LotroHome) {
        Write-Host "If Documents was relocated, rerun with -LotroHome `"D:\Path\The Lord of the Rings Online`"" -ForegroundColor Yellow
    }
    exit 1
}

if ($AllUsers) {
    $targetUsers = GetLotroPlayerAccounts -HomeDir $lotroHome
    if ($targetUsers.Count -eq 0) {
        Write-Host "No LOTRO player accounts found in UserPreferences.ini or PluginData." -ForegroundColor Red
        exit 1
    }
}
else {
    $knownUsers = GetLotroUserNames -HomeDir $lotroHome
    $selectedUser = SelectLotroUserName -KnownUsers $knownUsers -PreferredUser $UserName
    if (-not $selectedUser) {
        Write-Host "LOTRO username is required." -ForegroundColor Red
        exit 1
    }
    $targetUsers = @($selectedUser)
}

Write-Host "Music path : $MusicPath" -ForegroundColor Blue
if ($AllUsers) {
    Write-Host "Accounts   : $($targetUsers -join ', ')" -ForegroundColor Blue
}
else {
    Write-Host "LOTRO user : $($targetUsers[0])" -ForegroundColor Blue
}
if ($JukeOnly) {
    Write-Host "Scan mode  : juke.* folders only" -ForegroundColor Blue
}
Write-Host $('-' * 24) $MyInvocation.MyCommand.Name / $Env:UserName $('-' * 24)

Write-Host "`nScanning ABC files..."
$library = GetSongbookLibrary -MusicRoot $MusicPath -JukeOnlyMode ([bool]$JukeOnly)

$outputFiles = [System.Collections.Generic.List[string]]::new()
foreach ($account in $targetUsers) {
    $outputFiles.Add((PublishSongbookLibrary -Library $library -HomeDir $lotroHome -AccountName $account))
}

Write-Host "`nGenerated song library." -ForegroundColor Green
Write-Host "Found $($library.Songs.Count) song files in $($library.Directories.Count) directories."
if ($library.ParseErrors -gt 0) {
    Write-Host "Skipped $($library.ParseErrors) files due to read/parse errors." -ForegroundColor Yellow
}

if ($AllUsers) {
    Write-Host "Updated $($targetUsers.Count) player account(s)." -ForegroundColor Green
}

if (-not $WhatIfPreference) {
    Write-Host "`nSong library saved to:"
    foreach ($path in $outputFiles) {
        Write-Host $path -ForegroundColor Green
    }
}
else {
    Write-Host "`nWhatIf: no files were written." -ForegroundColor Yellow
}
