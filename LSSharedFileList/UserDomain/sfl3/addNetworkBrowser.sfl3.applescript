#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
com.cocolog-nifty.quicktimer.icefloe
com.apple.LSSharedFileList.NetworkBrowser.sfl3
を処理したあとで
com.apple.LSSharedFileList.FavoriteVolumes.sfl3
も処理する事で有効になります
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
#################################################
###com.apple.LSSharedFileList.NetworkBrowser.sfl3処理
###ファイル名
set strFileName to "com.apple.LSSharedFileList.NetworkBrowser.sfl3" as text
###パス
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLArray to appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask)
set ocidAppSuppDirPathURL to ocidURLArray's firstObject()
set strAppendPath to ("com.apple.sharedfilelist/" & strFileName) as text
set ocidSfl3FilePathURL to ocidAppSuppDirPathURL's URLByAppendingPathComponent:(strAppendPath) isDirectory:false
##NSdataに読み込み
set ocidPlistData to refMe's NSData's dataWithContentsOfURL:(ocidSfl3FilePathURL)
###【１】解凍してDictに
#macOS13までの方式
#set ocidArchveDict to refMe's NSKeyedUnarchiver's unarchiveObjectWithData:(ocidPlistData)
#macOS14からの方式
set listResponse to refMe's NSKeyedUnarchiver's unarchivedObjectOfClass:((refMe's NSObject)'s class) fromData:(ocidPlistData) |error|:(reference)
set ocidArchveDict to (item 1 of listResponse)
###【２】可変Dictにセット
set ocidArchveDictM to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidArchveDictM's setDictionary:ocidArchveDict
###ALLkeys
set ocidAllKeysArray to ocidArchveDict's allKeys()
log ocidAllKeysArray as list -->(*items, properties*)

#######################################
###　itemsはリセット
#######################################
###【３】items のArrayを取り出して
set ocidItemsArray to ocidArchveDictM's objectForKey:"items"
###【４】項目入替用のArray
set ocidItemsArrayM to refMe's NSMutableArray's alloc()'s initWithCapacity:0
####【２】可変Dictに【４】の新しいArrayを"items"としてセット
ocidArchveDictM's setObject:(ocidItemsArrayM) forKey:("items")
#######################################
###　properties Dictを新しいレコードに丸ごと入替る
#######################################
###【５】properties のDictを取り出して
set ocidPropertiesDict to ocidArchveDictM's objectForKey:"properties"
###【６】項目入替用のDict
set ocidPropertiesDictM to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
##【６】にキーと値を入れる　NetworkBrowser.bonjourEnabled
#	set ocidBoolValue to (refMe's NSNumber's numberWithBool:false) --OFFの場合はこちら
set ocidBoolValue to (refMe's NSNumber's numberWithBool:true)
ocidPropertiesDictM's setValue:(ocidBoolValue) forKey:("com.apple.NetworkBrowser.bonjourEnabled")
##【６】にキーと値を入れる　NetworkBrowser.connectedEnabled
#	set ocidBoolValue to (refMe's NSNumber's numberWithBool:false) --OFFの場合はこちら
set ocidBoolValue to (refMe's NSNumber's numberWithBool:true)
ocidPropertiesDictM's setValue:(ocidBoolValue) forKey:("com.apple.NetworkBrowser.connectedEnabled")

###【２】可変Dictに【６】の新しいDictをセット
ocidArchveDictM's setObject:(ocidPropertiesDictM) forKey:("properties")

#######################################
###　値が新しくなった解凍済みDictをアーカイブする
#######################################
##NSKeyedArchiverに戻す
set listSaveData to refMe's NSKeyedArchiver's archivedDataWithRootObject:(ocidArchveDictM) requiringSecureCoding:(true) |error|:(reference)
set ocidSaveData to item 1 of listSaveData
#######################################
###　データを上書き保存する
#######################################
##保存
set listDone to ocidSaveData's writeToURL:(ocidSfl3FilePathURL) options:0 |error|:(reference)
log (item 1 of listDone)
#################################################
###com.apple.LSSharedFileList.FavoriteVolumes.sfl3処理
###ファイル名
set strFileName to "com.apple.LSSharedFileList.FavoriteVolumes.sfl3" as text
###パス
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLArray to appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask)
set ocidAppSuppDirPathURL to ocidURLArray's firstObject()
set strAppendPath to ("com.apple.sharedfilelist/" & strFileName) as text
set ocidSfl3FilePathURL to ocidAppSuppDirPathURL's URLByAppendingPathComponent:(strAppendPath) isDirectory:false
##NSdataに読み込み
set ocidPlistData to refMe's NSData's dataWithContentsOfURL:(ocidSfl3FilePathURL)
###【１】解凍してDictに
#macOS13までの方式
#set ocidArchveDict to refMe's NSKeyedUnarchiver's unarchiveObjectWithData:(ocidPlistData)
#macOS14からの方式
set listResponse to refMe's NSKeyedUnarchiver's unarchivedObjectOfClass:((refMe's NSObject)'s class) fromData:(ocidPlistData) |error|:(reference)
set ocidArchveDict to (item 1 of listResponse)
###【２】可変Dictにセット
set ocidArchveDictM to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidArchveDictM's setDictionary:ocidArchveDict
###ALLkeys
set ocidAllKeysArray to ocidArchveDict's allKeys()
log ocidAllKeysArray as list -->(*items, properties*)

#######################################
###　itemsはリセット
#######################################
###【３】items のArrayを取り出して
set ocidItemsArray to ocidArchveDictM's objectForKey:"items"
###【４】項目入替用のArray
set ocidItemsArrayM to refMe's NSMutableArray's alloc()'s initWithCapacity:0
####【２】可変Dictに【４】の新しいArrayを"items"としてセット
ocidArchveDictM's setObject:(ocidItemsArrayM) forKey:("items")
#######################################
###　properties Dictを新しいレコードに丸ごと入替る
#######################################
###【５】properties のDictを取り出して
set ocidPropertiesDict to ocidArchveDictM's objectForKey:"properties"
###【６】項目入替用のDict
set ocidPropertiesDictM to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
##【６】にキーと値を入れる　NetworkBrowser.bonjourEnabled
#	set ocidBoolValue to (refMe's NSNumber's numberWithBool:false) --OFFの場合はこちら
set ocidBoolValue to (refMe's NSNumber's numberWithBool:true)
ocidPropertiesDictM's setValue:(ocidBoolValue) forKey:("com.apple.LSSharedFileList.FavoriteVolumes.ShowNetworkVolumes")

###【２】可変Dictに【６】の新しいDictをセット
ocidArchveDictM's setObject:(ocidPropertiesDictM) forKey:("properties")

#######################################
###　値が新しくなった解凍済みDictをアーカイブする
#######################################
##NSKeyedArchiverに戻す
set listSaveData to refMe's NSKeyedArchiver's archivedDataWithRootObject:(ocidArchveDictM) requiringSecureCoding:(true) |error|:(reference)
set ocidSaveData to item 1 of listSaveData
#######################################
###　データを上書き保存する
#######################################
##保存
set listDone to ocidSaveData's writeToURL:(ocidSfl3FilePathURL) options:0 |error|:(reference)
set boolDone to (item 1 of listDone)


#######################################
###　リロード
#######################################
if boolDone = true then
	###リロード
	try
		do shell script "/usr/bin/killall sharedfilelistd"
	on error
		set strAgentPath to "/System/Library/LaunchAgents/com.apple.coreservices.sharedfilelistd.plist"
		set strCommandText to ("/bin/launchctl stop -w \"" & strAgentPath & "\"")
		try
			do shell script strCommandText
		end try
		set strCommandText to ("/bin/launchctl start -w \"" & strAgentPath & "\"")
		try
			do shell script strCommandText
		end try
	end try
	delay 0.5
	do shell script "/usr/bin/killall Finder"
else
	display alert "データの保存に失敗しました"
end if



return