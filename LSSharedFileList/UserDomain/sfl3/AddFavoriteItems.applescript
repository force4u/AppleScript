#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
サーバーに接続の
よく使うサーバーを追加します
macOS14以降のsfl3版です
AirDrop
nwnode://domain-AirDrop
等
一部個別のスキームがあります
SFL3 os14対応版
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

#############################################
###設定項目
#############################################
###追加するディレクトリパス　サンプルはダウンロードフォルダ
set strAddDirPath to ("~/Downloads") as text

###
set ocidAddDirPathStr to refMe's NSString's stringWithString:(strAddDirPath)
set ocidAddDirPath to ocidAddDirPathStr's stringByStandardizingPath()
set ocidAddDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidAddDirPath) isDirectory:false)
set strAddDirPath to ocidAddDirPathURL's absoluteString() as text

#######################################
##NSdataに読み込み　Keyを解凍する
#######################################
set appFileManager to refMe's NSFileManager's defaultManager()
###処理するファイル名
set strFileName to "com.apple.LSSharedFileList.FavoriteItems.sfl3" as text
###URLに
set ocidURLArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidAppSuppDirPathURL to ocidURLArray's firstObject()
set ocidContainerPathURL to (ocidAppSuppDirPathURL's URLByAppendingPathComponent:("com.apple.sharedfilelist") isDirectory:true)
set ocidSharedFileListURL to (ocidContainerPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false)
###NSDATAに読み込みます
set ocidPlistData to (refMe's NSData's dataWithContentsOfURL:(ocidSharedFileListURL))
###	解凍してDictに　Flozenなので値を変更するために　可変に変えます
#NSKeyedUnarchiver's 　OS13までの方式
#	set ocidArchveDict to (refMe's NSKeyedUnarchiver's unarchiveObjectWithData:(ocidPlistData))
#NSKeyedUnarchiver's 　OS14からの方式
set listResponse to refMe's NSKeyedUnarchiver's unarchivedObjectOfClass:((refMe's NSObject)'s class) fromData:(ocidPlistData) |error|:(reference)
set ocidArchveDict to (item 1 of listResponse)
###	可変Dictにセット
set ocidArchveDictM to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
(ocidArchveDictM's setDictionary:ocidArchveDict)

#######################################
###　items の処理
#######################################
###		items のArrayを取り出して　Flozenなので値を変更するために　可変に変えます
set ocidItemsArray to (ocidArchveDictM's objectForKey:("items"))
###		項目入替用のArray　
set ocidItemsArrayM to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
(ocidItemsArrayM's setArray:ocidItemsArray)
set numCntArrayItem to count of ocidItemsArray
#######################################
###		値がすでにあるか？確認
set boolChkTagName to (missing value)
##################
###itemsの数だけ繰り返し
repeat with itemsArrayDict in ocidItemsArrayM
	####
	set ocidBookMarkData to (itemsArrayDict's objectForKey:("Bookmark"))
	#BOOKMarkデータの解凍
	set listResponse to (refMe's NSURL's URLByResolvingBookmarkData:(ocidBookMarkData) options:(refMe's NSURLBookmarkResolutionWithoutUI) relativeToURL:(missing value) bookmarkDataIsStale:(missing value) |error|:(reference))
	set ocidBookMarkURL to (item 1 of listResponse)
	set strBookMarkPath to ocidBookMarkURL's absoluteString() as text
	##
	if strAddDirPath is strBookMarkPath then
		###値があった場合
		set boolChkTagName to true as boolean
		exit repeat
	else
		###なかった場合
		set boolChkTagName to false as boolean
	end if
end repeat

#######################################
###　本処理項目の追加
#######################################

###なければ追加
if boolChkTagName is false then
	######## 	【１】項目追加用のDict
	set ocidAddDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	######## CustomItemProperties
	#【２】CustomItemProperties用のDICT
	set ocidCustomPropertiesDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	# 0=true 1=false
	set ocidSetValue to (refMe's NSNumber's numberWithInteger:1)
	ocidCustomPropertiesDict's setValue:(ocidSetValue) forKey:("com.apple.LSSharedFileList.ItemIsHidden")
	# 0=true 1=false
	set ocidSetValue to (refMe's NSNumber's numberWithInteger:0)
	ocidCustomPropertiesDict's setValue:(ocidSetValue) forKey:("com.apple.finder.dontshowonreappearance")
	
	#【１】のDICTに追加
	ocidAddDict's setObject:(ocidCustomPropertiesDict) forKey:("CustomItemProperties")
	######## 追加用のDict root
	##	uuid
	set ocidUUID to refMe's NSUUID's alloc()'s init()
	set ocidUUIDString to ocidUUID's UUIDString()
	ocidAddDict's setValue:(ocidUUIDString) forKey:("uuid")
	##	visibility
	set ocidVisibility to refMe's NSNumber's numberWithInteger:(0)
	ocidAddDict's setValue:(ocidVisibility) forKey:("visibility")
	##	Bookmark
	set listBookMarkData to (ocidAddDirPathURL's bookmarkDataWithOptions:(11) includingResourceValuesForKeys:({missing value}) relativeToURL:(missing value) |error|:(reference))
	set ocidBookMarkData to (item 1 of listBookMarkData)
	ocidAddDict's setObject:(ocidBookMarkData) forKey:("Bookmark")
	
	##itemsのArrayに追加
	ocidItemsArrayM's addObject:(ocidAddDict)
end if
### RootにItemsを追加
(ocidArchveDictM's setObject:(ocidItemsArrayM) forKey:("items"))

#######################################
###　値が新しくなった解凍済みDictをアーカイブする
#######################################
##NSKeyedArchiverに戻す OS13までの形式
# set listSaveData to (refMe's NSKeyedArchiver's archivedDataWithRootObject:(ocidArchveDictM) requiringSecureCoding:(true) |error|:(reference))
##NSKeyedArchiver OS14からの形式
set listSaveData to refMe's NSKeyedArchiver's archivedDataWithRootObject:(ocidArchveDictM) requiringSecureCoding:(false) |error|:(reference)
set ocidSaveData to item 1 of listSaveData

#######################################
###　データを上書き保存する
#######################################
##保存
set listDone to ocidSaveData's writeToURL:(ocidSharedFileListURL) options:0 |error|:(reference)

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
##	do shell script "/usr/bin/killall Finder"

return
