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
set strBundleID to "com.microsoft.onenote.mac"

set strGetBundleID to "com.microsoft.onenote.standalone.365" as text
(* インストールパッケージのバンドルID
	com.microsoft.office.suite.365
	com.microsoft.office.suite.365.businesspro
	com.microsoft.word.standalone.365
	com.microsoft.excel.standalone.365
	com.microsoft.powerpoint.standalone.365
	com.microsoft.outlook.standalone.365
	com.microsoft.outlook.standalone.365.monthly
	com.microsoft.onenote.standalone.365
	com.microsoft.onedrive.standalone
	com.microsoft.skypeforbusiness.standalone
	com.microsoft.teams.standalone
	com.microsoft.intunecompanyportal.standalone
	com.microsoft.edge
	com.microsoft.defender.standalone
	com.microsoft.remotedesktop.standalone
	com.microsoft.vscode.zip
	com.microsoft.autoupdate.standalone
*)


set strURL to "https://macadmins.software/latest.xml" as text

set coidBaseURLStr to refMe's NSString's stringWithString:(strURL)
set ocidBaseURL to refMe's NSURL's URLWithString:(coidBaseURLStr)

################################################
###### URLRequest部分
################################################
set ocidURLRequest to refMe's NSMutableURLRequest's alloc()'s init()
ocidURLRequest's setHTTPMethod:"GET"
ocidURLRequest's setURL:(ocidBaseURL)
ocidURLRequest's addValue:"application/xml" forHTTPHeaderField:"Content-Type"
###ポストするデータは空
ocidURLRequest's setHTTPBody:(missing value)

################################################
###### データ取得
################################################
set ocidServerResponse to refMe's NSURLConnection's sendSynchronousRequest:(ocidURLRequest) returningResponse:(missing value) |error|:(reference)
###取得
set ocidXMLData to (item 1 of ocidServerResponse)
set listXMLDoc to refMe's NSXMLDocument's alloc()'s initWithData:ocidXMLData options:(refMe's NSXMLDocumentTidyXML) |error|:(reference)

set ocidXMLDoc to item 1 of listXMLDoc
set ocidRootElement to ocidXMLDoc's rootElement()

################################################
###### o365バージョン取得
################################################
repeat with itemRootElement in ocidRootElement's children()
	set strName to itemRootElement's |name|() as text
	if strName is "o365" then
		set ocido365ver to (ocidRootElement's childAtIndex:0)'s stringValue()
	end if
end repeat
#######
log ocido365ver as text

################################################
###### 各アプリケーションのUTI取得
################################################
set ocidPackageArray to ocidRootElement's elementsForName:"package"
repeat with itemackageArray in ocidPackageArray
	set ocidElementID to (itemackageArray's childAtIndex:0)'s stringValue()
	log ocidElementID as text
	
end repeat


################################################
###### 対象アプリ最新のバージョン
################################################

set ocidPackageArray to ocidRootElement's elementsForName:"package"
repeat with itemackageArray in ocidPackageArray
	set numCntChild to itemackageArray's childCount() as integer
	set ocidElementID to (itemackageArray's childAtIndex:0)'s stringValue()
	if (ocidElementID as text) is strGetBundleID then
		set ocidCfbundleversionXML to (itemackageArray's childAtIndex:8)'s stringValue()
		set ocidDownloadURL to (itemackageArray's childAtIndex:(numCntChild - 1))'s stringValue()
	end if
end repeat

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
###### リンク解決
################################################
set strDownloadURL to ocidDownloadURL as text
set strCommandText to ("/usr/bin/curl -Lvs -I -o /dev/null -w '%{url_effective}' " & strDownloadURL & "") as text
set strLocation to (do shell script strCommandText) as text

################################################
###### チェック
################################################
set strCfbundleversionXML to ocidCfbundleversionXML as text
set strCfbundleversionPlist to ocidCfbundleversionPlist as text

if strCfbundleversionXML is strCfbundleversionPlist then
	set strTitle to ("最新版を利用中です") as text
	set strCom to ("最新版を利用中です\r" & strCfbundleversionXML) as text
	set strMes to (strTitle & "\rRSS:" & strCfbundleversionXML & "\rPLIST:" & strCfbundleversionPlist & "\rLink:" & strDownloadURL & "\rLocation:" & strLocation) as text
else
	set strTitle to ("アップデートがあります：" & strCfbundleversionXML) as text
	set strCom to ("アップデートがあります\r最新：" & strCfbundleversionXML & "\r使用中：" & strCfbundleversionPlist) as text
	set strMes to ("最新版ダウンロード:" & strDownloadURL & "\r" & strLocation) as text
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
