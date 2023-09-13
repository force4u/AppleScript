#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.6"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
###初期化
set appFileManager to refMe's NSFileManager's defaultManager()
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()

##############################
#####入力ファイル　ダイアログ
##############################
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###デスクトップ
set ocidDesktopPathArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopPathURL to ocidDesktopPathArray's firstObject()
set alisDesktopPath to (ocidDesktopPathURL's absoluteURL()) as alias
###ダイアログ
set listUTI to {"public.item"}
set strMes to ("ファイルを選んでください") as text
set strPrompt to ("ファイルを選んでください") as text
try
	###　ファイル選択時
	set aliasFilePath to (choose file strMes with prompt strPrompt default location (alisDesktopPath) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
on error
	log "エラーしました"
	return
end try
##########
set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)

##############################
#####アイコンファイル　ダイアログ
##############################
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###デスクトップ
set ocidAppDirPathArray to (appFileManager's URLsForDirectory:(refMe's NSAllApplicationsDirectory) inDomains:(refMe's NSLocalDomainMask))
set ocidAppDirPathURL to ocidAppDirPathArray's firstObject()
set aliasAppDirPath to (ocidAppDirPathURL's absoluteURL()) as alias
###ダイアログ
set listUTI to {"com.apple.icns"}
set strMes to ("アイコンファイルを選んでください") as text
set strPrompt to ("アイコンファイルを選んでください") as text
try
	###　ファイル選択時
	set aliasIconFilePath to (choose file strMes with prompt strPrompt default location (aliasAppDirPath) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
on error
	log "エラーしました"
	return
end try
##########
set strIconFilePath to (POSIX path of aliasIconFilePath) as text
set ocidIconFilePathStr to refMe's NSString's stringWithString:(strIconFilePath)
set ocidIconFilePath to ocidIconFilePathStr's stringByStandardizingPath()
set ocidIconFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidIconFilePath) isDirectory:false)
##アイコン用のイメージデータ取得
set ocidImageData to (refMe's NSImage's alloc()'s initWithContentsOfURL:(ocidIconFilePathURL))

###アイコン付与
set boolAddIcon to (appSharedWorkspace's setIcon:(ocidImageData) forFile:(ocidFilePath) options:(refMe's NSExclude10_4ElementsIconCreationOption))

