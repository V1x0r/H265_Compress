# H265_Compress
A little Script i'm working on for compressing films into h265 encoded copies.  (while keeping original audio and subs)

<br>Required Files and associated Directories:

<br>Resources\Data\magic.mgc    -- For mkvpropedit.exe (comes with MKVToolnix)
<br>Resources\comment.xml       -- Feel Free to edit to your desires (only used if kodi .nfo not included with film)
<br>Resources\ffmpeg.exe        -- Make your own, Download your own, Or use mine. (Mine is everything not cuda) 10bit x64
<br>Resources\mediainfo.dll     -- Reference Library for MediaInfo.exe
<br>Resources\mediainfo.exe     -- Not Used in Powershell edition, but may be usefull in the future
<br>Resources\mkvmerge.exe      -- Not Used presently, but may be used to quickly rebuild pesky files not initially supported by ffmpeg
<br>Resources\mkvpropedit.exe   -- Used to apply details and cover art to the MKV output (used by both VBS and Powershell)
<br>Resources\MP4Box.exe        -- Used to build MP4 (may be added as an option for powershell gui, needed for abandoned mp4 vbs)


==================  Requirements  ==================
====================================================

1 - TheRenamer (amazing tool for renaming movies and TV shows to proper naming conventions) http://therenamer.com/
2 - Kodi (or some other way of gathering coverart)
3 - Media files

==================  Folder Layout Requirements  ==================
==================================================================


==================  Movies  ==================
==============================================

.\MovieFolder\moviename1.mkv
.\MovieFolder\moviename1-poster.jpg
.\MovieFolder\movienamea.mp4
.\MovieFolder\movienamea-poster.jpg
A poster must be provided...it must have the exact Movie File Name with "-poster" at the end of it.

Ex.	.\Guardians of the Galaxy (2014 PG-13).mkv
	.\Guardians of the Galaxy (2014 PG-13)-poster.jpg
	.\The Martian (2015 PG-13).mkv
	.\The Martian (2015 PG-13)-poster.jpg

==================  TV Shows  ==================
================================================
TV show folders MUST be
.\TV Show Name\Season 01\S01E01EpisodeName.mkv
.\TV Show Name\Season 02\S02E01EpisodeName.mp4
.\TV Show Name\Season01-poster.jpg
.\TV Show Name\Season02-poster.jpg

ex.	.\Archer\Season 01\S01E01.Mole Hunt.mkv
	.\Archer\season01-poster.jpg

==================  Fixing File Names (TV Shows and Movies)  ==================
===============================================================================


1- Install TheRenamer from http://therenamer.com/
2a- With Movies Toggled select the "Settings" on the top right
2b- Configure for your use (I uncheck everything on Page 1 of 2 except for "in File:" and "-MPAA Rating:"
2c- make sure the source and destination folders are selected...I have them the same folder and the 3 options NOT selected. Now select "Close"
2d- Click on the Toggle Mode "movies" (in blue) and it will turn to TVshows in Green. Selecte "Settings" as before
2e- select ONLY "Season:", "Episode Titles:" "S1e01" "Caps(SE/X):", "Add "0" to Season:", "Getfrom akas.imdb","TV Show Folder""Season Folder:Season","Option A (Long)".
	(most of these options should already be selected for both of these)
3 - with TVShows Selected you can toggle Sites on the bottom right (helpful if episodes are incorrect for your order or missing episodes)
4 - with only a couple seasons selected, drag and drop the TV show onto TheRename...it will automatically look for correct titles.
5 - With Movies Toggle selected you can do this with the movies as well.  all things must be in order...especially or movies...or it won't work.


==================  Getting Cover Art Via Kodi  ==================
==================================================================

1- Install Kodi and point kodi to your TV Shows and your Movies directories
2- View all the Seasons for TV Shows so as to force download the images. (go into the TV Show so as to see Season 01, 02, 03, etc)
3- Select the Options icon (the gear if stock theme)
4- Select "Media Settings"
5- Select the gear icon on the bottom left (likely says Standard), Click this until it says "Advanced" or "Expert"
6- in this settings area Hover over "Library"
7- If you remove media select "Clean Library" before exporting..so you don't get files for media you already moved/converted
8- Select "Export library" > Separate > Yes (to export thumbnails and fanart) > No to Actor Thumbs > Yes/No (for "Overwrite old files?")
9- depending on how large your library is this may take a minute...just wait.
10- now all covers should be exported nicely for converting!

==================  Converting!  ==================
===================================================

This part is SUPER easy!  

==================  For Movies  ==================
==================================================

1- Copy "!HEVC_Rebuild_###.exe" to the Movie Folder where your movies and cover art is located

Ex.	.\Movies\!HEVC_Rebuild_###.exe
	.\Movies\Guardians of the Galaxy (2014 PG-13).mkv
	.\Movies\Guardians of the Galaxy (2014 PG-13)-poster.jpg
	.\Movies\The Martian (2015 PG-13).mkv
	.\Movies\The Martian (2015 PG-13)-poster.jpg

2- execute the program...either with a Double Click or select it and press enter. 
	(If only Administrator has rights to the directory..then run as admin)
3- Wait until it completes.  This can take a LONG time depending on your computer and the movie file.
	(I've had some conversions take a couple weeks on my server)

==================  For TV Shows ==================
===================================================

1- Copy "!HEVC_Rebuild_###.exe" to the root of the TV Series you wish to Convert/compress

ex.	.\Archer\Season 01\S01E01.Mole Hunt.mkv
	.\Archer\Season 02\S02E01.Swiss Miss.mp4
	.\Archer\!HEVC_Rebuild_###.exe
	.\Archer\season01-poster.jpg

2- execute the program...either with a Double Click or select it and press enter. 
	(If only Administrator has rights to the directory..then run as admin)
3- Wait until it completes.  This can take a LONG time depending on your computer and the movie file.
	(I've had some conversions take a couple weeks on my server)

==================  Notes  ==================
=============================================
- existing .mp4 files will be renamed to old_Filename.mp4
- Accent Characters may not properly convert
- I have not worked in Audio Delay yet....I need a file with this to experiment with.
- Bulk Rename Utility can be VERY helpful with incorrectly named tv series that aren't working with theRenamer
	URL: http://www.bulkrenameutility.co.uk/Main_Intro.php
- If you have an issue then please provide as MUCH information as you can about the file and potentially the file
- Check back for udpates -  http://v1x0r.com/downloads/mp4rebuild/
	(I will have to add an update function at some point)
- if you edit my code or have suggestions for it, please feel free to share with me.  
	I know it currently is messy...some parts are notes.
- I build ffmpeg with NON Free components...this is for personal use ONLY!
