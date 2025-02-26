# Table Of Contents

- [Table Of Contents](#table-of-contents)
  - [Jukebox Player](#jukebox-player)
    - [Player Example](#player-example)
  - [Localhost Webserver](#localhost-webserver)
    - [Webserver Example](#webserver-example)
  - [ZIP Creator](#zip-creator)
    - [ZIP Example](#zip-example)

## Jukebox Player

Script to play a random sequence of ABC files using either AbcPlayer or Maestro. The default LOTRO Music folder is used to build a list of melodies. Then a random melody file is picked for listening at the default audio end point (desktop speaker, earbud, headset, & etc), and random ABC file selection continues until user input to stop/exit.

- The script can be started from any location (via GUI or CLI) and it will prompt the user with several options to customize their music session
  - Please review the comments contained within the Powershell script to see the full list of options, conditions, or limitations

The purpose of the "Jukebox Player" is to make it easy to listen to multiple ABC files for debugging new melody files, or to enjoy hearing an endless stream of music tuned for LOTRO in-game activities.

- Non "Jukebox" ABC files can also be played as long as the duration can be found in the Title field
  - Which is left as an exercise for the reader to edit their copies of the ABC melody files from 3rd party sources
  - NOTE: The "Jukebox Player" can be changed to use a different default directory location if needed to only use "Jukebox" ABC files stored under an alternate folder path

### Player Example

    PS C:\Users\*****> .\GitHub\juke.lute\my.tools\jukebox.ps1

    ------------------------ jukebox.ps1 / ***** ------------------------
    "C:\Program Files (x86)\Maestro\AbcPlayer.exe"  Press '1' for this option.
    "C:\Program Files (x86)\Maestro\Maestro.exe"    Press '2' for this option.
    
    NOTE:   Edit this script to change default paths or pause between melodies
    PATH:   C:\Users\*****\Documents\The Lord of the Rings Online\Music
    PAUSE:  3 seconds
    ------------------------ jukebox.ps1 / ***** ------------------------
    Please enter which player to use (default is AbcPlayer): 2
    
    Available folders:
    [0]BASSOON-LUTE  [1]BASSOON-TTF  [2]FLUTE-LUTE  [3]FLUTE-TTF  [4]LUTE-TTF  [5]LUTE-VIOLIN
    [6]TTF-VIOLIN  [7]JUKE.FIDDLE  [8]JUKE.FLUTE  [9]AI  [10]CLUB  [11]DISC  [12]FAVS  [13]FOLK
    [14]FORMAL  [15]JAMS  [16]LONG1  [17]LONG2  [18]LONG3  [19]LONG4  [20]LONG5  [21]LONG6
    [22]OLDER  [23]QUICK  [24]QUIET  [25]RURAL  [26]SHOW  [27]SPIRIT  [28]JUKE.VIOLIN  [29]ALL
    Please enter the number for which folder to use (default is [29]ALL):
    
    Playtime  : 1:33 (96 seconds)
    Selection : C_Petzold-Minuet_BWV_114(lute).abc (formal)
    To Stop   : Use CTRL-C key to exit the jukebox.
    
    Playtime  : 3:04 (187 seconds)
    Selection : Train-Hey_Soul_Sister(lute).abc (long3)
    To Stop   : Use CTRL-C key to exit the jukebox.
    
    Playtime  : 2:52 (175 seconds)
    Selection : Hollies-Bus_Stop(lute).abc (long2)
    To Stop   : Use CTRL-C key to exit the jukebox.
    
    Playtime  : 2:33 (156 seconds)
    Selection : Yevgeny_Krylatov-Wondrous_Future(duet).abc (flute-lute)
    To Stop   : Use CTRL-C key to exit the jukebox.
    
    Playtime  : 3:49 (232 seconds)
    Selection : Dance_Techno-Come_Take_My_Hand(lute).abc (favs)
    To Stop   : Use CTRL-C key to exit the jukebox.
    
    Playtime  : 2:37 (160 seconds)
    Selection : Initial_D-Running_In_The_90s(ttf).abc (juke.fiddle)
    To Stop   : Use CTRL-C key to exit the jukebox.
    
    Playtime  : 3:49 (232 seconds)
    Selection : Greek-Torapia(lute).abc (folk)
    To Stop   : Use CTRL-C key to exit the jukebox.
    
    Playtime  : 3:16 (199 seconds)
    Selection : John_Lennon-So_This_Is_Christmas(lute).abc (spirit)
    To Stop   : Use CTRL-C key to exit the jukebox.
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

- This script must be run from its home directory due to how the source/destination paths are setup
  - Where, this script assumes that "git clone git@github.com:**********/juke.lute.git" has been run previously
  - Please review the comments contained within the script to see the full list of options, conditions, or limitations

The purpose of the "ZIP Creator" is to quickly make a compressed backup file of the available ABC files located in the LOTRO Music folder.

### ZIP Example

    PS C:\Users\*****\GitHub\juke.lute\my.tools> .\zip_loop.ps1
    
    BEFORE:
    
        Directory: C:\Users\*****\GitHub\juke.lute\999.songs
    
    Mode                 LastWriteTime         Length Name
    ----                 -------------         ------ ----
    -a---           2/29/2025 1:54 AM         6707074 juke.duet.zip
    -a---           2/29/2025 1:54 AM         6122024 juke.fiddle.zip
    -a---           2/29/2025 1:54 AM          246557 juke.flute.zip
    -a---           2/29/2025 1:55 AM        30814994 juke.lute.zip
    -a---           2/29/2025 1:55 AM          121572 juke.violin.zip
    
    AFTER:
    
    -a---           2/29/2025  3:59 PM          41047 juke.bassoon.zip
    -a---           2/29/2025  3:59 PM        6968914 juke.duet.zip
    -a---           2/29/2025  3:59 PM        6261199 juke.fiddle.zip
    -a---           2/29/2025  3:59 PM         246558 juke.flute.zip
    -a---           2/29/2025  4:00 PM       30814556 juke.lute.zip
    -a---           2/29/2025  4:00 PM         121572 juke.violin.zip
    
    PS C:\Users\*****\GitHub\juke.lute\my.tools>
