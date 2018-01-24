clear-history
$StrHomeDir = ($(get-location).Path + "\");
$StrResourceDir = ($StrHomeDir + "Resources");
$MainScript = ($StrHomeDir + "!Rebuild.ps1");
$MP4BOX = $StrResourceDir + "\MP4Box.exe";
$MKVEXTRACT = $StrResourceDir + "\mkvextract.exe";
$MKVINFO = $StrResourceDir + "\Mkvinfo.exe";
$MKVPROPEDIT = $StrResourceDir + "\mkvpropedit.exe";
$MEDIAINFO = $StrResourceDir + "\MediaInfo.exe";
$FFMPEG = $StrResourceDir + "\FFmpeg.exe";
$DefaultPoster = $StrResourceDir + "\Default_Poster.jpg";
$ExcludeList = ("*.exe", "*.dll", "*.jpg", "*.png", "*.xml", "*.nfo");
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
       Where-Object {$_.Length -ge 5MB} | Where-Object {!($_.Name.Contains("old_"))} |`
       Where-Object {!(("old_" + $_.Name) | Test-Path)}
       $Count = $MovieFolder.count
    ForEach ($Film in $MovieFolder)
    {
        $MediaOut = ('"' + $StrHomeDir + $Film.BaseName + ".mkv" + '"')
        Get-Poster -MediaInput $Film -MediaOut $MediaOut -Type "Movie"
        #Get-Item -Path $Film.FullName -Filter 
    }

#================================== TV Shows ====================================

 $SeasonsFolders = Get-ChildItem $WorkingDir -recurse -directory -depth 1 |`
       Where-Object { $_.name -match "Season*"}
  ForEach ($Season in $SeasonsFolders)
    {
       $Episodes = Get-ChildItem $Season -Exclude $ExcludeList | Where-Object {$_.Length -ge 5MB} |`
       Where-Object {!($_.Name.Contains("old_"))} |`
       Where-Object {!(($Season.fullname + "\" + "old_" + $_.name) | Test-Path)}
       $Count = ($Episodes.count)
       ForEach ($Episode in $Episodes)
       {
            $MediaOut = ('"' + $Season.fullname + "\" + $Episode.BaseName + ".mkv" + '"')
            Get-Poster -MediaInput $Episode -MediaOut $MediaOut -Type "TV"
        }
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
    $MoviePoster = ($StrHomeDir + $MediaInput.BaseName + "-poster.jpg")
    $SeasonPoster = ($StrHomeDir + ($Season.BaseName + "-poster.jpg").ToLower().replace(" ",""))
    If ($Type -eq "Movie")
       {
       if (Test-Path $MoviePoster)
          {
          $Poster = $MoviePoster
          $PosterInfo = $Poster
          ParseKodiNFO -MediaInput $MediaInput -MediaOut $MediaOut -Type $Type
          }Else{
          $PosterInfo = ("ERROR " + "'" + $MoviePoster + "'" + " Not Present, Using Default")
          $Poster = $DefaultPoster
          ParseKodiNFO -MediaInput $MediaInput -MediaOut $MediaOut -Type $Type
          }
       }
    If ($Type -eq "TV")
       {
       if (Test-Path $SeasonPoster)
          {
          $Poster = $SeasonPoster
          $PosterInfo = $Poster
          ParseKodiNFO -MediaInput $MediaInput -MediaOut $MediaOut -Type $Type
          }Else{
          $PosterInfo = ("ERROR " + "'" + $SeasonPoster + "'" + " Not Present, Using Default")
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
       $OutComment = ($StrHomeDir + $MediaInput.BaseName + ".xml")
       $NFOInfo = $OutComment
       $VideoxmlOutput.Formatting = 'Indented'
       $VideoxmlOutput.Indentation = 1
       $VideoxmlOutput.IndentChar = "`t"
       $VideoxmlOutput.WriteStartDocument()
       $VideoxmlOutput.WriteStartElement('Tags')
       if (Test-Path $MovieNFO)
          {
          [xml]$MovieNFOXML = Get-Content ($MediaInput.BaseName + ".nfo") 
          $MovieNFOArr = Select-XML -XML $MovieNFOXML -XPath "//movie"| Select-Object -ExpandProperty Node
          #$MovieNFOArr.actor.name # | Select-Object "title"
          foreach ($item in $array) 
             {
             if ($MovieNFOArr.$item -ne $null)
                {
                $MovieNFOContent = $MovieNFOArr.$item.replace("&","and").replace("Rated ", "").trim() -join ', '
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
          Check_Codec -MediaInput $MediaInput -MediaOut $MediaOut -Type $Type
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
          $NFOInfo = ("ERROR " + "'" + $MovieNFO + "'" + " Not Present - Created Basic xml")
          Check_Codec -MediaInput $MediaInput -MediaOut $MediaOut -Type $Type
          }
       }
    If ($Type -eq "TV")
       {
       $EpisodexmlOutput = New-Object System.XML.XmlTextWRiter(($Season.fullname + "\" + $Episode.BaseName + ".xml"),$Null)
       $OutComment = ($Season.fullname + "\" + $Episode.BaseName + ".xml")
       $NFOInfo = $OutComment
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
                $EpisodeNFOContent = $EpisodeNFOArr.$item.replace("&","and").replace("Rated ", "").trim() -join ', '
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
          Check_Codec -MediaInput $MediaInput -MediaOut $MediaOut -Type $Type
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
          $NFOInfo = ("ERROR " + "'" + $EpisodeNFO + "'" + " Not Present - Created Basic xml")
          Check_Codec -MediaInput $MediaInput -MediaOut $MediaOut -Type $Type
          }
       }
}

#========================================================================================
#=============================  Determine Video Codec ===================================
#========================================================================================
function Check_Codec
{
    <#
    .SYNOPSIS
    Verifies if the video compression is required or not
    #>

    Param($MediaInput,$MediaOut,$Type)
    $FullInput = ('"' + $MediaInput.fullname + '"')
    $MEDIAINFOCLI = "--Inform=Video;%Format%"
    $MEDIATime = "--inform=General;%Duration/String3%"
    [string] $VideoFormat = (Run_Process -Filename $MEDIAINFO -Arguments $MEDIAINFOCLI,$FullInput -StdErr $false -StdOut $true)
    [string] $VideoTime = (Run_Process -Filename $MEDIAINFO -Arguments $MEDIATime,$FullInput -StdErr $false -StdOut $true)
    $VidTimeSec = ([TimeSpan]::Parse($VideoTime).TotalSeconds)
    if ($VideoFormat.trim().CompareTo("HEVC") -eq "0")
       {
          $ConvertMedia = $false
          RenameVideo -MediaInput $MediaInput -MediaOut $MediaOut -Type $Type
       }else{
          $ConvertMedia = $true
          RenameVideo -MediaInput $MediaInput -MediaOut $MediaOut -Type $Type
       }
    
}

#========================================================================================
#============================== Rename Video For Backup =================================
#========================================================================================
function RenameVideo
{
    <#
    .SYNOPSIS
    Renames Original Media to old_name
    #>
    
   Param($MediaInput,$MediaOut,$Type)
   
   #if ($MediaInput.Extension -eq ".mkv"){
       $OriginalInput = ("old_" + $MediaInput.name)
       $MediaInput = Rename-Item $MediaInput.FullName $OriginalInput
       #Write-Output $OriginalInput
       
       if (Test-Path $OriginalInput)
       {       
       $MediaInput = Get-Item $OriginalInput
       } Else {
       $MediaInput = Get-Item ($Season.FullName + "\" + $OriginalInput)
       }
  #  }
    Compress_Media -MediaInput $MediaInput -MediaOut $MediaOut -Type $Type
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
    
    $FullInput = ('"' + $MediaInput.fullname + '"')
    $CleanMKV = ('--delete-attachment mime-type:image/jpeg --tags all: --edit info --set title=')
    $FFMPEGArg1 = ('-hide_banner -i ' + $FullInput + ' -map 0 -c copy')
    $TagArg1 = ('--tags all:' + '"' + $OutComment + '" ')
    $TagArg2 = ('--attachment-name cover.jpg ')
    $TagArg3 = ('--add-attachment ' + '"' + $Poster + '"')
    
#================================= Clean MKV Poster =====================================
    if($MediaInput.extension -eq ".mkv")
    { 
       Run_Process -Filename $MKVPROPEDIT -Arguments $FullInput,$CleanMKV -StdErr $true -StdOut $false
    }

#================================ Convert Media Content =================================  
    if($ConvertMedia -eq $true)
    {
		$FFMPEGArg2 = ('-c:v libx265 -x265-params crf=21 -max_muxing_queue_size 9999')
    }Else{
		$FFMPEGArg2 = ('-c:v copy -max_muxing_queue_size 9999')
	}
    #StatusBar -FileCount $Count
    Run_Process -Filename $FFMPEG -Arguments $FFMPEGArg1,$FFMPEGArg2,$MediaOut -StdErr $true -StdOut $false

#===================================== Tag MKV File =====================================
    Run_Process -Filename $MKVPROPEDIT -Arguments $MediaOut,$TagArg1,$TagArg2,$TagArg3 -StdErr $true -StdOut $false
}

#========================================================================================
#=============================== Run Execution Commands =================================
#========================================================================================
function Run_Process
{
    <#
    .SYNOPSIS
    Executes scripts with Arguments
    #>
    Param($Filename,$Arguments,$StdErr,$StdOut)
    $stderrArr = New-Object System.Collections.ArrayList
    $p = new-object System.Diagnostics.ProcessStartInfo
    $p.Filename = $Filename
    $p.Arguments = $Arguments
    $p.RedirectStandardOutput = $StdOut
    $p.RedirectStandardError = $StdErr
    $p.UseShellExecute = $false
    $p.CreateNoWindow = $true
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $p
    $process.start() | Out-Null
    $StartTime = (Get-date -DisplayHint DateTime)
      while($process.HasExited -ne $true)
      {
      if ($Stderr -eq $true){
        [string]$stderrLine = $Process.StandardError.ReadLine();
             if ($stderrLine.contains("speed")){
                $stderrArr = @(((((($stderrLine -split '=' -split ' ') | Where { $_ }) -join "`r" |`
                Where { $_ }) -replace("frame","") -replace("q",",") -replace("-","") -replace("fps",",") |`
                Where { $_ }) -replace("size",",") -replace("time",",") -replace("bitrate",",") |`
                Where { $_ }) -replace("speed",",") -replace("x","") -replace("kbits/s","")).split(",")
                    foreach ($item in $stderrArr){
                     #clear-host
                      $InputSize = [int64]($MediaInput.length.ToString())
                          If ($InputSize -lt 1MB)
                          {
                             $InputSizeType = 1KB
                             $InputByteType = "KB" 
                          }ElseIf ($InputSize -ge 1MB -and $InputSize -lt 1GB)
                          {
                             $InputSizeType = 1MB
                             $InputByteType = "MB"
                          }ElseIf ($InputSize -ge 1GB -and $InputSize -lt 1TB)
                          {
                             $InputSizeType = 1GB
                             $InputByteType = "GB"
                          }
                      $ByteSize = [int64](($stderrarr[3]/"1").ToString())
                          If ($ByteSize -lt 1MB)
                          {
                             $SizeType = 1KB
                             $ByteType = "KB" 
                          }ElseIf ($ByteSize -ge 1MB -and $ByteSize -lt 1GB)
                          {
                             $SizeType = 1MB
                             $ByteType = "MB"
                          }ElseIf ($ByteSize -ge 1GB -and $ByteSize -lt 1TB)
                          {
                             $SizeType = 1GB
                             $ByteType = "GB"
                          }
                          $CompletedTime = [int64]([TimeSpan]::Parse($StdErrArr[4]).TotalSeconds)
                          $RemainingTime = [int](($VidTimesec-$CompletedTime)/$stderrarr[6]).toString(".00")
                          $timeSpan = New-Timespan -Seconds $RemainingTime
                          $TimeRemaining = '{0:00}:{1:00}:{2:00}' -f $timeSpan.Hours,$timeSpan.Minutes,$timeSpan.Seconds
                    StatusBar
                    }
             } 
         } 
          if ($StdOut -eq $true){
                if ($stdOut.length -ne "0"){
                    [string]$stdout = $process.StandardOutput.ReadToEnd();
                    Write-output $stdOut
                    }
          }
       }
   $process.WaitForExit()
   #  Time Left / EncSpeed
   #0 Frame
   #1 FPS
   #2 Q
   #3 Size
   #4 Amount Time Process (in Film)
   #5 Bitrate
   #6 Speed Writing
}

#========================================================================================
#================================== Status Bar Update ===================================
#========================================================================================
function StatusBar()
{
    <#
    .SYNOPSIS
    Print and Update Status Bar
    #>
    Write-Progress -Activity ("Rebuilding:" + $MediaInput.name + " Started At: " + $StartTime) -status ("Original Size: " + (($InputSize/$InputSizeType).ToString(".00")`
     + $InputByteType) + (" / New Size: " + ($stderrarr[3]/$SizeType).ToString(".00") + $ByteType) + (" / Current Speed: " + $stderrarr[6])`
     + (" / Remaining Time: " + $TimeRemaining) + (" / Percent comp: " + (($CompletedTime / $VidTimeSec) * 100).tostring(".00"))) -percentComplete (($CompletedTime / $VidTimeSec) * 100)
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
       if (Test-Path $OutComment)
          {
             Remove-Item -Path $OutComment -Force
          }
       if (Test-Path $MainScript) 
          {
             Remove-Item -Path $MainScript -Force
          }
}

#=========================================================================================================================

#=========================================================================================================================

TraverseFolders -WorkingDir $StrHomeDir
CleanupWorkingDir
#=========================================================================================================================
