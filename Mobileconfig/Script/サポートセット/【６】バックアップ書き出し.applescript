#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

#####################################
###	デフォルトロケーション　パス
#####################################
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDocumentDirPathURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidDocumentDirPathURL's URLByAppendingPathComponent:("Mobileconfig/Bakup")
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
set aliasDefaultLocation to (ocidSaveDirPathURL's absoluteURL()) as alias

#############################
###ダイアログ
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
############UTIリスト
set listUTI to {"com.apple.property-list"}
set strMes to ("ファイルを選んでください") as text
set strPrompt to ("ファイルを選んでください") as text
try
	###　ファイル選択時
	set aliasFilePath to (choose file strMes with prompt strPrompt default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
on error
	log "エラーしました"
	return "エラーしました"
end try

set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
###書き出し先
set ocidSaveFileDirPathURL to ocidFilePathURL's URLByDeletingPathExtension()
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveFileDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)

#####################################
###	plist読み込み
#####################################
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set listResults to refMe's NSMutableDictionary's dictionaryWithContentsOfURL:(ocidFilePathURL) |error|:(reference)
set ocidPlistDict to item 1 of listResults
#####################################
### PLISTのROOT項目＝ユーザー名を取得
#####################################
set ocidUserName to refMe's NSUserName()
set arrayPlistRoot to ocidPlistDict's objectForKey:(ocidUserName)
##
repeat with itemPlistRoot in arrayPlistRoot
	set ocidDisplayName to (itemPlistRoot's valueForKey:("ProfileDisplayName"))
	set ocidBaseFilePathURL to (ocidSaveFileDirPathURL's URLByAppendingPathComponent:(ocidDisplayName))
	set ocidSaveFilePathURL to (ocidBaseFilePathURL's URLByAppendingPathExtension:("mobileconfig"))
	
	set listDone to (itemPlistRoot's writeToURL:(ocidSaveFilePathURL) atomically:true)
end repeat




return
