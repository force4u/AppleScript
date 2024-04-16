#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
デスクトップ上にあるファイルやフォルダの
アイコンを表示するか？切り替えます
*)
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions



##############################################
## ファイルパス関連
##############################################
####preferences folderまでのパス
set strPlistFileName to "com.apple.finder.plist" as text
tell application "Finder"
	set aliasPreferencesDir to (path to preferences folder from user domain) as alias
	set alisPrefFilePath to (file strPlistFileName of folder aliasPreferencesDir) as alias
end tell
####ファイル名と繋げてUNIXパスにする
set strPlistPath to (POSIX path of alisPrefFilePath) as text

##############################################
## まずは今の設定を読み込む
##############################################
tell application "System Events"
	#設定ファイルを呼び出し
	tell property list file strPlistPath
		try
			set boolCreateDesktop to value of (property list item "CreateDesktop")
			log "値が取れました"
		on error
			log "値が取れませんでした"
			#値が無い場合はTRUE＝デスクトップ表示中
			set boolCreateDesktop to false as boolean
		end try
	end tell
end tell
##############################################
## 今の設定内容と逆のことを実行する
##############################################
###ダイアログを前面に出す
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FinderIcon.icns" as alias

if boolCreateDesktop is true then
	display dialog "デスクトップのアイコンを隠します" with icon aliasIconPath
	tell application "System Events"
		tell property list file strPlistPath
			set value of property list item "CreateDesktop" to false
		end tell
	end tell
	
else
	display dialog "デスクトップのアイコンを表示します" with icon aliasIconPath
	tell application "System Events"
		tell property list file strPlistPath
			set value of property list item "CreateDesktop" to true
		end tell
	end tell
end if
##############################################
## 結果確認
##############################################
tell application "System Events"
	tell property list file strPlistPath
		log value of (property list item "CreateDesktop") as boolean
	end tell
end tell

##############################################
## Finder 再起動
##############################################
try
	tell application "Finder" to quit
on error
	delay 1
	tell application "Finder" to launch
end try
delay 1
launch application "Finder"
tell application "Finder" to activate

return