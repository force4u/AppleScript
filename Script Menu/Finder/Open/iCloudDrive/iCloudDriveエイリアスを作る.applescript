#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#	デスクトップにクラウドドライブのエイリアスを作ります
#	Finderでは『iCloud Drive』と表示されていますが
#	フォルダ名は『Mobile Documents』なので留意
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
set strAddAliasFilePath to ("~/Desktop/iCloudDrive") as text

###アイコンどうする？
set boolSetIcon to true as boolean
###アイコン付きの場合
if boolSetIcon is true then
	###iCloudDrive.icnsのパス
	set strIconFilePath to "/System/Library/PrivateFrameworks/iCloudDriveCore.framework/Versions/A/Resources/iCloudDrive.icns" as text
end if

####################################
####エイリアスが作られる場所
set ocidAddAliasFilePathStr to refMe's NSString's stringWithString:(strAddAliasFilePath)
set ocidAddAliasFilePath to ocidAddAliasFilePathStr's stringByStandardizingPath
set ocidAddAliasFilePathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidAddAliasFilePath) isDirectory:false
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
set ocidiCloudDriveURL to ocidUserLibraryPathURL's URLByAppendingPathComponent:"Mobile Documents"

####################################
#### エイリアスを作る
####################################
set listDone to (ocidiCloudDriveURL's bookmarkDataWithOptions:(refMe's NSURLBookmarkCreationSuitableForBookmarkFile) includingResourceValuesForKeys:{refMe's NSURLCustomIconKey} relativeToURL:(missing value) |error|:(reference))
set ocdiBookMarkData to (item 1 of listDone)

set listResults to (refMe's NSURL's writeBookmarkData:(ocdiBookMarkData) toURL:(ocidAddAliasFilePathURL) options:(refMe's NSURLBookmarkCreationSuitableForBookmarkFile) |error|:(reference))
log item 1 of listResults
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