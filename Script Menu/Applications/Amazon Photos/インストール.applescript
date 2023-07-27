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

set strURL to ("https://play.google.com/store/apps/details?id=com.amazon.clouddrive.photos")
set strURL to ("https://www.amazon.co.jp/photos/download") as text
set strURL to ("https://www.amazon.co.jp/clouddrive/download?type=photos") as text

set strURL to ("https://d29x207vrinatv.cloudfront.net/mac/AmazonPhotosApp.zip") as text

set listMakeDirName to {"Pictures", "Developer", "Movies", "Music", "Sites", "Downloads", "Library", "Utilities", "System", "Users", "Documents", "Shared", "Public", "Groups", "Favorites"} as list

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

repeat with itemMakeDirName in listMakeDirName
	###
	set ocidNamedAppDirPathURL to (ocidApplicationDirPathURL's URLByAppendingPathComponent:(itemMakeDirName) isDirectory:(true))
	set ocidAttrDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	(ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions))
	set listBoolMakeDir to (appFileManager's createDirectoryAtURL:(ocidNamedAppDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
	###
	set ocidLocalizedFilePathURL to (ocidNamedAppDirPathURL's URLByAppendingPathComponent:(".localized") isDirectory:(false))
	set ocidNullString to (refMe's NSString's alloc()'s initWithString:(""))
	set listDone to (ocidNullString's writeToURL:(ocidLocalizedFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference))
end repeat


#######################################
### ダウンロード
#######################################
set ocidZipFilePath to (refMe's NSString's stringWithString:(strURL))
set ocidZipFilePathURL to refMe's NSURL's alloc()'s initWithString:(ocidZipFilePath)
set ocidZipData to refMe's NSData's dataWithContentsOfURL:(ocidZipFilePathURL)
set ocidPicturesAppDirPathURL to ocidApplicationDirPathURL's URLByAppendingPathComponent:("Pictures") isDirectory:(true)
set ocidSaveZipFilePathURL to ocidPicturesAppDirPathURL's URLByAppendingPathComponent:("AmazonPhotosApp.zip") isDirectory:(false)
set boolResults to ocidZipData's writeToURL:(ocidSaveZipFilePathURL) atomically:(true)
###ダウンロードとファイルの保存が成功したら
if boolResults = true then
	#### 古い方はゴミ箱へ
	set ocidAppPathURL to ocidPicturesAppDirPathURL's URLByAppendingPathComponent:("Amazon Photos.app") isDirectory:(false)
	set listResult to (appFileManager's trashItemAtURL:(ocidAppPathURL) resultingItemURL:(missing value) |error|:(reference))
	###ZIPファイルを解凍
	set strBundleID to "com.apple.archiveutility" as text
	set aliasZipFilePath to (ocidSaveZipFilePathURL's absoluteURL()) as alias
	tell application id strBundleID to open aliasZipFilePath
	try
		tell application id strBundleID to quit
	end try
end if




