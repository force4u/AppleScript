#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application
###初期化
set appFileManager to refMe's NSFileManager's defaultManager()
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
##############################
###デフォルトロケーション
set ocidApplicationDirPathArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidApplicationDirPathURL to ocidApplicationDirPathArray's firstObject()
set aliasDefaultLocation to ocidApplicationDirPathURL's absoluteURL() as alias
##############################
#####ダイアログを前面に
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
##############################
#####ファイルを選択
set listUTI to {"public.item"}
set strPromptText to "アプリケーションを選んで下さい。" as text
set strMesText to "アプリケーションを選んで下さい。" as text
set aliasFilePath to (choose file strMesText default location aliasDefaultLocation with prompt strPromptText of type listUTI with invisibles without multiple selections allowed and showing package contents) as alias
try
	set aliasFilePath to result as alias
on error
	log "エラーしました"
	return "エラーしました"
end try
if aliasFilePath is false then
	return "エラーしました"
end if
##############################
#####アプリケーションのパス
set strFilePath to POSIX path of aliasFilePath as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:true
set ocidPlistPathURL to ocidFilePathURL's URLByAppendingPathComponent:("Contents/Info.plist") isDirectory:false
##############################
#####CFBundleDocumentTypesの取得
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistPathURL)
set ocidDocTypeArray to ocidPlistDict's objectForKey:"CFBundleDocumentTypes"
if ocidDocTypeArray = (missing value) then
	set strOutPutText to "missing value" as text
else
	####リストにする
	set listUTl to {} as list
	repeat with itemDocTypeArray in ocidDocTypeArray
		set listContentTypes to (itemDocTypeArray's objectForKey:"LSItemContentTypes")
		if listContentTypes = (missing value) then
			set ocidExtension to (itemDocTypeArray's objectForKey:"CFBundleTypeExtensions")
			set strClassName to ocidExtension's className() as text
			repeat with itemExtension in ocidExtension
				set strExtension to itemExtension as text
				set ocidContentTypes to (refMe's UTType's typeWithFilenameExtension:strExtension)
				set strContentTypes to ocidContentTypes's identifier() as text
				set strContentTypes to ("" & strContentTypes & "") as text
				set end of listUTl to (strContentTypes)
			end repeat
		else
			repeat with itemContentTypes in listContentTypes
				set strContentTypes to ("" & itemContentTypes & "") as text
				set end of listUTl to (strContentTypes)
			end repeat
		end if
	end repeat
	##############################
	set numCntUTI to (count of listUTl) as integer
	repeat with numCnt from 1 to numCntUTI
		if numCnt = 1 then
			set strOutPutText to ("{\"" & (item numCnt of listUTl as text) & "\",") as text
		else if numCnt = numCntUTI then
			set strOutPutText to strOutPutText & ("\"" & (item numCnt of listUTl as text) & "\"}") as text
		else
			set strOutPutText to strOutPutText & "\"" & (item numCnt of listUTl as text) & "\"," as text
		end if
	end repeat
end if
##set strText to listUTl as text
#####ダイアログに戻す
set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns" as alias
###ダイアログ
set recordResult to (display dialog "type identifier 戻り値です" with title "uniform type identifier" default answer strOutPutText buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" giving up after 20 with icon aliasIconPath without hidden answer)
###クリップボードコピー
if button returned of recordResult is "クリップボードにコピー" then
	set strText to text returned of recordResult as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
end if

