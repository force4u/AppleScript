#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
(*
ICONセットのサイズ
https://developer.apple.com/design/human-interface-guidelines/app-icons
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

############################
### Retinaチェック
set ocidScreenArray to refMe's NSScreen's screens()
set appMainScreen to refMe's NSScreen's mainScreen()
set ocidDescription to appMainScreen's deviceDescription()
set recordDeviceResolution to refMe's NSSizeFromCGSize(ocidDescription's valueForKey:(refMe's NSDeviceResolution))
set intDeviceResolution to width of recordDeviceResolution as integer
if intDeviceResolution ≥ 144 then
	set boolRetina to true as boolean
	log "Retinaディスプレイです"
else
	set boolRetina to false as boolean
end if
log "解像度：" & intDeviceResolution

###デフォルトロケーション
set ocidUserDocumentPathArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopPathURL to ocidUserDocumentPathArray's firstObject()
set aliasDefaultLocation to (ocidDesktopPathURL's absoluteURL()) as alias
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

####ダイアログを出す
set strMes to "フォルダを選んでください" as text
set strPrompt to "フォルダを選択してください" as text
set aliasDirPath to (choose folder strMes with prompt strPrompt default location aliasDefaultLocation without multiple selections allowed, invisibles and showing package contents) as alias
###パス関連
set strDirPath to (POSIX path of aliasDirPath) as text
set ocidDirPathStr to refMe's NSString's stringWithString:(strDirPath)
set ocidDIrPath to ocidDirPathStr's stringByStandardizingPath()
set ocidDirName to ocidDIrPath's lastPathComponent()
set ocidContainerDirPath to ocidDIrPath's stringByDeletingLastPathComponent()
###ファイル名-拡張子ベースファイル名
set ocidBaseFileName to ocidDirName's stringByDeletingPathExtension()
set ocidFileName to ocidBaseFileName's stringByAppendingPathExtension:("icns")
###保存ICNSファイルパス関連
set ocidSaveFilePath to ocidContainerDirPath's stringByAppendingPathComponent:(ocidFileName)
set ocidSaveFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidSaveFilePath) isDirectory:true)
set sttSaveFilePath to ocidSaveFilePathURL's |path|() as text
###コマンド整形→実行
set strCommandText to ("/usr/bin/iconutil --convert icns -o \"" & sttSaveFilePath & "\"  \"" & strDirPath & "\" ") as text
do shell script strCommandText

##保存先を選択状態で開く
set ocidSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
ocidSharedWorkspace's selectFile:(ocidSaveFilePathURL's |path|()) inFileViewerRootedAtPath:"/"

###Finderを前面に
set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppArray to (ocidRunningApplication's runningApplicationsWithBundleIdentifier:("com.apple.finder"))
set ocidApp to ocidAppArray's firstObject()
ocidApp's activateWithOptions:(refMe's NSApplicationActivateAllWindows)
