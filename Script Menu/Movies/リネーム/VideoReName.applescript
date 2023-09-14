#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#		元ファイル名　横サイズ　縦サイズ　fpsに変更します
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AVFoundation"
use framework "AppKit"
use framework "CoreMedia"
use scripting additions
property refMe : a reference to current application



####################################
####ダイアログ 入力ビデオ
####################################
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
set listUTI to {"public.movie"}
set strMes to ("ファイルを選んでください") as text
set strPrompt to ("ファイルを選んでください") as text
try
	###　ファイル
	set aliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
on error
	log "エラーしました"
	return "エラーしました"
end try
set strFilePath to POSIX path of aliasFilePath
set ocidFilePath to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePathURL to refMe's NSURL's fileURLWithPath:(ocidFilePath)
set ocidExtensionName to ocidFilePathURL's pathExtension()
set ocidBaseFilePathURL to ocidFilePathURL's URLByDeletingPathExtension()
set ocidBaseFileName to ocidBaseFilePathURL's lastPathComponent()
set ocidContainerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()
##########################################
######AVAsset 基本処理
##########################################
set ocidReadAsset to refMe's AVAsset's assetWithURL:(ocidFilePathURL)
##Duration 
set ocidReadAssetDuration to ocidReadAsset's duration()
log ocidReadAssetDuration as record
###総秒
set cmTime to refMe's CMTimeGetSeconds(ocidReadAssetDuration)
###時間
set numHours to (round of ((cmTime as number) / 3600) rounding down) as integer
###分
set numMinutes to (round of (((cmTime as number) - (numHours * 3600)) / 60) rounding down) as integer
###残り秒
set numSec to cmTime - ((numHours * 3600) + (numMinutes * 60))
log "時間：" & numHours & "時 " & numMinutes & "分　" & numSec & "秒"
######AVAssetTrackGroup
set ocidReadAssetTrackGArray to ocidReadAsset's trackGroups()
set numCntTrackG to (ocidReadAssetTrackGArray count) as integer
log "トラックグループ数: " & numCntTrackG
log ("トラックグループID: " & ((ocidReadAssetTrackGArray's firstObject())'s trackIDs() as integer)) as text

######AVAssetTrack
set ocidReadAssetTrackArray to ocidReadAsset's tracks()
set numCntTrack to (ocidReadAssetTrackArray count) as integer
log "トラック数は: " & numCntTrack
##
repeat with itemIntNo from 0 to (numCntTrack - 1) by 1
	set ocidTrack to (ocidReadAssetTrackArray's objectAtIndex:(itemIntNo))
	log className() of ocidTrack as text
	set strTrackID to ocidTrack's trackID() as text
	log strTrackID
	set strMediaType to ocidTrack's mediaType() as text
	if strMediaType is "vide" then
		########################
		log "MediaType: vide ビデオトラック:トラックIDは" & strTrackID
		## トラックの総時間
		set listAssetTrackTimeRange to ocidTrack's timeRange()
		set listStartTime to (item 1 of listAssetTrackTimeRange)
		set listDurationTime to (item 2 of listAssetTrackTimeRange)
		log listStartTime as list
		log listDurationTime as list
		##タイムスケール
		set numAssetTrackTimeScale to ocidTrack's naturalTimeScale()
		log numAssetTrackTimeScale
		##トラックの画面サイズ
		set recordAssetTrackNaturalSize to ocidTrack's naturalSize()
		log recordAssetTrackNaturalSize
		set numTrackWidth to (width of recordAssetTrackNaturalSize) as integer
		set numTrackHeight to (height of recordAssetTrackNaturalSize) as integer
		##１フレームの長さ
		set recordCMTimeFrameDura to ocidTrack's minFrameDuration()
		set numFlameScale to ((value of recordCMTimeFrameDura) / (timescale of recordCMTimeFrameDura)) as number
		log numFlameScale
		set numFlameRateDura to (1 / numFlameScale)
		log numFlameRateDura
		##フレームレート
		set numFlameRate to ocidTrack's nominalFrameRate() as number
		log numFlameRate
	else if strMediaType is "soun" then
		########################
		log "MediaType: soun サウンドトラック:トラックIDは" & strTrackID
	end if
	
end repeat

##########################################
###### 時間処理
##########################################

###ファイル名用フォーマット
set ocidFileNameFormatter to refMe's NSDateFormatter's alloc()'s init()
ocidFileNameFormatter's setTimeStyle:(refMe's NSDateFormatterNoStyle)
ocidFileNameFormatter's setDateStyle:(refMe's NSDateFormatterNoStyle)
ocidFileNameFormatter's setDateFormat:("HH_mm_ss")
####ビデオの長さ
set ocidCalendar to refMe's NSCalendar's currentCalendar()
set ocidEndTimeComp to refMe's NSDateComponents's alloc()'s init()
ocidEndTimeComp's setHour:(numHours)
ocidEndTimeComp's setMinute:(numMinutes)
ocidEndTimeComp's setSecond:(numSec)
set ocidEndTime to ocidCalendar's dateFromComponents:(ocidEndTimeComp)
set strTimeNO to (ocidFileNameFormatter's stringFromDate:(ocidEndTime)) as text

##########################################
###### リネーム
##########################################

###時間も入れる場合
set strNewFileName to ((ocidBaseFileName as text) & "." & (numTrackWidth as text) & "x" & (numTrackHeight as text) & "." & ((numFlameRate as integer) & "." & strTimeNO & "." & ocidExtensionName)) as text

###通常
set strNewFileName to ((ocidBaseFileName as text) & "." & (numTrackWidth as text) & "x" & (numTrackHeight as text) & "." & ((numFlameRate as integer) & "fps." & ocidExtensionName)) as text

###移動　リネームURL
set ocidNewFilePathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:(strNewFileName)

set listDone to appFileManager's moveItemAtURL:(ocidFilePathURL) toURL:(ocidNewFilePathURL) |error|:(reference)
log (item 1 of listDone) as boolean

return




