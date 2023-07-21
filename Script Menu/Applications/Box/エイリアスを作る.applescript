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
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

####################################
###ドコ？に作る？
set strAddAliasFilePath to "~/Desktop/Box" as text

###アイコンどうする？
set boolSetIcon to true as boolean
if boolSetIcon is true then
	set strIconFilePath to "/Applications/Box.app/Contents/Resources/Sync.icns" as text
end if

####################################
####エイリアスが作られる場所
set ocidAddAliasFilePathStr to refMe's NSString's stringWithString:strAddAliasFilePath
set ocidAddAliasFilePath to ocidAddAliasFilePathStr's stringByStandardizingPath
set ocidAddAliasFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:ocidAddAliasFilePath isDirectory:false
set strAddAliasFilePathURL to ocidAddAliasFilePathURL's |path|() as text

###ディレクトリを作る必要があれば作る
set ocidAddAliasDirFilePathURL to ocidAddAliasFilePathURL's URLByDeletingLastPathComponent()
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:511 forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidAddAliasDirFilePathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)

####################################
####エイリアスの元ファイル
####################################
set ocidUserLibraryPathArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidUserLibraryPathURL to ocidUserLibraryPathArray's objectAtIndex:0
set ocidCloudStorageURL to ocidUserLibraryPathURL's URLByAppendingPathComponent:"CloudStorage"
###プロパティ設定
set ocidPropertieKey to {(refMe's NSURLPathKey), (refMe's NSURLIsDirectoryKey)}
###オプション設定
set ocidOption to refMe's NSDirectoryEnumerationSkipsHiddenFiles
###ディレクトリのコンテンツを取得（第一階層のみ）
set listPathUrlArray to (appFileManager's contentsOfDirectoryAtURL:ocidCloudStorageURL includingPropertiesForKeys:ocidPropertieKey options:ocidOption |error|:(reference))
set ocidPathArray to item 1 of listPathUrlArray


####################################
##ディレクトリ名を取得
####################################
set listDirName to {} as list

repeat with itemPathArray in ocidPathArray
	set ocidDirName to itemPathArray's lastPathComponent()
	set strDirName to ocidDirName as text
	if strDirName starts with "Box" then
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
set ocidFilePathURL to (ocidCloudStorageURL's URLByAppendingPathComponent:strResponse)

####################################
#### エイリアスを作る
####################################
set listBookMarkNSData to (ocidFilePathURL's bookmarkDataWithOptions:(refMe's NSURLBookmarkCreationSuitableForBookmarkFile) includingResourceValuesForKeys:{refMe's NSURLCustomIconKey} relativeToURL:(missing value) |error|:(reference))
set ocdiBookMarkData to (item 1 of listBookMarkNSData)
set listResults to (refMe's NSURL's writeBookmarkData:ocdiBookMarkData toURL:ocidAddAliasFilePathURL options:(refMe's NSURLBookmarkCreationSuitableForBookmarkFile) |error|:(reference))

####################################
#### アイコンを付与
####################################
if boolSetIcon is true then
	###ICONパス
	set ocidIconPathStr to refMe's NSString's stringWithString:(strIconFilePath)
	set ocidIconPath to ocidIconPathStr's stringByStandardizingPath()
	set ocidIconPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidIconPath) isDirectory:false)
	##アイコン用のイメージデータ取得
	set ocidImageData to (refMe's NSImage's alloc()'s initWithContentsOfURL:(ocidIconPathURL))
	###NSWorkspace初期化
	set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
	###アイコン付与
	set boolAddIcon to (appSharedWorkspace's setIcon:(ocidImageData) forFile:(ocidAddAliasFilePath) options:(refMe's NSExclude10_4ElementsIconCreationOption))
end if

return
