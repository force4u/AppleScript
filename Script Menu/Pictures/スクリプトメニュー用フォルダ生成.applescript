#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7

use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()


#######################
#####パス Script Menu
#######################
set arrayURLsForDirectory to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryPathURL to arrayURLsForDirectory's objectAtIndex:0
set ocidScriptsDirFilePathURL to ocidLibraryPathURL's URLByAppendingPathComponent:"Scripts/Pictures"
#######################
#####フォルダを作る
#######################
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:511 forKey:(refMe's NSFilePosixPermissions)
set listResult to appFileManager's createDirectoryAtURL:(ocidScriptsDirFilePathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)

######################
##フォルダを作る
######################
set ocidMakeDirFilePathURL to ocidScriptsDirFilePathURL's URLByAppendingPathComponent:("Applications")
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:511 forKey:(refMe's NSFilePosixPermissions)
set listResult to appFileManager's createDirectoryAtURL:(ocidMakeDirFilePathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)

###リンクを作る
set strFilePath to "/System/Library/Image Capture/Automatic Tasks/MakePDF.app" as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFinderFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)

set strFilePath to "~/Library/Scripts/Pictures/Applications/MakePDF.app" as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidBookMarkPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)

###bookmark　エイリアスデータ
set listBookMarkNSData to (ocidFinderFilePathURL's bookmarkDataWithOptions:(refMe's NSURLBookmarkCreationSuitableForBookmarkFile) includingResourceValuesForKeys:{refMe's NSURLCustomIconKey} relativeToURL:(missing value) |error|:(reference))
set ocdiBookMarkData to (item 1 of listBookMarkNSData)
####エイリアスを作る
set listResults to (refMe's NSURL's writeBookmarkData:(ocdiBookMarkData) toURL:(ocidBookMarkPathURL) options:(refMe's NSURLBookmarkCreationSuitableForBookmarkFile) |error|:(reference))


###リンクを作る
set strFilePath to "/System/Library/Image Capture/Automatic Tasks/Build Web Page.app" as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFinderFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)

set strFilePath to "~/Library/Scripts/Pictures/Applications/Build Web Page.app" as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidBookMarkPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)

###bookmark　エイリアスデータ
set listBookMarkNSData to (ocidFinderFilePathURL's bookmarkDataWithOptions:(refMe's NSURLBookmarkCreationSuitableForBookmarkFile) includingResourceValuesForKeys:{refMe's NSURLCustomIconKey} relativeToURL:(missing value) |error|:(reference))
set ocdiBookMarkData to (item 1 of listBookMarkNSData)
####エイリアスを作る
set listResults to (refMe's NSURL's writeBookmarkData:(ocdiBookMarkData) toURL:(ocidBookMarkPathURL) options:(refMe's NSURLBookmarkCreationSuitableForBookmarkFile) |error|:(reference))


###リンクを作る
set strFilePath to "/System/Applications/Utilities/Screenshot.app" as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFinderFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)

set strFilePath to "~/Library/Scripts/Pictures/Applications/Screenshot.app" as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidBookMarkPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)

###bookmark　エイリアスデータ
set listBookMarkNSData to (ocidFinderFilePathURL's bookmarkDataWithOptions:(refMe's NSURLBookmarkCreationSuitableForBookmarkFile) includingResourceValuesForKeys:{refMe's NSURLCustomIconKey} relativeToURL:(missing value) |error|:(reference))
set ocdiBookMarkData to (item 1 of listBookMarkNSData)
####エイリアスを作る
set listResults to (refMe's NSURL's writeBookmarkData:(ocdiBookMarkData) toURL:(ocidBookMarkPathURL) options:(refMe's NSURLBookmarkCreationSuitableForBookmarkFile) |error|:(reference))


###リンクを作る
set strFilePath to "/System/Applications/Preview.app" as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFinderFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)

set strFilePath to "~/Library/Scripts/Pictures/Applications/Preview.app" as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidBookMarkPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)

###bookmark　エイリアスデータ
set listBookMarkNSData to (ocidFinderFilePathURL's bookmarkDataWithOptions:(refMe's NSURLBookmarkCreationSuitableForBookmarkFile) includingResourceValuesForKeys:{refMe's NSURLCustomIconKey} relativeToURL:(missing value) |error|:(reference))
set ocdiBookMarkData to (item 1 of listBookMarkNSData)
####エイリアスを作る
set listResults to (refMe's NSURL's writeBookmarkData:(ocdiBookMarkData) toURL:(ocidBookMarkPathURL) options:(refMe's NSURLBookmarkCreationSuitableForBookmarkFile) |error|:(reference))


###リンクを作る
set strFilePath to "/System/Applications/Utilities/Digital Color Meter.app" as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFinderFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)

set strFilePath to "~/Library/Scripts/Pictures/Applications/Digital Color Meter.app" as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidBookMarkPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)

###bookmark　エイリアスデータ
set listBookMarkNSData to (ocidFinderFilePathURL's bookmarkDataWithOptions:(refMe's NSURLBookmarkCreationSuitableForBookmarkFile) includingResourceValuesForKeys:{refMe's NSURLCustomIconKey} relativeToURL:(missing value) |error|:(reference))
set ocdiBookMarkData to (item 1 of listBookMarkNSData)
####エイリアスを作る
set listResults to (refMe's NSURL's writeBookmarkData:(ocdiBookMarkData) toURL:(ocidBookMarkPathURL) options:(refMe's NSURLBookmarkCreationSuitableForBookmarkFile) |error|:(reference))




#######################################
########スクリプトメニュー有効化
#######################################
tell application "AppleScript Utility"
	###スクリプトメニュー
	set boolScripMenu to Script menu enabled
	if boolScripMenu is false then
		set Script menu enabled to true
		set application scripts position to top
		set show Computer scripts to false
	end if
	###GUI
	set boolGuiScript to GUI Scripting enabled
	if boolGuiScript is false then
		GUI Scripting enabled
	end if
	set theAppPath to default script editor
end tell

