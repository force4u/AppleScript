#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()


###フォルダ名のリスト
set listMakeDirName to {"Applications", "Pictures", "Developer", "Movies", "Music", "Sites", "Downloads", "Library", "Utilities", "System", "Users", "Documents", "Shared", "Public", "Groups", "Favorites"} as list
###フォルダ名とアイコン名のレコード
## set recordDirIcon to {|Desktop|:"DesktopFolderIcon.icns", |Pictures|:"PicturesFolderIcon.icns", |Developer|:"DeveloperFolderIcon.icns", |Movies|:"MovieFolderIcon.icns", |Music|:"MusicFolderIcon.icns", |Sites|:"SitesFolderIcon.icns", |Downloads|:"DownloadsFolder.icns", |Library|:"LibraryFolderIcon.icns", |Utilities|:"UtilitiesFolder.icns", |System|:"SystemFolderIcon.icns", |Users|:"UsersFolderIcon.icns", |Documents|:"DocumentsFolderIcon.icns", |Shared|:"GenericSharepoint.icns", |Public|:"PublicFolderIcon.icns", |Groups|:"GroupFolder.icns", |Applications|:"ApplicationsFolderIcon.icns", |Favorites|:"ServerApplicationsFolderIcon.icns"} as record

set recordDirIcon to {|Applications|:"ApplicationsFolderIcon.icns", |Desktop|:"DesktopFolderIcon.icns", |Pictures|:"PicturesFolderIcon.icns", |Developer|:"DeveloperFolderIcon.icns", |Movies|:"MovieFolderIcon.icns", |Music|:"MusicFolderIcon.icns", |Sites|:"SitesFolderIcon.icns", |Downloads|:"DownloadsFolder.icns", |Library|:"LibraryFolderIcon.icns", |Utilities|:"UtilitiesFolder.icns", |System|:"SystemFolderIcon.icns", |Users|:"UsersFolderIcon.icns", |Documents|:"DocumentsFolderIcon.icns", |Shared|:"GenericSharepoint.icns", |Public|:"PublicFolderIcon.icns", |Groups|:"GroupFolder.icns", |Favorites|:"ServerApplicationsFolderIcon.icns"} as record

###キー一覧を取り出す
set ocidDirIconDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidDirIconDict's setDictionary:(recordDirIcon)
set ocidAllKeys to ocidDirIconDict's allKeys()
###パスURLにしておく
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSCoreServiceDirectory) inDomains:(refMe's NSSystemDomainMask))
set ocidCoreServiceDirURL to ocidURLsArray's firstObject()
set ocidCoreTypesPathURL to ocidCoreServiceDirURL's URLByAppendingPathComponent:("CoreTypes.bundle/Contents/Resources")

#######################################
###Sharedディレクトリ
#######################################
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSUserDirectory) inDomains:(refMe's NSLocalDomainMask))
set ocidUserDirPathURL to ocidURLsArray's firstObject()
set ocidSharedDirPathURL to ocidUserDirPathURL's URLByAppendingPathComponent:("Shared")

#######################################
###Sharedディレクトリ 子要素
#######################################

repeat with itemKey in ocidAllKeys
	set strKeyName to itemKey as text
	set strValue to (ocidDirIconDict's valueForKey:(strKeyName)) as text
	set ocidIconPathURL to (ocidCoreTypesPathURL's URLByAppendingPathComponent:(strValue))
	##アイコン用のイメージデータ取得
	set ocidImageData to (refMe's NSImage's alloc()'s initWithContentsOfURL:(ocidIconPathURL))
	###フォルダを作る
	set ocidNamedDirPathURL to (ocidSharedDirPathURL's URLByAppendingPathComponent:(strKeyName) isDirectory:(true))
	set ocidNamedDirPath to ocidNamedDirPathURL's |path|()
	set ocidAttrDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	(ocidAttrDict's setValue:(504) forKey:(refMe's NSFilePosixPermissions))
	set listBoolMakeDir to (appFileManager's createDirectoryAtURL:(ocidNamedDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
	###localizedファイルを作成
	set ocidLocalizedFilePathURL to (ocidNamedDirPathURL's URLByAppendingPathComponent:(".localized") isDirectory:(false))
	set ocidNullString to (refMe's NSString's alloc()'s initWithString:(""))
	set listDone to (ocidNullString's writeToURL:(ocidLocalizedFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference))
	###アイコン付与
	set boolAddIcon to (appSharedWorkspace's setIcon:(ocidImageData) forFile:(ocidNamedDirPath) options:(refMe's NSExclude10_4ElementsIconCreationOption))
end repeat

