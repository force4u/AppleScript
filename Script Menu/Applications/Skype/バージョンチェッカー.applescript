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
	set strTitle to "最新版を利用中です" as text
	set strMes to "最新版を利用中です:" & (strCfbundleversionPlist as text) & "\r" & strLocation & "\r"
else
	set strTitle to "アップデートがあります" as text
	set strMes to "アップデートがありますインストールが必要です:\r" & strLocation & "\r"
end if

################################################
###### ダイアログ
################################################
set appFileManager to refMe's NSFileManager's defaultManager()

####ダイアログに指定アプリのアイコンを表示する
###アイコン名をPLISTから取得
set strIconFileName to (ocidPlistDict's valueForKey:("CFBundleIconFile")) as text

###ICONのURLにして
set strPath to ("Contents/Resources/" & strIconFileName) as text
set ocidIconFilePathURL to ocidAppPathURL's URLByAppendingPathComponent:(strPath) isDirectory:false
###拡張子の有無チェック
set strExtensionName to (ocidIconFilePathURL's pathExtension()) as text
if strExtensionName is "" then
	set ocidIconFilePathURL to ocidIconFilePathURL's URLByAppendingPathExtension:"icns"
end if
##-->これがアイコンパス
log ocidIconFilePathURL's absoluteString() as text
###ICONファイルが実際にあるか？チェック
set boolExists to appFileManager's fileExistsAtPath:(ocidIconFilePathURL's |path|)
###ICONがみつかない時用にデフォルトを用意する
if boolExists is false then
	set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
else
	set aliasIconPath to ocidIconFilePathURL's absoluteURL() as alias
	set strIconPath to ocidIconFilePathURL's |path|() as text
end if


set recordResult to (display dialog strTitle with title strTitle default answer strMes buttons {"クリップボードにコピー", "終了", "ダウンロード"} default button "ダウンロード" cancel button "終了" giving up after 20 with icon aliasIconPath without hidden answer)

if button returned of recordResult is "ダウンロード" then
	tell application "Finder"
		open location strLocation
	end tell
end if
if button returned of recordResult is "クリップボードにコピー" then
	try
		set strText to text returned of recordResult as text
		####ペーストボード宣言
		set appPasteboard to refMe's NSPasteboard's generalPasteboard()
		set ocidText to (refMe's NSString's stringWithString:(strText))
		appPasteboard's clearContents()
		appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
	on error
		tell application "Finder"
			set the clipboard to strTitle as text
		end tell
	end try
end if
