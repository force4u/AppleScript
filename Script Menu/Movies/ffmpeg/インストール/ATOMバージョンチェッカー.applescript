#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

################################################
###### URLRequest部分
################################################
set strURL to "https://evermeet.cx/ffmpeg/rss.xml" as text
set coidBaseURLStr to refMe's NSString's stringWithString:(strURL)
set ocidBaseURL to refMe's NSURL's URLWithString:(coidBaseURLStr)
set ocidURLRequest to refMe's NSMutableURLRequest's alloc()'s init()
ocidURLRequest's setHTTPMethod:"GET"
ocidURLRequest's setURL:(ocidBaseURL)
ocidURLRequest's addValue:"application/xml" forHTTPHeaderField:"Content-Type"
ocidURLRequest's setHTTPBody:(missing value)

################################################
###### データ取得
################################################
set ocidServerResponse to refMe's NSURLConnection's sendSynchronousRequest:(ocidURLRequest) returningResponse:(missing value) |error|:(reference)
###取得
set ocidXMLData to (item 1 of ocidServerResponse)
set listXMLDoc to refMe's NSXMLDocument's alloc()'s initWithData:ocidXMLData options:(refMe's NSXMLDocumentTidyXML) |error|:(reference)
###RSSデータ
set ocidXMLDoc to item 1 of listXMLDoc
set ocidRootElement to ocidXMLDoc's rootElement()
set ocidChannel to ocidRootElement's childAtIndex:0

################################################
###### バージョン取得
################################################
set listURL to {} as list
repeat with itemRootElement in ocidChannel's children()
	set strName to itemRootElement's |name|() as text
	log strName
	##  itemRootElement = item
	##	set ocidItemDict to (itemRootElement's childAtIndex:0)'s objectValue()
	##	set strItemTitle to ocidItemDict as text
	###ここは対象のRSS毎に違ってくるので書き換えて
	if strName contains "item" then
		set ocidoVer to (itemRootElement's childAtIndex:1)'s stringValue()
		if (ocidoVer as text) contains ".zip" then
			set end of listURL to (ocidoVer as text)
		end if
	end if
end repeat

################################################
###### 念の為ソートする
################################################
set ocidURLArray to refMe's NSArray's arrayWithArray:(listURL)
set ocidURLArrayM to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
(ocidURLArrayM's addObjectsFromArray:(ocidURLArray))
###並び替え
set ocidDescriptor to (refMe's NSSortDescriptor's sortDescriptorWithKey:("self") ascending:(false) selector:"localizedStandardCompare:")
ocidURLArrayM's sortUsingDescriptors:{ocidDescriptor}

set listURL to ocidURLArrayM as list



try
	###ダイアログを前面に出す
	tell current application
		set strName to name as text
	end tell
	####スクリプトメニューから実行したら
	if strName is "osascript" then
		tell application "Finder"
			activate
		end tell
	else
		tell current application
			activate
		end tell
	end if
	set listResponse to (choose from list listURL with title "選んでください" with prompt "選んだファイルをダウンロードします" default items (item 1 of listURL) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if

set strNewerFileURL to (item 1 of listResponse) as text


###最新をダウンロードする場合はこちら
##	set strNewerFileURL to (ocidURLArrayM's firstObject()) as text

###取り出したダウンロードURL（最新）
set ocidURLString to refMe's NSString's stringWithString:(strNewerFileURL)
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLString)
set strURL to ocidURL's absoluteString() as text
set strFileName to (ocidURL's lastPathComponent()) as text



################################################
###### ダウンロード
################################################
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDownloadsDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDownloadsDirPathURL to ocidURLsArray's firstObject()
set ocidSaveFilePathURL to ocidDownloadsDirPathURL's URLByAppendingPathComponent:(strFileName)
set strSaveFilePath to (ocidSaveFilePathURL's |path|()) as text
set strCommandText to ("/usr/bin/curl -L \"" & strURL & "\" -o \"" & strSaveFilePath & "\"") as text
log (do shell script strCommandText) as text

tell application "Finder"
	set aliasSaveFile to (POSIX file strSaveFilePath) as alias
	set aliasContainerDir to (container of aliasSaveFile) as alias
	open aliasContainerDir
	select file aliasSaveFile
	activate
end tell
return strURL
