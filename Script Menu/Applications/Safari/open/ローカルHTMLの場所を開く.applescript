#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#  開いているURLが　file://と　ローカルファイルの場合の
#保存先を開く
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

set strBundleID to "com.apple.Safari" as text

###全面のタブのURLを取得して
tell application "Safari"
	set numCntWindow to (count of every document) as integer
	if numCntWindow = 0 then
		return "ウィンドウがありません"
	end if
end tell
tell application "Safari"
	set numID to id of front window
	set objTab to current tab of window id numID
	
	tell window id numID
		tell objTab
			set strURL to URL
		end tell
	end tell
end tell
##############
set strFileURL to strURL as text
###保存先ファイル
set ocidURLString to refMe's NSString's stringWithString:(strFileURL)
set ocidURL to refMe's NSURL's URLWithString:(ocidURLString)
set aliasFilePath to (ocidURL's absoluteURL()) as alias
###保存先ディレクトリ
set ocidContainerDirURL to ocidURL's URLByDeletingLastPathComponent()
set aliasDirPath to (ocidContainerDirURL's absoluteURL()) as alias

tell application "Finder"
	set refNewWindow to make new Finder window
	tell refNewWindow
		set position to {10, 30}
		set bounds to {10, 30, 720, 480}
	end tell
	set target of refNewWindow to aliasDirPath
	set selection to aliasFilePath
end tell
