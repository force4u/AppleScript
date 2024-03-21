#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
#
# よく使う項目にiCloudを追加する
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

#######################################
##設定
#######################################
##Trueで追加 Falaseで置き換え(初期用)
set boolAdd to true as boolean

###追加する位置　上から何番目に追加？0が最上段
set numPosisionNo to 0 as integer

#######################################
###処理するファイル名
set strFileName to "com.apple.LSSharedFileList.FavoriteItems.sfl3" as text
#######################################
##追加するフォルダを選択
#Finder上の表示はiCloud Driveになっていますが実名はMobile Documents
#set strFilePath to "~/Library/Mobile Documents" as text
#set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
#set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
#set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)

set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
###スキーム を追加
(ocidURLComponents's setScheme:("x-apple-finder"))
###パスを追加（setHostじゃないよ）
(ocidURLComponents's setPath:("icloud"))
set strAddDirPathURL to ocidURLComponents's |URL|()


#######################################
##ファイルパス
#######################################
###ディレクトリ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidAppSuppDirPathURL to ocidURLArray's firstObject()
set ocidContainerPathURL to (ocidAppSuppDirPathURL's URLByAppendingPathComponent:("com.apple.sharedfilelist") isDirectory:true)
set ocidSfl3FilePathURL to (ocidContainerPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false)


#######################################
##NSdataに読み込み　Keyを解凍する
#######################################
set ocidPlistData to (refMe's NSData's dataWithContentsOfURL:(ocidSfl3FilePathURL))
###【１】解凍してDictに
#macOS13まで
#set ocidArchveDict to (refMe's NSKeyedUnarchiver's unarchiveObjectWithData:(ocidPlistData))
#macOS14から
set listResponse to (refMe's NSKeyedUnarchiver's unarchivedObjectOfClass:((refMe's NSObject)'s class) fromData:(ocidPlistData) |error|:(reference))
set ocidArchveDict to (item 1 of listResponse)
###【２】可変Dictにセット
set ocidArchveDictM to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
(ocidArchveDictM's setDictionary:ocidArchveDict)
###ALLkeys
set ocidAllKeysArray to ocidArchveDictM's allKeys()
#######################################
###　items の処理
#######################################
###【３】items のArrayを取り出して
set ocidItemsArray to (ocidArchveDictM's objectForKey:("items"))
###【４】項目入替用のArray
set ocidItemsArrayM to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
if boolAdd is true then
	(ocidItemsArrayM's setArray:ocidItemsArray)
end if
#######################################
###【５】項目追加用のDict 
set ocidAddDictM to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
###【５】boolmark
set listBookMarkData to (strAddDirPathURL's bookmarkDataWithOptions:(11) includingResourceValuesForKeys:({missing value}) relativeToURL:(missing value) |error|:(reference))
set ocidBookMarkData to item 1 of listBookMarkData
(ocidAddDictM's setObject:(ocidBookMarkData) forKey:("Bookmark"))
###【５】	visibility = 0
set ocidAddVisibility to (refMe's NSNumber's numberWithInteger:0)
(ocidAddDictM's setValue:(ocidAddVisibility) forKey:("visibility"))
###【５】	 UUIDは新規生成しているが、本当は？別な方法か？
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDStr to ocidUUID's UUIDString()
(ocidAddDictM's setValue:(ocidUUIDStr) forKey:("uuid"))
###【５】	Name			ocidLocalizedName 追加しても無視される？
##	set ocidNamestr to (refMe's NSString's stringWithString:(ocidLocalizedName))
##	(ocidAddDictM's setValue:(ocidNamestr) forKey:("Name"))
###【５】	 CustomItemProperties  
##特殊フォルダの場合は指定があるが、基本は空
set ocidPropertiesDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
(*
	例：x-apple-finder:airdropの場合はこれを追加
	set ocidStringValue to (refMe's NSString's stringWithString:("com.apple.LSSharedFileList.IsMeetingRoom")
	(ocidPropertiesDict's setValue:(ocidStringValue) forKey:("com.apple.LSSharedFileList.SpecialItemIdentifier"))
		*)
###iCloud用の値
set ocidStringValue to (refMe's NSString's stringWithString:("com.apple.LSSharedFileList.IsICloudDrive"))
(ocidPropertiesDict's setValue:(ocidStringValue) forKey:("com.apple.LSSharedFileList.SpecialItemIdentifier"))
set ocidBoolValue to (refMe's NSNumber's numberWithBool:true)
(ocidPropertiesDict's setValue:(ocidBoolValue) forKey:("kLSSharedFileListItemUserIsiCloud"))
(ocidAddDictM's setObject:(ocidPropertiesDict) forKey:("CustomItemProperties"))

####【４】項目追加用のArrayに追加して
(ocidItemsArrayM's insertObject:(ocidAddDictM) atIndex:(numPosisionNo))
##	(ocidItemsArrayM's addObject:(ocidAddDictM))

####【２】可変Dictに【４】の新しいArrayを"items"としてセット
(ocidArchveDictM's setObject:(ocidItemsArrayM) forKey:("items"))

#######################################
###　properties Dictを新しいレコードに丸ごと入替る
#######################################
###【５】properties のDictを取り出して
set ocidPropertiesDict to (ocidArchveDictM's objectForKey:"properties")
###【６】項目入替用のDict
set ocidPropertiesDictM to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
(ocidPropertiesDictM's setDictionary:ocidPropertiesDict)
###
set ocidBoolValue to (refMe's NSNumber's numberWithBool:true)
(ocidPropertiesDictM's setValue:(ocidBoolValue) forKey:("com.apple.LSSharedFileList.ForceTemplateIcons"))
###【２】可変Dictに【６】の新しいDictをセット
(ocidArchveDictM's setObject:(ocidPropertiesDictM) forKey:("properties"))

#######################################
###　値が新しくなった解凍済みDictをアーカイブする
#######################################
##NSKeyedArchiverに戻す
set listSaveData to (refMe's NSKeyedArchiver's archivedDataWithRootObject:(ocidArchveDictM) requiringSecureCoding:(true) |error|:(reference))
set ocidSaveData to item 1 of listSaveData

#######################################
###　データを上書き保存する
#######################################
##保存
set listDone to (ocidSaveData's writeToURL:(ocidSfl3FilePathURL) options:0 |error|:(reference))

set boolDone to (item 1 of listDone) as boolean
log boolDone



#######################################
###　リロード
#######################################

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




return