<#
.SYNOPSIS
    Script to play a random sequence of ABC files with AbcPlayer or Maestro
    kept in any folder(s) contained under the default LOTRO Music folder.

.DESCRIPTION
    This script is used to open an ABC player to load a random melody file
    for output to the default audio end point (earbud, headset, & etc).

    It will repeat this task until user input to stop (exit) from this script.

.PARAMETER MusicPath
    Path to the LOTRO Music folder. Defaults to Documents\The Lord of the
    Rings Online\Music.

.PARAMETER PlayerPath
    Full path to AbcPlayer.exe (option 1).

.PARAMETER EditorPath
    Full path to Maestro.exe (option 2).

.PARAMETER PauseSeconds
    Seconds to wait between melodies (added to each track duration).

.PARAMETER History
    Number of recent melodies to avoid repeating.

.EXAMPLE
    .\jukebox.ps1

.EXAMPLE
    .\jukebox.ps1 -MusicPath "D:\Games\LOTRO\Music" -PauseSeconds 5

.NOTES
    WARNING:
    If Powershell script execution is blocked by your MSW security policy,
    then try the following steps to allow the execution of *.ps1 files:

        Start a new Powershell session as admin  i.e. "Run as administrator"
        Run the following commands:
            Get-ExecutionPolicy -List
            Set-ExecutionPolicy Unrestricted
            Get-ExecutionPolicy -List

    ASSUMPTION:
        - Using the latest version of Powershell (i.e. version 7 or above)
            - Powershell ISE will also work (as per Execution Policy above)
            - Default MSW Powershell should work too (e.g. version 3 or 5)
        - Installed: ABC Player & Maestro (https://github.com/digero/maestro)
        - At least one juke.<instrument> folder exists under the Music path
        - Title field in each *.abc file contains duration i.e. "T: ...(mm:ss)..."
        - ...

    TODO:
        - Add pick by metadata options (i.e. keys, beats, keywords, so on)
        - Add check and application restart after N iterations
        - Add user prompt to include 2nd folder
        - ...
#>

[CmdletBinding()]
param (
    [string]$MusicPath,
    [string]$PlayerPath,
    [string]$EditorPath,
    [int]$PauseSeconds = -1,
    [int]$History = -1
)

########################################################################
################## End-User Modifications (if needed) ##################
# History of previously played ABC files to avoid repeat selections.
$music_abc_history = 3

# Add a delay between each melody selection (in seconds).
$music_abc_pause = 3

# Fallback duration when the Title key:value pair is missing (mm:ss). 
$music_abc_fallback = '0:55'

# Default Music folder (Documents), overridable via -MusicPath.
$music_abc_path = Join-Path ([Environment]::GetFolderPath('MyDocuments')) `
    'The Lord of the Rings Online\Music'

# Default player apps (assumes default install location), overridable via params.
$music_player = 'C:\Program Files (x86)\Maestro\AbcPlayer.exe'
$music_editor = 'C:\Program Files (x86)\Maestro\Maestro.exe'

# Shared folder names offered as cross-instrument choices (lowercase).
# Only these appear as simple shared picks (e.g. favs across every juke.* tree).
# Add more names here later, e.g. @('favs', 'folk', 'spirit').
$music_shared_folders = @('favs')

# Bare instrument-root choices listed first in the instrument grouping
# (after shared picks). Maps from on-disk juke.bassoon -> bassoon, etc.
$music_leading_instruments = @('bassoon', 'flute', 'violin')

# Before running this script; use "$env:MyVariable = "MyValue" to set
# and/or override defaults. See above e.g. $MusicPath.

################## End-User Modifications (if needed) ##################
########################################################################

if ($MusicPath) { $music_abc_path = $MusicPath.TrimEnd('\') }
if ($PlayerPath) { $music_player = $PlayerPath }
if ($EditorPath) { $music_editor = $EditorPath }
if ($PauseSeconds -ge 0) {
    if ($PauseSeconds -gt 3600) {
        Write-Host "-PauseSeconds must be between 0 and 3600." -ForegroundColor Red
        exit 1
    }
    $music_abc_pause = $PauseSeconds
}
if ($History -ge 0) {
    if ($History -gt 100) {
        Write-Host "-History must be between 0 and 100." -ForegroundColor Red
        exit 1
    }
    $music_abc_history = $History
}
<#
.SYNOPSIS
    Pick a random melody, avoiding recent history when possible.
#>
function ProbabilityPick {
    param (
        $abc_list
    )

    $paths = @($abc_list)
    if ($paths.Count -eq 0) {
        throw "ProbabilityPick called with an empty melody list."
    }

    try {
        # Prefer a tune not in recent history when the pool is large enough.
        $candidates = @($paths | Where-Object { $script:MelodyTrack -notcontains $_ })
        if ($candidates.Count -eq 0) {
            $candidates = $paths
        }
        return ($candidates | Get-Random)
    }
    catch {
        Write-Host "An error occurred to select a melody file..." -ForegroundColor Red
        Write-Host $_
        throw
    }
}

<#
.SYNOPSIS
    Strip the juke. prefix from a Music-relative path for display/selection.
    juke.lute\folk -> lute\folk
#>
function ConvertFromJukeRelativePath {
    param ([string]$RelativePath)

    if ($RelativePath -match '^juke\.([^\\]+)(\\.*)?$') {
        return ($Matches[1] + $Matches[2]).ToLowerInvariant()
    }
    return $RelativePath.ToLowerInvariant()
}

<#
.SYNOPSIS
    Restore the on-disk juke.* relative path from a display selection.
    lute\folk -> juke.lute\folk
#>
function ConvertToJukeRelativePath {
    param ([string]$DisplayPath)

    if ([string]::IsNullOrWhiteSpace($DisplayPath)) {
        return $DisplayPath
    }

    $normalized = $DisplayPath.Trim().TrimStart('\').ToLowerInvariant()
    if ($normalized -match '^juke\.') {
        return $normalized
    }

    $parts = $normalized -split '[\\/]', 2
    if ($parts.Count -eq 1) {
        return "juke.$($parts[0])"
    }
    return "juke.$($parts[0])\$($parts[1])"
}

<#
.SYNOPSIS
    Restrict the full library to melodies for a folder selection (or all).

    Selection forms:
      all              - entire library
      favs             - shared leaf from $music_shared_folders (across instruments)
      lute\folk        - one instrument bucket (maps to juke.lute\folk)
#>
function GetFolderMelodyPool {
    param (
        $abc_list,
        [string]$FolderName,
        [string]$MusicRoot,
        [string[]]$SharedFolders = @('favs')
    )

    if ($FolderName -eq 'all') {
        return @($abc_list)
    }

    $rootFull = (Get-Item -LiteralPath $MusicRoot).FullName.TrimEnd('\')
    $sharedSet = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($name in @($SharedFolders)) {
        if ($name) { [void]$sharedSet.Add($name.Trim().ToLowerInvariant()) }
    }

    $isSharedLeaf = ($FolderName -notmatch '[\\/]') -and $sharedSet.Contains($FolderName.ToLowerInvariant())
    $targetRelative = if ($isSharedLeaf) { $null } else { ConvertToJukeRelativePath $FolderName }

    $filtered = @(
        foreach ($path in @($abc_list)) {
            $parent = Split-Path -Path $path -Parent
            if ($parent.Length -lt $rootFull.Length) { continue }
            $relativeParent = $parent.Substring($rootFull.Length).TrimStart('\')

            if ($isSharedLeaf) {
                $leaf = Split-Path -Path $relativeParent -Leaf
                if ($leaf -and ($leaf -ieq $FolderName)) {
                    $path
                }
            }
            elseif ($relativeParent -and ($relativeParent -ieq $targetRelative)) {
                $path
            }
        }
    )
    return $filtered
}

<#
.SYNOPSIS
    Build a sorted folder menu: allowlisted shared leaves, then leading
    instrument roots (bassoon/flute/violin), then remaining instrument
    paths without the juke. prefix (lute\folk).
#>
function GetMusicFolderList {
    param (
        $abc_list,
        [string]$MusicRoot,
        [string[]]$SharedFolders = @('favs'),
        [string[]]$LeadingInstruments = @('bassoon', 'flute', 'violin')
    )

    $rootFull = (Get-Item -LiteralPath $MusicRoot).FullName.TrimEnd('\')
    $sharedAllow = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($name in @($SharedFolders)) {
        if ($name) { [void]$sharedAllow.Add($name.Trim().ToLowerInvariant()) }
    }

    $sharedFound = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    $instrumentFolders = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)

    foreach ($path in @($abc_list)) {
        $parent = Split-Path -Path $path -Parent
        if ($parent.Length -lt $rootFull.Length) { continue }
        $relativeParent = $parent.Substring($rootFull.Length).TrimStart('\')
        if (-not $relativeParent) { continue }

        if ($relativeParent -match '^juke\.') {
            # Strip juke. for both roots (juke.flute -> flute) and nested paths.
            $display = ConvertFromJukeRelativePath $relativeParent
            if ($relativeParent -match '^juke\.[^\\]+\\') {
                $leaf = (Split-Path -Path $relativeParent -Leaf).ToLowerInvariant()
                if ($leaf -and $sharedAllow.Contains($leaf)) {
                    [void]$sharedFound.Add($leaf)
                }
            }
            [void]$instrumentFolders.Add($display)
        }
        else {
            # Non-juke paths keep a lowercase relative listing.
            [void]$instrumentFolders.Add($relativeParent.ToLowerInvariant())
        }
    }

    $menu = [System.Collections.Generic.List[string]]::new()
    # Preserve allowlist order for shared entries that actually exist.
    foreach ($name in @($SharedFolders)) {
        $key = $name.Trim().ToLowerInvariant()
        if ($key -and $sharedFound.Contains($key)) {
            $menu.Add($key)
        }
    }

    # Leading bare instrument roots first (bassoon, flute, violin), then the rest.
    $remaining = [System.Collections.Generic.List[string]]::new()
    foreach ($folder in $instrumentFolders) {
        $remaining.Add($folder)
    }
    foreach ($name in @($LeadingInstruments)) {
        $key = $name.Trim().ToLowerInvariant()
        if ($key -and $instrumentFolders.Contains($key)) {
            $menu.Add($key)
            [void]$remaining.Remove($key)
        }
    }
    foreach ($folder in ($remaining | Sort-Object)) {
        $menu.Add($folder)
    }
    return @($menu)
}

<#
.SYNOPSIS
    Recursively stop a process and its descendants (Maestro launcher + Java UI).
#>
function StopProcessTree {
    param (
        [int]$ProcessId
    )

    if ($ProcessId -le 0) {
        return
    }

    try {
        $children = @(Get-CimInstance -ClassName Win32_Process -Filter "ParentProcessId = $ProcessId" -ErrorAction SilentlyContinue)
        foreach ($child in $children) {
            StopProcessTree -ProcessId ([int]$child.ProcessId)
        }
    }
    catch {
        Write-Verbose "Could not enumerate children of ${ProcessId}: $_"
    }

    try {
        Stop-Process -Id $ProcessId -Force -ErrorAction Stop
    }
    catch {
        Write-Verbose "Could not stop process ${ProcessId}: $_"
    }
}

<#
.SYNOPSIS
    Stop leftover Java processes started from the Maestro/AbcPlayer install folder.
#>
function StopMaestroJavaChildren {
    param (
        [string]$InstallDirectory
    )

    if (-not $InstallDirectory) {
        return
    }

    $root = $InstallDirectory.TrimEnd('\')
    try {
        $jvmProcs = @(Get-CimInstance -ClassName Win32_Process -ErrorAction SilentlyContinue |
            Where-Object {
                $_.Name -match '^(java|javaw)\.exe$' -and
                $_.ExecutablePath -and
                $_.ExecutablePath.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)
            })
        foreach ($proc in $jvmProcs) {
            try {
                Stop-Process -Id ([int]$proc.ProcessId) -Force -ErrorAction Stop
            }
            catch {
                Write-Verbose "Could not stop JVM $($proc.ProcessId): $_"
            }
        }
    }
    catch {
        Write-Verbose "Could not scan for Maestro JVM processes: $_"
    }
}

<#
.SYNOPSIS
    Delete tracked player redirect logs, if present and unlocked.
#>
function RemovePlayerLogFiles {
    param (
        [string[]]$LogPaths
    )

    foreach ($path in @($LogPaths)) {
        if (-not $path) { continue }
        try {
            if (Test-Path -LiteralPath $path -PathType Leaf) {
                Remove-Item -LiteralPath $path -Force -ErrorAction Stop
            }
        }
        catch {
            Write-Verbose "Could not remove player log ${path}: $_"
        }
    }
}

<#
.SYNOPSIS
    Remove stale jukebox-player-*.log files older than the given age.
#>
function ClearStalePlayerLogs {
    param (
        [int]$OlderThanHours = 24
    )

    $cutoff = (Get-Date).AddHours(-1 * [Math]::Abs($OlderThanHours))
    try {
        Get-ChildItem -LiteralPath $env:TEMP -File -Filter 'jukebox-player-*.log' -ErrorAction SilentlyContinue |
            Where-Object { $_.LastWriteTime -lt $cutoff } |
            ForEach-Object {
                try {
                    Remove-Item -LiteralPath $_.FullName -Force -ErrorAction Stop
                }
                catch {
                    Write-Verbose "Could not prune stale log $($_.FullName): $_"
                }
            }
    }
    catch {
        Write-Verbose "Could not scan TEMP for stale player logs: $_"
    }
}

<#
.SYNOPSIS
    Stop the previously launched AbcPlayer/Maestro process tree, if any.
#>
function StopJukeboxPlayer {
    $rootPid = $null
    if ($null -ne $script:PlayerProcess) {
        try {
            $rootPid = [int]$script:PlayerProcess.Id
        }
        catch {
            $rootPid = $null
        }
    }

    if ($rootPid) {
        StopProcessTree -ProcessId $rootPid
    }

    # Maestro's WinRun4J launcher often leaves a Java UI process behind.
    if ($script:PlayerExeDirectory) {
        StopMaestroJavaChildren -InstallDirectory $script:PlayerExeDirectory
    }

    $script:PlayerProcess = $null

    # Logs are unlocked once the launcher process has exited.
    RemovePlayerLogFiles -LogPaths @($script:PlayerStdoutLog, $script:PlayerStderrLog)
    $script:PlayerStdoutLog = $null
    $script:PlayerStderrLog = $null
}

<#
.SYNOPSIS
    Start an ABC player program and pass in the selected *.abc file.
    Stops any previous player process first to avoid stacking/overlap.
    Maestro/AbcPlayer launcher stdout and stderr are redirected away from
    the console so [info] lines do not pollute the jukebox output.
#>
function PlayMelody {
    param (
        [Parameter(Mandatory)]
        [string]$AbcPath,

        [Parameter(Mandatory)]
        [string]$PlayerExePath,

        [string]$PlayerLabel = 'player'
    )

    StopJukeboxPlayer

    $exePath = $PlayerExePath
    # Unique files per launch so a quick restart cannot collide with still-open logs.
    $logStamp = '{0:yyyyMMddHHmmssfff}-{1}' -f (Get-Date), [guid]::NewGuid().ToString('N').Substring(0, 8)
    $stdoutLog = Join-Path $env:TEMP "jukebox-player-$logStamp.stdout.log"
    $stderrLog = Join-Path $env:TEMP "jukebox-player-$logStamp.stderr.log"
    $script:PlayerStdoutLog = $stdoutLog
    $script:PlayerStderrLog = $stderrLog
    $script:PlayerExeDirectory = Split-Path -Path $exePath -Parent

    try {
        # RedirectStandard* detaches the child from this console (required to
        # hide WinRun4J/Maestro launcher chatter). WindowStyle cannot be used
        # together with these redirects.
        $script:PlayerProcess = Start-Process -FilePath $exePath `
            -ArgumentList "`"$AbcPath`"" `
            -WorkingDirectory $script:PlayerExeDirectory `
            -RedirectStandardOutput $stdoutLog `
            -RedirectStandardError $stderrLog `
            -PassThru -ErrorAction Stop
    }
    catch {
        Write-Host "An error occurred to run ${PlayerLabel}: " -ForegroundColor Red
        Write-Host $_
        $script:PlayerProcess = $null
        RemovePlayerLogFiles -LogPaths @($stdoutLog, $stderrLog)
        $script:PlayerStdoutLog = $null
        $script:PlayerStderrLog = $null
    }
}

<#
.SYNOPSIS
    Read the first T: header title text and optional (mm:ss) duration from an ABC file.
.OUTPUTS
    Hashtable with Title and Duration (mm:ss) keys.
#>
function GetAbcTitleInfo {
    param (
        [string]$FilePath,
        [string]$Fallback = '0:55'
    )

    $fileTitle = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)

    try {
        foreach ($line in [System.IO.File]::ReadLines($FilePath)) {
            if ($line -notmatch '^T:') {
                continue
            }

            $titleText = $line.Substring(2).Trim()
            $commentPos = $titleText.IndexOf('%')
            if ($commentPos -ge 0) {
                $titleText = $titleText.Substring(0, $commentPos).Trim()
            }

            $duration = $Fallback
            if ($titleText -match '\((\d{1,2}):(\d{2})\)') {
                $duration = '{0}:{1:D2}' -f [int]$Matches[1], [int]$Matches[2]
                # Prefer text before the duration marker as the song title.
                $before = $titleText.Substring(0, $titleText.IndexOf($Matches[0])).Trim()
                $after = $titleText.Substring($titleText.IndexOf($Matches[0]) + $Matches[0].Length).Trim()
                if ($before) {
                    $titleText = $before
                }
                elseif ($after) {
                    $titleText = $after
                }
                else {
                    $titleText = $fileTitle
                }
            }

            if (-not $titleText) {
                $titleText = $fileTitle
            }

            return @{
                Title    = $titleText
                Duration = $duration
            }
        }
    }
    catch {
        Write-Verbose "Title parse failed for ${FilePath}: $_"
    }

    return @{
        Title    = $fileTitle
        Duration = $Fallback
    }
}

<#
.SYNOPSIS
    Convert mm:ss duration text to track length in seconds (no pause).
#>
function ConvertDurationToSeconds {
    param (
        [string]$time
    )

    $fallbackSeconds = 55
    if ($music_abc_fallback -match '^(\d{1,2}):(\d{2})$') {
        $fallbackSeconds = ([int]$Matches[1] * 60) + [int]$Matches[2]
    }

    if (-not $time) {
        return $fallbackSeconds
    }

    $normalized = $time.Trim().Trim('()')
    if ($normalized -notmatch '^(\d{1,2}):(\d{2})$') {
        Write-Host "Invalid duration '$time'; using fallback $music_abc_fallback." -ForegroundColor Yellow
        return $fallbackSeconds
    }

    $minutes = [int]$Matches[1]
    $seconds = [int]$Matches[2]
    if ($seconds -gt 59) {
        Write-Host "Invalid duration seconds in '$time'; using fallback $music_abc_fallback." -ForegroundColor Yellow
        return $fallbackSeconds
    }

    return ($minutes * 60) + $seconds
}

<#
.SYNOPSIS
    Select the next melody and return Path, Title, and Duration.
#>
function NextMelody {
    $path = ProbabilityPick $script:active_melody_pool

    $titleInfo = GetAbcTitleInfo -FilePath $path -Fallback $music_abc_fallback

    if ($music_abc_history -le 0) {
        $script:MelodyTrack = @()
    }
    else {
        $updated = @($script:MelodyTrack) + @($path)
        $script:MelodyTrack = @($updated | Select-Object -Last $music_abc_history)
    }

    return [pscustomobject]@{
        Path     = $path
        Title    = $titleInfo.Title
        Duration = $titleInfo.Duration
    }
}

<#
.SYNOPSIS
    Map a console key to 'quit', 'skip', or $null if none / not a control key.
#>
function ReadMelodyControlKey {
    try {
        if (-not [Console]::KeyAvailable) {
            return $null
        }

        $key = [Console]::ReadKey($true)
        if ($key.Key -eq 'Escape' -or $key.KeyChar -eq 'q' -or $key.KeyChar -eq 'Q') {
            return 'quit'
        }
        return 'skip'
    }
    catch {
        return $null
    }
}

<#
.SYNOPSIS
    Wait for track playback, supporting skip (any key) and quit (Q/Escape).
    Returns 'continue', 'skip', or 'quit'. Falls back to plain sleep when
    console input is unavailable (redirected stdin).
#>
function WaitMelodyInterval {
    param (
        [int]$TotalSeconds
    )

    if ($TotalSeconds -lt 0) { $TotalSeconds = 0 }

    $consoleReady = $true
    try {
        # Drain any buffered keys from earlier prompts.
        while ([Console]::KeyAvailable) {
            [void][Console]::ReadKey($true)
        }
    }
    catch {
        $consoleReady = $false
    }

    if (-not $consoleReady) {
        if ($TotalSeconds -gt 0) {
            Start-Sleep -Seconds $TotalSeconds
        }
        return 'continue'
    }

    $remaining = [double]$TotalSeconds
    while ($remaining -gt 0) {
        $slice = [Math]::Min(0.5, $remaining)
        Start-Sleep -Seconds $slice
        $remaining -= $slice

        $action = ReadMelodyControlKey
        if ($action) {
            return $action
        }
    }

    $action = ReadMelodyControlKey
    if ($action) {
        return $action
    }

    return 'continue'
}

<#
.SYNOPSIS
    Seed MelodyTrack with distinct paths from the active pool.
#>
function InitializeMelodyHistory {
    param (
        $MelodyPool,
        [int]$HistorySize
    )

    if ($HistorySize -le 0) {
        return @()
    }

    $paths = @($MelodyPool | Select-Object -Unique)

    if ($paths.Count -eq 0) {
        return @()
    }

    $take = [Math]::Min($HistorySize, $paths.Count)
    return @($paths | Get-Random -Count $take)
}

<#
.SYNOPSIS
    Trim whitespace and surrounding quotes from a path value.
#>
function GetUnquotedPath {
    param ([string]$PathValue)
    if (-not $PathValue) { return $PathValue }
    return $PathValue.Trim().Trim('"')
}

########################################################################
################ Main Body (Console, Data, User Input) #################
########################################################################

# Fail fast when Music folder is missing.
if (-not (Test-Path -LiteralPath $music_abc_path -PathType Container)) {
    Write-Host "LOTRO Music folder not found: $music_abc_path" -ForegroundColor Red
    Write-Host "Extract at least one juke.<instrument> archive into the Music folder first." -ForegroundColor Yellow
    exit 1
}

$music_player = GetUnquotedPath $music_player
$music_editor = GetUnquotedPath $music_editor

# Use do - while loop to request from user which application to use.
do {
    Clear-Host
    # Request user input to confirm playback.
    Write-Host $("-" * 24) $MyInvocation.MyCommand.Name / $Env:UserName $("-" * 24)
    Write-Host "$music_player `tPress '1' for this option."
    Write-Host "$music_editor `tPress '2' for this option.`n"
    Write-Host "NOTE:     Use -MusicPath / -PlayerPath / -EditorPath / -PauseSeconds / -History to override defaults" -ForegroundColor Blue
    Write-Host "PATH:     $music_abc_path" -ForegroundColor Blue
    Write-Host "PAUSE:    $music_abc_pause seconds between each melody" -ForegroundColor Blue
    Write-Host "HISTORY:  $music_abc_history melodies (i.e. no repeats)" -ForegroundColor Blue
    Write-Host $("-" * 24) $MyInvocation.MyCommand.Name / $Env:UserName $("-" * 24)
    # Set default selection to "PLAYER" program.
    $def_player = "1"
    # Capture user selection for re-use.
    $player_type = Read-Host "Please enter which player to use (default is AbcPlayer)"
    # Test user input (none vs. number) and assign default when null.
    if (-NOT $player_type) { $player_type = $def_player }
} while ($player_type -notmatch '^[12]$')

# Validate only the chosen player executable.
$chosen_player_path = if ($player_type -eq '1') { $music_player } else { $music_editor }
$chosen_player_label = if ($player_type -eq '1') { 'AbcPlayer' } else { 'Maestro' }
if (-not (Test-Path -LiteralPath $chosen_player_path -PathType Leaf)) {
    Write-Host "$chosen_player_label not found: $chosen_player_path" -ForegroundColor Red
    Write-Host "Install Maestro/AbcPlayer or pass -PlayerPath / -EditorPath." -ForegroundColor Yellow
    exit 1
}
Write-Host "Using $chosen_player_label at $chosen_player_path" -ForegroundColor Blue
# Build an array list of melody files.
try {
    # NOTE: if additional non-juke ABC files are found, they will also be
    #       indexed. And if they don't meet the assumptions noted above
    #       about an accurate ...(mm:ss)... playtime duration included in
    #       the T: ... title field then roll-over to the next melody will
    #       be incorrect i.e. truncated playback of ABC file to next one.
    $music_collection = @(Get-ChildItem -LiteralPath $music_abc_path -Recurse -File -Filter "*.abc" -ErrorAction Stop |
        ForEach-Object -MemberName FullName)
}
catch {
    Write-Host "Failed to scan ABC files under: $music_abc_path" -ForegroundColor Red
    Write-Host $_
    exit 1
}

if ($music_collection.Count -eq 0) {
    Write-Host "No *.abc files found under: $music_abc_path" -ForegroundColor Red
    Write-Host "Extract at least one juke.<instrument> archive into the Music folder first." -ForegroundColor Yellow
    exit 1
}

Write-Host "Found $($music_collection.Count) ABC file(s) under $music_abc_path" -ForegroundColor Blue

# Build folder menu: allowlisted shared leaves (favs), then instrument paths
# without the juke. prefix (lute\folk). All entries are lowercase.
$folder_array = @(GetMusicFolderList -abc_list $music_collection -MusicRoot $music_abc_path `
    -SharedFolders $music_shared_folders -LeadingInstruments $music_leading_instruments)
# Include an all-folders selection and use it as the default choice.
$folder_array += 'all'

# Use do - while loop to request from user which folder(s) to use.
$folder_pick_index = -1
do {
    # Display folders to select (lowercase labels).
    Write-Host "`nAvailable folders: "
    foreach ($tune in $folder_array) {
        $ndx = $folder_array.IndexOf("$tune")
        Write-Host "[$ndx]$tune  " -NoNewline
    }
    # Set default selection to "all" folders.
    $def_folder = [Int]$folder_array.IndexOf('all')
    # Capture user selection, if any index number is entered
    $folder_pick = Read-Host ("`nPlease enter the number for which folder to use (default is [{0}]all)" -f $def_folder)
    # Empty input -> default "all".
    if (-not $folder_pick) {
        $folder_pick_index = $def_folder
    }
    elseif ($folder_pick -match '^\d+$') {
        $folder_pick_index = [int]$folder_pick
        if ($folder_pick_index -lt 0 -or $folder_pick_index -ge $folder_array.Count) {
            $folder_pick_index = -1
        }
    }
    else {
        # Non-numeric input: re-prompt without throwing on [int] cast.
        $folder_pick_index = -1
    }
} while ($folder_pick_index -lt 0)

# Pre-filter the library for the chosen folder (avoids rejection-sampling hangs).
$selected_folder = $folder_array[$folder_pick_index]
$script:active_melody_pool = GetFolderMelodyPool -abc_list $music_collection -FolderName $selected_folder `
    -MusicRoot $music_abc_path -SharedFolders $music_shared_folders
if ($script:active_melody_pool.Count -eq 0) {
    Write-Host "No ABC files found in folder selection: $selected_folder" -ForegroundColor Red
    exit 1
}
Write-Host "Playing from [$selected_folder] ($($script:active_melody_pool.Count) file(s))." -ForegroundColor Blue

# Seed history from the selected pool with distinct paths when possible.
$script:MelodyTrack = @(InitializeMelodyHistory -MelodyPool $script:active_melody_pool -HistorySize $music_abc_history)
Write-Host "History seed: $($script:MelodyTrack.Count) distinct track(s)." -ForegroundColor Blue

# Use loop to iterate through melodies until quit (Q/Escape).
$script:PlayerProcess = $null
$script:PlayerExeDirectory = $null
$script:PlayerStdoutLog = $null
$script:PlayerStderrLog = $null
ClearStalePlayerLogs -OlderThanHours 24
$jukebox_running = $true
try {
    while ($jukebox_running) {
        # Pick the next tune.
        $new_melody = NextMelody
        # Display title and duration for upcoming melody
        $trackSeconds = ConvertDurationToSeconds $new_melody.Duration
        $sleepSeconds = $trackSeconds + [int]$music_abc_pause
        Write-Host "`nTitle     : $($new_melody.Title)"
        Write-Host "Playtime  : $($new_melody.Duration) ($trackSeconds seconds)"
        Write-Host "Wait      : $sleepSeconds seconds (includes ${music_abc_pause}s pause)"
        Write-Host "Selection : $(Split-Path -Path $new_melody.Path -Leaf) ($(Split-Path -Path (Split-Path -Path $new_melody.Path -Parent) -Leaf))"
        # Run player (stops any previous instance first).
        PlayMelody -AbcPath $new_melody.Path -PlayerExePath $chosen_player_path -PlayerLabel $chosen_player_label
        Write-Host "To Skip   : Press any key to jump to the next melody."
        Write-Host "To Stop   : Press Q or Escape to exit the jukebox."
        $waitResult = WaitMelodyInterval -TotalSeconds $sleepSeconds
        if ($waitResult -eq 'quit') {
            Write-Host "`nJukebox stopped." -ForegroundColor Green
            $jukebox_running = $false
        }
        elseif ($waitResult -eq 'skip') {
            # End current playback immediately before the next melody.
            StopJukeboxPlayer
        }
    }
}
finally {
    # Always stop player on quit, Ctrl+C, or unhandled error.
    StopJukeboxPlayer
}
