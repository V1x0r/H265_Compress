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


# $newvid = [io.path]::ChangeExtension($oldvid.FullName, '.mp4')


function TraverseFolders
{
    <#
    .SYNOPSIS
    Determines if TV Series or Movie
    #>
    Param($WorkingDir)

    $MovieFolder = Get-ChildItem $WorkingDir -Exclude $ExcludeList |`
        Where-Object {$_.Length -ge 5MB}
    $SeasonsFolders = Get-ChildItem $WorkingDir -recurse -directory -depth 1 |`
        Where-Object { $_.name -match "Season*"}
#================================================================================
    ForEach ($Film in $MovieFolder)
    {
    if ($Film.Name -Notlike "old_*") 
        {
             if (!(("old_" + $Film.Name) | Test-Path))
                {
                     CheckMedia -MediaInput $Film -Type "Movie"
                     #Get-Item -Path $Film.FullName -Filter 
                }
        }
    }
#================================================================================
  ForEach ($Season in $SeasonsFolders)
    {
        $Episodes = Get-ChildItem $Season -File  | Where-Object {$_.Length -ge 5MB} |`
        Where-Object {!($_.Name.Contains("old_"))} #| Where-Object {("old_" + $_.Name) -like $_.Name}
        ForEach ($Episode in $Episodes)
        {
   If (!(Test-Path ($Season.fullname + "\" + "old_" + $Episode.name)))
   {
   # write-output $Episodes.count  
   CheckMedia -MediaInput $Episode -Type "TV"
   }
   }
        }
}


#=========================================================================================================================
function CheckMedia
{
    <#
    .SYNOPSIS
    Filters Videos for conversion
    #>
    
   Param($MediaInput,$Type)
    
    write-output $MediaInput.name
    Write-Output $Type
    #if ($MediaInput.Name -notlike "old_*") 
  #  { 
        #rename if already mkv exists
       ## if ($sf.name -ilike "*.mkv")
         #   {
                   # Rename-Item -NewName ($sf.name –replace $sf.name,("old_" + $sf.name)) -path $SubFolders
         #   } 
   # }
}
#=========================================================================================================================


#=========================================================================================================================
function Get-Poster ()
{
}
#=========================================================================================================================




#=========================================================================================================================
function CleanupWorkingDir ()
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
