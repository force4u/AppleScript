#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
## https://quicktimer.cocolog-nifty.com/icefloe/2023/06/post-2c5c04.html
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

###実行環境取得
set ocidLocale to refMe's NSLocale's currentLocale()
set ocidLocaleID to ocidLocale's localeIdentifier()

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
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
###保存先
set ocidSaveFilePathURL to ocidFilePathURL's URLByAppendingPathExtension:"plist"
#######################################
###　NSdataをNSKeyedUnarchiverで解凍
#######################################
###【１】NSdataにデータを読み込む
set ocidPlistData to refMe's NSData's dataWithContentsOfURL:(ocidFilePathURL)
###【２】解凍してDictに
set ocidArchveDict to refMe's NSKeyedUnarchiver's unarchiveObjectWithData:(ocidPlistData)
#######################################
###　ROOT
#######################################
###【３】値を追加するために可変Dictを用意
set ocidArchveDictM to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
####２の解凍したデータを３の可変Dictにセット
(ocidArchveDictM's setDictionary:ocidArchveDict)
#######################################
###　ITEMS
#######################################
###【４】itemsの値を追加するための可変Array
set ocidItemsArrayM to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
###３からitemsのArrayを取り出して
set ocidItemsArray to ocidArchveDictM's objectForKey:"items"

##################
###itemsの数だけ繰り返し
repeat with itemsArrayDict in ocidItemsArray
	###【５】項目追加用のDict 
	set ocidAddDictM to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	(ocidAddDictM's setDictionary:itemsArrayDict)
	####BOOKMARKエイリアスの解決
	set ocidBookMarkData to (ocidAddDictM's objectForKey:("Bookmark"))
	###エイリアスの解決
	set listResponse to (refMe's NSURL's URLByResolvingBookmarkData:(ocidBookMarkData) options:11 relativeToURL:(missing value) bookmarkDataIsStale:(true) |error|:(reference))
	set ocidBookMarkURL to item 1 of listResponse
	####booKmarkデータがあるなら
	if ocidBookMarkURL is not (missing value) then
		###可読可能なテキストにして
		set coidAliasStrings to ocidBookMarkURL's absoluteString()
		###値をセットする
		if (ocidLocaleID as text) contains "ja" then
			(ocidAddDictM's setValue:(coidAliasStrings) forKey:("Bookmarkのテキスト表示"))
		else
			(ocidAddDictM's setValue:(coidAliasStrings) forKey:("BookMarkStrings"))
		end if
	end if
	###４の可変Arrayにセット
	(ocidItemsArrayM's addObject:ocidAddDictM)
end repeat

#######################################
###　bookMarkのテキスト入りのArrayを戻す
#######################################
###３の可変Dictに可読可能なBookMarkを入れた４のArrayを戻す
ocidArchveDictM's setObject:(ocidItemsArrayM) forKey:("items")

#######################################
###　PLIST XML形式にする
#######################################
set ocidFromat to refMe's NSPropertyListXMLFormat_v1_0
set listPlistEditDataArray to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidArchveDictM) format:(ocidFromat) options:0 |error|:(reference)
set ocidPlistData to item 1 of listPlistEditDataArray

#######################################
###　データを上書き保存する
#######################################
##保存
set boolDone to ocidPlistData's writeToURL:(ocidSaveFilePathURL) atomically:true
log boolDone

###保存したファイル
set aliasSaveFile to (ocidSaveFilePathURL's absoluteURL()) as alias
###ファインダーで選択
tell application "Finder"
	set aliasContainerDir to container of aliasSaveFile as alias
	set objNewWindow to make new Finder window
	set target of objNewWindow to aliasContainerDir
	tell objNewWindow
		select aliasSaveFile
	end tell
	activate
end tell

