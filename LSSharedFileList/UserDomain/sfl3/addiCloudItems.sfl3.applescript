#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
com.cocolog-nifty.quicktimer.icefloe
macOS14対応版
com.apple.LSSharedFileList.iCloudItems.sfl3
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()


#################################
### 検索条件をダウンロードして生成
#################################
###SavePlistPath
set strFileName to "iCloud Driveを検索.savedSearch" as text
set ocidURLArray to appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask)
set ocidLibraryDirPathURL to ocidURLArray's firstObject()
set ocidSavedSearchesURL to ocidLibraryDirPathURL's URLByAppendingPathComponent:("Saved Searches") isDirectory:true
set ocidSavedFileURL to ocidSavedSearchesURL's URLByAppendingPathComponent:(strFileName) isDirectory:false

########################
##FXScopeArrayOfPaths
set strFXScopePath to "~/Library/Mobile Documents" as text
set ocidFXScopePathStr to refMe's NSString's stringWithString:(strFXScopePath)
set ocidFXScopePath to ocidFXScopePathStr's stringByStandardizingPath()
set strFXScopePath to ocidFXScopePath as text

##SearchScopes
set strSearchScopesPath to ("/System/Volumes/Data" & strFXScopePath & "") as text
set ocidSearchScopesPathStr to refMe's NSString's stringWithString:(strSearchScopesPath)
set ocidSearchScopesPath to ocidSearchScopesPathStr's stringByStandardizingPath()
set strSearchScopesPath to ocidSearchScopesPath as text

###検索ファイルURL
set strSavedsearchURL to "https://quicktimer.cocolog-nifty.com/icefloe/files/template.savedsearch" as text
###
set ocidSavedsearchURLstr to refMe's NSString's stringWithString:(strSavedsearchURL)
set ocidSavedsearchURL to refMe's NSURL's URLWithString:(ocidSavedsearchURLstr)
###ファイルを読み込む
set ocidPlistDictM to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidSavedsearchURL)
###項目の内容を変更
set ocidRawQuery to ocidPlistDictM's objectForKey:"RawQueryDict"
set ocidSearchScopes to ocidRawQuery's objectForKey:"SearchScopes"
set ocidNestArray to ocidSearchScopes's firstObject()
ocidNestArray's replaceObjectAtIndex:0 withObject:(strSearchScopesPath)
###項目の内容を変更
set ocidSearchCriteria to ocidPlistDictM's objectForKey:"SearchCriteria"
set ocidFXScope to ocidSearchCriteria's objectForKey:"FXScopeArrayOfPaths"
ocidFXScope's replaceObjectAtIndex:0 withObject:(strFXScopePath)
#################################
####保存
set boolDone to ocidPlistDictM's writeToURL:(ocidSavedFileURL) atomically:true
log boolDone
set ocidSaveFilePath to ocidSavedFileURL's |path|()

#################################
### サイドバーiCloudItems.sfl2を編集
#################################
###ファイル名
set strFileName to "com.apple.LSSharedFileList.iCloudItems.sfl3" as text
###パス
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLArray to appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask)
set ocidAppSuppDirPathURL to ocidURLArray's firstObject()
set strAppendPath to ("com.apple.sharedfilelist/" & strFileName) as text
set ocidSfl2FilePathURL to ocidAppSuppDirPathURL's URLByAppendingPathComponent:(strAppendPath) isDirectory:false
##NSdataに読み込み
set ocidPlistData to refMe's NSData's dataWithContentsOfURL:(ocidSfl2FilePathURL)
###【１】解凍してDictに
#MacOS13の場合
#set ocidArchveDict to refMe's NSKeyedUnarchiver's unarchiveObjectWithData:(ocidPlistData)
#macOS14対応
set listResponse to refMe's NSKeyedUnarchiver's unarchivedObjectOfClass:((refMe's NSObject)'s class) fromData:(ocidPlistData) |error|:(reference)
set ocidArchveDict to (item 1 of listResponse)
###【２】可変Dictにセット
set ocidArchveDictM to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidArchveDictM's setDictionary:(ocidArchveDict)
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

#######################################
###【５】項目追加用のDict 
set ocidAddDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###【５】	visibility = 0
set ocidAddVisibility to (refMe's NSNumber's numberWithInteger:0)
ocidAddDict's setValue:(ocidAddVisibility) forKey:("visibility")
###【５】	 CustomItemProperties  ここはDictをセットする
set ocidPropertiesDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set ocidStringValue to refMe's NSString's stringWithString:("com.apple.LSSharedFileList.IsICloudDrive")
ocidPropertiesDict's setValue:(ocidStringValue) forKey:("com.apple.LSSharedFileList.SpecialItemIdentifier")
set ocidTrue to (refMe's NSNumber's numberWithBool:true)
ocidPropertiesDict's setValue:(ocidTrue) forKey:("kLSSharedFileListItemUserIsiCloud")
ocidAddDict's setObject:(ocidPropertiesDict) forKey:("CustomItemProperties")
###【５】	 UUIDは新規生成しているが、本当は？別な方法か？
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDStr to ocidUUID's UUIDString()
ocidAddDict's setValue:(ocidUUIDStr) forKey:("uuid")
###【５】	Bookmark
set strURL to "x-apple-finder:icloud"
set ocidURLstr to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's URLWithString:(ocidURLstr)
set ocidBookMarkDataArray to (ocidURL's bookmarkDataWithOptions:(11) includingResourceValuesForKeys:({missing value}) relativeToURL:(missing value) |error|:(reference))
set ocidBookMarkData to item 1 of ocidBookMarkDataArray
ocidAddDict's setObject:(ocidBookMarkData) forKey:("Bookmark")
###【５】	Name
set ocidNamestr to refMe's NSString's stringWithString:("iCloud")
ocidAddDict's setValue:(ocidNamestr) forKey:("Name")
####【４】項目追加用のArrayに追加して
ocidItemsArrayM's addObject:(ocidAddDict)
#######################################
###【５】項目追加用のDict 
set ocidAddDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###【５】	visibility = 0
set ocidAddVisibility to (refMe's NSNumber's numberWithInteger:0)
ocidAddDict's setValue:(ocidAddVisibility) forKey:("visibility")
###【５】	 CustomItemProperties  ここは『空』のDictをセットする
set ocidPropertiesDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set ocidStringValue to refMe's NSString's stringWithString:("com.apple.LSSharedFileList.IsMeetingRoom")
ocidPropertiesDict's setValue:(ocidStringValue) forKey:("com.apple.LSSharedFileList.SpecialItemIdentifier")
ocidAddDict's setObject:(ocidPropertiesDict) forKey:("CustomItemProperties")
###【５】	 UUIDは新規生成しているが、本当は？別な方法か？
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDStr to ocidUUID's UUIDString()
ocidAddDict's setValue:(ocidUUIDStr) forKey:("uuid")
###【５】	Bookmark
set ocidURLComponents to refMe's NSURLComponents's alloc()'s init()
###スキーム を追加
ocidURLComponents's setScheme:("x-apple-finder")
###パスを追加（setHostじゃないよ）
ocidURLComponents's setPath:("airdrop")
set ocidURL to ocidURLComponents's |URL|
set ocidBookMarkDataArray to (ocidURL's bookmarkDataWithOptions:(11) includingResourceValuesForKeys:({missing value}) relativeToURL:(missing value) |error|:(reference))
set ocidBookMarkData to item 1 of ocidBookMarkDataArray
ocidAddDict's setObject:(ocidBookMarkData) forKey:("Bookmark")
###【５】	Name は追加しないURL
## set ocidNamestr to refMe's NSString's stringWithString:("iCloud")
## ocidAddDict's setValue:(ocidNamestr) forKey:("Name")
####【４】項目追加用のArrayに追加して
ocidItemsArrayM's addObject:(ocidAddDict)
#######################################
###【５】項目追加用のDict 
set ocidAddDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###【５】	visibility = 0
set ocidAddVisibility to (refMe's NSNumber's numberWithInteger:0)
ocidAddDict's setValue:(ocidAddVisibility) forKey:("visibility")
###【５】	 CustomItemProperties  ここは『空』のDictをセットする
set ocidPropertiesDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAddDict's setObject:(ocidPropertiesDict) forKey:("CustomItemProperties")
###【５】	 UUIDは新規生成しているが、本当は？別な方法か？
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDStr to ocidUUID's UUIDString()
ocidAddDict's setValue:(ocidUUIDStr) forKey:("uuid")
###【５】	Bookmark
set strURL to "file:///System/Library/CoreServices/Finder.app/Contents/Resources/MyLibraries/SharedDocuments.cannedSearch/"
set ocidURLstr to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's URLWithString:(ocidURLstr)
set ocidBookMarkDataArray to (ocidURL's bookmarkDataWithOptions:(11) includingResourceValuesForKeys:({missing value}) relativeToURL:(missing value) |error|:(reference))
set ocidBookMarkData to item 1 of ocidBookMarkDataArray
ocidAddDict's setObject:(ocidBookMarkData) forKey:("Bookmark")
###【５】	Name は追加しないURL
## set ocidNamestr to refMe's NSString's stringWithString:("iCloud")
## ocidAddDict's setValue:(ocidNamestr) forKey:("Name")
####【４】項目追加用のArrayに追加して
ocidItemsArrayM's addObject:(ocidAddDict)
#######################################
###【５】項目追加用のDict 
set ocidAddDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###【５】	visibility = 0
set ocidAddVisibility to (refMe's NSNumber's numberWithInteger:0)
ocidAddDict's setValue:(ocidAddVisibility) forKey:("visibility")
###【５】	 CustomItemProperties  ここは『空』のDictをセットする
set ocidPropertiesDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set ocidStringValue to refMe's NSString's stringWithString:("com.apple.LSSharedFileList.IsICloudDrive")
ocidPropertiesDict's setValue:(ocidStringValue) forKey:("com.apple.LSSharedFileList.SpecialItemIdentifier")
ocidAddDict's setObject:(ocidPropertiesDict) forKey:("CustomItemProperties")
###【５】	 UUIDは新規生成しているが、本当は？別な方法か？
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDStr to ocidUUID's UUIDString()
ocidAddDict's setValue:(ocidUUIDStr) forKey:("uuid")
###【５】	Bookmark
set strURL to "file:///System/Library/CoreServices/Finder.app/Contents/Resources/MyLibraries/myDocuments.cannedSearch/"
set ocidURLstr to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's URLWithString:(ocidURLstr)
set ocidBookMarkDataArray to (ocidURL's bookmarkDataWithOptions:(11) includingResourceValuesForKeys:({missing value}) relativeToURL:(missing value) |error|:(reference))
set ocidBookMarkData to item 1 of ocidBookMarkDataArray
ocidAddDict's setObject:(ocidBookMarkData) forKey:("Bookmark")
###【５】	Name は追加しないURL
## set ocidNamestr to refMe's NSString's stringWithString:("iCloud")
## ocidAddDict's setValue:(ocidNamestr) forKey:("Name")
####【４】項目追加用のArrayに追加して
ocidItemsArrayM's addObject:(ocidAddDict)
#######################################
###【５】項目追加用のDict 
set ocidAddDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###【５】	visibility = 0
set ocidAddVisibility to (refMe's NSNumber's numberWithInteger:0)
ocidAddDict's setValue:(ocidAddVisibility) forKey:("visibility")
###【５】	 CustomItemProperties  ここは『空』のDictをセットする
set ocidPropertiesDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set ocidStringValue to refMe's NSString's stringWithString:("com.apple.LSSharedFileList.IsICloudDrive")
ocidPropertiesDict's setValue:(ocidStringValue) forKey:("com.apple.LSSharedFileList.SpecialItemIdentifier")
ocidAddDict's setObject:(ocidPropertiesDict) forKey:("CustomItemProperties")
###【５】	 UUIDは新規生成しているが、本当は？別な方法か？
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDStr to ocidUUID's UUIDString()
ocidAddDict's setValue:(ocidUUIDStr) forKey:("uuid")
###【５】	Bookmark
set strURL to "file:///System/Library/CoreServices/Finder.app/Contents/Resources/MyLibraries/SharedByMe.cannedSearch/"
set ocidURLstr to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's URLWithString:(ocidURLstr)
set ocidBookMarkDataArray to (ocidURL's bookmarkDataWithOptions:(11) includingResourceValuesForKeys:({missing value}) relativeToURL:(missing value) |error|:(reference))
set ocidBookMarkData to item 1 of ocidBookMarkDataArray
ocidAddDict's setObject:(ocidBookMarkData) forKey:("Bookmark")
###【５】	Name は追加しないURL
## set ocidNamestr to refMe's NSString's stringWithString:("iCloud")
## ocidAddDict's setValue:(ocidNamestr) forKey:("Name")
####【４】項目追加用のArrayに追加して
ocidItemsArrayM's addObject:(ocidAddDict)
#######################################
###【５】項目追加用のDict 
set ocidAddDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###【５】	visibility = 0
set ocidAddVisibility to (refMe's NSNumber's numberWithInteger:0)
ocidAddDict's setValue:(ocidAddVisibility) forKey:("visibility")
###【５】	 CustomItemProperties  ここは『空』のDictをセットする
set ocidPropertiesDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
set ocidStringValue to refMe's NSString's stringWithString:("com.apple.LSSharedFileList.IsICloudDrive")
ocidPropertiesDict's setValue:(ocidStringValue) forKey:("com.apple.LSSharedFileList.SpecialItemIdentifier")
ocidAddDict's setObject:(ocidPropertiesDict) forKey:("CustomItemProperties")
###【５】	 UUIDは新規生成しているが、本当は？別な方法か？
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDStr to ocidUUID's UUIDString()
ocidAddDict's setValue:(ocidUUIDStr) forKey:("uuid")
###【５】	Bookmark
set strURL to "file:///System/Library/CoreServices/Finder.app/Contents/Resources/MyLibraries/SharedWithMe.cannedSearch/"
set ocidURLstr to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's URLWithString:(ocidURLstr)
set ocidBookMarkDataArray to (ocidURL's bookmarkDataWithOptions:(11) includingResourceValuesForKeys:({missing value}) relativeToURL:(missing value) |error|:(reference))
set ocidBookMarkData to item 1 of ocidBookMarkDataArray
ocidAddDict's setObject:(ocidBookMarkData) forKey:("Bookmark")
###【５】	Name は追加しないURL
## set ocidNamestr to refMe's NSString's stringWithString:("iCloud")
## ocidAddDict's setValue:(ocidNamestr) forKey:("Name")
####【４】項目追加用のArrayに追加して
ocidItemsArrayM's addObject:(ocidAddDict)
#######################################
###【５】項目追加用のDict 
set ocidAddDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###【５】	visibility = 0
set ocidAddVisibility to (refMe's NSNumber's numberWithInteger:0)
ocidAddDict's setValue:(ocidAddVisibility) forKey:("visibility")
###【５】	 CustomItemProperties  ここは『空』のDictをセットする
set ocidPropertiesDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0

ocidAddDict's setObject:(ocidPropertiesDict) forKey:("CustomItemProperties")
###【５】	 UUIDは新規生成しているが、本当は？別な方法か？
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDStr to ocidUUID's UUIDString()
ocidAddDict's setValue:(ocidUUIDStr) forKey:("uuid")
###【５】	Bookmark
set strURL to "file:///System/Library/CoreServices/Finder.app/Contents/Resources/MyLibraries/SharedWithMe.cannedSearch/"
set ocidURLstr to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's URLWithString:(ocidURLstr)
set ocidBookMarkDataArray to (ocidURL's bookmarkDataWithOptions:(11) includingResourceValuesForKeys:({missing value}) relativeToURL:(missing value) |error|:(reference))
set ocidBookMarkData to item 1 of ocidBookMarkDataArray
ocidAddDict's setObject:(ocidBookMarkData) forKey:("Bookmark")
###【５】	Name は追加しないURL
## set ocidNamestr to refMe's NSString's stringWithString:("iCloud")
## ocidAddDict's setValue:(ocidNamestr) forKey:("Name")
####【４】項目追加用のArrayに追加して
ocidItemsArrayM's addObject:(ocidAddDict)

#######################################
###【５】項目追加用のDict 
set ocidAddDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###【５】	visibility = 0
set ocidAddVisibility to (refMe's NSNumber's numberWithInteger:0)
ocidAddDict's setValue:(ocidAddVisibility) forKey:("visibility")
###【５】	 CustomItemProperties  ここは『空』のDictをセットする
set ocidPropertiesDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0

ocidAddDict's setObject:(ocidPropertiesDict) forKey:("CustomItemProperties")
###【５】	 UUIDは新規生成しているが、本当は？別な方法か？
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDStr to ocidUUID's UUIDString()
ocidAddDict's setValue:(ocidUUIDStr) forKey:("uuid")
###【５】	Bookmark
set strURL to "~/Library/Saved Searches/iCloud Driveを検索.savedSearch/"
set ocidURLstr to refMe's NSString's stringWithString:(strURL)
set ocidFilePath to ocidURLstr's stringByStandardizingPath()
##set ocidURL to refMe's NSURL's URLWithString:(ocidURLstr)
set ocidURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
set ocidBookMarkDataArray to (ocidURL's bookmarkDataWithOptions:(11) includingResourceValuesForKeys:({missing value}) relativeToURL:(missing value) |error|:(reference))
set ocidBookMarkData to item 1 of ocidBookMarkDataArray
ocidAddDict's setObject:(ocidBookMarkData) forKey:("Bookmark")
###【５】	Name は追加しないURL
## set ocidNamestr to refMe's NSString's stringWithString:("iCloud")
## ocidAddDict's setValue:(ocidNamestr) forKey:("Name")
####【４】項目追加用のArrayに追加して
ocidItemsArrayM's addObject:(ocidAddDict)

#######################################
####【２】可変Dictに新しいArrayを"items"としてセット
ocidArchveDictM's setObject:(ocidItemsArrayM) forKey:("items")

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
set listDone to ocidSaveData's writeToURL:(ocidSfl2FilePathURL) options:0 |error|:(reference)
set boolDone to (item 1 of listDone) as boolean
if boolDone = true then
	#######################################
	###リロード
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
end if




return