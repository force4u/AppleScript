#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
サイドバーのよく使う項目に指定のフォルダを追加します
macOS14以降のsfl3版です
AirDropを追加する場合
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
set appFileManager to refMe's NSFileManager's defaultManager()

#############################################
###フォルダ選択
#############################################
###追加するディレクトリパス　サンプルはダウンロードフォルダ
set strAddDirPath to ("~/Library/Fonts/") as text

###何番目に追加するか
set numPosIndex to 0 as integer

###パス
set ocidAddDirPathStr to refMe's NSString's stringWithString:(strAddDirPath)
set ocidAddDirPath to ocidAddDirPathStr's stringByStandardizingPath()
set ocidAddDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidAddDirPath) isDirectory:true)
set strAddDirPath to ocidAddDirPathURL's absoluteString() as text

#######################################
##NSdataに読み込み　Keyを解凍する
#######################################
###処理するファイル名
set strFileName to "com.apple.LSSharedFileList.FavoriteItems.sfl3" as text
###ユーザーライブラリ
set ocidURLArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidAppSuppDirPathURL to ocidURLArray's firstObject()
##com.apple.sharedfilelistフォルダ
set ocidContainerPathURL to (ocidAppSuppDirPathURL's URLByAppendingPathComponent:("com.apple.sharedfilelist") isDirectory:true)
##sfl3のファイルパス
set ocidSharedFileListURL to (ocidContainerPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false)
##NSDATA
set ocidOption to (refMe's NSDataReadingMappedIfSafe)
set listResponse to refMe's NSData's dataWithContentsOfURL:(ocidSharedFileListURL) options:(ocidOption) |error|:(reference)
if (item 2 of listResponse) = (missing value) then
	log "正常処理"
	set ocidPlistData to (item 1 of listResponse)
else if (item 2 of listResponse) ≠ (missing value) then
	log (item 2 of listResponse)'s code() as text
	log (item 2 of listResponse)'s localizedDescription() as text
	return "NSDATAでエラーしました"
end if
###########################
###	解凍してDictに　Flozenなので値を変更するために　可変に変えます
#NSKeyedUnarchiver's 　OS13までの方式
#	set ocidArchveDict to (refMe's NSKeyedUnarchiver's unarchiveObjectWithData:(ocidPlistData))
#NSKeyedUnarchiver's 　OS14からの方式
##解凍
set listResponse to refMe's NSKeyedUnarchiver's unarchivedObjectOfClass:(refMe's NSObject's class) fromData:(ocidPlistData) |error|:(reference)
if (item 2 of listResponse) = (missing value) then
	log "正常処理"
	set ocidArchveDict to (item 1 of listResponse)
else if (item 2 of listResponse) ≠ (missing value) then
	log (item 2 of listResponse)'s code() as text
	log (item 2 of listResponse)'s localizedDescription() as text
	return "NSKeyedUnarchiverでエラーしました"
end if

###	可変Dictにセット
set ocidArchveDictM to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
ocidArchveDictM's setDictionary:(ocidArchveDict)

#######################################
###　items の処理
#######################################
###		items のArrayを取り出して　Flozenなので値を変更するために　可変に変えます
set ocidItemsArray to (ocidArchveDictM's objectForKey:("items"))
###		項目入替用のArray　
set ocidItemsArrayM to (refMe's NSMutableArray's alloc()'s initWithCapacity:0)
ocidItemsArrayM's setArray:(ocidItemsArray)
set numCntArrayItem to count of ocidItemsArray
#######################################
###		値がすでにあるか？確認
set boolChkTagName to (missing value)
##################
###itemsの数だけ繰り返し
set numChkIndex to numPosIndex as integer
repeat with itemsArrayDict in ocidItemsArrayM
	####
	set ocidBookMarkData to (itemsArrayDict's objectForKey:("Bookmark"))
	#BOOKMarkデータの解凍
	set ocidOption to (refMe's NSURLBookmarkResolutionWithoutUI)
	set listResponse to (refMe's NSURL's URLByResolvingBookmarkData:(ocidBookMarkData) options:(ocidOption) relativeToURL:(missing value) bookmarkDataIsStale:(true) |error|:(reference))
	if (item 2 of listResponse) = (missing value) then
		log "正常処理"
		set ocidBookMarkURL to (item 1 of listResponse)
		set strBookMarkPath to ocidBookMarkURL's absoluteString() as text
		log strBookMarkPath
		log strAddDirPath
		if strAddDirPath is strBookMarkPath then
			###値があった場合
			set boolChkTagName to true as boolean
			exit repeat
		else
			###なかった場合
			set boolChkTagName to false as boolean
		end if
	else if (item 2 of listResponse) ≠ (missing value) then
		log (item 2 of listResponse)'s code() as text
		log (item 2 of listResponse)'s localizedDescription() as text
		log "ocidBookMarkData が見つからない"
	end if
	set numChkIndex to numChkIndex + 1 as integer
end repeat
log boolChkTagName

#######################################
###　本処理項目の追加
#######################################
###すでに項目がある場合
if boolChkTagName is true then
	#順番を入れ替える
	set ocidExchngeDict to ocidItemsArrayM's objectAtIndex:(numChkIndex)
	ocidItemsArrayM's removeObjectAtIndex:(numChkIndex)
	ocidItemsArrayM's insertObject:(ocidExchngeDict) atIndex:(numPosIndex)
	#
end if
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
	set ocidResourceKeys to (refMe's NSMutableArray's alloc()'s initWithCapacity:(0))
	(ocidResourceKeys's addObject:(refMe's NSURLPathKey))
	(ocidResourceKeys's addObject:(refMe's NSURLBookmarkURLStringKey))
	(ocidResourceKeys's addObject:(refMe's NSURLCreationDateKey))
	(ocidResourceKeys's addObject:(refMe's NSURLIsRegularFileKey))
	(ocidResourceKeys's addObject:(refMe's NSURLIsPackageKey))
	(*	この値どれが正解なのか？わからないな
	log (refMe's NSURLBookmarkCreationPreferFileIDResolution) as integer
	-->OK(*256*)
	log (refMe's NSURLBookmarkCreationMinimalBookmark) as integer
	-->OK(*512*)
	log (refMe's NSURLBookmarkCreationSuitableForBookmarkFile) as integer
	-->OK(*1024*)
	log (refMe's NSURLBookmarkCreationWithSecurityScope) as integer
	-->NG(*2048*)
	log (refMe's NSURLBookmarkCreationSecurityScopeAllowOnlyReadAccess) as integer
	-->NG(*4096*)
	log (refMe's NSURLBookmarkCreationWithoutImplicitSecurityScope) as text
	-->OK(*536870912*) 
	*)
	set ocidOption to (refMe's NSURLBookmarkCreationWithoutImplicitSecurityScope) as integer
	
	set listResponse to (ocidAddDirPathURL's bookmarkDataWithOptions:(ocidOption) includingResourceValuesForKeys:(ocidResourceKeys) relativeToURL:(missing value) |error|:(reference))
	if (item 2 of listResponse) = (missing value) then
		log "正常処理"
		set ocidBookMarkData to (item 1 of listResponse)
	else if (item 2 of listResponse) ≠ (missing value) then
		log (item 2 of listResponse)'s code() as text
		log (item 2 of listResponse)'s localizedDescription() as text
		return "bookmarkDataWithOptionsでエラーしました"
	end if
	ocidAddDict's setObject:(ocidBookMarkData) forKey:("Bookmark")
	
	##itemsのArrayに追加
	ocidItemsArrayM's insertObject:(ocidAddDict) atIndex:(numPosIndex)
end if
### RootにItemsを追加
(ocidArchveDictM's setObject:(ocidItemsArrayM) forKey:("items"))

#######################################
###　値が新しくなった解凍済みDictをアーカイブする
#######################################
##NSKeyedArchiverに戻す OS13までの形式
# set listSaveData to (refMe's NSKeyedArchiver's archivedDataWithRootObject:(ocidArchveDictM) requiringSecureCoding:(true) |error|:(reference))
##NSKeyedArchiver OS14からの形式
set listResponse to refMe's NSKeyedArchiver's archivedDataWithRootObject:(ocidArchveDictM) requiringSecureCoding:(false) |error|:(reference)
if (item 2 of listResponse) = (missing value) then
	log "正常処理"
	set ocidSaveData to (item 1 of listResponse)
else if (item 2 of listResponse) ≠ (missing value) then
	log (item 2 of listResponse)'s code() as text
	log (item 2 of listResponse)'s localizedDescription() as text
	return "NSKeyedArchiverでエラーしました"
end if


#######################################
###　データを上書き保存する
#######################################
##保存
set ocidOption to (refMe's NSDataWritingAtomic)
set listDone to ocidSaveData's writeToURL:(ocidSharedFileListURL) options:(ocidOption) |error|:(reference)
if (item 1 of listDone) is true then
	log "正常処理"
else if (item 2 of listDone) ≠ (missing value) then
	log (item 2 of listDone)'s code() as text
	log (item 2 of listDone)'s localizedDescription() as text
	return "保存で　エラーしました"
end if

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
