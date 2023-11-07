#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
# USB接続中のiPhoneを開きます
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

####設定項目
###iPhoneの名前（一部でもOK）
set strPhoneName to ("iPhone") as text

##################
###処理開始
set appFileManager to refMe's NSFileManager's defaultManager()
###ファイル名
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
	
	set ocidName to (itemArray's objectForKey:("Name"))
	try
		log className() of ocidName as text
		log "■" & ocidName as text
		set strName to ocidName as text
	on error
		set strName to ("missing value") as text
	end try
	if strName contains strPhoneName then
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
	end if
end repeat
if listDockPath is {} then
	return "接続中のiPhone無し"
end if
log listDockPath
try
	###ダイアログ
	set strName to (name of current application) as text
	if strName is "osascript" then
		tell application "Finder" to activate
	else
		tell current application to activate
	end if
	set listResponse to (choose from list listDockPath with title "選んでください" with prompt "FavoriteVolumesから取得した\n接続中のiPhoneのURL\n複数選択時は対象を選んでください" default items (item 1 of listDockPath) OK button name "このiPhoneのURLを取得する" cancel button name "閉じる" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
set strOpenURL to (item 1 of listResponse) as text


####クリップボードに渡す用のスクリプトテンプレート
set strScript to ("#!/usr/bin/env osascript\n----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\n#\n#com.cocolog-nifty.quicktimer.icefloe\n----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\nuse AppleScript version \"2.8\"\nuse framework \"Foundation\"\nuse scripting additions\nset strURL to \"" & strOpenURL & "\"\ntell application \"Finder\"\nopen location strURL\nend tell") as text

set strMes to ("↓接続中のiPhoneのURLです\n" & strOpenURL & "\n↓は次回から利用可能なスクリプト") as text
###ダイアログ
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
set recordResult to (display dialog strMes with title "接続中のiPhoneのURL" default answer strScript buttons {"クリップボードにコピー", "キャンセル", "Finderで開く"} default button "Finderで開く" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer)
if button returned of recordResult is "Finderで開く" then
	tell application "Finder"
		open location strOpenURL
	end tell
	###クリップボードコピー
else if button returned of recordResult is "クリップボードにコピー" then
	set strText to text returned of recordResult as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
end if


display notification "処理終了" with title "処理が終了" subtitle "処理が終了しました" sound name "Sonumi"
log ">>>>>>>>>>>>処理終了<<<<<<<<<<<<<<<"
return ">>>>>>>>>>>>処理終了<<<<<<<<<<<<<<<"

