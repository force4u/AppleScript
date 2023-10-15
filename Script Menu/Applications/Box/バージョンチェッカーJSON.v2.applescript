#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
com.cocolog-nifty.quicktimer.icefloe
*)
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

###アプリケーションのバンドルID
set strBundleID to "com.box.desktop"

set strURL to "https://cdn07.boxcdn.net/Autoupdate4.json" as text

set coidURLStr to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's URLWithString:(coidURLStr)

################################################
###### URLRequest部分
################################################
set ocidURLRequest to refMe's NSMutableURLRequest's alloc()'s init()
ocidURLRequest's setHTTPMethod:"GET"
ocidURLRequest's setURL:(ocidURL)
ocidURLRequest's addValue:"application/json" forHTTPHeaderField:"Content-Type"
###ポストするデータは空
ocidURLRequest's setHTTPBody:(missing value)

################################################
###### データ取得
################################################
set ocidServerResponse to refMe's NSURLConnection's sendSynchronousRequest:(ocidURLRequest) returningResponse:(missing value) |error|:(reference)
###取得
set coidReadData to (item 1 of ocidServerResponse)
##NSJSONSerialization's
set listJSONSerialization to (refMe's NSJSONSerialization's JSONObjectWithData:(coidReadData) options:(refMe's NSJSONReadingMutableContainers) |error|:(reference))
set ocidJsonData to item 1 of listJSONSerialization
##NSDictionary's
set ocidJsonDict to refMe's NSDictionary's alloc()'s initWithDictionary:(ocidJsonData)
################################################
###### データ精査
################################################
set ocidMacMinDict to (ocidJsonDict's objectForKey:("mac_min"))
##
set ocidMacMinVer to (ocidMacMinDict's valueForKey:("version"))
set ocidMacMinURL to (ocidMacMinDict's valueForKey:("download-url"))
##
set ocidMacDict to (ocidJsonDict's objectForKey:("mac"))
set ocidEapDict to ocidMacDict's objectForKey:("eap")
set ocidEapVer to (ocidEapDict's valueForKey:("version"))
set ocidEapURL to (ocidEapDict's valueForKey:("download-url"))



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


################################################
###### チェック
################################################
set strCfbundleversionJson to ocidMacMinVer as text
set strCfbundleversionPlist to ocidCfbundleversionPlist as text
log strCfbundleversionJson
log strCfbundleversionPlist

if strCfbundleversionJson is strCfbundleversionPlist then
	set strTitle to ("最新版を利用中です") as text
	set strCom to ("最新版を利用中です\r" & strCfbundleversionJson & "\rEAPは早期リリースです") as text
	set strMes to (strTitle & "\rMIN:" & strCfbundleversionJson & "\rEAP:" & (ocidEapVer as text) & "\rPLIST:" & strCfbundleversionPlist & "\rLink:" & (ocidMacMinURL as text) & "\rEAP:" & (ocidEapURL as text)) as text
else
	set strTitle to ("アップデートがあります：" & strCfbundleversionJson) as text
	set strCom to ("アップデートがあります\r最新：" & strCfbundleversionJson & "\r使用中：" & strCfbundleversionPlist) as text
	set strMes to ("最新版ダウンロード:" & (ocidMacMinURL as text) & "\rEAP:" & (ocidEapURL as text)) as text
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

set recordResult to (display dialog strCom with title strTitle default answer strMes buttons {"クリップボードにコピー", "終了", "ダウンロード"} default button "ダウンロード" cancel button "終了" giving up after 20 with icon aliasIconPath without hidden answer)

if button returned of recordResult is "ダウンロード" then
	tell application "Finder"
		open location (ocidMacMinURL as text)
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
