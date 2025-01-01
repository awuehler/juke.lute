<#
.SYNOPSIS
    Script to play multiple *.abc files using AbcPlayer.exe or Maestro.exe

.DESCRIPTION
    This script is used to open either aforementioned programs to load a
    selected ABC melody file for output to the default audio end point
    (speaker, headset, etc).

    Run this script and follow its prompt to define a playlist of melodies.

        e.g. ".\play_pack.ps1"
    
    If PowerShell script execution is blocked by the local security policy,
    then try the following steps to allow the execution of *.ps1 files:

        Start a new Powershell session as admin  i.e. "Run as administrator"
        Run the following commands:
            Get-ExecutionPolicy -List
            Set-ExecutionPolicy Unrestricted
            Get-ExecutionPolicy -List

    ASSUMPTIONS:
        - Using the latest version of Powershell (i.e. vesion 7 or above)
            - PowerShell ISE should work (as per Execution Policy above)
            - Default PowerShell (e.g. version 3 or 5) should also work
        - Installed: ABC Player & Maestro (https://github.com/digero/maestro)
        - Installed: juke.lute (C:\Users\***\Documents\The Lord of the Rings Online\Music)
        - Title field in each *.abc file contains duration i.e. "T: ...(mm:ss)..."
        - ...

    TODO:
        - Add skip to next random melody keyboard input e.g. "spacebar"
        - Build setup wizard to craft play list
            - pick list of folders
            - set default path to juke.lute vs. juke.flute vs. juke.xyz
            - set default path to Maestro / ABCplayer
        - Track previous melodies to skip when reselected via random pick
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

# Build a collection of melody files.
try {
    $music_collection = ( Get-ChildItem -Path $music_abc_path -Recurse -File | Select-Object -Property FullName )
}
catch {
    Write-Host "An error occurred to juke.lute: "
    Write-Host $_
}

# Create placeholder array.
$folder_array = @()
# Add folders into array (assumes flat directory structure).
foreach ($melody in $music_collection) {
    $file_parent = Split-Path -Path "$melody" -Parent
    $file_folder = Split-Path -Path "$file_parent" -Leaf
    # Unique folders only.
    if ($folder_array -notcontains $file_folder) {
        $folder_array += $file_folder
    }
}
$folder_array += "ALL"

# Pick a random melody (testing).
try {
    $global:music_random = ( $music_collection | Get-Random | Select-Object -ExpandProperty FullName )
}
catch {
    Write-Host "An error occurred to select a melody file..."
    Write-Host $_
}

# Function: Select type of application to play *.abc files
function PlayMelody {

    # One parameter to pass into function.
    param (
        $app
    )

    # Run application based on user input.
    if ($app -eq "1") {
        # Run player and send standard output to null.
        Start-Process $music_player -ArgumentList $($new_melody[1]) -RedirectStandardOutput ".\NUL"
    } else {
        # Run editor and send standard output to null.
        Start-Process $music_editor -ArgumentList $($new_melody[1]) -RedirectStandardOutput ".\NUL"
    }

    return
}

# Function: See https://codepal.ai/code-generator/query/rY3Q5FYh/format-time-to-seconds
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

# Function: Select a new melody then return an array of variables
function NextMelody {

    # Pick a new melody.
    #$random_melody = ( $music_collection | Get-Random | Select-Object -ExpandProperty FullName )

    # Condition checking (as per folder selection).
    if ($folder_array[[Int]$folder_pick] -match 'ALL') {
        # Pick a new melody.
        $random_melody = ( $music_collection | Get-Random | Select-Object -ExpandProperty FullName )
    }
    #elseif (<#condition#>) {
    #    <# Action when this condition is true #>
    #}
    #Write-Host $folder_pick $folder_array[[Int]$folder_pick]
    #11 long5

    # Check for back to back duplicates.
    if ($random_melody -eq $global:music_random) {
        # NOTE: Back to back duplicates can still occur, BTW.
        # This kluge is a basic hack to lower its probability.
        $random_melody = ( $music_collection | Get-Random | Select-Object -ExpandProperty FullName )
    } else {
        $global:music_random = $random_melody
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
    return @( $random_melody, $music_maestro, $music_content, $music_abc_title, $music_abc_title_short, $music_abc_title_time )
}

# Confirm which application to use.
do {
    Clear-Host
    
    # User input to confirm playback.
    Write-Host $("-" * 24) $MyInvocation.MyCommand.Name / $Env:UserName $("-" * 24)
    Write-Host "$music_player `t  Press '1' for this option."
    Write-Host "$music_editor `t  Press '2' for this option."
    Write-Host "(**NOTE: Edit this script to change default paths or pause between melodies**)" -ForegroundColor Red
    Write-Host $("-" * 24) $MyInvocation.MyCommand.Name / $Env:UserName $("-" * 24)

    # Capture user selection for re-use.
    $player_type = Read-Host "Please enter which player to use (must be 1 or 2)"
} while (-not ($player_type -match '^\d?1|2'))

# Confirm which folder(s) to use.
do {
    # Display folders to select.
    Write-Host "`nAvailable folders: "
    foreach ($tune in $folder_array) {
        $ndx = $folder_array.IndexOf("$tune")
        Write-Host "[$ndx]$($tune.ToUpper())  " -NoNewline
    }

    # Capture user selection for re-use.
    $folder_pick = Read-Host "`nPlease enter which folders to use (must be number)"

    #if ($folder_pick -le "$folder_array.Length") {
    #    Write-Host "TRUE"
    #} else {
    #    Write-Host "FALSE"
    #}

} while ( ( (-not ($folder_pick -match '^\d+$')) -AND ($folder_pick -le "$folder_array.Length") ) )

# Simple do - until loop to iterate through melodies.
do {
    $new_melody = NextMelody
    Write-Host "`nPlaytime  : $($new_melody[5]) ($(FormatTimeToSecond $($new_melody[5])) seconds)"
    Write-Host "Selection : $(Split-Path -Path "$($new_melody[0])" -Leaf) ($(Split-Path -Path $(Split-Path -Path "$($new_melody[0])" -Parent) -Leaf))"

    # Run player and send standard output to null.
    PlayMelody $player_type

    #Write-Host "To Skip   : Use TBD key to jump to next melody. "
    Write-Host "To Stop   : Use CTRL-C key to exit the jukebox."

    # TODO: Change to support continue to next melody...
    #$keyInfo = [Console]::ReadKey()
    #$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    Start-Sleep -Seconds $(FormatTimeToSecond $($new_melody[5]))

} until ( [System.Console]::KeyAvailable )
#} until ($null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown'))
