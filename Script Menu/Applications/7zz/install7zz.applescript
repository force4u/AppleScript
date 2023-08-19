#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
# 7zz を /Users/実行したユーザー名/bin/7zipにインストールします
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

set strURL to "https://sourceforge.net/projects/sevenzip/rss?path=/7-Zip" as text

set coidBaseURLStr to refMe's NSString's stringWithString:(strURL)
set ocidBaseURL to refMe's NSURL's URLWithString:(coidBaseURLStr)

################################################
###### URLRequest部分
################################################
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
	set ocidItemDict to (itemRootElement's childAtIndex:0)'s objectValue()
	set strItemTitle to ocidItemDict as text
	###ここは対象のRSS毎に違ってくるので書き換えて
	if strItemTitle contains "mac.tar.xz" then
		set ocido365ver to (itemRootElement's childAtIndex:1)'s stringValue()
		set end of listURL to (ocido365ver as text)
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
set strNewerFileURL to (ocidURLArrayM's firstObject()) as text
###取り出したダウンロードURL（最新）
set ocidURLString to refMe's NSString's stringWithString:(strNewerFileURL)
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLString)
set ocidLastPathURL to ocidURL's URLByDeletingLastPathComponent()
###ファイル名
set strFileName to (ocidLastPathURL's lastPathComponent()) as text
###ダウンロードURL上書き
set strURL to ("https://www.7-zip.org/a/" & strFileName) as text
set ocidURLString to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLString)

################################################
###### URLRequest部分
################################################
set ocidURLRequest to refMe's NSMutableURLRequest's alloc()'s init()
ocidURLRequest's setHTTPMethod:"GET"
ocidURLRequest's setURL:(ocidURL)
ocidURLRequest's addValue:"application/xml" forHTTPHeaderField:"Content-Type"
ocidURLRequest's setHTTPBody:(missing value)
################################################
###### データ取得
################################################
set ocidServerResponse to refMe's NSURLConnection's sendSynchronousRequest:(ocidURLRequest) returningResponse:(missing value) |error|:(reference)
###取得
set ocidXZData to (item 1 of ocidServerResponse)
################################################
###### 保存先
################################################
###保存先 ディレクトリ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
###フォルダ作る
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###保存パス
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false
set strSaveFilePathURL to (ocidSaveFilePathURL's |path|()) as text
####保存
set listDone to ocidXZData's writeToURL:(ocidSaveFilePathURL) options:(refMe's NSDataWritingAtomic) |error|:(reference)
################################################
###### 展開
################################################
###展開先
set ocidHomeDirURL to appFileManager's homeDirectoryForCurrentUser()
set ocidSaveDirPathURL to ocidHomeDirURL's URLByAppendingPathComponent:("bin/7zip") isDirectory:true
set strSaveDirPathURL to (ocidSaveDirPathURL's |path|()) as text
###フォルダ作る
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
##展開
set strCommandText to ("/usr/bin/bsdtar -xvzf \"" & strSaveFilePathURL & "\"  -C \"" & strSaveDirPathURL & "\"") as text
set strResponse to (do shell script strCommandText) as text




