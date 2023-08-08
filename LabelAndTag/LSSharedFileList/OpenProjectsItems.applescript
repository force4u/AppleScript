#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
com.cocolog-nifty.quicktimer.icefloe
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()

set strFileName to "com.apple.LSSharedFileList.ProjectsItems.sfl2" as text

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
#################################
###itemsの数だけ繰り返し
#################################
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
	set listResponse to (refMe's NSURL's URLByResolvingBookmarkData:(ocidBookMarkData) options:11 relativeToURL:(missing value) bookmarkDataIsStale:(true) |error|:(reference))
	set ocidBookMarkURL to item 1 of listResponse
	###エイリアスが無い場合＝すでに削除された場合や移動してしまった場合
	if ocidBookMarkURL is not (missing value) then
		#	set ocidScheme to ocidBookMarkURL's |scheme|()
		#	set ocidResourceSpecifier to ocidBookMarkURL's resourceSpecifier()
		#	set strBoolMarkSpec to (ocidResourceSpecifier's stringByRemovingPercentEncoding()) as text
		###パスにして
		set ocidBoolMarkPath to ocidBookMarkURL's absoluteString()
		##%エンコードを読める文字に戻してから
		set strBoolMarkSpec to (ocidBoolMarkPath's stringByRemovingPercentEncoding()) as text
		log strBoolMarkSpec as text
		###リストに追加
		set end of listDockPath to strBoolMarkSpec
	end if
	set ocidName to (itemArray's objectForKey:("Name"))
	log className() of ocidName as text
	log ocidName as text
end repeat


#################################
#####ダイアログを前面に
#################################
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set listResponse to (choose from list listDockPath with title "選んでください" with prompt "タグ（インデックス）項目" default items (item 1 of listDockPath) OK button name "Finderで開く" cancel button name "閉じる" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
set strResponse to (item 1 of listResponse) as text
#################################
#####ダイアログを前面に
####################
log strResponse
##読める文字のURLを
set ocidURLString to refMe's NSString's stringWithString:(strResponse)
##%エンコードして
set ocidChrSet to refMe's NSCharacterSet's URLQueryAllowedCharacterSet
set ocidArgTextEncoded to ocidURLString's stringByAddingPercentEncodingWithAllowedCharacters:(ocidChrSet)
##NSURLにしてから
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidArgTextEncoded)
##テキストに戻し
set strBoolMarkPath to (ocidURL's absoluteString()) as text
log ocidBoolMarkPath
#############
##ファインダーで開く
tell application "Finder"
	open location strBoolMarkPath
	activate
end tell



