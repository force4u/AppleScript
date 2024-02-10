#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

############
set strCarFilePath to ("/System/Library/PrivateFrameworks/IconFoundation.framework/Versions/A/Resources/Assets.car") as text
set ocidCarFilePath to refMe's NSString's stringWithString:(strCarFilePath)
set ocidCarFilePathURL to refMe's NSURL's fileURLWithPath:(ocidCarFilePath)
set ocidFileName to ocidCarFilePathURL's lastPathComponent()


set listFolderName to {"FolderDark", "SmartFolder", "Folder", "SmartFolderDark"} as list

repeat with itemFolderName in listFolderName
	############
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSPicturesDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidPicturesDirPathURL to ocidURLsArray's firstObject()
	set strSubPath to ("Icons/GenericFolderIcon.iconset/" & itemFolderName & ".iconset") as text
	set ocidIconsDirPathURL to (ocidPicturesDirPathURL's URLByAppendingPathComponent:(strSubPath))
	set ocidAttrDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	# 777-->511 755-->493 700-->448 766-->502 
	(ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions))
	set listBoolMakeDir to (appFileManager's createDirectoryAtURL:(ocidIconsDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
	############
	set strIconFilePath to (ocidCarFilePathURL's |path|) as text
	set strSaveDirPath to (ocidIconsDirPathURL's |path|) as text
	try
		set strCommandText to ("/usr/bin/iconutil --convert iconset \"" & strIconFilePath & "\" " & itemFolderName & " -o \"" & strSaveDirPath & "\"") as text
		do shell script strCommandText
	end try
end repeat
############
set strSubPath to ("Icons/GenericFolderIcon.iconset") as text
set ocidIconsDirPathURL to ocidPicturesDirPathURL's URLByAppendingPathComponent:(strSubPath)
set ocidDistIconFilePathURL to ocidIconsDirPathURL's URLByAppendingPathComponent:(ocidFileName)
set listDone to appFileManager's copyItemAtURL:(ocidCarFilePathURL) toURL:(ocidDistIconFilePathURL) |error|:(reference)

set listFolderName to {"FolderDark", "SmartFolder", "Folder", "SmartFolderDark"} as list

repeat with itemFolderName in listFolderName
	set strSubPath to ("Icons/GenericFolderIcon.iconset/" & itemFolderName & ".iconset") as text
	set ocidIconsDirPathURL to (ocidPicturesDirPathURL's URLByAppendingPathComponent:(strSubPath))
	set strFileNamePath to ("Icons/GenericFolderIcon.iconset/" & itemFolderName & ".icns") as text
	set ocidSaveFilePathURL to (ocidPicturesDirPathURL's URLByAppendingPathComponent:(strFileNamePath))
	############
	set strIconDirPath to (ocidIconsDirPathURL's |path|) as text
	set strSaveFilePath to (ocidSaveFilePathURL's |path|) as text
	try
		set strCommandText to ("/usr/bin/iconutil --convert icns \"" & strIconDirPath & "\"  -o \"" & strSaveFilePath & "\"") as text
		do shell script strCommandText
	end try
	
end repeat


############
set ocidSelectFilePath to ocidDistIconFilePathURL's |path|
set ocidContainerDirPath to ocidIconsDirPathURL's |path|
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's selectFile:(ocidSelectFilePath) inFileViewerRootedAtPath:(ocidContainerDirPath)



return "処理終了"



