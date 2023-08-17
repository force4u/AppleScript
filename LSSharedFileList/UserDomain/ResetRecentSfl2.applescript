#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# https://quicktimer.cocolog-nifty.com/icefloe/2023/06/post-3fdc1e.html
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


set listReventSfl2 to {"com.apple.LSSharedFileList.RecentServers.sfl2", "com.apple.LSSharedFileList.RecentHosts.sfl2", "com.apple.LSSharedFileList.RecentDocuments.sfl2", "com.apple.LSSharedFileList.RecentApplications.sfl2"} as list

####ファイルの数だけ繰り返し
repeat with itemReventSfl2 in listReventSfl2
	###ファイル名の確定とファイルパスをURLで取得
	set strFileName to itemReventSfl2 as text
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidAppSuppDirPathURL to ocidURLArray's firstObject()
	set strAppendPath to ("com.apple.sharedfilelist/" & strFileName) as text
	set ocidSfl2FilePathURL to (ocidAppSuppDirPathURL's URLByAppendingPathComponent:(strAppendPath) isDirectory:false)
	##NSdataに読み込み
	set ocidPlistData to (refMe's NSData's dataWithContentsOfURL:(ocidSfl2FilePathURL))
	#######################################
	###　NSdataをNSKeyedUnarchiverで解凍
	#######################################
	###【１】解凍してDictに
	set ocidArchveDict to (refMe's NSKeyedUnarchiver's unarchiveObjectWithData:(ocidPlistData))
	#######################################
	###　空のデータをセットする
	#######################################
	###【２】可変Dictにセット
	set ocidArchveDictM to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	(ocidArchveDictM's setDictionary:ocidArchveDict)
	###【３】ブランクのArray
	set ocidItemsArrayM to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
	###Itemsにセット
	(ocidArchveDictM's setObject:(ocidItemsArrayM) forKey:("items"))
	###【４】項目入替用のDict 設定項目は残す
	#	set ocidPropertiesDictM to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	###propertiesにセット
	#	(ocidArchveDictM's setObject:(ocidPropertiesDictM) forKey:("properties"))
	#######################################
	###　値が新しくなった解凍済みDictをアーカイブする
	#######################################
	##NSKeyedArchiverに戻す
	set listSaveData to (refMe's NSKeyedArchiver's archivedDataWithRootObject:(ocidArchveDictM) requiringSecureCoding:(true) |error|:(reference))
	set ocidSaveData to item 1 of listSaveData
	
	#######################################
	###　データを上書き保存する
	#######################################
	set boolDone to (ocidSaveData's writeToURL:(ocidSfl2FilePathURL) atomically:true)
	log boolDone
end repeat

#######################################
###　リロード
#######################################
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

return
