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
###設定ファイル保存先　Application Support
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidApplicatioocidupportDirPathURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidApplicatioocidupportDirPathURL's URLByAppendingPathComponent:("com.cocolog-nifty.quicktimer/Finder")
###設定ファイル
set ocidJsonFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("com.apple.finder.window.json")
#
set ocidJsonFilePath to ocidJsonFilePathURL's |path|()
set boolDirExists to appFileManager's fileExistsAtPath:(ocidJsonFilePath) isDirectory:(false)
if boolDirExists is false then
	return "設定ファイルが見つかりません"
end if
#
set listReadJsonStrings to refMe's NSString's stringWithContentsOfURL:(ocidJsonFilePathURL) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
set ocidJsonStrings to item 1 of listReadJsonStrings
#
set ocidJsonData to ocidJsonStrings's dataUsingEncoding:(refMe's NSUTF8StringEncoding)
set ocidOption to (refMe's NSJSONReadingMutableContainers)
set listWindowArray to refMe's NSJSONSerialization's JSONObjectWithData:(ocidJsonData) options:(ocidOption) |error|:(reference)
set ocidWindowArray to item 1 of listWindowArray
#
set ocidWindowDict to ocidWindowArray's firstObject()
#
set strDirPath to (ocidWindowDict's valueForKey:("target")) as text
set aliasDirPath to (POSIX file strDirPath) as alias


set listBounds to (ocidWindowDict's valueForKey:("bounds")) as list
set listPosition to (ocidWindowDict's valueForKey:("position")) as list
set strViewName to (ocidWindowDict's valueForKey:("current view")) as text
set numSidebarWidth to (ocidWindowDict's valueForKey:("sidebar width")) as integer
set boolToolbar to (ocidWindowDict's valueForKey:("toolbar visible")) as boolean
set boolStatusbar to (ocidWindowDict's valueForKey:("statusbar visible")) as boolean
set boolPathbar to (ocidWindowDict's valueForKey:("pathbar visible")) as boolean
set boolCollapsed to (ocidWindowDict's valueForKey:("collapsed")) as boolean


tell application "Finder"
	set objNewWindow to (make new Finder window to folder aliasDirPath)
	tell objNewWindow
		set bounds to listBounds
		set position to listPosition
		if strViewName contains "list" then
			set current view to list view
		else if strViewName contains "icon" then
			set current view to icon view
		else if strViewName contains "column" then
			set current view to column view
		else if strViewName contains "flow" then
			set current view to flow view
		end if
		set sidebar width to numSidebarWidth
		set toolbar visible to boolToolbar
		set statusbar visible to boolStatusbar
		set pathbar visible to boolPathbar
		set collapsed to boolCollapsed
	end tell
end tell


