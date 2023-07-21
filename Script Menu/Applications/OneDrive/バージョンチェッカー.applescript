#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
com.cocolog-nifty.quicktimer.icefloe
*)
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

###アプリケーションのバンドルID
set strBundleID to "com.microsoft.OneDrive"

set strGetBundleID to "com.microsoft.onedrive.standalone" as text
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
	set ocidElementID to (itemackageArray's childAtIndex:0)'s stringValue()
	if (ocidElementID as text) is strGetBundleID then
		set ocidCfbundleversionXML to (itemackageArray's childAtIndex:8)'s stringValue()
		set strPkgURL to (itemackageArray's childAtIndex:17)'s stringValue() as text
	end if
end repeat
log "RSS:" & ocidCfbundleversionXML as text
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
set strCfbundleversionXML to ocidCfbundleversionXML as text
set strCfbundleversionPlist to ocidCfbundleversionPlist as text
if strCfbundleversionXML is strCfbundleversionPlist then
	return "最新版を利用中です"
else
	return "アップデートがありますインストールが必要です"
end if

