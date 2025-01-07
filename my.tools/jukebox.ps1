<#
.SYNOPSIS
    Script to play a random list of *.abc files using AbcPlayer or Maestro
    using the lute instrument (default).

.DESCRIPTION
    This script is used to open an ABC player to load a selected melody file
    for output to the default audio end point (speaker, headset, & etc).

    It will repeat this task until user input to stop (exit) from the player.

    Double-click to run this script or open a PowerShell console window on
    your desktop to run this script from any directory. Follow its prompts
    to create a new session of randomly selected melodies for listening.

        e.g. ".\jukebox.ps1"
    
    The default instrument (i.e. "X: 1" inside the *.abc file) is mapped to
    the "Lute Of Ages" instrument in both the AbcPlayer and Maestro programs.
        - Because the other %% lines added by Maestro have been removed
          from the solo instrument *.abc files in the juke.lute folder
          which were used to identify the other types of instruments

    WARNING:
    If PowerShell script execution is blocked by your MSW security policy,
    then try the following steps to allow the execution of *.ps1 scripts:

        Start a new Powershell session as admin  i.e. "Run as administrator"
        Run the following commands:
            Get-ExecutionPolicy -List
            Set-ExecutionPolicy Unrestricted
            Get-ExecutionPolicy -List

    ASSUMPTION:
        - Using the latest version of Powershell (i.e. version 7 or above)
            - PowerShell ISE will also work (as per Execution Policy above)
            - Default MSW PowerShell should work too (e.g. version 3 or 5)
        - Installed: ABC Player & Maestro (https://github.com/digero/maestro)
        - Installed: juke.lute (C:\Users\***\Documents\The Lord of the Rings Online\Music)
        - Title field in each *.abc file contains duration i.e. "T: ...(mm:ss)..."
        - ...

    TODO:
        - Add skip to next random melody keyboard input e.g. "spacebar"
        - Expand the setup wizard to allow:
            - set default path to juke.lute vs. juke.flute vs. juke.xyz
            - set default path to Maestro / AbcPlayer
            - set default pause between each *.abc melody file
        - Track previous melodies to skip
            - to avoid repeats within a given folder of tunes
        - Remove duplicate code and rewrite back-to-back duplicate checking
        - Add pick by metadata options (i.e. keys, beats, keywords, so on)
        - ...
#>

########################################################################
################## End-User Modifications (if needed) ##################
# Add a pause between each music session.
$music_abc_title_pause = 4

# Capture the current username (assumes the default user location is used).
$music_abc_path = "C:\Users\$Env:UserName\Documents\The Lord of the Rings Online\Music\juke.lute"

# Define safe paths to each application (assumes the default install location is used).
$music_player = """C:\Program Files (x86)\Maestro\AbcPlayer.exe"""
$music_editor = """C:\Program Files (x86)\Maestro\Maestro.exe"""
################## End-User Modifications (if needed) ##################
########################################################################

# Build an array list of melody files.
try {
    $music_collection = ( Get-ChildItem -Path $music_abc_path -Recurse -File | Select-Object -Property FullName )
}
catch {
    Write-Host "An error occurred to juke.lute: "
    Write-Host $_
}

# Seed an initial random pick for test and verify.
try {
    $global:music_random = ( $music_collection | Get-Random | Select-Object -ExpandProperty FullName )
}
catch {
    Write-Host "An error occurred to select a melody file..."
    Write-Host $_
}

# Build an array list of sub folders within the juke box (assumes flat directory structure).
$folder_array = @()
# Find each (unique) folder across all *.abc files.
foreach ($melody in $music_collection) {
    $file_parent = Split-Path -Path "$melody" -Parent
    $file_folder = Split-Path -Path "$file_parent" -Leaf

    # Test to add unique folders only.
    if ($folder_array -NOTcontains $file_folder) {
        $folder_array += $file_folder
    }
}
$folder_array += "ALL"

<#
.SYNOPSIS
    Pick a random melody to test and verify (assumes Get-Random is not pseudo random i.e. biased).
#>
function ProbabilityPick {
    param (
        $abc_list
    )

    try {
        $abc_pick = ( $abc_list | Get-Random | Select-Object -ExpandProperty FullName )
    }
    catch {
        Write-Host "An error occurred to select a melody file..."
        Write-Host $_
    }

    return $abc_pick
}

<#
.SYNOPSIS
    Start one of the ABC player programs and pass in the selected *.abc file.
#>
function PlayMelody {
    # One parameter to pass into function.
    param (
        $abc_program
    )

    # Run application based on user input. 
    if ($abc_program -eq "1") {
        try {
            # Run player and send standard output to null.
            Start-Process $music_player -ArgumentList $($new_melody[1]) -RedirectStandardOutput ".\NUL"
        }
        catch {
            Write-Host "An error occurred to run AbcPlayer program: "
            Write-Host $_
        }
    } else {
        try {
            # Run editor and send standard output to null.
            Start-Process $music_editor -ArgumentList $($new_melody[1]) -RedirectStandardOutput ".\NUL"
        }
        catch {
            Write-Host "An error occurred to run Maestro program: "
            Write-Host $_
        }
    }

    return
}

<#
.SYNOPSIS
    Function: See https://codepal.ai/code-generator/query/rY3Q5FYh/format-time-to-seconds
#>
function FormatTimeToSecond {
    # One parameter to pass into function.
    param (
        [string]$time
    )

    # Split the time values into minutes and seconds.
    $minutes, $seconds = $time -split ":"
    # Convert to seconds (integer).
    [Int]$minutes *= 60
    # Add minutes and seconds for total seconds (integer).
    $totalSeconds = [Int]$minutes + [Int]$seconds + [Int]$music_abc_title_pause

    # Return total duration with included pause between melodies.
    return $totalSeconds
}

<#
.SYNOPSIS
    Function: Select a new melody then return an array of variables
#>
function NextMelody {
    # Condition checking (as per folder selection).
    if ($folder_array[[Int]$folder_pick] -match 'ALL') {
        $random_melody = ProbabilityPick $music_collection
        # Check for back to back duplicates.
        # TODO: re-factor to remove duplicate code
        if ($random_melody -eq $global:music_random) {
            # NOTE: Back to back duplicates can still occur, BTW.
            # This kluge is a basic hack to lower its probability.
            $random_melody = ProbabilityPick $music_collection
            $global:music_random = $random_melody
        } else {
            $global:music_random = $random_melody
        }
    }
    else {
        # Repeat the random melody pick until a tune from target folder is returned.
        do {
            $random_melody = ProbabilityPick $music_collection
            # Check for back to back duplicates.
            # TODO: re-factor to remove duplicate code
            if ($random_melody -eq $global:music_random) {
                # NOTE: Back to back duplicates can still occur, BTW.
                # This kluge is a basic hack to lower its probability.
                $random_melody = ProbabilityPick $music_collection
                $global:music_random = $random_melody
            } else {
                $global:music_random = $random_melody
            }
        # Include matching backslashes to restrict pattern matches to folder names only.
        } until ($random_melody -match "\\" + $folder_array[[Int]$folder_pick] + "\\")
    }

    # Set sheltering for parameter placement.
    $music_maestro = """" + ( $random_melody ) + """"
    $music_content = "'"  + ( $random_melody ) + "'"

    # Extract title.
    $music_abc_title         = ( Select-String -Path $random_melody -Pattern '^T: ' )
    $music_abc_title_string  = $music_abc_title.ToString()
    $music_abc_title_length  = $music_abc_title_string.Length
    $music_abc_title_length -= 9
    
    # Extract time.
    $music_abc_title_short = $music_abc_title_string.Remove( 0, $music_abc_title_length )
    $music_abc_title_time  = ( $music_abc_title_short  -replace '.*\(' -replace '\).*' )

    # Remove new selection from collection.
    #$music_collection = $music_collection | ? {$_.Server -ne $random_melody}

    # Return an array of values.
    return @($random_melody, $music_maestro, $music_content, $music_abc_title, $music_abc_title_short, $music_abc_title_time)
}

<#
.SYNOPSIS
    Use do - while loop to request from user which application to use.
#>
do {
    Clear-Host
    
    # Request user input to confirm playback.
    Write-Host $("-" * 24) $MyInvocation.MyCommand.Name / $Env:UserName $("-" * 24)
    Write-Host "$music_player `t Press '1' for this option."
    Write-Host "$music_editor `t Press '2' for this option."
    Write-Host "(NOTE:  Edit this script to change default paths or pause between melodies)" -ForegroundColor Blue
    Write-Host $("-" * 24) $MyInvocation.MyCommand.Name / $Env:UserName $("-" * 24)

    # Set default selection to "PLAYER" program.
    $def_player = "1"
    # Capture user selection for re-use.
    $player_type = Read-Host "Please enter which player to use (default is AbcPlayer)"
    # Test user input (none vs. number) and assign default when null.
    if (-NOT $player_type) {$player_type = $def_player}

} while (-NOT ($player_type -match '^\d?1|2'))

<#
.SYNOPSIS
    Use do - while loop to request from user which folder(s) to use.
#>
do {
    # Display folders to select.
    Write-Host "`nAvailable folders: "
    foreach ($tune in $folder_array) {
        $ndx = $folder_array.IndexOf("$tune")
        Write-Host "[$ndx]$($tune.ToUpper())  " -NoNewline
    }

    # Set default selection to "ALL" folders.
    $def_folder = [Int]$folder_array.IndexOf('ALL')
    # Capture user selection, if any index number is entered
    $folder_pick = Read-Host ("`nPlease enter the number for which folder to use (default is [{0}]ALL)" -f $def_folder)
    # Test user input (none vs. number) and assign default when null.
    if (-NOT $folder_pick) {$folder_pick = $def_folder}

} while (-NOT (($folder_pick -match '^\d+$') -AND ($folder_pick -le $folder_array.Length - 1)) )

<#
.SYNOPSIS
    Use do - until loop to iterate through melodies until user input to exit.
#>
do {
    # Pick the next tune.
    $new_melody = NextMelody

    # Display title and duration for upcoming melody
    Write-Host "`nPlaytime  : $($new_melody[5]) ($(FormatTimeToSecond $($new_melody[5])) seconds)"
    Write-Host "Selection : $(Split-Path -Path "$($new_melody[0])" -Leaf) ($(Split-Path -Path $(Split-Path -Path "$($new_melody[0])" -Parent) -Leaf))"

    # Run player and send standard output to null.
    PlayMelody $player_type

    #Write-Host "To Skip   : Use TBD key to jump to next melody. "
    Write-Host "To Stop   : Use CTRL-C key to exit the jukebox."

    # TODO: Change to support continue to next melody.
    Start-Sleep -Seconds $(FormatTimeToSecond $($new_melody[5]))

} until ([System.Console]::KeyAvailable)
