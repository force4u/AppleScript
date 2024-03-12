#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
https://quicktimer.cocolog-nifty.com/icefloe/2023/06/post-88164f.html
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

###デフォルトロケーション
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLArray to appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask)
set ocidAppSuppDirPathURL to ocidURLArray's firstObject()
set strAppendPath to ("com.apple.sharedfilelist") as text
set ocidDefaultLocationURL to ocidAppSuppDirPathURL's URLByAppendingPathComponent:(strAppendPath) isDirectory:false
set aliasDefaultLocation to (ocidDefaultLocationURL's absoluteURL()) as alias

##############################
#####ダイアログを前面に出す
##############################
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
####ダイアログを出す
set listUTI to {"public.item", "dyn.ah62d4rv4ge81g3xqgk"} as list
set aliasFilePath to (choose file with prompt "ファイルを選んでください" default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias
####入力ファイルパス
set strFilePath to POSIX path of aliasFilePath
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidSfl2FilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
set ocidFileName to ocidSfl2FilePathURL's lastPathComponent()
set strFileName to ocidFileName as text

##NSdataに読み込み
set ocidPlistData to refMe's NSData's dataWithContentsOfURL:(ocidSfl2FilePathURL)
###【１】解凍してDictに
set ocidArchveDict to refMe's NSKeyedUnarchiver's unarchiveObjectWithData:(ocidPlistData)
###【２】可変Dictにセット
set ocidArchveDictM to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidArchveDictM's setDictionary:ocidArchveDict
###ALLkeys
set ocidAllKeysArray to ocidArchveDict's allKeys()
log ocidAllKeysArray as list -->(*items, properties*)

#######################################
###　itemsのリストを新しいリストに丸ごと入替る
#######################################
###【３】items のArrayを取り出して
set ocidItemsArray to ocidArchveDictM's objectForKey:"items"
###【４】項目入替用のArray
set ocidItemsArrayM to refMe's NSMutableArray's alloc()'s initWithCapacity:0
####【２】可変Dictに新しいArrayを"items"としてセット
ocidArchveDictM's setObject:(ocidItemsArrayM) forKey:("items")

#######################################
###　propertiesのリストを新しいリストに丸ごと入替る
#######################################
###【５】propertiesの値
set ocidPropertiesDict to ocidArchveDictM's objectForKey:"properties"
###【６】項目入替用のDict
set ocidPropertiesDictM to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
####【２】可変Dictに新しい【６】のDictを"properties"としてセット
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
set boolDone to ocidSaveData's writeToURL:(ocidSfl2FilePathURL) atomically:true
log boolDone
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
end if




return
