## Simple tips about joining tunes into a playlist *.abc file

Please recall that ABC files are text files. They may be edited using a basic editor i.e. Notepad or Notepad++.

  - It is recommended to avoid using a word processor or any other editor that automatically formats text files

  - Append or join or merge multiple *.abc files into a single file based on whichever method is familiar to the reader
    - Max file size supported (i.e. playable) within LOTRO is 150 KB (approximate)

The following is a basic 3 melody example to append several ABC files into a single playlist.

  - For clarity, the music notation is removed for each tune to make it easier to review the overall file structure
    - Where, each \<snip\> reference is a simple placeholder to the original melody

As per ABC notation, the % or percent symbol is used for comments and ignored during music playback.

    X: 1                                                            % Required; Use as is
    T: Brown Eyes Blue / Mad About Him / Bad Feeling Blues (6:08)   % Title; short anything; In LOTRO: 60 character limit
    C: Rural Blues Melodies                                         % Composer; can be anything for a playlist
    Z: LOTRO (ABC v2.11)                                            % Optional; can be anything for a playlist
    M: 4/4                                                          % Required; all playlist songs must use matching
    Q: 122                                                          % Required; all playlist songs must use matching
    K: C maj                                                        % Required; all playlist songs must use matching
    
                                                                    % Blank lines can be blank (no need for % to comment)
    
    %X: 1                                                           % Only 1 X field is needed; left in as a placeholder
    %T: Don't It Make My Brown Eyes Blue (1:57)                     % Only 1 T field is needed; left in as a placeholder
    %C: Crystal Gayle & Richard Leigh                               % Only 1 C field is needed; left in as a placeholder
    %Z: LOTRO (ABC v2.11)                                           % Only 1 Z field is needed; left in as a placeholder
    %M: 4/4                                                         % Only 1 M field is needed; left in as a placeholder
    %Q: 122                                                         % Only 1 Q field is needed; left in as a placeholder
    %K: C maj                                                       % Only 1 K field is needed; left in as a placeholder
    
    <snip>                                                          % Where the ABC music notation is for the first melody 
    
    %                                                               % Use the invisible rest aka pause between tunes
    x24                                                             % Given this tune (see M and Q) 24 => 12 seconds
    %                                                               % 
    %X: 1                                                           % Only 1 X field is needed; left in as a placeholder
    %T: Mad About Him, Sad About Him Blues (2:21)                   % Only 1 T field is needed; left in as a placeholder
    %C: Dinah Shore                                                 % Only 1 C field is needed; left in as a placeholder
    %Z: LOTRO (ABC v2.11)                                           % Only 1 Z field is needed; left in as a placeholder
    %M: 4/4                                                         % Only 1 M field is needed; left in as a placeholder
    %Q: 122                                                         % Only 1 Q field is needed; left in as a placeholder
    %K: C maj                                                       % Only 1 K field is needed; left in as a placeholder
    
    <snip>                                                          % Where the ABC music notation is for the second melody
    
    %                                                               % Use the invisible rest aka pause between tunes
    x24                                                             % Given this tune (see M and Q) 24 => 12 seconds
    %                                                               % 
    %X: 1                                                           % Only 1 X field is needed; left in as a placeholder
    %T: Bad Feeling Blues (1:50)                                    % Only 1 T field is needed; left in as a placeholder
    %C: Arthur Blake                                                % Only 1 C field is needed; left in as a placeholder
    %Z: LOTRO (ABC v2.11)                                           % Only 1 Z field is needed; left in as a placeholder
    %M: 4/4                                                         % Only 1 M field is needed; left in as a placeholder
    %Q: 122                                                         % Only 1 Q field is needed; left in as a placeholder
    %K: C maj                                                       % Only 1 K field is needed; left in as a placeholder
    
    <snip>                                                          % Where the ABC music notation is for the third melody
    
    .                                                               % Repeat this pattern for each added ABC file
    .                                                               %    "rest" "header" "melody"
    .                                                               %    ...

## Further Suggestions

  - For each melody, leave the original X: through K: header lines in place and simply mark each line as a comment using the % symbol for future reference

  - Keep the top title "T: ..." short (< 60 characters) and prefix/suffix it with the total play time for quick reference inside LOTRO

  - There are two kinds of "rest" flags for ABC notation; please use the "x" rest because it is hidden (i.e. ignored) in tools like Easy ABC; Whereas the other rest flag will cause applications like Easy ABC to change the appearance of a music score

  - Playlist Jams can be of any length in terms of total time taken end to end; please keep in mind your listeners and scale/curate each playlist for a well defined situation

  - The challenge to is collect *.abc files with matching M, Q, and K header fields and this effort is left as an ongoing exercise to the reader
    - **So...** Be Patient, Carry On, And Try Try Again
