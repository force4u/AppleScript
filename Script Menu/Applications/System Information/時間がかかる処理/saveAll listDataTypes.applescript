#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# 【注意】　実行後５分ほど時間がかかります
#（インストールしているアプリケーションの数によって増減します）
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()

#####################################
######ファイル保存先
#####################################
set ocidUserLibraryPathArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidFilePathURL to ocidUserLibraryPathArray's objectAtIndex:0
set ocidSaveDirPathURL to ocidFilePathURL's URLByAppendingPathComponent:"Apple/system_profiler"
############################
#####属性 511 --> 777
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:511 forKey:(refMe's NSFilePosixPermissions)
############################
###フォルダを作る
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
#####################################
######DataTypesを取得
#####################################
set strCommandText to ("/usr/sbin/system_profiler -listDataTypes")
set strResponse to (do shell script strCommandText) as text
set ocidListDataTypes to refMe's NSString's stringWithString:(strResponse)
##
set ocidListDataTypeArray to ocidListDataTypes's componentsSeparatedByString:("\r")
#####################################
######ocidListDataTypeの数だけ繰り返し
#####################################
repeat with itemListDataTypeArray in ocidListDataTypeArray
	set strItemListDataTypeArray to itemListDataTypeArray as text
	###保存先パス
	set ocidPlistPathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strItemListDataTypeArray & ".plist"))
	set ocidJsonPathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strItemListDataTypeArray & ".json"))
	set strPlistPath to (ocidPlistPathURL's |path|()) as text
	set strJsonPath to (ocidJsonPathURL's |path|()) as text
	##
	###古いファイルはゴミ箱に
	set listDone to (appFileManager's trashItemAtURL:(ocidPlistPathURL) resultingItemURL:(ocidPlistPathURL) |error|:(reference))
	set listDone to (appFileManager's trashItemAtURL:(ocidJsonPathURL) resultingItemURL:(ocidJsonPathURL) |error|:(reference))
	###
	set strCommandText to "/usr/sbin/system_profiler  " & strItemListDataTypeArray & " -xml > \"" & strPlistPath & "\""
	do shell script strCommandText
	set strCommandText to "/usr/sbin/system_profiler  " & strItemListDataTypeArray & " -json > \"" & strJsonPath & "\""
	do shell script strCommandText
	
end repeat



