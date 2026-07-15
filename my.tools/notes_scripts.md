# Table Of Contents

- [Table Of Contents](#table-of-contents)
  - [Jukebox Player](#jukebox-player)
    - [Player Example](#player-example)
  - [Localhost Webserver](#localhost-webserver)
    - [Webserver Example](#webserver-example)
  - [ZIP Creator](#zip-creator)
    - [ZIP Example](#zip-example)
  - [Songbook Index](#songbook-index)
    - [Songbook Example](#songbook-example)

## Jukebox Player

Script to play a random sequence of ABC files using either AbcPlayer or Maestro. The default LOTRO Music folder is used to build a list of melodies. Then a random melody file is picked for listening at the default audio end point (desktop speaker, earbud, headset, & etc), and random ABC file selection continues until user input to stop/exit.

- The script can be started from any location (via GUI or CLI) and it will prompt the user with several options to customize their music session
  - Please review the comments contained within the Powershell script to see the full list of options, conditions, or limitations

The purpose of the "Jukebox Player" is to make it easy to listen to multiple ABC files for debugging new melody files, or to enjoy hearing an endless stream of music tuned for LOTRO in-game activities.

- Non "Jukebox" ABC files can also be played as long as the duration can be found in the Title field
  - Which is left as an exercise for the reader to edit their copies of the ABC melody files from 3rd party sources

### Player Example

    PS C:\Users\*****> .\GitHub\juke.lute\my.tools\jukebox.ps1

    ------------------------ jukebox.ps1 / ***** ------------------------
    "C:\Program Files (x86)\Maestro\AbcPlayer.exe"  Press '1' for this option.
    "C:\Program Files (x86)\Maestro\Maestro.exe"    Press '2' for this option.
    
    NOTE:     Use -MusicPath / -PlayerPath / -EditorPath / -PauseSeconds / -History to override defaults
    PATH:     C:\Users\*****\Documents\The Lord of the Rings Online\Music
    PAUSE:    3 seconds between each melody
    HISTORY:  3 melodies (i.e. no repeats)
    ------------------------ jukebox.ps1 / ***** ------------------------
    Please enter which player to use (default is AbcPlayer): 2
    Found 10196 ABC file(s) under C:\Users\*****\Documents\The Lord of the Rings Online\Music

    Available folders:
    [0]favs  [1]bassoon  [2]flute  [3]violin  [4]bassoon\favs  [5]bassoon\folk  [6]bassoon\spirit  [7]bassoon\tolkien  [8]duet\bassoon-flute  [9]duet\bassoon-lute  [10]duet\bassoon-ttf  [11]duet\bassoon-violin  [12]duet\favs  [13]duet\flute-harp  [14]duet\flute-lute  [15]duet\flute-ttf  [16]duet\flute-violin  [17]duet\lute-ttf  [18]duet\lute-violin  [19]duet\ttf-violin  [20]fiddle\artist  [21]fiddle\favs  [22]fiddle\folk  [23]fiddle\formal  [24]fiddle\game  [25]fiddle\longer1  [26]fiddle\longer2  [27]fiddle\longer4  [28]fiddle\longest  [29]fiddle\older  [30]fiddle\spirit  [31]fiddle\tolkien  [32]fiddle\venue  [33]flute\favs  [34]flute\folk  [35]flute\formal  [36]flute\game  [37]flute\spirit  [38]flute\tolkien  [39]lute\ai  [40]lute\artist  [41]lute\club  [42]lute\favs  [43]lute\folk  [44]lute\formal  [45]lute\game  [46]lute\jams  [47]lute\longer1  [48]lute\longer2  [49]lute\longer3  [50]lute\longer4  [51]lute\longer5  [52]lute\longest  [53]lute\older  [54]lute\quick  [55]lute\quiet  [56]lute\rural  [57]lute\spirit  [58]lute\tolkien  [59]lute\venue  [60]violin\favs  [61]violin\folk  [62]violin\spirit  [63]violin\tolkien  [64]all
    Please enter the number for which folder to use (default is [64]all): 3
    Playing from [violin] (250 file(s)).
    History seed: 3 distinct track(s).

    Title     : By The Time I Get To Phoenix
    Playtime  : 1:23 (83 seconds)
    Wait      : 86 seconds (includes 3s pause)
    Selection : Jimmy_Webb-Time_I_Get_To_Phoenix(violin).abc (juke.violin)
    To Skip   : Press any key to jump to the next melody.
    To Stop   : Press Q or Escape to exit the jukebox.

    Title     : Babe I'm Gonna Leave You
    Playtime  : 6:41 (401 seconds)
    Wait      : 404 seconds (includes 3s pause)
    Selection : Anne_Bredon-Babe_I'm_Gonna_Leave_You(violin).abc (juke.violin)
    To Skip   : Press any key to jump to the next melody.
    To Stop   : Press Q or Escape to exit the jukebox.

    Title     : Only In Dreams
    Playtime  : 7:55 (475 seconds)
    Wait      : 478 seconds (includes 3s pause)
    Selection : Weezer-Only_In_Dreams(violin).abc (juke.violin)
    To Skip   : Press any key to jump to the next melody.
    To Stop   : Press Q or Escape to exit the jukebox.

    Title     : Blues 06
    Playtime  : 1:22 (82 seconds)
    Wait      : 85 seconds (includes 3s pause)
    Selection : Jurg_Hochweber-Blues_06(violin).abc (juke.violin)
    To Skip   : Press any key to jump to the next melody.
    To Stop   : Press Q or Escape to exit the jukebox.

    Jukebox stopped.
    ...

## Localhost Webserver

Script to quickly serve a directory of files on localhost for remote access within a local network. This script uses the feature from Python http.server to enable HTTP GET operations for display and download of files. Via WEB (browser) or CLI (wget or curl).

- The script is started in the folder i.e sub directory where the files are located for remote access
  - Please review the comments contained within the script to see the full list of options, conditions, or limitations

The purpose of the "Localhost Webserver" is to make it easy to redistribute a folder of ABC melody files (or MIDI files, & etc.).

- The Powershell console will print the connection details for client access to the HTTP server (see "web_env.py" to change)
  - Where the full URL is listed to each and every *.abc (or *.mid) file in the folder (see "web_env.py" to change)
  - Where the access history is updated at the end each time a "Localhost Webserver" connection request from a client occurs
  
    - A WSL (Ubuntu) example:
      ```wget -p -k --user-agent="Mozilla" --limit-rate=512k --wait=3 --random-wait --waitretry=5 --mirror --no-check-certificate http://192.168.***.***:8000/juke.lute```
      - Will download each and every *.abc file and sub directory located under the juke.lute folder
      - NOTE: This is an advanced CLI example and DO NOT use either "wget" or "curl" commands to target public web servers without permission (explicit and/or implied)

### Webserver Example

    PS C:\Users\*****> cd ".\Documents\The Lord of the Rings Online\Music"
    PS C:\Users\*****\Documents\The Lord of the Rings Online\Music> python 'C:\Users\*****\GitHub\juke.lute\my.tools\web_get.py'
    
    -------------------------------------------------------------------------
    SYSTEM IP:    192.168.***.*** / WEB SERVER PORT: 8000
    WARNING:      IP 192.168.***.*** likely non-routable (setup a bridge)!
    HTTP URL:     http://192.168.***.***:8000/
    
    http://192.168.***.***:8000/juke.duet/bassoon-lute/AFI-Girls_Not_Grey(duet).abc
    http://192.168.***.***:8000/juke.duet/bassoon-lute/Beatles-Eight_Days_A_Week(duet).abc
    http://192.168.***.***:8000/juke.duet/bassoon-lute/Beatles-Here_Comes_The_Sun(duet).abc
    http://192.168.***.***:8000/juke.duet/bassoon-lute/Ben_E_King-Stand_By_Me(duet).abc
    ...
    http://192.168.***.***:8000/juke.violin/Tenchi_Muyo-Aeka's_Theme(violin).abc
    http://192.168.***.***:8000/juke.violin/Tenchi_Muyo-Sad_Piano_Theme(violin).abc
    http://192.168.***.***:8000/juke.violin/Traditional-Slow_Scottish_Waltz(violin).abc
    http://192.168.***.***:8000/juke.violin/Vintage-Was_Soll_Das_Bedeuten(violin).abc
    
    To Stop: Use CTRL-C key to exit from the HTTP server session
    
    -------------------------------------------------------------------------
    
    127.0.0.1 - - [24/Feb/2025 15:25:55] "GET / HTTP/1.1" 200 -
    ...

## ZIP Creator

Script to package each instrument folder into a separate jukebox ZIP file. Automate the steps to create new editions of the ZIP archives with updated *.abc files in preparation for upload to a remote destination i.e. GitHub, GitLab, Gitea, & etc.

- This script assumes that "git clone git@github.com:**********/juke.lute.git" has been run previously
  - Please review the comments contained within the script to see the full list of options, conditions, or limitations
- Use the -WhatIf parameter to confirm i.e. test that *.abc files are found within the location environment

The purpose of the "ZIP Creator" is to quickly make a compressed backup of the available ABC files located in the default LOTRO Music folder.

### ZIP Example

    PS C:\Users\*****> .\GitHub\juke.lute\my.tools\zip_loop.ps1

    ------------------------ zip_loop.ps1 / ***** ------------------------
    Music path : C:\Users\*****\Documents\The Lord of the Rings Online\Music
    Output path: C:\Users\*****\GitHub\juke.lute\999.songs
    Compression: Fastest
    Found 6 juke folder(s): juke.bassoon, juke.duet, juke.fiddle, juke.flute, juke.lute, juke.violin
    ------------------------ zip_loop.ps1 / ***** ------------------------

    BEFORE:
    
        Directory: C:\Users\*****\GitHub\juke.lute\999.songs
    
    Mode                 LastWriteTime         Length Name
    ----                 -------------         ------ ----
    -a---           2/29/2025 1:54 PM          711593 juke.bassoon.zip
    -a---           2/29/2025 1:54 AM         6707074 juke.duet.zip
    -a---           2/29/2025 1:54 AM         6122024 juke.fiddle.zip
    -a---           2/29/2025 1:54 AM          246557 juke.flute.zip
    -a---           2/29/2025 1:55 AM        30814994 juke.lute.zip
    -a---           2/29/2025 1:55 AM          121572 juke.violin.zip
    
    Packaging juke.bassoon...
    Packaging juke.duet...
    Packaging juke.fiddle...
    Packaging juke.flute...
    Packaging juke.lute...
    Packaging juke.violin...

    AFTER:
    -a---           2/29/2025  3:59 PM          41047 juke.bassoon.zip
    -a---           2/29/2025  3:59 PM        6968914 juke.duet.zip
    -a---           2/29/2025  3:59 PM        6261199 juke.fiddle.zip
    -a---           2/29/2025  3:59 PM         246558 juke.flute.zip
    -a---           2/29/2025  4:00 PM       30814556 juke.lute.zip
    -a---           2/29/2025  4:00 PM         121572 juke.violin.zip
    
    Created 6 archive(s).

    PS C:\Users\*****\GitHub\juke.lute\my.tools>

## Songbook Index

Script to build the Chiran Songbook MOD melody index (i.e. `SongbookData.plugindata` file). This is a PowerShell port of the original `songbook.hta` VBScript tool with the same output format plus optional parameters and improvements.

- Scans the LOTRO Music folder for `*.abc` and `*.txt` files (same as the original tool)
- Writes the plugin data file under `Documents\The Lord of the Rings Online\PluginData\<LOTRO_USER>\AllServers\`
- May be run anytime after extracting the jukebox ZIP files (or after any *.abc file changes)
- Use `-JukeOnly` to index only `juke.*` folders
  - Useful for creating a "jukebox" only playlist of *.abc melodies
- Use `-WhatIf` to preview counts without updating the current SongbookData file 
- Use `-AllUsers` to update the `SongbookData.plugindata` file for every LOTRO account setup on the local MS Windows system

This script can also support non default locations (other than C:\ Drive) by using environment variables to override the default user, default LOTRO music folder, & etc. (refer to the in-script comments)

### Songbook Example

    PS C:\Users\*****\GitHub\juke.lute\my.tools> .\songbook.ps1

    ------------------------ songbook.ps1 / ***** ------------------------
    LOTRO user : *****
    Music path : C:\Users\*****\Documents\The Lord of the Rings Online\Music
    Output file: C:\Users\*****\Documents\The Lord of the Rings Online\PluginData\*****\AllServers\SongbookData.plugindata
    ------------------------ songbook.ps1 / ***** ------------------------

    Scanning ABC files...

    Generated song library.
    Found 1234 song files in 56 directories.

    Song library saved to:
    C:\Users\*****\Documents\The Lord of the Rings Online\PluginData\*****\AllServers\SongbookData.plugindata

    PS C:\Users\*****\GitHub\juke.lute\my.tools> .\songbook.ps1 -UserName "MyChar" -JukeOnly

    PS C:\Users\*****\GitHub\juke.lute\my.tools> .\songbook.ps1 -AllUsers -JukeOnly
