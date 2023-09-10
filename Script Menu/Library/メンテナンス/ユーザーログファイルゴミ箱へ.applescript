#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7

use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

(*
Chromeエンジン使っているアプリは終了させてから実行しないと
chrome_crashpadがログを書き込めなくなるので
恐ろしい数のエラーが出ます。
*)
###Chromeエンジン使っているアプリは終了させてから
tell application id "com.google.Chrome" to quit
tell application id "com.microsoft.VSCode" to quit
###終了を待つ
delay 5
####################################
####対象ディレクトリ
####################################
####ライブラリーのURL
set ocidLibraryURLArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidUserLibraryURL to ocidLibraryURLArray's objectAtIndex:0
set ocidLogDirPathURL to (ocidUserLibraryURL's URLByAppendingPathComponent:"Logs" isDirectory:true)

##############################################
##準備
##############################################
###enumeratorAtURL用のBoolean用
set ocidFalse to (refMe's NSNumber's numberWithBool:false)
set ocidTrue to (refMe's NSNumber's numberWithBool:true)
###enumeratorAtURLL格納用のレコード
set ocidEmuDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###enumeratorAtURLL格納するリスト
set ocidEmuFileURLArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
###ファイルURLのみを格納するリスト
set ocidFilePathURLArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0

##############################################
##ディレクトリのコンテツを収集
##############################################
###収集する付随プロパティ
set ocidPropertiesForKeys to {refMe's NSURLIsRegularFileKey}
####ディレクトリのコンテツを収集
set ocidEmuDict to (appFileManager's enumeratorAtURL:ocidLogDirPathURL includingPropertiesForKeys:ocidPropertiesForKeys options:(refMe's NSDirectoryEnumerationSkipsHiddenFiles) errorHandler:(reference))
###戻り値用のリストに格納
set ocidEmuFileURLArray to ocidEmuDict's allObjects()

##############################################
##『ファイル』だけ取り出したリストにする
##############################################

####enumeratorAtURLのかずだけ繰り返し
repeat with itemEmuFileURL in ocidEmuFileURLArray
	####URLをforKeyで取り出し
	set listResult to (itemEmuFileURL's getResourceValue:(reference) forKey:(refMe's NSURLIsRegularFileKey) |error|:(reference))
	###リストからNSURLIsRegularFileKeyのBOOLを取り出し
	set boolIsRegularFileKey to item 2 of listResult
	####ファイルのみを(ディレクトリやリンボリックリンクは含まない）
	if boolIsRegularFileKey is ocidTrue then
		####リストにする
		(ocidFilePathURLArray's addObject:itemEmuFileURL)
	end if
end repeat

###解放
set ocidEmuFileURLArray to ""
set ocidEmuDict to ""

##############################################
##ゴミ箱に入れる
##############################################

repeat with itemFilePathURL in ocidFilePathURLArray
	
	log itemFilePathURL's |path|() as text
	####ゴミ箱
	set listResult to (appFileManager's trashItemAtURL:itemFilePathURL resultingItemURL:(missing value) |error|:(reference))
	
end repeat
