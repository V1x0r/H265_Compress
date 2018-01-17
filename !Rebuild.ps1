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
$DefaultPoster = $StrResourceDir + "\Default_Poster.jpg"
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
                $MediaOut = ($StrHomeDir + $Film.BaseName + ".mkv")
                RenameMKV -MediaInput $Film -MediaOut $MediaOut -Type "Movie"
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
               $MediaOut = ('"' + $Season.fullname + "\" + $Episode.BaseName + ".mkv" + '"')
               RenameMKV -MediaInput $Episode -MediaOut $MediaOut -Type "TV"
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
    
   Param($MediaInput,$MediaOut,$Type)
  # write-output $Mediaout
   if ($MediaInput.Extension -eq ".mkv")
   {
        $OriginalInput = ("old_" + $MediaInput.name)
      <#$MediaInput = Rename-Item $MediaInput.FullName $OriginalInput
        #Write-Output $OriginalInput
        if (Test-Path $OriginalInput)
        {        
        $MediaInput = Get-Item $OriginalInput
        } Else {
        $MediaInput = Get-Item ($Season.FullName + "\" + $OriginalInput)
        }
        #>
        Get-Poster -MediaInput $MediaInput -MediaOut $MediaOut -Type $Type
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

    Param($MediaInput,$MediaOut,$Type)
    $MoviePoster = ($MediaInput.BaseName + "-poster.jpg")
    $SeasonPoster = (($Season.BaseName + "-poster.jpg").ToLower().replace(" ",""))
    If ($Type -eq "Movie")
        {
        if (Test-Path $MoviePoster)
            {
            $Poster = $MoviePoster
            ParseKodiNFO -MediaInput $MediaInput -MediaOut $MediaOut -Type $Type
            }Else{
            Write-OutPut ("ERROR " + "'" + $MoviePoster + "'" + " Not Present, Using Default")
            $Poster = $DefaultPoster
            ParseKodiNFO -MediaInput $MediaInput -MediaOut $MediaOut -Type $Type
            }
        }
    If ($Type -eq "TV")
        {
        if (Test-Path $SeasonPoster)
            {
            $Poster = $SeasonPoster
            ParseKodiNFO -MediaInput $MediaInput -MediaOut $MediaOut -Type $Type
            }Else{
            Write-OutPut ("ERROR " + "'" + $SeasonPoster + "'" + " Not Present, Using Default")
            $Poster = $DefaultPoster
            ParseKodiNFO -MediaInput $MediaInput -MediaOut $MediaOut -Type $Type
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

    Param($MediaInput,$MediaOut,$Type)
    $Comment = "Brought To you By V1x0r"
    [string[]]$array = @("TITLE","SHOWTITLE","SEASON","EPISODE","PLOT","TAGLINE","MPAA","PREMIERED","STUDIO","GENRE")
    $MovieNFO = ($MediaInput.BaseName + ".nfo")
    $EpisodeNFO = ($Season.fullname + "\" + $Episode.BaseName + ".nfo")
    If ($Type -eq "Movie")
        {
        $VideoxmlOutput = New-Object System.XML.XmlTextWRiter(($StrHomeDir + $MediaInput.BaseName + ".xml"),$Null)
        $VideoxmlOutput.Formatting = 'Indented'
        $VideoxmlOutput.Indentation = 1
        $VideoxmlOutput.IndentChar = "`t"
        $VideoxmlOutput.WriteStartDocument()
        $VideoxmlOutput.WriteStartElement('Tags')
        if (Test-Path $MovieNFO)
            {

            [xml]$MovieNFOXML = Get-Content $MovieNFO
            $MovieNFOArr = Select-XML -XML $MovieNFOXML -XPath "//movie"| Select-Object -ExpandProperty Node
            #$MovieNFOArr.actor.name # | Select-Object "title"
            foreach ($item in $array) 
                {
                if ($MovieNFOArr.$item -ne $null)
                    {
                    $MovieNFOContent = $MovieNFOArr.$item.replace("&","and").replace("Rated ", "").trim()
                    $item = $item.replace("PLOT","SYNOPSIS").replace("MPAA","LAW_RATING").replace("TAGLINE","SUMMARY").replace("PREMIERED","DATE_RELEASED").replace("STUDIO","PRODUCTION_STUDIO")
                    $VideoxmlOutput.WriteStartElement('Tag')
                    $VideoxmlOutput.writestartelement('Simple')
                    $VideoxmlOutput.WriteElementString('Name',$item)
                    $VideoxmlOutput.WriteElementString('String',$MovieNFOContent)
                    $VideoxmlOutput.WriteEndElement()
                    $VideoxmlOutput.WriteEndElement()
                    }
                 }
            $VideoxmlOutput.WriteStartElement('Tag')
            $VideoxmlOutput.writestartelement('Simple')
            $VideoxmlOutput.WriteElementString('Name',"COMMENT")
            $VideoxmlOutput.WriteElementString('String',$Comment)
            $VideoxmlOutput.WriteEndElement()
            $VideoxmlOutput.WriteEndElement()
            $VideoxmlOutput.WriteEndDocument()
            $VideoxmlOutput.Flush()
            $VideoxmlOutput.Close()
            Compress_Media -MediaInput $MediaInput -MediaOut $MediaOut -Type $Type
            }Else{
            $VideoxmlOutput.WriteStartElement('Tag')
            $VideoxmlOutput.writestartelement('Simple')
            $VideoxmlOutput.WriteElementString('Name',"TITLE")
            $VideoxmlOutput.WriteElementString('String',$MediaInput.BaseName)
            $VideoxmlOutput.WriteEndElement()
            $VideoxmlOutput.WriteEndElement()
            $VideoxmlOutput.WriteStartElement('Tag')
            $VideoxmlOutput.writestartelement('Simple')
            $VideoxmlOutput.WriteElementString('Name',"COMMENT")
            $VideoxmlOutput.WriteElementString('String',$Comment)
            $VideoxmlOutput.WriteEndDocument()
            $VideoxmlOutput.Flush()
            $VideoxmlOutput.Close()
            Write-OutPut ("ERROR " + "'" + $MovieNFO + "'" + " Not Present - Created Basic xml")
            Compress_Media -MediaInput $MediaInput -MediaOut $MediaOut -Type $Type
            }
        }
    If ($Type -eq "TV")
        {
        $EpisodexmlOutput = New-Object System.XML.XmlTextWRiter(($Season.fullname + "\" + $Episode.BaseName + ".xml"),$Null)
        $Episodexml = ($Season.fullname + "\" + $Episode.BaseName + ".xml")
        $EpisodexmlOutput.Formatting = 'Indented'
        $EpisodexmlOutput.Indentation = 1
        $EpisodexmlOutput.IndentChar = "`t"
        $EpisodexmlOutput.WriteStartDocument()
        $EpisodexmlOutput.WriteStartElement('Tags')
        if (Test-Path $EpisodeNFO)
            {
            [xml]$EpisodeNFOXML = Get-Content $EpisodeNFO
            $EpisodeNFOArr = Select-XML -XML $EpisodeNFOXML -XPath "//episodedetails"| Select-Object -ExpandProperty Node
            foreach ($item in $array) 
                {
                if ($EpisodeNFOArr.$item -ne "")
                    {
                    $EpisodeNFOContent = $EpisodeNFOArr.$item.replace("&","and").replace("Rated ", "").trim()
                    $item = $item.replace("PLOT","SYNOPSIS").replace("MPAA","LAW_RATING").replace("TAGLINE","SUMMARY").replace("PREMIERED","DATE_RELEASED").replace("STUDIO","PRODUCTION_STUDIO")
                    $EpisodexmlOutput.WriteStartElement('Tag')
                    $EpisodexmlOutput.writestartelement('Simple')
                    $EpisodexmlOutput.WriteElementString('Name',$item)
                    $EpisodexmlOutput.WriteElementString('String',$EpisodeNFOContent)
                    $EpisodexmlOutput.WriteEndElement()
                    $EpisodexmlOutput.WriteEndElement()
                    }
                 }
            $EpisodexmlOutput.WriteStartElement('Tag')
            $EpisodexmlOutput.writestartelement('Simple')
            $EpisodexmlOutput.WriteElementString('Name',"COMMENT")
            $EpisodexmlOutput.WriteElementString('String',$Comment)
            $EpisodexmlOutput.WriteEndDocument()
            $EpisodexmlOutput.Flush()
            $EpisodexmlOutput.Close()
            Compress_Media -MediaInput $MediaInput -MediaOut $MediaOut -Type $Type
            }Else{
            $EpisodexmlOutput.WriteStartElement('Tag')
            $EpisodexmlOutput.writestartelement('Simple')
            $EpisodexmlOutput.WriteElementString('Name',"TITLE")
            $EpisodexmlOutput.WriteElementString('String',$Episode.BaseName)
            $EpisodexmlOutput.WriteEndElement()
            $EpisodexmlOutput.WriteEndElement()
            $EpisodexmlOutput.WriteStartElement('Tag')
            $EpisodexmlOutput.writestartelement('Simple')
            $EpisodexmlOutput.WriteElementString('Name',"COMMENT")
            $EpisodexmlOutput.WriteElementString('String',$Comment)
            $EpisodexmlOutput.WriteEndDocument()
            $EpisodexmlOutput.Flush()
            $EpisodexmlOutput.Close()
            Write-OutPut ("ERROR " + "'" + $EpisodeNFO + "'" + " Not Present - Created Basic xml")
            Compress_Media -MediaInput $MediaInput -MediaOut $MediaOut -Type $Type
            }
        }
}

#========================================================================================
#============================ Begin Media Conversion & tag ==============================
#========================================================================================
function Compress_Media
{
    <#
    .SYNOPSIS
    Compresses the provided media files into H265 inside of matroska
    #>
    Param($MediaInput,$MediaOut,$Type)
    $argument = ('`"' + $MediaInput.fullname + '`"')
    $CleanMKV = "`"--delete-attachment mime-type:image/jpeg --tags all: --edit info --set title=`""
    $p = Start-Process $MKVPROPEDIT -ArgumentList "`"$Mediainput.Fullname`"","`"--delete-attachment mime-type:image/jpeg --tags all: --edit info --set title=`"" -wait -PassThru -NoNewWindow
    
    $p.HasExited
    $p.ExitCode
    
    
    #write-output $argument
    #write-output $CleanMKV

$argument = ('"' + $MediaInput.fullname + '"')
$arg1 = " -i "
$argument2 = "D:\Video\Test\test.mkv"
#Start-Process $FFMPEG -ArgumentList $arg1,$Argument,$argument2 -wait -PassThru -NoNewWindow
#write-output $test
#write-output $argument
#write-output $argument2
#write-output $MediaOut
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
