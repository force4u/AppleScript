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
set listMakeDirName to {"Pictures", "Developer", "Movies", "Music", "Sites", "Downloads", "Library", "Utilities", "System", "Users", "Documents", "Shared", "Public", "Groups", "Favorites"} as list
###フォルダ名とアイコン名のレコード
## set recordDirIcon to {|Desktop|:"DesktopFolderIcon.icns", |Pictures|:"PicturesFolderIcon.icns", |Developer|:"DeveloperFolderIcon.icns", |Movies|:"MovieFolderIcon.icns", |Music|:"MusicFolderIcon.icns", |Sites|:"SitesFolderIcon.icns", |Downloads|:"DownloadsFolder.icns", |Library|:"LibraryFolderIcon.icns", |Utilities|:"UtilitiesFolder.icns", |System|:"SystemFolderIcon.icns", |Users|:"UsersFolderIcon.icns", |Documents|:"DocumentsFolderIcon.icns", |Shared|:"GenericSharepoint.icns", |Public|:"PublicFolderIcon.icns", |Groups|:"GroupFolder.icns", |Applications|:"ApplicationsFolderIcon.icns", |Favorites|:"ServerApplicationsFolderIcon.icns"} as record

set recordDirIcon to {|Desktop|:"DesktopFolderIcon.icns", |Pictures|:"PicturesFolderIcon.icns", |Developer|:"DeveloperFolderIcon.icns", |Movies|:"MovieFolderIcon.icns", |Music|:"MusicFolderIcon.icns", |Sites|:"SitesFolderIcon.icns", |Downloads|:"DownloadsFolder.icns", |Library|:"LibraryFolderIcon.icns", |Utilities|:"UtilitiesFolder.icns", |System|:"SystemFolderIcon.icns", |Users|:"UsersFolderIcon.icns", |Documents|:"DocumentsFolderIcon.icns", |Shared|:"GenericSharepoint.icns", |Public|:"PublicFolderIcon.icns", |Groups|:"GroupFolder.icns", |Favorites|:"ServerApplicationsFolderIcon.icns"} as record

###キー一覧を取り出す
set ocidDirIconDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidDirIconDict's setDictionary:(recordDirIcon)
set ocidAllKeys to ocidDirIconDict's allKeys()
###パスURLにしておく
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSCoreServiceDirectory) inDomains:(refMe's NSSystemDomainMask))
set ocidCoreServiceDirURL to ocidURLsArray's firstObject()
set ocidCoreTypesPathURL to ocidCoreServiceDirURL's URLByAppendingPathComponent:("CoreTypes.bundle/Contents/Resources")


#######################################
###ユーザーアプリケーションディレクトリ
#######################################
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidApplicationDirPathURL to ocidURLsArray's firstObject()
###
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
###　700--> 448必須
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidApplicationDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###
set ocidLocalizedFilePathURL to ocidApplicationDirPathURL's URLByAppendingPathComponent:(".localized") isDirectory:(false)
set ocidNullString to refMe's NSString's alloc()'s initWithString:("")
set listDone to ocidNullString's writeToURL:(ocidLocalizedFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
###
set ocidSymbolicLinkAtPathURL to (ocidApplicationDirPathURL's URLByAppendingPathComponent:("Applications") isDirectory:(false))
###
set strDestinationPath to "/Applications" as text
set ocidDestinationPathStr to refMe's NSString's stringWithString:(strDestinationPath)
set ocidDestinationPath to ocidDestinationPathStr's stringByStandardizingPath()
set ocidDestinationURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidDestinationPath) isDirectory:(true))
####シンボリックリンクを作る
set listResults to appFileManager's createSymbolicLinkAtURL:(ocidSymbolicLinkAtPathURL) withDestinationURL:(ocidDestinationURL) |error|:(reference)


#######################################
###ユーザーアプリケーションディレクトリ 子要素
#######################################

repeat with itemKey in ocidAllKeys
	set strKeyName to itemKey as text
	set strValue to (ocidDirIconDict's valueForKey:(strKeyName)) as text
	set ocidIconPathURL to (ocidCoreTypesPathURL's URLByAppendingPathComponent:(strValue))
	##アイコン用のイメージデータ取得
	set ocidImageData to (refMe's NSImage's alloc()'s initWithContentsOfURL:(ocidIconPathURL))
	###
	set ocidNamedAppDirPathURL to (ocidApplicationDirPathURL's URLByAppendingPathComponent:(strKeyName) isDirectory:(true))
	set ocidNamedAppDirPath to ocidNamedAppDirPathURL's |path|()
	set ocidAttrDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	(ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions))
	set listBoolMakeDir to (appFileManager's createDirectoryAtURL:(ocidNamedAppDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
	###
	set ocidLocalizedFilePathURL to (ocidNamedAppDirPathURL's URLByAppendingPathComponent:(".localized") isDirectory:(false))
	set ocidNullString to (refMe's NSString's alloc()'s initWithString:(""))
	set listDone to (ocidNullString's writeToURL:(ocidLocalizedFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference))
	###アイコン付与
	set boolAddIcon to (appSharedWorkspace's setIcon:(ocidImageData) forFile:(ocidNamedAppDirPath) options:(refMe's NSExclude10_4ElementsIconCreationOption))
end repeat


#######################################
###ユーザー ユーティリティ　ディレクトリ
#######################################
set ocidUtilitiesDirPathURL to (ocidApplicationDirPathURL's URLByAppendingPathComponent:("Utilities") isDirectory:(true))
###
set ocidSymbolicLinkAtPathURL to (ocidUtilitiesDirPathURL's URLByAppendingPathComponent:("Finder Libraries") isDirectory:(false))
###
set strDestinationPath to "/System/Library/CoreServices/Finder.app/Contents/Resources/MyLibraries" as text
set ocidDestinationPathStr to refMe's NSString's stringWithString:(strDestinationPath)
set ocidDestinationPath to ocidDestinationPathStr's stringByStandardizingPath()
set ocidDestinationURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidDestinationPath) isDirectory:(true))
####シンボリックリンクを作る
set listResults to appFileManager's createSymbolicLinkAtURL:(ocidSymbolicLinkAtPathURL) withDestinationURL:(ocidDestinationURL) |error|:(reference)

###
set ocidSymbolicLinkAtPathURL to (ocidUtilitiesDirPathURL's URLByAppendingPathComponent:("Finder Applications") isDirectory:(false))
###
set strDestinationPath to "/System/Library/CoreServices/Finder.app/Contents/Applications" as text
set ocidDestinationPathStr to refMe's NSString's stringWithString:(strDestinationPath)
set ocidDestinationPath to ocidDestinationPathStr's stringByStandardizingPath()
set ocidDestinationURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidDestinationPath) isDirectory:(true))
####シンボリックリンクを作る
set listResults to appFileManager's createSymbolicLinkAtURL:(ocidSymbolicLinkAtPathURL) withDestinationURL:(ocidDestinationURL) |error|:(reference)


###
set ocidSymbolicLinkAtPathURL to (ocidUtilitiesDirPathURL's URLByAppendingPathComponent:("System Utilities") isDirectory:(false))
###
set strDestinationPath to "/Applications/Utilities" as text
set ocidDestinationPathStr to refMe's NSString's stringWithString:(strDestinationPath)
set ocidDestinationPath to ocidDestinationPathStr's stringByStandardizingPath()
set ocidDestinationURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidDestinationPath) isDirectory:(true))
####シンボリックリンクを作る
set listResults to appFileManager's createSymbolicLinkAtURL:(ocidSymbolicLinkAtPathURL) withDestinationURL:(ocidDestinationURL) |error|:(reference)

###
set ocidSymbolicLinkAtPathURL to (ocidUtilitiesDirPathURL's URLByAppendingPathComponent:("System Applications") isDirectory:(false))
###
set strDestinationPath to "/System/Library/CoreServices/Applications" as text
set ocidDestinationPathStr to refMe's NSString's stringWithString:(strDestinationPath)
set ocidDestinationPath to ocidDestinationPathStr's stringByStandardizingPath()
set ocidDestinationURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidDestinationPath) isDirectory:(true))
####シンボリックリンクを作る
set listResults to appFileManager's createSymbolicLinkAtURL:(ocidSymbolicLinkAtPathURL) withDestinationURL:(ocidDestinationURL) |error|:(reference)

