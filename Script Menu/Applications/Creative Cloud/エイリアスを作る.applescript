#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#デスクトップにクラウドドライブのエイリアスを作ります
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

####################################
###ドコ？に作る？
set strAddAliasFilePath to "~/Desktop/Creative Cloud Files" as text

###アイコンどうする？
set boolSetIcon to true as boolean
if boolSetIcon is true then
	#通常creativecloud_folder_bigsur
	set strIconFilePath to "/Applications/Utilities/Adobe Sync/CoreSync/Core Sync.app/Contents/Resources/creativecloud_folder_bigsur.icns" as text
	#レッドタイプ
	set strIconFilePath to "/Applications/Utilities/Adobe Creative Cloud/ACC/Creative Cloud.app/Contents/Resources/CreativeCloudApplicationFolder.icns" as text
	
end if

####################################
####エイリアスが作られる場所
set ocidAddAliasFilePathStr to refMe's NSString's stringWithString:(strAddAliasFilePath)
set ocidAddAliasFilePath to ocidAddAliasFilePathStr's stringByStandardizingPath
set ocidAddAliasFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidAddAliasFilePath) isDirectory:false
set strAddAliasFilePath to ocidAddAliasFilePathURL's |path|() as text

###ディレクトリを作る必要があれば作る
set ocidAddAliasDirFilePathURL to ocidAddAliasFilePathURL's URLByDeletingLastPathComponent()
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:511 forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidAddAliasDirFilePathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)

####################################
####エイリアスの元ファイル
####################################
(* 通常のCloudStorageの場合はこちら
set ocidUserLibraryPathArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidUserLibraryPathURL to ocidUserLibraryPathArray's objectAtIndex:0
set ocidCloudStorageURL to ocidUserLibraryPathURL's URLByAppendingPathComponent:"CloudStorage"
###プロパティ設定
set ocidPropertieKey to {(refMe's NSURLPathKey), (refMe's NSURLIsDirectoryKey)}
###オプション設定
set ocidOption to refMe's NSDirectoryEnumerationSkipsHiddenFiles
###ディレクトリのコンテンツを取得（第一階層のみ）
set listPathUrlArray to (appFileManager's contentsOfDirectoryAtURL:(ocidCloudStorageURL) includingPropertiesForKeys:ocidPropertieKey options:ocidOption |error|:(reference))
set ocidPathArray to item 1 of listPathUrlArray
*)
(* Adobeだけはこちら　*)
set ocidHomeDirURL to appFileManager's homeDirectoryForCurrentUser()
###プロパティ設定
set ocidPropertieKey to {(refMe's NSURLPathKey), (refMe's NSURLIsDirectoryKey)}
###オプション設定
set ocidOption to refMe's NSDirectoryEnumerationSkipsHiddenFiles
###ディレクトリのコンテンツを取得（第一階層のみ）
set listPathUrlArray to (appFileManager's contentsOfDirectoryAtURL:(ocidHomeDirURL) includingPropertiesForKeys:ocidPropertieKey options:ocidOption |error|:(reference))
set ocidPathArray to item 1 of listPathUrlArray


####################################
##ディレクトリ名を取得
####################################
set listDirName to {} as list

repeat with itemPathArray in ocidPathArray
	set ocidDirName to itemPathArray's lastPathComponent()
	set strDirName to ocidDirName as text
	if strDirName starts with "Creative Cloud Files" then
		copy strDirName to end of listDirName
	end if
end repeat
####################################
##ダイアログ
####################################

###ダイアログを前面に出す
tell current application
	set strName to name as text
end tell
try
	####スクリプトメニューから実行したら
	if strName is "osascript" then
		tell application "Finder"
			activate
			set listResponse to (choose from list listDirName with title "選んでください" with prompt "クラウドストレージを開きます" default items (item 1 of listDirName) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed without empty selection allowed) as list
		end tell
	else
		####スクリプトエディタから実行したら
		tell current application
			activate
			set listResponse to (choose from list listDirName with title "選んでください" with prompt "クラウドストレージを開きます" default items (item 1 of listDirName) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
		end tell
	end if
on error
	log "エラーしました"
	return "エラーしました"
	error "エラーしました" number -200
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
	error "キャンセルしました" number -200
end if

####################################
#### 受け取ったディレクトリ
####################################
set strResponse to item 1 of listResponse as text
###URLにして
set ocidFilePathURL to (ocidHomeDirURL's URLByAppendingPathComponent:(strResponse))

####################################
#### エイリアスを作る
####################################
set listBookMarkNSData to (ocidFilePathURL's bookmarkDataWithOptions:(refMe's NSURLBookmarkCreationSuitableForBookmarkFile) includingResourceValuesForKeys:{refMe's NSURLCustomIconKey} relativeToURL:(missing value) |error|:(reference))
set ocdiBookMarkData to (item 1 of listBookMarkNSData)
set listResults to (refMe's NSURL's writeBookmarkData:(ocdiBookMarkData) toURL:(ocidAddAliasFilePathURL) options:(refMe's NSURLBookmarkCreationSuitableForBookmarkFile) |error|:(reference))

####################################
#### アイコンを付与
####################################
if boolSetIcon is true then
	set ocidIconPathStr to (refMe's NSString's stringWithString:(strIconFilePath))
	set ocidIconPath to ocidIconPathStr's stringByStandardizingPath()
	set ocidIconPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidIconPath) isDirectory:false)
	##アイコン用のイメージデータ取得
	set ocidImageData to (refMe's NSImage's alloc()'s initWithContentsOfURL:(ocidIconPathURL))
	###NSWorkspace初期化
	set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
	###アイコン付与
	set boolAddIcon to (appSharedWorkspace's setIcon:(ocidImageData) forFile:(strAddAliasFilePath) options:(refMe's NSExclude10_4ElementsIconCreationOption))
end if

return
