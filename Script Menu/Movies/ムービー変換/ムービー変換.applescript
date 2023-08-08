#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AVFoundation"
use scripting additions

property refMe : a reference to current application
property refNSString : a reference to refMe's NSString
property refNSURL : a reference to refMe's NSURL
property refNSArray : a reference to refMe's NSArray
property refNSDate : a reference to refMe's NSDate
property refNSCalendar : a reference to refMe's NSCalendar
property refNSTimeZone : a reference to refMe's NSTimeZone
property refNSDateFormatter : a reference to NSDateFormatter
property refNSMutableDictionary : a reference to refMe's NSMutableDictionary
-->(*__NSCFConstantString*)

property refAVAsset : a reference to refMe's AVAsset
property refAVAssetExportSession : a reference to refMe's AVAssetExportSession
set objFileManager to refMe's NSFileManager's defaultManager()

###入力
tell application "Finder"
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
end tell
####UTIリスト PDFのみ
set listUTI to {"public.movie"}

####ダイアログを出す
set aliasFilePath to (choose file with prompt "ムービーファイルを選んでください" default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias

set strFilePath to POSIX path of aliasFilePath
set ocidFilePath to refNSString's stringWithString:strFilePath
set ocidContainerPath to ocidFilePath's stringByDeletingLastPathComponent()
set ocidFileName to ocidFilePath's lastPathComponent()
set ocidBaseFileName to ocidFileName's stringByDeletingPathExtension()
set ocidFileExetension to ocidFileName's pathExtension()
####ドキュメントのパスをNSURLに
set ocidFullPathURL to a reference to (refNSURL's fileURLWithPath:ocidFilePath)

####保存先をこのロケーションで
set ocidContainerDirPathURL to ocidFullPathURL's URLByDeletingLastPathComponent()
set aliasContainerDirPath to ocidContainerDirPathURL as alias
####入力ファイル関連
################################################
####出力メディアフォーマット関連

set listChooseType to {"LowQuality", "MediumQuality", "HighestQuality", "HEVCHighestQuality", "HEVCHighestQualityWithAlpha", "640x480", "960x540", "1280x720", "1920x1080", "3840x2160", "HEVC1920x1080", "HEVC3840x2160", "HEVC1920x1080WithAlpha", "HEVC3840x2160WithAlpha", "HEVC7680x4320", "AppleM4V480pSD", "AppleM4V720pHD", "AppleM4V1080pHD", "AppleM4ViPod", "AppleM4VAppleTV", "AppleM4VCellular", "AppleM4VWiFi", "AppleProRes422LPCM", "AppleProRes4444LPCM", "Passthrough", "AppleM4A"} as list
try
	set objResponse to (choose from list listChooseType with title "出力形式" with prompt "フォーマットを選んでください" default items (item 3 of listChooseType) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed without empty selection allowed)
on error
	log "エラーしました"
	return
end try
if objResponse is false then
	log "キャンセルしました"
	return
end if
set strPresetName to ("AVAssetExportPreset" & objResponse) as text

####################################################
set ocidPresetArray to refNSArray's arrayWithArray:listChooseType
set numChooseListNo to (ocidPresetArray's indexOfObject:(objResponse as text)) as integer
set numChooseListNo to numChooseListNo + 1 as integer
log numChooseListNo
####################################################
###出力
set strDateNO to doGetDateNo("yyyyMMdd_hhmmss") as text
###ファイル名＋拡張子
if (objResponse as text) is "AppleM4A" then
	set strExportFileName to ("" & ocidBaseFileName & "_" & strDateNO & ".m4a") as text
else
	set strExportFileName to ("" & ocidBaseFileName & "_" & strDateNO & ".mov") as text
end if
####

set strDefaultName to strExportFileName as text
set strPromptText to "名前を決めてください"

set aliasDistFilePath to (choose file name default location aliasContainerDirPath default name strDefaultName with prompt strPromptText) as «class furl»
set strDistFilePath to POSIX path of aliasDistFilePath as text
set ocidDistFilePath to refNSString's stringWithString:strDistFilePath
set ocidFullDistPathURL to refNSURL's fileURLWithPath:ocidDistFilePath


###書き出し途中の添付ファイルの書き出し先
set strTmpPath to ("/private/tmp/AVAssetExportSession") as text
set ocidTmpPath to refNSString's stringWithString:strTmpPath
set ocidFullTmpPath to ocidTmpPath's stringByStandardizingPath()
set ocidFullTmpPathURL to refMe's NSURL's fileURLWithPath:ocidFullTmpPath
####TMPフォルダを作成
objFileManager's createDirectoryAtURL:ocidFullTmpPathURL withIntermediateDirectories:true attributes:(missing value) |error|:(missing value)


log "######AVAsset"
set ocidReadAsset to refAVAsset's assetWithURL:ocidFullPathURL
log className() of ocidReadAsset as text

set ocidReadAssetDuration to ocidReadAsset's duration()
log ocidReadAssetDuration
log "######AVAssetTrack"
set ocidReadAssetTrackArray to ocidReadAsset's tracks()
set numCntTrackNo to (count of ocidReadAssetTrackArray) as integer
log "トラック数は: " & numCntTrackNo
set numCntTrak to numCntTrackNo - 1
repeat numCntTrackNo times
	log "--------"
	set ocidTrack to (ocidReadAssetTrackArray's objectAtIndex:numCntTrak)
	log className() of ocidTrack as text
	set strTrackID to ocidTrack's trackID() as text
	set strMediaType to ocidTrack's mediaType() as text
	if strMediaType is "vide" then
		log "MediaType: vide ビデオトラック:トラックIDは" & strTrackID
	else if strMediaType is "soun" then
		log "MediaType: soun サウンドトラック:トラックIDは" & strTrackID
	else
		log "MediaType: " & strMediaType
		log "TrackID: " & strTrackID
	end if
	log (ocidTrack's formatDescriptions()'s objectAtIndex:0)
	-->NSCFType
	log ocidTrack's isPlayable()
	log ocidTrack's isDecodable()
	log ocidTrack's isEnabled()
	log ocidTrack's isSelfContained()
	log ocidTrack's totalSampleDataLength()
	##log ocidTrack's hasMediaCharacteristic()
	log "->"
	set ocidAssetTrackTimeRange to ocidTrack's timeRange()
	log ocidAssetTrackTimeRange
	set ocidAssetTrackTimeScale to ocidTrack's naturalTimeScale()
	log ocidAssetTrackTimeScale
	set ocidAssetTrackNaturalSize to ocidTrack's naturalSize()
	log ocidAssetTrackNaturalSize
	set ocidCMTimeFrameDura to ocidTrack's minFrameDuration()
	log ocidCMTimeFrameDura as record
	log "-->"
	log ocidTrack's nominalFrameRate() as number
	
	log ocidTrack's requiresFrameReordering() as boolean
	log ocidTrack's metadata() as list
	log ocidTrack's commonMetadata() as list
	log ocidTrack's availableMetadataFormats() as list
	log ocidTrack's segments() as list
	log ocidTrack's availableTrackAssociationTypes() as list
	log "--->"
	log ocidTrack's preferredTransform()
	log ocidTrack's preferredVolume()
	log ocidTrack's estimatedDataRate()
	log ocidTrack's languageCode() as text
	log ocidTrack's extendedLanguageTag()
	log ocidTrack's hasAudioSampleDependencies()
	set numCntTrak to numCntTrak - 1
	
end repeat

log strPresetName as text

(*
AVAssetExportPresetLowQuality
AVAssetExportPresetMediumQuality
AVAssetExportPresetHighestQuality
AVAssetExportPresetHEVCHighestQuality
AVAssetExportPresetHEVCHighestQualityWithAlpha

AVAssetExportPreset640x480
AVAssetExportPreset960x540
AVAssetExportPreset1280x720
AVAssetExportPreset1920x1080
AVAssetExportPreset3840x2160

AVAssetExportPresetHEVC1920x1080
AVAssetExportPresetHEVC3840x2160
AVAssetExportPresetHEVC1920x1080WithAlpha
AVAssetExportPresetHEVC3840x2160WithAlpha
AVAssetExportPresetHEVC7680x4320

AVAssetExportPresetAppleM4V480pSD
AVAssetExportPresetAppleM4V720pHD
AVAssetExportPresetAppleM4V1080pHD
AVAssetExportPresetAppleM4ViPod
AVAssetExportPresetAppleM4VAppleTV
AVAssetExportPresetAppleM4VCellular
AVAssetExportPresetAppleM4VWiFi

AVAssetExportPresetAppleProRes422LPCM
AVAssetExportPresetAppleProRes4444LPCM

AVAssetExportPresetPassthrough
AVAssetExportPresetAppleM4A
*)

set ocidExSession to refAVAssetExportSession's alloc()'s initWithAsset:ocidReadAsset presetName:strPresetName

ocidExSession's setOutputURL:ocidFullDistPathURL

if (objResponse as text) is "AppleM4A" then
	ocidExSession's setOutputFileType:(refMe's AVFileTypeAppleM4A)
else
	ocidExSession's setOutputFileType:(refMe's AVFileTypeQuickTimeMovie)
end if


(*
AVFileTypeAC3
AVFileTypeAIFC
AVFileTypeAIFF
AVFileTypeAMR
AVFileTypeEnhancedAC3
AVFileTypeSunAU
AVFileTypeMPEGLayer3
AVFileTypeCoreAudioFormat
AVFileTypeAppleM4A
AVFileTypeWAVE

AVFileTypeDNG
AVFileTypeHEIC
AVFileTypeHEIF
AVFileTypeJPEG
AVFileTypeAVCI
AVFileTypeTIFF


AVFileTypeAppleM4V
AVFileType3GPP
AVFileType3GPP2
AVFileTypeQuickTimeMovie
AVFileTypeMPEG4

AVFileTypeSCC
AVFileTypeAppleiTT
*)

ocidExSession's setTimeRange:ocidAssetTrackTimeRange
#ocidExSession's setFileLengthLimit:(missing value)
ocidExSession's setShouldOptimizeForNetworkUse:false
ocidExSession's setCanPerformMultiplePassesOverSourceMediaData:true
ocidExSession's setDirectoryForTemporaryFiles:ocidFullTmpPathURL
ocidExSession's exportAsynchronouslyWithCompletionHandler:(missing value)

log "########################################"
set numStatusNo to ocidExSession's status()
log "status:\t" & numStatusNo
(*
AVAssetExportSessionStatusUnknown:0
AVAssetExportSessionStatusWaiting:1
AVAssetExportSessionStatusExporting:2
AVAssetExportSessionStatusCompleted:3
AVAssetExportSessionStatusFailed:4
AVAssetExportSessionStatusCancelled:5
*)
set progress total steps to 1
set progress completed steps to 0
set progress description to "書出"

repeat
	set numProgress to ocidExSession's progress()
	set numProgressPer to numProgress * 100 as integer
	set progress additional description to "状況:" & numProgressPer & "%"
	set progress completed steps to numProgress
	set numStatusNo to ocidExSession's status()
	if numStatusNo > 2 then
		exit repeat
	end if
	delay 1
end repeat
log "status:\t" & numStatusNo

set ocidReadAsset to ""
set objFileManager to ""
set ocidExSession to ""

#ocidReadAsset's release()
#objFileManager's release()
#ocidExSession's release()



to doGetDateNo(strDateFormat)
	####日付情報の取得
	set ocidDate to refNSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to refNSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(refMe's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	ocidNSDateFormatter's setDateFormat:strDateFormat
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo
