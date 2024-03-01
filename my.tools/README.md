## Scripts

Both MS PowerShell and WSL Linux (i.e. Debian or Ubuntu) are used for modifications done across concurrent files i.e.

  - Compress *.abc files into a single efficient ZIP file
  - Search and replace of keywords across multiple files
  - Append and optimize 2 or more song files into a single ABC playlist

Finally, to reduce the 'Enshittification' of shared ABC files by removing unnecessary and unwanted complexity.

## Applications

A small number of open-source desktop tools are used to work with both MIDI and ABC files. This is a personal mantra, and as a LOTRO on-again and off-again player my in-game needs are simple (please recall my claim as a "lute soloist"). To achieve up to date and clean ABC music files which may be re-purposed by any soloist of other instruments please consider the following toolbox:

  - Notepad++ / VLC / VSCodium  (Open-source applications; very active communities; loads of documentation)
  - ABC Player / Maestro (GitHub project: https://github.com/digero/maestro)
  - EasyABC (visualization and editing of ABC notation)

Each have their specific pros and cons in terms of the MS Windows setup requirements, user knowledge and debug skills, and overall learning curve to master for each application.
  - Thankfully, there are many alternative tools available to the reader

## Modifications (aka MODS)

  - 'Chiran' Songbook
    - Current version is old and is not maintained
    - However, it is popular and in wide-spread use
  - 'Badger' SongbookBB
    - https://www.linawillow.org/home/plugins-2/songbook/
      - In development with frequent updates and support

The exact steps are left to the reader as an exercise to find appropriate instruction and/or necessary information to install a LOTRO modification aka MOD.

## Resources

### ABC

Here are a few examples to public ABC libraries that are actively maintained. These particular websites will also include features such as in-line playback options, plus ancillary materials to explore topics and resources relating to the ABC notation.

  - https://www.abcnotation.com/
  - https://trillian.mit.edu/~jc/cgi/abc/tunefind
  - https://www.freesheetmusic.net/directory/free-abc-format-music-sites
    - e.g. https://kunstderfuge.com/

  - Special comment (i.e "Hat Tip") about the 'Fat Lute' archives:
    - There are various copies available for download to review, update, and listen
      - Where many LOTRO music collections contain ABC files from this primary online source

  - Plus many smaller or special interest websites can be researched
      - Found embedded within link lists noted at the above websites
      - By scraping search engine results using a small list of keywords
    - Please be aware that many ABC websites are no longer available and the curated lists located on these larger ABC websites are seriously out of date
  
      - **So...** Be Patient, Carry On, And Try Try Again
      - **And...** Don't forget, use the Internet "WayBack Machine"

### MIDI

The step before the ABC file is the MIDI file used for the conversion to text (ASCII) based on ABC music notation.

  - The effort to find MIDI files for conversion to ABC format is much easier (i.e. MIDI is widely known and understood) than a direct search for only ABC formatted files
  - Websites like Free MIDI, MIDI 101, Bit MIDI, Supreme MIDI, MIDI World, and others offer a variety of content beyond music melodies
    - Locating one or more favorite melodies is left as an exercise for the reader to explore further
  
  - Please note that the same problems exist for any curated lists of MIDI websites as with ABC websites

    - **So...** Be Patient, Carry On, And Try Try Again
    - **And...** Don't forget, use the Internet "WayBack Machine"

  - From the above toolbox, the **Maestro** application is used to convert MIDI to ABC format (i.e. this is the "tune" not "compose" step mentioned previously)

### AUDIO

The step before the MIDI file is the audio file for recorded tunes. Available in a variety of formats e.g. MP3, AAC, WAV, FLAC, & so on. Where each type of audio file format have specific strengths and uses for music appreciation and beyond.

  - Tools, steps, and details to convert an audio file to MIDI is not in scope for this project
    - Learning to make and edit MIDI files from audio files is left as an exercise for the reader to explore further

      - For example, the "WaoN - a wave-to-notes transcriber" project is great starting point

### LIVE

The step before the AUDIO file is a live stream (i.e. recorded live stream/session). Live streams are captured using a variety of media file formats, then must be converted to an audio-only format. From an audio format to MIDI, and finally transcribed to ABC notation and stored as a text (ASCII) file.

  - Tools, steps, and details to convert a live stream file to an audio only format is not in scope for this project
    - Learning to make and edit audio files from live stream recordings is left as an exercise for the reader to explore further

      - For example, the FFmpeg open-source project is great starting point
