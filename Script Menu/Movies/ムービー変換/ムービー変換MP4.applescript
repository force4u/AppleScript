#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "AVFoundation"
use framework "CoreMedia"
use scripting additions

property refMe : a reference to current application
property refZero : a reference to refMe's kCMTimeZero
set appFileManager to refMe's NSFileManager's defaultManager()

#############################
###入力ファイル
#############################
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
############ デフォルトロケーション
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias
####UTIリスト
set listUTI to {"public.movie"}
####ダイアログを出す
set aliasFilePath to (choose file with prompt "ムービーファイルを選んでください" default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
###入力ファイル
set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
##
set ocidFileName to ocidFilePath's lastPathComponent()
set ocidBaseFileName to ocidFileName's stringByDeletingPathExtension()
#############################
###テンポラリーパス
#############################
set ocidTempDirURL to appFileManager's temporaryDirectory()
##
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidTemporaryDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:(true)
##フォルダを作っておく
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidTemporaryDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
#############################
###保存先
#############################
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSMoviesDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidMoviesDirPathURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidMoviesDirPathURL's URLByAppendingPathComponent:("AVAssetExport")
##フォルダを作っておく
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###上書きチェック
set numCnt to 0 as number
set strSaveFileName to ocidBaseFileName's stringByAppendingPathExtension:("mp4")
repeat 100 times
	###保存先URL
	set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strSaveFileName)
	set ocidSaveFilePath to ocidSaveFilePathURL's |path|()
	set boolExist to appFileManager's fileExistsAtPath:(ocidSaveFilePath) isDirectory:(false)
	##
	if boolExist is true then
		set numCnt to numCnt + 1 as number
		set strZeroSup to "000" as text
		set strZeroSup to (strZeroSup & (numCnt as text)) as text
		set strZeroSup to (text -3 through -1 of strZeroSup) as text
		set strZeroSupFileName to ocidBaseFileName's stringByAppendingPathExtension:(strZeroSup)
		set strSaveFileName to strZeroSupFileName's stringByAppendingPathExtension:("mp4")
	else
		log "保存先パス: " & ocidSaveFilePath as text
		exit repeat
	end if
end repeat
#############################
###　ムービー読み込み
#############################
set ocidReadAsset to refMe's AVAsset's assetWithURL:(ocidFilePathURL)
set ocidReadAssetTrackArray to ocidReadAsset's tracks()
#set ocidReadAssetTrackArray to ocidReadAsset's tracksWithMediaType:(refMe's AVMediaTypeVideo)
set ocidVideoTrack to ocidReadAssetTrackArray's firstObject()
#
set ocidAssetTrackTimeRange to ocidVideoTrack's timeRange()
#############################
### 書き出し
#############################

set ocidExportSession to refMe's AVAssetExportSession's alloc()'s initWithAsset:(ocidReadAsset) presetName:("AVAssetExportPresetHighestQuality")
ocidExportSession's setOutputURL:(ocidSaveFilePathURL)
ocidExportSession's setOutputFileType:(refMe's AVFileTypeMPEG4)

ocidExportSession's setTimeRange:(ocidAssetTrackTimeRange)
ocidExportSession's setShouldOptimizeForNetworkUse:false
ocidExportSession's setCanPerformMultiplePassesOverSourceMediaData:true
ocidExportSession's setDirectoryForTemporaryFiles:(ocidTemporaryDirPathURL)
ocidExportSession's exportAsynchronouslyWithCompletionHandler:(missing value)


log "########################################"
set numStatusNo to ocidExportSession's status()
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
	set numProgress to ocidExportSession's progress()
	set numProgressPer to numProgress * 100 as integer
	set progress additional description to "状況:" & numProgressPer & "%"
	set progress completed steps to numProgress
	set numStatusNo to ocidExportSession's status()
	if numStatusNo > 2 then
		exit repeat
	end if
	delay 1
end repeat
log "status:\t" & numStatusNo

set ocidReadAsset to ""
set ocidExportSession to ""

## Finder で開く
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
appSharedWorkspace's activateFileViewerSelectingURLs:({ocidSaveDirPathURL})



return
