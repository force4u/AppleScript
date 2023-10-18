#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#	終わるまで３分程度かかります
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKIt"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

set strBundleID to ("com.apple.SystemProfiler") as text

###終了させてから
tell application id strBundleID to quit
####半ゾンビ化対策	
set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
repeat with itemAppArray in ocidAppArray
	itemAppArray's terminate
end repeat

###起動
tell application id strBundleID to activate
repeat 10 times
	try
		tell application id strBundleID to activate
	end try
	tell application id strBundleID
		set boolFontmost to its frontmost as boolean
	end tell
	log boolFontmost
	if boolFontmost is false then
		delay 0.5
		tell application id strBundleID to activate
	else
		tell application id strBundleID to activate
		exit repeat
	end if
end repeat

tell application "System Information"
	tell front document
		###ドキュメント名を取得
		set strName to its name as text
	end tell
end tell
##コンピューター名
set objSysInfo to system info
set strComputerName to (computer name of objSysInfo) as text
###ファイル名にして
set strFileName to (strComputerName & "." & strName & ".spx") as text
set strPlistFileName to (strComputerName & "." & strName & ".plist") as text
tell application "Finder"
	###書類フォルダ
	set aliasDocumentsPath to (path to documents folder from user domain) as alias
end tell
set strDocumentsPath to (POSIX path of aliasDocumentsPath) as text
set strSaveDirPath to (strDocumentsPath & "Apple/system_profiler/") as text
###ファイル名繋げてパスにしておく
set strSaveFilePath to (strSaveDirPath & strFileName) as text
set strPlistFilePath to (strSaveDirPath & strPlistFileName) as text
###保存
tell application "System Information"
	tell front document
		save in (POSIX file strSaveFilePath)
	end tell
end tell
set aliasOpenDirPath to (POSIX file strSaveDirPath) as alias


####場所を表示
tell application "Finder"
	open folder aliasOpenDirPath
	tell front window
		select (POSIX file strSaveFilePath) as alias
	end tell
end tell



