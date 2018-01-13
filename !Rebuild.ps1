clear-history
$StrHomeDir = ($(get-location).Path + "\");
$StrResourceDir = ($StrHomeDir + "Resources");
$MainScript = ($StrHomeDir + "!Rebuild.ps1");
$MP4BOX = $StrResourceDir + "\MP4Box.exe"
$MKVEXTRACT = $StrResourceDir + "\mkvextract.exe"
$MKVINFO = $StrResourceDir + "\Mkvinfo.exe"
$MKVPROPEDIT = $StrResourceDir + "\mkvpropedit.exe"
$MEDIAINFO = $StrResourceDir + "\MediaInfo.exe"
$FFMPEG = $StrResourceDir + "\FFmpeg.exe"
$ExcludeList = ("*.exe", "*.dll", "*.jpg", "*.png", "*.xml", "*.nfo")
Clear-Host

#ToDo - Check Directory Structure before running?

#========================================================================================
#=====================  Traverse Folders Finding Files To Rebuild =======================
#========================================================================================

function TraverseFolders
{
    <#
    .SYNOPSIS
    Determines if TV Series or Movie
    #>
    Param($WorkingDir)

#=================================== Movies =====================================

 $MovieFolder = Get-ChildItem $WorkingDir -Exclude $ExcludeList |`
        Where-Object {$_.Length -ge 5MB} | Where-Object {!($_.Name.Contains("old_"))}
    ForEach ($Film in $MovieFolder)
    {
        if (!(("old_" + $Film.Name) | Test-Path))
            {
                RenameMKV -MediaInput $Film -Type "Movie"
                #Get-Item -Path $Film.FullName -Filter 
            }
    }

#================================== TV Shows ====================================

 $SeasonsFolders = Get-ChildItem $WorkingDir -recurse -directory -depth 1 |`
        Where-Object { $_.name -match "Season*"}
  ForEach ($Season in $SeasonsFolders)
    {
        $Episodes = Get-ChildItem $Season -Exclude $ExcludeList | Where-Object {$_.Length -ge 5MB} |`
        Where-Object {!($_.Name.Contains("old_"))}
        ForEach ($Episode in $Episodes)
        {
           If (!(Test-Path ($Season.fullname + "\" + "old_" + $Episode.name)))
               {
               # write-output $Episodes.count  
               RenameMKV -MediaInput $Episode -Type "TV"
               }
           }
        }
}

#========================================================================================
#============================== Rename MKV For Backup ===================================
#========================================================================================
function RenameMKV
{
    <#
    .SYNOPSIS
    Determines if Media Needs to be renamed
    #>
    
   Param($MediaInput,$Type)
   if ($MediaInput.Extension -eq ".mkv")
   {
        $OriginalInput = ("old_" + $MediaInput.name)
      <# $MediaInput = Rename-Item $MediaInput.FullName $OriginalInput
        #Write-Output $OriginalInput
        if (Test-Path $OriginalInput)
        {        
        $MediaInput = Get-Item $OriginalInput
        } Else {
        $MediaInput = Get-Item ($Season.FullName + "\" + $OriginalInput)
        }
        #>
        Get-Poster -MediaInput $MediaInput -Type $Type
    }
}

#========================================================================================
#================================= Determine Poster =====================================
#========================================================================================
function Get-Poster
{
    <#.SYNOPSIS
    Looks for locally storated Posters exported from Kodi.
    MovieName-poster.jpg & SeasonXX.jpg in working dir.
    #>

    Param($MediaInput,$Type)
    $MoviePoster = ($MediaInput.BaseName + "-poster.jpg")
    $SeasonPoster = (($Season.BaseName + "-poster.jpg").ToLower().replace(" ",""))
    If ($Type -eq "Movie")
        {
        if (Test-Path $MoviePoster)
            {
            Write-Output $MoviePoster
            }Else{
            Write-OutPut ("ERROR " + "'" + $MoviePoster + "'" + " Not Present")
            }
        }
    If ($Type -eq "TV")
        {
        if (Test-Path $SeasonPoster)
            {
            Write-Output $SeasonPoster
            }Else{
            Write-OutPut ("ERROR " + "'" + $SeasonPoster + "'" + " Not Present")
            }
        }
}

#========================================================================================
#================================= Parse Kodi .NFO ======================================
#========================================================================================
function ParseKodiNFO
{
    <#
    .SYNOPSIS
    This part of the Script will use Kodi's .NFO output to embed various information
    Into the Media File.
    #>
}
#========================================================================================
#============================= Cleanup Working Directory ================================
#========================================================================================
function CleanupWorkingDir
{
    <#
    .SYNOPSIS
    Cleans the working directory after the script has finished
    #>
        Write-Host "Cleaning Up Remaining Resources"
        if (Test-Path $StrResourceDir)
            { 
                Remove-Item -Path $StrResourceDir -Force -Recurse
            }
        if (Test-Path $MainScript) 
            {
                Remove-Item -Path $MainScript -Force
            }
}

#=========================================================================================================================

#=========================================================================================================================

TraverseFolders -WorkingDir $StrHomeDir
#CleanupWorkingDir

#=========================================================================================================================
