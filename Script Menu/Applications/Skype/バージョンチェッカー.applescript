#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

###アプリケーションのバンドルID
set strBundleID to "com.skype.skype"

###URL
set strURL to "https://get.skype.com/go/getskype-skypeformac" as text
###コマンド実行してサーバーレスポンスからファイル名を取得する
try
	set strCommandText to ("/usr/bin/curl -s -L -I -o /dev/null -w '%{url_effective}' " & strURL & "") as text
	set strLocation to (do shell script strCommandText) as text
on error strErrorMes number errorNumber
	return "ファイル名の取得に失敗しまし"
end try

################################################
###### インストール済みのパージョン
################################################
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
##バンドルからアプリケーションのURLを取得
set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(strBundleID))
if ocidAppBundle ≠ (missing value) then
	set ocidAppPathURL to ocidAppBundle's bundleURL()
else if ocidAppBundle = (missing value) then
	set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID))
end if
##予備（アプリケーションのURL）
if ocidAppPathURL = (missing value) then
	tell application "Finder"
		try
			set aliasAppApth to (application file id strBundleID) as alias
			set strAppPath to POSIX path of aliasAppApth as text
			set strAppPathStr to refMe's NSString's stringWithString:(strAppPath)
			set strAppPath to strAppPathStr's stringByStandardizingPath()
			set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(strAppPath) isDirectory:true
		on error
			return "アプリケーションが見つかりませんでした"
		end try
	end tell
end if
set ocidFilePathURL to ocidAppPathURL's URLByAppendingPathComponent:("Contents/Info.plist")
#####PLISTの内容を読み込んで
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set listReadPlistData to refMe's NSMutableDictionary's dictionaryWithContentsOfURL:ocidFilePathURL |error|:(reference)
set ocidPlistDict to item 1 of listReadPlistData
set ocidCfbundleversionPlist to ocidPlistDict's valueForKey:"CFBundleVersion"
log "PLIST:" & ocidCfbundleversionPlist as text
################################################
###### チェック
################################################
set strCfbundleversionPlist to ocidCfbundleversionPlist as text
log strCfbundleversionPlist

if strLocation contains strCfbundleversionPlist then
	return "最新版を利用中です:" & (strCfbundleversionPlist as text) & "\r" & strLocation & "\r"
else
	return "アップデートがありますインストールが必要です:\r" & strLocation & "\r"
end if

################################################
###### 置換
################################################
to doReplace(argOrignalText, argSearchText, argReplaceText)
	set strDelim to AppleScript's text item delimiters
	set AppleScript's text item delimiters to argSearchText
	set listDelim to every text item of argOrignalText
	set AppleScript's text item delimiters to argReplaceText
	set strReturn to listDelim as text
	set AppleScript's text item delimiters to strDelim
	return strReturn
end doReplace
