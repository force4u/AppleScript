#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

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
############ デフォルトロケーション
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDownloadsDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDownloadsDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDownloadsDirPathURL's absoluteURL()) as alias


set listPIP to {"lxml", "booleanOperations", "defcon", "pens", "fontMath", "unicode", "psautohint", "tqdm", "ufonormalizer", "ufoProcessor", "pyclipper", "fontPens", "unicodedata2", "fs", "zopfli", "brotli", "fontParts", "mutatorMath", "appdirs", "setuptools", "six"} as list

repeat with itemPIP in listPIP
	############コマンド実行
	set strCommandText to ("python3  -m pip install --upgrade --user " & itemPIP & "") as text
	tell application "Terminal"
		launch
		activate
		set objWindowID to (do script "\n\n")
		delay 1
		do script strCommandText in objWindowID
	end tell
	delay 2
end repeat


