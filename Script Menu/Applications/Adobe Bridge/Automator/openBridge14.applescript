#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# Automator ワークフロー用 (クイックアクション)
# ワークフローが受け取るのは『フォルダ』 アプリケーションは『Finder』
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use scripting additions

on run {input}
	set strBundleID to "com.adobe.bridge14" as text
	####フォルダの数だけ繰り返し
	repeat with itemFolderPath in input
		######パス フォルダのエイリアス
		set aliasDirPath to itemFolderPath as alias
		###入力のフォルダのエイリアスをアプリで開く
		tell application id strBundleID to launch
		tell application id strBundleID
			open aliasDirPath
		end tell
	end repeat
end run
