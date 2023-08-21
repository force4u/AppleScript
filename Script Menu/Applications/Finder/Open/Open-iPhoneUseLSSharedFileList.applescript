#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
# USB接続中のiPhoneを開きます
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()

set strFileName to "com.apple.LSSharedFileList.FavoriteVolumes.sfl2" as text

###パス
set ocidURLArray to appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask)
set ocidAppSuppDirPathURL to ocidURLArray's firstObject()
set strAppendPath to ("com.apple.sharedfilelist/" & strFileName) as text
set ocidFavoriteServersURL to ocidAppSuppDirPathURL's URLByAppendingPathComponent:(strAppendPath) isDirectory:false
##NSdataに読み込み
set ocidPlistData to refMe's NSData's dataWithContentsOfURL:(ocidFavoriteServersURL)
###解凍してDictに
set ocidArchveDict to refMe's NSKeyedUnarchiver's unarchiveObjectWithData:(ocidPlistData)
###ここは不要なんだけど、値も変更できるように準備
set ocidArchveDictM to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidArchveDictM's setDictionary:ocidArchveDict
###ALLkeys
set ocidAllKeysArray to ocidArchveDict's allKeys()
log ocidAllKeysArray as list -->(*items, properties*)
###items のArrayを取り出しhて
set ocidItemsArray to ocidArchveDictM's objectForKey:"items"
###URL格納用のlist
set listDockPath to {} as list
###itemsの数だけ繰り返し
repeat with itemArray in ocidItemsArray
	log className() of itemArray as text
	log itemArray's allKeys() as list
	--> (*visibility, CustomItemProperties, Bookmark, uuid*)
	set ocidVisibility to (itemArray's objectForKey:("visibility"))
	log className() of ocidVisibility as text
	log ocidVisibility as integer
	
	set ocidCustomItemProperties to (itemArray's objectForKey:("CustomItemProperties"))
	log className() of ocidCustomItemProperties as text
	log ocidCustomItemProperties as record
	
	set ocidUUID to (itemArray's objectForKey:("uuid"))
	log className() of ocidUUID as text
	log ocidUUID as text
	
	set ocidBookMarkData to (itemArray's objectForKey:("Bookmark"))
	###エイリアスの解決
	set listResponse to (refMe's NSURL's URLByResolvingBookmarkData:(ocidBookMarkData) options:11 relativeToURL:(missing value) bookmarkDataIsStale:(false) |error|:(reference))
	set ocidBookMarkURL to item 1 of listResponse
	###エイリアスが無い場合＝すでに削除された場合や移動してしまった場合
	if ocidBookMarkURL is not (missing value) then
		###パスにして
		set strFilePath to ocidBookMarkURL's absoluteString() as text
		log strFilePath
		###リストに追加
		if strFilePath contains "x-finder-iTunes" then
			set end of listDockPath to strFilePath
		end if
	end if
	
end repeat
if listDockPath is {} then
	return "接続中のiPhone無し"
end if

try
	set listResponse to (choose from list listDockPath with title "選んでください" with prompt "最近使った項目" default items (item 1 of listDockPath) OK button name "Finderで開く" cancel button name "閉じる" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
set strResponse to (item 1 of listResponse) as text

tell application "Finder"
	open location strResponse
end tell


display notification "処理終了" with title "処理が終了" subtitle "処理が終了しました" sound name "Sonumi"
log ">>>>>>>>>>>>処理終了<<<<<<<<<<<<<<<"
return ">>>>>>>>>>>>処理終了<<<<<<<<<<<<<<<"

