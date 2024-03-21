#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

#######################################
##設定
#######################################
##Trueで追加 Falaseで置き換え(初期用)
set boolAdd to true as boolean

#######################################
###処理するファイル名
set strFileName to "com.apple.LSSharedFileList.FavoriteItems.sfl3" as text
#######################################
##　CloudStorage URLの収集
#######################################
set appFileManager to refMe's NSFileManager's defaultManager()
###ディレクトリ
set ocidURLArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirPathURL to ocidURLArray's firstObject()
set ocidContainerPathURL to (ocidLibraryDirPathURL's URLByAppendingPathComponent:("CloudStorage") isDirectory:true)
###コンテンツモードでファイル収集（第一階層のみ）
set ocidPropertyKeys to {(refMe's NSURLIsDirectoryKey), (refMe's NSURLPathKey), (refMe's NSURLLocalizedNameKey)}
set ocidOption to refMe's NSDirectoryEnumerationSkipsHiddenFiles
set listContentsDict to (appFileManager's contentsOfDirectoryAtURL:(ocidContainerPathURL) includingPropertiesForKeys:(ocidPropertyKeys) options:(ocidOption) |error|:(reference))
set ocidContentsDict to item 1 of listContentsDict
##リストに追加
set ocidContentsURLArrayM to refMe's NSMutableArray's alloc()'s initWithCapacity:0
ocidContentsURLArrayM's addObjectsFromArray:(ocidContentsDict's allObjects())

#######################################
## ディレクトリURLのみ収集するチェック
#######################################
##ファイル名とマッチするURLだけ処理用のリストにする
set ocidCloudStorageURLArrayM to refMe's NSMutableArray's alloc()'s initWithCapacity:0
####収集したURLを総当たり
repeat with itemContentsURL in ocidContentsURLArrayM
	####URLをforKeyで取り出し
	set listResult to (itemContentsURL's getResourceValue:(reference) forKey:(refMe's NSURLIsDirectoryKey) |error|:(reference))
	###リストからNSURLIsRegularFileKeyのBOOLを取り出し
	set boolResourceValue to item 2 of listResult
	####ディレクトリのみのリストにする
	if boolResourceValue is (refMe's NSNumber's numberWithBool:true) then
		####リストにする
		(ocidCloudStorageURLArrayM's addObject:(itemContentsURL))
	end if
end repeat

#######################################
##ファイルパスURLの収集
#######################################
###ディレクトリ
set ocidURLArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidAppSuppDirPathURL to ocidURLArray's firstObject()
set ocidContainerPathURL to (ocidAppSuppDirPathURL's URLByAppendingPathComponent:("com.apple.sharedfilelist") isDirectory:true)
set ocidPlistFilePathURL to (ocidContainerPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false)


#######################################
##NSdataに読み込み　Keyを解凍する
#######################################
set ocidPlistData to (refMe's NSData's dataWithContentsOfURL:(ocidPlistFilePathURL))
###【１】解凍してDictに
#macOS13までの方式
--set ocidArchveDict to (refMe's NSKeyedUnarchiver's unarchiveObjectWithData:(ocidPlistData))
#macoS14からの方式
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
######################
##CloudStorageを追加
######################
repeat with itemCloudStorageURL in ocidCloudStorageURLArrayM
	###【５】項目追加用のDict 
	set ocidAddDictM to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	###【５】boolmark
	###先に選択したフォルダのURLをブックマークに
	set listAttributesDict to (itemCloudStorageURL's resourceValuesForKeys:({refMe's NSURLLocalizedNameKey}) |error|:(reference))
	set ocidAttributesDict to (item 1 of listAttributesDict)
	set ocidLocalizedName to (ocidAttributesDict's objectForKey:(refMe's NSURLLocalizedNameKey))
	set listBookMarkData to (itemCloudStorageURL's bookmarkDataWithOptions:(11) includingResourceValuesForKeys:({missing value}) relativeToURL:(missing value) |error|:(reference))
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
	set ocidNamestr to (refMe's NSString's stringWithString:(ocidLocalizedName))
	(ocidAddDictM's setValue:(ocidNamestr) forKey:("Name"))
	###【５】	 CustomItemProperties  
	set ocidPropertiesDictM to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	##	set ocidIntValue to (refMe's NSNumber's numberWithInteger:0)
	##	(ocidPropertiesDictM's setValue:(ocidIntValue) forKey:("com.apple.LSSharedFileList.VolumeGroup"))
	##	set ocidStringValue to (refMe's NSString's stringWithString:("FileProvider"))
	##	(ocidPropertiesDictM's setValue:(ocidStringValue) forKey:("com.apple.LSSharedFileList.SpecialItemIdentifier"))
	##	set ocidBoolValue to (refMe's NSNumber's numberWithBool:false)
	##	(ocidPropertiesDictM's setValue:(ocidBoolValue) forKey:("NSURLIsVolumeKey"))
	##	set ocidBoolValue to (refMe's NSNumber's numberWithBool:true)
	##	(ocidPropertiesDictM's setValue:(ocidBoolValue) forKey:("NSURLVolumeIsRootFileSystemKey"))
	##	set ocidBoolValue to (refMe's NSNumber's numberWithBool:true)
	##	(ocidPropertiesDictM's setValue:(ocidBoolValue) forKey:("com.apple.finder.kLSSharedFileListItemIsFileProvider"))
	##	(ocidAddDictM's setObject:(ocidPropertiesDictM) forKey:("CustomItemProperties"))
	
	####【４】項目追加用のArrayに追加して
	(ocidItemsArrayM's addObject:(ocidAddDictM))
	
end repeat
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
#macOS13までの方式
--set listSaveData to (refMe's NSKeyedArchiver's archivedDataWithRootObject:(ocidArchveDictM) requiringSecureCoding:(true) |error|:(reference))
--set ocidSaveData to item 1 of listSaveData
#macoS14からの方式
set listSaveData to (refMe's NSKeyedArchiver's archivedDataWithRootObject:(ocidArchveDictM) requiringSecureCoding:(true) |error|:(reference))
set ocidSaveData to item 1 of listSaveData
#######################################
###　データを上書き保存する
#######################################
##保存
set listDone to (ocidSaveData's writeToURL:(ocidPlistFilePathURL) options:0 |error|:(reference))


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
#do shell script "/usr/bin/killall Finder"

return