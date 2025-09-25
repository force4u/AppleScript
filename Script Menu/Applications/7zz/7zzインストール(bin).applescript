#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
7zz を /Users/実行したユーザー名/bin/7zipにインストールします

com.cocolog-nifty.quicktimer.icefloe *)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set strURL to "https://sourceforge.net/projects/sevenzip/rss" as text


################################################
###### RSSデータ保存
################################################
###ディレクトリ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###パス
set strFileName to "feed.xml" as text
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false
set strSaveFilePath to ocidSaveFilePathURL's |path|() as text

set strCommandText to ("/usr/bin/curl -L \"" & strURL & "\" -o \"" & strSaveFilePath & "\" --connect-timeout 20")
do shell script strCommandText
################################################
###### データ読み込み
################################################
set ocidOption to (refMe's NSXMLDocumentTidyXML)
set listReadXML to refMe's NSXMLDocument's alloc()'s initWithContentsOfURL:(ocidSaveFilePathURL) options:(ocidOption) |error|:(reference)
set ocidXMLDoc to (item 1 of listReadXML)

################################################
###### リンク取得
################################################
### root
set ocidRootElement to ocidXMLDoc's rootElement()
###	channel
set ocidChannel to ocidRootElement's elementsForName:("channel")
set ocidChannelElement to ocidChannel's firstObject()
### ITEM
set ocidItemArray to (ocidChannelElement's elementsForName:("item"))
###リンク取得
set listURL to {} as list
repeat with itemElement in ocidItemArray
	set strItemTitle to (itemElement's elementsForName:("title"))'s stringValue as text
	###
	if strItemTitle contains "mac.tar.xz" then
		set strItemLink to (itemElement's elementsForName:("link"))'s stringValue as text
		set end of listURL to strItemLink
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


###################################
###保存先を開く
###################################
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's openURL:(ocidSaveDirPathURL)
if boolDone is false then
	set aliasFilePathURL to (ocidSaveDirPathURL's absoluteURL()) as alias
	set boolResults to (appShardWorkspace's openURL:ocidCloudStorageDirURL)
	if boolResults is false then
		tell application "Finder"
			make new Finder window to aliasFilePathURL
		end tell
	end if
end if


