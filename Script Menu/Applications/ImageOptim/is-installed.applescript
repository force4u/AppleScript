#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKIt"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

set strBundleID to ("net.pornel.ImageOptim") as text

try
	tell application "Finder"
		set aliasAppPath to (get application file id strBundleID) as alias
	end tell
	set strAppPath to (POSIX path of aliasAppPath) as text
	
	set ocidFilePathStr to refMe's NSString's stringWithString:(strAppPath)
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
	set ocidContainerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()
	set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
	set boolDone to appShardWorkspace's selectFile:(ocidFilePathURL's |path|()) inFileViewerRootedAtPath:(ocidContainerDirPathURL's |path|())
	
on error
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidApplicationDirPathURL to ocidURLsArray's firstObject()
	set ocidSaveDirPathURL to ocidApplicationDirPathURL's URLByAppendingPathComponent:("Pictures")
	set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("ImageOptim.tbz2")
	
	##
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	# 777-->511 755-->493 700-->448 766-->502 
	ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
	set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
	set strURL to ("https://imageoptim.com/ImageOptim.tbz2") as text
	set ocidURLString to refMe's NSString's stringWithString:(strURL)
	set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLString)
	##
	set ocidOption to (refMe's NSDataReadingMappedIfSafe)
	set listDownloadData to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidURL) options:(ocidOption) |error|:(reference)
	set ocidDownloadData to (item 1 of listDownloadData)
	set ocidOption to (refMe's NSDataWritingAtomic)
	set listDone to ocidDownloadData's writeToURL:(ocidSaveFilePathURL) options:(ocidOption) |error|:(reference)
	set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
	tell application id "com.apple.archiveutility" to open aliasSaveFilePath
end try




