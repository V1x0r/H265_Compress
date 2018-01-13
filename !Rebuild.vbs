'On Error Resume Next
Const ForReading = 1
Const DeleteReadOnly = TRUE
Dim objFSO, folder, files, sFolder
dim AudArr(), VidArr()
dim outputAudArray, outputVidArray
dim AudInfo, VidInfo
Set extensions = CreateObject("Scripting.Dictionary")
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set WshShell = WScript.CreateObject("WScript.Shell")
Set oShell = CreateObject("Shell.Application")
Set PlotRegEx = CreateObject("VBScript.RegExp")
Set SeasonRegEx = CreateObject("VBScript.RegExp")
Set EpisodeRegEx = CreateObject("VBScript.RegExp")
Set TitleRegEx = CreateObject("VBScript.RegExp")
Set ShowTitleRegEx = CreateObject("VBScript.RegExp")
Set MPAARegEx = CreateObject("VBScript.RegExp")
Set YearRegEx = CreateObject("VBScript.RegExp")
Set ApostropheFix = CreateObject("VBScript.RegExp")

'strHomeFolder = "C:\MP4BuildNTag"
sFolder = objFSO.GetAbsolutePathName(".") &  "\"
Set folder = objFSO.GetFolder(sFolder)
Set files = folder.Files

'mkvextract = strHomeFolder & "\mkvextract\mkvextract.exe"
'mkvmerge = strHomeFolder & "\mkvextract\mkvmerge.exe"
strHomeFolder = sFolder & "resources"
FFMPEG = chr(34) & strHomeFolder & "\FFMPEG.exe" & chr(34)
MP4BOX = chr(34) & strHomeFolder & "\MP4BOX.exe" & chr(34)
MEDIAINFO = chr(34) & strHomeFolder & "\MEDIAINFO.exe" & chr(34)
MKVPROPEDIT = chr(34) & strHomeFolder & "\mkvpropedit.exe" & chr(34)

	IF objFSO.FileExists(sFolder & "!Rebuild.vbs") Then 
		objFSO.DeleteFile(sFolder & "!Rebuild.vbs"),DeleteReadOnly
	END IF

'=====MAIN EXECUTION CALLS========
TraverseFolders folder
CleanupFiles
'=================================

Function TraverseFolders(fldr)
	'TV Shows
		For Each sf In fldr.SubFolders
			IF objFSO.getfolder(sf) <> strHomeFolder then
				Set folder = objFSO.GetFolder(sf)
				Set files = folder.Files
					'for each objfile in files
					'	WSCRIPT.ECHO ObjFile.Path
					'next
					DetType
			END IF
		Next
	'Movies
	DetType
End Function



Sub CleanupFiles

	IF objFSO.FolderExists(strHomeFolder) Then 
	WSCRIPT.ECHO "cleaning up Remaining resouces"
		objFSO.DeleteFolder(strHomeFolder),force
	END IF	
End Sub
	


Sub DetType
	For Each ObjFile In Files
		ext = objFSO.GetExtensionName(ObjFile)
		'Only Check files larger than 5MB
		IF ext <> "exe" then
			IF objFile.Size > 5000000 then
				getbase = objFSO.getbasename(ObjFile.Path)
				IF Left(getbase,4) <> "old_" then
					IF NOT objFSO.fileexists(folder & "\" & "old_" & getbase & ".mkv") then

'============================================================================================
'==================================== Video Information =====================================

						VidInfo = mediainfo & " --Inform=Video;%StreamOrder%,%Format%,%Codec%,%FrameRate%," _ 
						& "%FrameRate_Original% " & chr(34) & ObjFile.Path & chr(34)
							Set VidInfo = WshShell.Exec(VidInfo)
						VidInfo = VidInfo.StdOut.ReadLine()
		
'============================================================================================
'===================================== Vid Array Split ======================================

						outputVidArray = split(VidInfo,",")
						VidInt = 0
						reDim Preserve VidArr(AudInt)
						for each x in outputVidArray
							reDim Preserve VidArr(VidInt)
							VidArr(VidInt) = x
							VidInt = VidInt + 1
						next
						
						VidID = VidArr(0)
						VF = VidArr(1)
						VC = VidArr(2)
						FPS = VidArr(3)
							IF FPS = "" then
								FPS = VidArr(4)
							END IF

'============================================================================================
'=================================== Video Corrections ======================================

						IF VidID = "4113" then
							VidID = "1"
						END IF
						IF VF = "MPEG-4 Visual" then
							VF = "xvid"
						ElseIF VF = "HEVC" then
							VF = "H265"
						Else
							VF = "H264"
						END IF

'============================================================================================
'==================================== Audio Information =====================================

						AudioCnt = mediainfo & " --Inform=General;%AudioCount% " & chr(34) & _
						ObjFile.Path & chr(34)
							Set AudioCnt = WshShell.Exec(AudioCnt)
						AudioCnt = AudioCnt.StdOut.ReadLine()
						AudInfo = mediainfo & " --Inform=Audio;%StreamOrder%,%Language%,%Codec%," _
						& "%Delay%,%Channels%, " & chr(34) & ObjFile.Path & chr(34)
							Set AudInfo = WshShell.Exec(AudInfo)
						AudInfo = AudInfo.StdOut.ReadLine()
	
'============================================================================================
'===================================== Aud Array Split ======================================
		
						outputAudArray = split(AudInfo,",")
						AudInt = 0
						reDim Preserve AudArr(AudInt)
						for each x in outputAudArray
							reDim Preserve AudArr(AudInt)
							AudArr(AudInt) = x
							AudInt = AudInt + 1
						next

						AudID1 = AudArr(0)
						Lang1 = AudArr(1)
						AF1 = AudArr(2)
						Delay1 = AudArr(3)
						AC1 = AudArr(4)
						'AudArr(5) blank Comma delimiter
						IF AudioCnt <> 1 then
							AudID2 = AudArr(5)
							Lang2 = AudArr(6)
							AF2 = AudArr(7)
							Delay2 = AudArr(8)
							AC2 = AudArr(9)
							'Second Audio Details AudArr(10) Blank Comma Delimter
							IF AudioCnt = 3 then
								AudID3 = AudArr(10)
								Lang3 = AudArr(11)
								AF3 = AudArr(12)
								Delay3 = AudArr(13)
								AC3 = AudArr(14)
							'Third Audio Details AudArr(15) Blank Comma Delimter
							End If
						END IF

'============================================================================================
'=================================== Audio Corrections ======================================
						IF AudID1 = "234" then
							AudID1 = "2"
						END IF
						IF AudID1 = "4352" then
							AudID1 = "2"
						ElseIF AudID1 = "23" then
							AudID1 = "2"
						END IF
						IF AudID2 = "235" then
							AudID2 = "3"
						END IF
						IF AudID2 = "4353" then
							AudID2 = "3"
						ElseIF AudID2 = "24" then
							AudID1 = "3"
						END IF
						IF ((AC1 = "8 / 7 / 6") or _
							(AC1 = "8 / 7") or _
							(AC1 = "8 / 6")) then
							AC1 = "8"
						END IF
						IF ((AC1 = "7 / 6 / 5") or _
							(AC1 = "7 / 6")) then
							AC1 = "7"
						END IF
						IF ((AC1 = "2 / 2 / 2") or _
							(AC1 = "2 / 2")) then
							AC1 = "2"
						END IF
						IF ((AC1 = "2 / 23 / 23") or _
							(AC1 = "2 / 23")) then
							AC1 = "2"
						END IF
						IF ((AC1 = "2 / 24 / 24") or _
							(AC1 = "2 / 24")) then
							AC1 = "2"
						END IF
						IF AC1 = "Object Based / 8" then
							AC1 = "8"
						END IF
						IF AC1 = "Object Based / 8 / 6" then
							AC1 = "8"
						END IF
						IF ((AC2 = "8 / 7 / 6") or _
							(AC2 = "8 / 7") or _
							(AC2 = "8 / 6")) then
							AC2 = "8"
						END IF
						IF ((AC2 = "7 / 6 / 5") or _
							(AC2 = "7 / 6")) then
							AC2 = "7"
						END IF
						IF ((AC2 = "2 / 2 / 2") or _
							(AC2 = "2 / 2")) then
							AC2 = "2"
						END IF
						IF ((AC2 = "2 / 23 / 23") or _
							(AC2 = "2 / 23")) then
							AC2 = "2"
						END IF
						IF ((AC2 = "2 / 24 / 24") or _
							(AC2 = "2 / 24")) then
							AC2 = "2"
						END IF
						IF AC2 = "Object Based / 8" then
							AC2 = "8"
						END IF
						IF AC2 = "Object Based / 8 / 6" then
							AC2 = "8"
						END IF
						IF ((AC3 = "8 / 7 / 6") or _
							(AC3 = "8 / 7") or _
							(AC3 = "8 / 6")) then
							AC3 = "8"
						END IF
						IF ((AC3 = "7 / 6 / 5") or _
							(AC3 = "7 / 6")) then
							AC3 = "7"
						END IF
						IF ((AC3 = "2 / 2 / 2") or _
							(AC3 = "2 / 2")) then
							AC3 = "2"
						END IF
						IF ((AC3 = "2 / 23 / 23") or _
							(AC3 = "2 / 23")) then
							AC3 = "2"
						END IF
						IF ((AC3 = "2 / 24 / 24") or _
							(AC3 = "2 / 24")) then
							AC3 = "2"
						END IF
						IF AC3 = "Object Based / 8" then
							AC3 = "8"
						END IF
						IF AC3 = "Object Based / 8 / 6" then
							AC3 = "8"
						END IF
			
'===================================== Audio Delay ==========================================

						IF Delay1 = "" then
							Delay1 = 0
						END IF
						IF ((Delay1 <> 0) or (Delay1 <> null)) then
							Delay1 = Delay1 / 1000
						END IF
						
						IF AudioCnt <> 1 then
							IF Delay2 = "" then
								Delay2 = 0
							END IF
							IF ((Delay2 <> 0) or (Delay2 <> null)) then
								Delay2 = Delay2 / 1000
							END IF
								IF AudioCnt = 3 then
									IF Delay3 = "" then
										Delay3 = 0
									END IF
									IF ((Delay3 <> 0) or (Delay3 <> null)) then
										Delay3 = Delay3 / 1000
									END IF
								END IF
						END IF
			
'==================================== Supported Audio =======================================
'============================================================================================
'For all supported Audio codecs, as currently defined, so they are copied exactly.
						AF1SUPPORTED = FALSE
						AF2SUPPORTED = FALSE
						AF3SUPPORTED = FALSE
'NewCodec SpecIFied as FLAC or ATMOS and TRUEHD In lower statements
						AF1NewCodec = "libfdk_aac"
						AF2NewCodec = "libfdk_aac"
						AF3NewCodec = "libfdk_aac"

'========================================== MP3 =============================================
						IF ((AF1 = "MP3") or _
							(AF1 = "MPEG Audio") or _
							(AF1 = "MPA1L2") or _
							(AF1 = "MPA2L3") or _
							(AF1 = "MPA1L3")) then
							AF1 = "MP3"
							AF1SUPPORTED = TRUE
						END IF

						'Track 2
						IF ((AF2 = "MP3") or _ 
							(AF2 = "MPEG Audio") or _ 
							(AF2 = "MPA1L2") or _
							(AF2 = "MPA2L3") or _
							(AF2 = "MPA1L3")) then
							AF2 = "MP3"
							AF2SUPPORTED = TRUE
						END IF
						
						'Track 3
						IF ((AF3 = "MP3") or _ 
							(AF3 = "MPEG Audio") or _ 
							(AF3 = "MPA1L2") or _
							(AF3 = "MPA2L3") or _
							(AF3 = "MPA1L3")) then
							AF3 = "MP3"
							AF3SUPPORTED = TRUE
						END IF

'========================================== AAC =============================================
						IF ((AF1 = "AAC") or _
							(AF1 = "AAC Main") or _
							(AF1 = "AAC LC") or _
							(AF1 = "AAC LC-SBR-PS") or _
							(AF1 = "AAC LC-SBR")) then
							AF1 = "AAC"
							AF1SUPPORTED = TRUE
						END IF

						'Track 2
						IF ((AF2 = "AAC") or _
							(AF2 = "AAC Main") or _
							(AF2 = "AAC LC") or _
							(AF2 = "AAC LC-SBR-PS") or _
							(AF2 = "AAC LC-SBR")) then
							AF2 = "AAC"
							AF2SUPPORTED = TRUE
						END IF
						
						'Track 3
						IF ((AF3 = "AAC") or _
							(AF3 = "AAC Main") or _
							(AF3 = "AAC LC") or _
							(AF3 = "AAC LC-SBR-PS") or _
							(AF3 = "AAC LC-SBR")) then
							AF3 = "AAC"
							AF3SUPPORTED = TRUE
						END IF

'========================================== AC3 =============================================
						IF ((AF1 = "AC3") or _
							(AF1 = "AC-3")) then
							AF1 = "AC3"
							AF1SUPPORTED = TRUE
						END IF

						'Track 2
						IF ((AF2 = "AC3") or _
							(AF2 = "AC-3")) then
							AF2 = "AC3"
							AF2SUPPORTED = TRUE
						END IF
						
						'Track 3
						IF ((AF3 = "AC3") or _
							(AF3 = "AC-3")) then
							AF3 = "AC3"
							AF3SUPPORTED = TRUE
						END IF

'========================================== EAC3 ============================================
						IF ((AF1 = "EAC3") or _
							(AF1 = "AC3+")) Then
							AF1 = "EAC3"
							AF1SUPPORTED = TRUE
						END IF

						'Track 2
						IF ((AF2 = "EAC3") or _
							(AF2 = "AC3+")) Then
							AF2 = "EAC3"
							AF2SUPPORTED = TRUE
						END IF
						
						'Track 3
						IF ((AF3 = "EAC3") or _
							(AF3 = "AC3+")) Then
							AF3 = "EAC3"
							AF3SUPPORTED = TRUE
						END IF

'========================================== DTS =============================================
						IF ((AF1 = "DTS") or _
							(AF1 = "DTS-HD")) then
							AF1 = "DTS"
							AF1SUPPORTED = TRUE
						END IF

						'Track 2
						IF ((AF2 = "DTS") or _
							(AF2 = "DTS-HD")) then
							AF2 = "DTS"
							AF2SUPPORTED = TRUE
						END IF
						
						'Track 3
						IF ((AF3 = "DTS") or _
							(AF3 = "DTS-HD")) then
							AF3 = "DTS"
							AF3SUPPORTED = TRUE
						END IF

'=================================== unSupported Audio ======================================
'============================================================================================
'This Media will be converted to either AAC or FLAC -- depending on original Codec.
'========================================== Opus ============================================
						IF ((AF1 = "OGG") or _
							(AF1 = "Opus")) Then
							AF1 = "Opus"
							AF1SUPPORTED = FALSE
							AF1NewCodec = "libfdk_aac"
						END IF
						
						'Track 2
						IF ((AF2 = "OGG") or _
							(AF2 = "Opus")) Then
							AF2 = "Opus"
							AF2SUPPORTED = FALSE
							AF2NewCodec = "libfdk_aac"
						END IF
						
						'Track 3
						IF ((AF3 = "OGG") or _
							(AF3 = "Opus")) Then
							AF3 = "Opus"
							AF3SUPPORTED = FALSE
							AF3NewCodec = "libfdk_aac"
						END IF

'========================================= TRUEHD ===========================================
						IF ((AF1 = "TrueHD") or _
							(AF1 = "A_TRUEHD")) then
							AF1SUPPORTED = FALSE
							AF1NewCodec = "flac"
						END IF
						
						'Track 2
						IF ((AF2 = "TrueHD") or _
							(AF2 = "A_TRUEHD")) then
							AF2SUPPORTED = FALSE
							AF2NewCodec = "flac"
						END IF
						
						'Track 3
						IF ((AF3 = "TrueHD") or _
							(AF3 = "A_TRUEHD")) then
							AF3SUPPORTED = FALSE
							AF3NewCodec = "flac"
						END IF

'============================================================================================
'========================================== Atmos ===========================================
						IF ((AF1 = "Atmos") or _
							(AF1 = "Atmos / TRUEHD")) then
							AF1 = "Atmos"
							AF1SUPPORTED = FALSE
							AF1NewCodec = "flac"
						END IF
						
						'Track 2
						IF ((AF2 = "Atmos") or _
							(AF2 = "Atmos / TRUEHD")) then
							AF2 = "Atmos"
							AF2SUPPORTED = FALSE
							AF2NewCodec = "flac"
						END IF
						
						'Track 3
						IF ((AF3 = "Atmos") or _
							(AF3 = "Atmos / TRUEHD")) then
							AF3 = "Atmos"
							AF3SUPPORTED = FALSE
							AF3NewCodec = "flac"
						END IF
				
'============================================================================================
						SubID = mediainfo & " --Inform=Text;%ID% " & chr(34) & ObjFile.Path & chr(34)
							Set SubObject = WshShell.Exec(SubID)
						SubID = SubObject.StdOut.ReadLine()
						SubCodec = mediainfo & " --Inform=Text;%Format% " & chr(34) & _
						ObjFile.Path & chr(34)
							Set SubObject = WshShell.Exec(SubCodec)
						SubCodec = SubObject.StdOut.ReadLine()
						MainVF = mediainfo & " --Inform=General;%Codec% " & chr(34) & _
						ObjFile.Path & chr(34)
							Set VidForm = WshShell.Exec(MainVF)
						MainVF = VidForm.StdOut.ReadLine()
						
						posterFolder = Replace(objFSO.getbasename(Folder.Path)," ","")
'TV Shows Posters
						IF objFSO.FileExists(posterFolder & "-poster.jpg") then
							TVShow = True
							Poster = posterFolder & "-poster.jpg"
							WSCRIPT.ECHO "Poster File Found!"
						END IF
'Movie Posters
'WSCRIPT.ECHO "1: " & sFolder & getbase & "-poster.jpg"
'WSCRIPT.ECHO "2: " & posterfolder & "\" & getbase & "-poster.jpg"
						IF objFSO.FileExists(sFolder & getbase & "-poster.jpg") then
							TVShow = False
							Poster = sFolder & getbase & "-poster.jpg"
							WSCRIPT.ECHO "Poster File Found!"
						ElseIF objFSO.FileExists(posterfolder & "\" & getbase & "-poster.jpg") then
							TVShow = False
							Poster = posterfolder & "\" & getbase & "-poster.jpg"
							WSCRIPT.ECHO "Poster File Found!"
						END IF
				
'RebuiltMKV DTS Audio
' mkvpropedit.exe [options] {source-filename} {actions}
' --delete-attchment 'selector'
' --add-attachment Poster --attachment-name cover.jpg

						IF isNumeric(VidID)Then
							Call BuildXML(ObjFile, VidID, AudID1, AudID2, AudID3, AC1, AC2, AC3, _
								VF, AF1, AF2, AF3, AF1SUPPORTED, AF2SUPPORTED, AF3SUPPORTED, Delay1, _ 
								Delay2, Delay3, FPS, VC, SubID, SubCodec, Poster, AudioCnt, _
								AF1NewCodec, AF2NewCodec, AF3NewCodec, Lang1, Lang2, Lang3, TVShow)
						END IF
					END IF
				END IF
			END IF
		END IF
	Next
End Sub

Sub BuildXML(ObjFile, VidID, AudID1, AudID2, AudID3, AC1, AC2, AC3, _
				VF, AF1, AF2, AF3, AF1SUPPORTED, AF2SUPPORTED, AF3SUPPORTED, Delay1, _ 
				Delay2, Delay3, FPS, VC, SubID, SubCodec, Poster, AudioCnt, _
				AF1NewCodec, AF2NewCodec, AF3NewCodec, Lang1, Lang2, Lang3, TVShow)
	getbase = folder & "\" & objFSO.getbasename(ObjFile.Path)
	KodiNFO = getbase & ".nfo"
	newXML = getbase & ".xml"
	IF objFSO.FileExists(KodiNFO) Then
		Set OutXML = objfso.CreateTextFile(newXML, True)
		Set KodiFile = objFSO.OpenTextFile(KodiNFO, ForReading)

		'============================================================================================
		'================================== Patterns From Kodi XML ==================================
		PlotRegEx.Pattern = "<plot>"
		SeasonRegEx.Pattern = "<season>"
		EpisodeRegEx.Pattern = "<episode>"
		TitleRegEx.Pattern = "<title>"
		ShowTitleRegEx.Pattern = "<showtitle>"
		MPAARegEx.Pattern = "<mpaa>"
		YearRegEx.Pattern = "<year>"
		ApostropheFix.Pattern = "&apos;"

			Do Until KodiFile.AtEndOfStream
				WholeString = KodiFile.ReadLine
				Set ApostropheMatches = ApostropheFix.Execute(WholeString)
				If ApostropheMatches.Count > 0 Then
					For Each StrMatch in ApostropheMatches
						WholeString = Replace(WholeString,"&apos;","'")
					Next
				End If
				Set PlotMatches = PlotRegEx.Execute(WholeString)
				If PlotMatches.Count > 0 Then
					For Each strMatch in PlotMatches
						PlotString = Replace(WholeString,"<plot>","")
						PlotString = Replace(PlotString,"</plot>","")
						Plot = Trim(PlotString)
					Next
				End If
				Set SeasonMatches = SeasonRegEx.Execute(WholeString)
				If SeasonMatches.Count > 0 Then
					For Each strMatch in SeasonMatches
						SeasonString = Replace(WholeString,"<season>","")
						SeasonString = Replace(SeasonString,"</season>","")
						Season = Trim(SeasonString)
					Next
				End If
				Set EpisodeMatches = EpisodeRegEx.Execute(WholeString)
				If EpisodeMatches.Count > 0 Then
					For Each strMatch in EpisodeMatches
						EpisodeString = Replace(WholeString,"<episode>","")
						EpisodeString = Replace(EpisodeString,"</episode>","")
						Episode = Trim(EpisodeString)
					Next
				End If
				Set TitleMatches = TitleRegEx.Execute(WholeString)
				If TitleMatches.Count > 0 Then
					For Each strMatch in TitleMatches
						TitleString = Replace(WholeString,"<title>","")
						TitleString = Replace(TitleString,"</title>","")
						Title = Trim(TitleString)
					Next
				End If
				Set ShowTitleMatches = ShowTitleRegEx.Execute(WholeString)
				If ShowTitleMatches.Count > 0 Then
					For Each strMatch in ShowTitleMatches
						ShowTitleString = Replace(WholeString,"<showtitle>","")
						ShowTitleString = Replace(ShowTitleString,"</showtitle>","")
						ShowTitle = Trim(ShowTitleString)
					Next
				End If
				Set MPAAMatches = MPAARegEx.Execute(WholeString)
				If MPAAMatches.Count > 0 Then
					For Each strMatch in MPAAMatches
						MPAAString = Replace(WholeString,"<mpaa>","")
						MPAAString = Replace(MPAAString,"</mpaa>","")
						MPAA = Trim(MPAAString)
					Next
				End If
				Set YearMatches = YearRegEx.Execute(WholeString)
				If YearMatches.Count > 0 Then
					For Each strMatch in YearMatches
						YearString = Replace(WholeString,"<year>","")
						YearString = Replace(YearString,"</year>","")
						EPYear = Trim(YearString)
					Next
				End If
			Loop
		KodiFile.Close

		'============================================================================================
		'==================== Generated Film XML File For Better Video Tagging ======================
		'============================================================================================
		OutXML.WriteLine "<Tags>"
		'========================================== Title ===========================================
		OutXML.WriteLine VBTab & "<Tag>" & VBCr & VBTab & VBTab & "<Simple>"
		OutXML.WriteLine VBTab & VBTab & VBTab & "<Name>" & "Title" & "</Name>"
		OutXML.WriteLine VBTab & VBTab & VBTab & "<String>" & Title & "</String>"
		OutXML.WriteLine VBTab & VBTab & "</Simple>" & VBCr & VBTab & "</Tag>"
		'======================================= MPAARating =========================================
		OutXML.WriteLine VBTab & "<Tag>" & VBCr & VBTab & VBTab & "<Simple>"
		OutXML.WriteLine VBTab & VBTab & VBTab & "<Name>" & "MPAA Rating" & "</Name>"
		OutXML.WriteLine VBTab & VBTab & VBTab & "<String>" & MPAA & "</String>"
		OutXML.WriteLine VBTab & VBTab & "</Simple>" & VBCr & VBTab & "</Tag>"
		'========================================== Year ============================================
		OutXML.WriteLine VBTab & "<Tag>" & VBCr & VBTab & VBTab & "<Simple>"
		OutXML.WriteLine VBTab & VBTab & VBTab & "<Name>" & "DATE_RELEASED" & "</Name>"
		OutXML.WriteLine VBTab & VBTab & VBTab & "<String>" & EPYear & "</String>"
		OutXML.WriteLine VBTab & VBTab & "</Simple>" & VBCr & VBTab & "</Tag>"
		IF TVShow = True Then
			'======================================== ShowTitle =========================================
			OutXML.WriteLine VBTab & "<Tag>" & VBCr & VBTab & VBTab & "<Simple>"
			OutXML.WriteLine VBTab & VBTab & VBTab & "<Name>" & "Show Title" & "</Name>"
			OutXML.WriteLine VBTab & VBTab & VBTab & "<String>" & ShowTitle & "</String>"
			OutXML.WriteLine VBTab & VBTab & "</Simple>" & VBCr & VBTab & "</Tag>"
			'========================================= Season ===========================================
			OutXML.WriteLine VBTab & "<Tag>" & VBCr & VBTab & VBTab & "<Simple>"
			OutXML.WriteLine VBTab & VBTab & VBTab & "<Name>" & "Season" & "</Name>"
			OutXML.WriteLine VBTab & VBTab & VBTab & "<String>" & Season & "</String>"
			OutXML.WriteLine VBTab & VBTab & "</Simple>" & VBCr & VBTab & "</Tag>"
			'========================================= Episode ==========================================
			OutXML.WriteLine VBTab & "<Tag>" & VBCr & VBTab & VBTab & "<Simple>"
			OutXML.WriteLine VBTab & VBTab & VBTab & "<Name>" & "Episode" & "</Name>"
			OutXML.WriteLine VBTab & VBTab & VBTab & "<String>" & Episode & "</String>"
			OutXML.WriteLine VBTab & VBTab & "</Simple>" & VBCr & VBTab & "</Tag>"
		End If
		'======================================= Description ========================================
		OutXML.WriteLine VBTab & "<Tag>" & VBCr & VBTab & VBTab & "<Simple>"
		OutXML.WriteLine VBTab & VBTab & VBTab & "<Name>" & "LongDescription" & "</Name>"
		OutXML.WriteLine VBTab & VBTab & VBTab & "<String>" & Plot & "</String>"
		OutXML.WriteLine VBTab & VBTab & "</Simple>" & VBCr & VBTab & "</Tag>"
		'========================================= Comment ==========================================
		OutXML.WriteLine VBTab & "<Tag>" & VBCr & VBTab & VBTab & "<Simple>"
		OutXML.WriteLine VBTab & VBTab & VBTab & "<Name>Comment</Name>"
		OutXML.WriteLine VBTab & VBTab & VBTab & "<String>Brought To you By V1x0r</String>"
		OutXML.WriteLine VBTab & VBTab & "</Simple>" & VBCr & VBTab & "</Tag>"
		OutXML.WriteLine "</Tags>"
		OutXML.close
		'============================================================================================
	End If
	Call HEVCRebuild(ObjFile, VidID, AudID1, AudID2, AudID3, AC1, AC2, AC3, _
				VF, AF1, AF2, AF3, AF1SUPPORTED, AF2SUPPORTED, AF3SUPPORTED, Delay1, _ 
				Delay2, Delay3, FPS, VC, SubID, SubCodec, Poster, AudioCnt, _
				AF1NewCodec, AF2NewCodec, AF3NewCodec, Lang1, Lang2, Lang3, TVShow, Title)
End Sub

Sub HEVCRebuild(ObjFile, VidID, AudID1, AudID2, AudID3, AC1, AC2, AC3, _
				VF, AF1, AF2, AF3, AF1SUPPORTED, AF2SUPPORTED, AF3SUPPORTED, Delay1, _ 
				Delay2, Delay3, FPS, VC, SubID, SubCodec, Poster, AudioCnt, _
				AF1NewCodec, AF2NewCodec, AF3NewCodec, Lang1, Lang2, Lang3, TVShow, Title)
	ext = objFSO.GetExtensionName(ObjFile)
	getbase = folder & "\" & objFSO.getbasename(ObjFile.Path)
	renbase = objFSO.getbasename(ObjFile.Path)
	newXML = getbase & ".xml"
	IF objFSO.FileExists(newXML) Then
		COMMENT = chr(34) & newXML & Chr(34)
	Else
		COMMENT = chr(34) & strHomeFolder & "\comment.xml" & chr(34)
	End If
	VFSrc = VF
	AF1Src = AF1
	AF2Ssrc = AF2
	FFAudio1Title = ""
	FFAudio2Title = ""
	FFAudio3Title = ""
	If AC1 = "8" then
		FFAudio1Title = "Surround 7.1"
		ElseIF AC1 = "7" then
				FFAudio1Title = "Surround 6.1"
		ElseIF AC1 = "6" then
				FFAudio1Title = "Surround 5.1"
		ElseIF AC1 = "5" then
				FFAudio1Title = "Surround 5"
		ElseIF AC1 = "2" then
				FFAudio1Title = "Stereo"
		ElseIF AC1 = "1" then
				FFAudio1Title = "Mono"
	End If
	if AC2 = "8" then
		FFAudio2Title = "Surround 7.1"
		ElseIF	AC2 = "7" then
				FFAudio2Title = "Surround 6.1"
		ElseIF	AC2 = "6" then
				FFAudio2Title = "Surround 5.1"
		ElseIF	AC2 = "5" then
				FFAudio2Title = "Surround 5"
		ElseIF	AC2 = "2" then
				FFAudio2Title = "Stereo"
		ElseIF	AC2 = "1" then
				FFAudio2Title = "Mono"
	End If
	if AC3 = "8" then
		FFAudio3Title = "Surround 7.1"
		ElseIF	AC3 = "7" then
				FFAudio3Title = "Surround 6.1"
		ElseIF	AC3 = "6" then
				FFAudio3Title = "Surround 5.1"
		ElseIF	AC3 = "5" then
				FFAudio3Title = "Surround 5"
		ElseIF	AC3 = "2" then
				FFAudio3Title = "Stereo"
		ElseIF	AC3 = "1" then
				FFAudio3Title = "Mono"
	End If
	AC1 = " -ac " & AC1
	AC2 = " -ac " & AC2
	AC3 = " -ac " & AC3
	AF1Convert = FALSE
	AF2Convert = FALSE
	AF3Convert = FALSE
	AF1SUPPORTED = TRUE
	AF2SUPPORTED = TRUE
	AF3SUPPORTED = TRUE
	VF = "H265"
	IF vidid <> 0 Then
		map0 = " -map 0:" & VidID & " "
		'map0 = " -map 0:" & VidID - 1 & " "
		else
		map0 = " -map 0:0 "
	END IF
	map1 = "" 
	map2 = ""
	map3 = ""
	
	H265Out = chr(34) & getbase & ".H265" & chr(34)
	FFAudio2 = Null
    IF objFile.Size > 12884901888 then
      compress = TRUE
    END IF
	
	IF VFSrc <> "H265" then
		VidCodec = "-c:v libx265 -x265-params crf=21" & " -metadata:s:v title=" & chr(34) & Title & chr(34)
		convertVid = TRUE
		Else
		VidCodec = "-c:v copy" & " -metadata:s:v title=" & chr(34) & Title & chr(34)
		convertVid = FALSE
	END IF
	
	IF compress = TRUE Then
		VidCodec = "-c:v libx265 -x265-params crf=21" & " -metadata:s:v title=" & chr(34) & renbase & chr(34)
		convertVid = TRUE
	END IF
	
'1st audio track rules
	IF AF1SUPPORTED = TRUE Then
		IF vidid <> 0 then
			map1 = " -map 0:" & AudID1 & " "
			'map1 = " -map 0:" & AudID1 - 1 & " "
			else
			map1 = " -map 0:1 "
		END IF
		'map1 = " -map 0:" & AudID1 - 1 & " "
		FFAudio1 = "-c:a:0 copy" & AC1 & " -metadata:s:a:0 title=" & chr(34) & FFAudio1Title & chr(34)
		ElseIF AF1SUPPORTED = FALSE Then
			IF vidid <> 0 then
				map1 = " -map 0:" & AudID1 & " "
				'map1 = " -map 0:" & AudID1 - 1 & " "
				else
				map1 = " -map 0:1 "
			END IF
		FFAudio1 = "-c:a:0 " & AF1NewCodec & " -strict -2" & AC1 & " -metadata:s:a:0 title=" & chr(34) & FFAudio1Title & chr(34)
		AF1 = AF1NewCodec
		AF1Convert = TRUE
	END IF

'2 or more audio track conversion rules *up to 3 tracks total*
	IF AudioCnt <> 1 Then
		IF AF2SUPPORTED = TRUE Then
			IF vidid <> 0 then
				map2 = " -map 0:" & AudID2 & " "
				'map2 = " -map 0:" & AudID2 - 1 & " "
				else
				map2 = " -map 0:2 "
			END IF
				FFAudio2 = "-c:a:1 copy" & AC2 & " -metadata:s:a:1 title=" & chr(34) & FFAudio2Title & chr(34)
				FFAudio2 = FFAudio2 & chr(32)
			ElseIF AF2SUPPORTED = FALSE Then
				IF vidid <> 0 then
					map2 = " -map 0:" & AudID2 & " "
					'map2 = " -map 0:" & AudID2 - 1 & " "
					else
					map2 = " -map 0:2 "
				END IF
					FFAudio2 = "-c:a:1 " & AF2NewCodec & " -strict -2" & AC2 & " -metadata:s:a:1 title=" & chr(34) & FFAudio2Title & chr(34)
					AF2 = AF2NewCodec
					AF2Convert = TRUE
					FFAudio2 = FFAudio2 & chr(32)
		END IF
		IF AudioCnt = 3 Then
			IF AF3SUPPORTED = TRUE Then
				IF vidid <> 0 then
					map3 = " -map 0:" & AudID3 & " "
					'map3 = " -map 0:" & AudID3 - 1 & " "
					else
					map3 = " -map 0:3 "
				END IF
					FFAudio3 = "-c:a:2 copy" & AC3 & " -metadata:s:a:2 title=" & chr(34) & FFAudio3Title & chr(34)
					FFAudio3 = chr(32) & FFAudio3 & chr(32)
				ElseIF AF3SUPPORTED = FALSE Then
					IF vidid <> 0 then
						map3 = " -map 0:" & AudID3 & " "
						'map3 = " -map 0:" & AudID3 - 1 & " "
						else
						map3 = " -map 0:3 "
					END IF
						FFAudio3 = "-c:a:2 " & af3NewCodec & " -strict -2" & AC3 & " -metadata:s:a:2 title=" & chr(34) & FFAudio3Title & chr(34)
						af3 = af3NewCodec
						af3Convert = TRUE
						FFAudio3 = chr(32) & FFAudio3 & chr(32)
			END IF
		END IF
	END IF
	
	'IF SubCodec = "ASS" then
	'		IF ext = "mkv" then
	'			SubID = SubID - 1
	'		END IF
		SubOut = chr(34) & sFolder & getbase & ".srt" & chr(34)
	'	WSHSHELL.RUN mkvextract & " --ui-language en tracks " & chr(34) & inFile _
	'	& chr(34) & chr(32) & SubID & ":" & chr(34) & SubOut & chr(34), 1, TRUE
	'Else
	'	Subtitle = "-c:s:1 copy"
	'	SubOut = chr(34) & getbase & "." & SubCodec & chr(34)
	'	WSHSHELL.RUN FFmpeg & " -hide_banner -i " & chr(34) & inFile & chr(34) _
	'	& chr(32) & Subtitle & chr(32) & chr(34) & SubOut & chr(34), 1, TRUE
	'END IF
	
	IF objFSO.FileExists(SubOut) Then
		subtitleAdd = " -add " & chr(34) & SubOut & ":lang=eng" & chr(34)
		else
		subtitleAdd = ""
	END IF

	IF ext = "mkv" then
		outFile = folder & "\" & renbase & ".mkv"
		inFile = folder & "\" & "old_" & renbase & ".mkv"
		objFSO.MoveFile outFile, inFile
		rename = TRUE
		else
		outFile = getbase & ".mkv"
		'outFile = getbase & ".mp4"
		inFile = getbase & "." & ext
		rename = FALSE
	END IF
	
'Add DELAY of audio file IF required'

'https://forum.videohelp.com/threads/346293-Insert-Audio-Delay-With-ffmpeg
	'remove first audio file...for when first codec is lower quality or wrong language
	'sCmd1 = FFmpeg & " -hide_banner -i " & chr(34) & inFile & chr(34) & map0 & map2 & _
	' chr(32) & VidCodec & chr(32) & FFAudio1 & Chr(32) & FFAudio2 & chr(34) & outFile & chr(34)
	' audio channels ffmpeg -ac 6 (6channels)
'	sCmd1 = FFmpeg & " -hide_banner -i " & chr(34) & inFile & chr(34) & map0 & _
'		map1 & map2 & map3 & chr(32) & VidCodec & chr(32) & FFAudio1 & chr(32) & FFAudio2 _
'		& FFAudio3 & chr(34) & outFile & chr(34)
	
	sCmd1 = mkvpropedit & chr(32) & chr(34) & inFile & chr(34) & chr(32) & _
		"--delete-attachment mime-type:image/jpeg --tags all: --edit info --set title="
	
	sCmd2 = FFmpeg & " -hide_banner -i " & chr(34) & inFile & chr(34) & " -map 0" & _
		chr(32) & "-c copy" & chr(32) & VidCodec & chr(32) & "-max_muxing_queue_size 9999" & _
		chr(32) & chr(34) & outFile & chr(34)
		
	scmd3 = mkvpropedit & chr(32) & chr(34) & outFile & chr(34) & chr(32) & "--tags all:" & Comment _
		& chr(32) & "--attachment-name cover.jpg" & chr(32) & "--add-attachment" & chr(32) & chr(34) _
		& Poster & chr(34)
		
		
	'scmd3 = mkvpropedit & chr(32) & chr(34) & outFile & chr(34) & chr(32) & "--tags all:" & chr(32) _
	'	& "--tags global:" & Comment & chr(32) & "--edit info --set" _
	'	& chr(32) & chr(34) & "title=" & renbase & chr(34) & chr(32) & "--attachment-name cover.jpg" _
	'	& chr(32) & "--add-attachment" & chr(32) & chr(34) & Poster & chr(34)
		
	'scmd2 = mp4box & subtitleAdd & " -itags tool=" & chr(34) & "Brought to you by V1x0r" _
	'	& chr(34) & ":cover=" & chr(34) & Poster & chr(34) & ":name=" & chr(34) & _
	'	renbase & chr(34) & " -v " & chr(34) & outFile & chr(34)


'Info Output - Primary Window		
		WSCRIPT.ECHO "File Name: " & getbase & "." & ext
		WSCRIPT.ECHO "VC: " & VC
		WSCRIPT.ECHO "Video Codec: " & VFSrc
		WSCRIPT.ECHO "ConvertVideo: " & convertVid
		WSCRIPT.ECHO "Video Codec ID: " & VidID
		WSCRIPT.ECHO "Audio Count: " & AudioCnt
		WSCRIPT.ECHO "===== Audio 1 ====="
		WSCRIPT.ECHO "Audio Codec ID: " & AudID1
		WSCRIPT.ECHO "Audio Codec: " & AF1
		WSCRIPT.ECHO "Audio Channels:" & AC1
		WSCRIPT.ECHO "Audio Delay: " & Delay1
		WSCRIPT.ECHO "Audio Language: " & Lang1
		WSCRIPT.ECHO "Convert Audio: " & AF1Convert
			IF AudioCnt <> 1 then
				WSCRIPT.ECHO "===== Audio 2 ====="
				WSCRIPT.ECHO "Audio Codec ID: " & AudID2
				WSCRIPT.ECHO "Audio Codec: " & AF2
				WSCRIPT.ECHO "Audio Channels:" & AC2
				WSCRIPT.ECHO "Audio Delay: " & Delay2
				WSCRIPT.ECHO "Audio Language: " & Lang2
				WSCRIPT.ECHO "Convert Audio: " & AF2Convert
					IF AudioCnt = 3 then
						WSCRIPT.ECHO "===== Audio 3 ====="
						WSCRIPT.ECHO "Audio Codec ID: " & AudID3
						WSCRIPT.ECHO "Audio Codec: " & AF3
						WSCRIPT.ECHO "Audio Channels:" & AC3
						WSCRIPT.ECHO "Audio Delay: " & Delay3
						WSCRIPT.ECHO "Audio Language: " & Lang3
						WSCRIPT.ECHO "Convert Audio: " & AF3Convert
					End If
			END IF
		wscript.echo "Comment File:" & Comment
		WSCRIPT.ECHO "===== Sub Info ====="
		WSCRIPT.ECHO "Subtitle Codec: " & SubCodec
		WSCRIPT.ECHO "Sutitle Codec: " & SubID
		WSCRIPT.ECHO
		WSCRIPT.ECHO "===== Rebuild ====="
		wscript.echo "=================== scmd1 ==================="
		WSCRIPT.ECHO scmd1
		wscript.echo "=================== scmd2 ==================="
		WSCRIPT.ECHO scmd2
		wscript.echo "=================== scmd3 ==================="
		WSCRIPT.ECHO scmd3
		
		
	 WSHSHELL.RUN sCmd1, 1, TRUE
	 WSHSHELL.RUN sCmd2, 1, TRUE
	 WSHSHELL.RUN sCmd3, 1, TRUE

	WSCRIPT.ECHO "Deleting temp files"
	IF objFSO.FileExists(getbase & " - Log.txt") Then 
		objFSO.DeleteFile(getbase & " - Log.txt"),DeleteReadOnly
	END IF
	IF objFSO.FileExists(H265Out) Then
		objFSO.DeleteFile(H265Out),DeleteReadOnly
	END IF
	IF objFSO.FileExists(AF1Out) Then 
		objFSO.DeleteFile(AF1Out),DeleteReadOnly
	END IF
	IF objFSO.FileExists(AF2Out) Then 
		objFSO.DeleteFile(AF2Out),DeleteReadOnly
	END IF
	IF objFSO.FileExists(getbase & ".txt") Then 
		objFSO.DeleteFile(getbase & ".txt"),DeleteReadOnly
	END IF
	IF objFSO.FileExists(SubOut) Then
		objFSO.DeleteFile(SubOut),DeleteReadOnly
	END IF
	IF objFSO.FileExists(newXML) Then
		objFSO.DeleteFile(newXML),DeleteReadOnly
	End If
End Sub