#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#	FinderWindowの保存
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()
###設定ファイル保存先　Application Support
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidApplicatioocidupportDirPathURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidApplicatioocidupportDirPathURL's URLByAppendingPathComponent:("com.cocolog-nifty.quicktimer/Finder")
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###設定ファイル
set ocidJsonFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("com.apple.finder.every.window.json")
###JSON格納用のArray
set ocidWindowArray to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
###ウィンドウを格納
tell application "Finder"
	set listEveryWindow to every window as list
end tell
##格納したWINDOWの数だけ々
repeat with itemWindow in listEveryWindow
	###WINDOWのプロパティを取得して
	tell application "Finder"
		tell itemWindow
			set listBounds to bounds as list
			set listPosition to position as list
			set strViewName to current view as text
			set numSidebarWidth to sidebar width as integer
			set boolToolbar to toolbar visible as boolean
			set boolStatusbar to statusbar visible as boolean
			set boolPathbar to pathbar visible as boolean
			set boolCollapsed to collapsed as boolean
			set aliasTarget to target as alias
		end tell
	end tell
	set strDirPath to (POSIX path of aliasTarget) as text
	set ocidDirPathStr to (refMe's NSString's stringWithString:(strDirPath))
	set ocidDirPath to ocidDirPathStr's stringByStandardizingPath()
	set strDirPath to (ocidDirPath) as text
	###DICTに保存していく
	set ocidFinderWindowDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	(ocidFinderWindowDict's setValue:(listBounds) forKey:("bounds"))
	(ocidFinderWindowDict's setValue:(listPosition) forKey:("position"))
	(ocidFinderWindowDict's setValue:(strViewName) forKey:("current view"))
	(ocidFinderWindowDict's setValue:(numSidebarWidth) forKey:("sidebar width"))
	(ocidFinderWindowDict's setValue:(boolToolbar) forKey:("toolbar visible"))
	(ocidFinderWindowDict's setValue:(boolStatusbar) forKey:("statusbar visible"))
	(ocidFinderWindowDict's setValue:(boolPathbar) forKey:("pathbar visible"))
	(ocidFinderWindowDict's setValue:(boolCollapsed) forKey:("collapsed"))
	(ocidFinderWindowDict's setValue:(strDirPath) forKey:("target"))
	(ocidWindowArray's addObject:(ocidFinderWindowDict))
	
end repeat

###	NSJSONSerialization's
set ocidOption to (refMe's NSJSONWritingPrettyPrinted)
set listJsonStrings to refMe's NSJSONSerialization's dataWithJSONObject:(ocidWindowArray) options:(ocidOption) |error|:(reference)
set ocidJsonStrings to item 1 of listJsonStrings
###	writeToURL
set ocidOption to (refMe's NSDataWritingAtomic)
set listDone to ocidJsonStrings's writeToURL:(ocidJsonFilePathURL) options:(ocidOption) |error|:(reference)

