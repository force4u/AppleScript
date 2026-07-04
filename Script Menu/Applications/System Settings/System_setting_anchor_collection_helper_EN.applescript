#!/usr/bin/env osascript
#coding: utf-8
----+----1----+----2----+----3----+----4----+----5----+----6----+----7
(*
Helper script for creating System Settings-opening scripts
Collects the anchor names used to build System Settings URLs
Multilingual support version
Simplified the retrieval of the localized name for General = GENERAL

【CAUTION】【CAUTION】【CAUTION】【CAUTION】
Panel IDs may contain personal information such as the Apple ID name
When distributing the output, please take care to remove the relevant records
License for this script
CC0 public domain
https://creativecommons.jp/sciencecommons/aboutcc0/
Reference URL
https://www.macscripter.net/t/system-settings-shortcuts/78007
com.cocolog-nifty.quicktimer.icefloe *)
----+----1----+----2----+----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application
#Bundle ID of System Settings
set strBundleID to ("com.apple.systempreferences") as text
############################
#Setting item (whether to include personal information = for your own use?)
#	If true, personal information = your own AppleID name will be included
#	If false, the AppleID setting will be entered in place of the name
set boolPrivacy to false as boolean

############################
#JSON save destination
set aliasPathToMe to (path to me) as alias
set strPathToMe to (POSIX path of aliasPathToMe) as text
set ocidPathToMeStr to refMe's NSString's stringWithString:(strPathToMe)
set ocidPathToMe to ocidPathToMeStr's stringByStandardizingPath()
set ocidPathToMeURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidPathToMe) isDirectory:(false)
set ocidContainerDirPathURL to ocidPathToMeURL's URLByDeletingLastPathComponent()
#JSON save file name
set ocidJsonFilePathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:("systempreferences.json") isDirectory:(false)
#Might be used for something? Array in JSON format of ALL keys
set ocidAllKeysFilePathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:("allKes.json") isDirectory:(false)
#This is the newline-delimited AllKeys used in the previous version
set ocidAllKeysTextFilePathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:("allKes.txt") isDirectory:(false)
############################
#Make sure System Settings is launched
set ocidRunAppArray to refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
if (count of ocidRunAppArray) ≠ 0 then
	log "It is running"
	tell application id strBundleID to activate
else
	####Terminate first to counter zombie processes, then proceed
	tell application id strBundleID
		set numCntWindow to (count of every window) as integer
	end tell
	if numCntWindow = 0 then
		tell application id strBundleID to quit
	else
		tell application id strBundleID
			close (every window)
		end tell
		delay 0.5
		tell application id strBundleID to quit
	end if
	#Countermeasure against becoming a half-zombie process
	set ocidRunningApplication to refMe's NSRunningApplication
	set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
	repeat with itemAppArray in ocidAppArray
		itemAppArray's terminate
	end repeat
	#Launch System Settings
	try
		tell application id strBundleID to activate
	on error
		tell application "System Settings" to activate
	end try
	#Wait for launch
	tell application id strBundleID
		#Confirm launch, maximum 10 seconds
		repeat 20 times
			activate
			set boolFrontMost to frontmost as boolean
			log boolFrontMost
			if boolFrontMost is true then
				#The magic 1 second
				delay 0.5
				exit repeat
			else
				delay 0.5
			end if
		end repeat
	end tell
end if
####################
#Region and language
#	set appLocale to refMe's NSLocale's currentLocale()
#	set ocidLocaleID to appLocale's objectForKey:(refMe's NSLocaleIdentifier)
#	set strLocaleID to ocidLocaleID as text
#Get the localized name of GENERAL "simplified version"
tell application "System Settings"
	set strGeneral to (localized string ("GENERAL") from table ("Localizable")) as text
end tell

############################
#Get the IDs of all panes
tell application "System Settings"
	set listPanelID to (id of every pane) as list
end tell
log listPanelID as list
##For retrieving the AppleID name
set strAppleIDName to ("") as text
############################
###【A】Forward-order record
set ocidPaneDict to (refMe's NSMutableDictionary's alloc()'s init())
###【B】Reverse-order record
set ocidReversePaneDict to (refMe's NSMutableDictionary's alloc()'s init())
###Repeat for the number of items in the list obtained in step 1
repeat with itemPanelID in listPanelID
	set strPanelID to itemPanelID as text
	tell application "System Settings"
		if strPanelID is "com.apple.systempreferences.GeneralSettings" then
			set strPanelName to (strGeneral) as text
		else
			set strPanelName to (name of pane id strPanelID) as text
		end if
	end tell
	log strPanelName
	#Privacy handling
	if strPanelID contains "AppleIDSettings" then
		set strAppleIDName to strPanelName as text
	end if
	###【A】Forward-order record
	set ocidItemDict to (refMe's NSDictionary's dictionaryWithObject:(strPanelName) forKey:(strPanelID))
	(ocidPaneDict's addEntriesFromDictionary:(ocidItemDict))
	###【B】Reverse-order record
	set ocidItemDict to (refMe's NSDictionary's dictionaryWithObject:(strPanelID) forKey:(strPanelName))
	(ocidReversePaneDict's addEntriesFromDictionary:(ocidItemDict))
end repeat
############################
#Build the LIST of forward-order records
set ocidAllValueArray to ocidPaneDict's allValues()
##Sort it
set ocidDescriptor to refMe's NSSortDescriptor's sortDescriptorWithKey:("self") ascending:(true) selector:("localizedStandardCompare:")
set ocidDescriptorArray to refMe's NSMutableArray's alloc()'s init()
ocidDescriptorArray's addObject:(ocidDescriptor)
set ocidSortedKey to (ocidAllValueArray's sortedArrayUsingDescriptors:(ocidDescriptorArray))
set listAllValueArray to ocidSortedKey as list
#DICT to pass to the next step
set ocidURLDict to refMe's NSMutableDictionary's alloc()'s init()
#Value = pane name here
repeat with itemValue in listAllValueArray
	set strValue to itemValue as text
	#Get the pane ID
	set ocidPaneID to (ocidReversePaneDict's valueForKey:(strValue))
	set strPaneID to ocidPaneID as text
	
	#Get the anchor values
	tell application "System Settings"
		set listPaneAnchor to (name of (every anchor of pane strValue)) as list
		log listPaneAnchor
	end tell
	
	if strValue is strGeneral then
		#Only General is handled individually
		set strID to ("" & strPaneID & "?Main")
		(ocidURLDict's setObject:(strID) forKey:(strGeneral))
	else if listPaneAnchor is {} then
		#Panes without an anchor
		set strID to strPaneID as text
		(ocidURLDict's setObject:(strID) forKey:(strValue))
	else if strValue contains strAppleIDName then
		#Privacy handling, AppleID pane only
		if boolPrivacy is false then
			set strValue to ("AppleID") as text
		end if
		repeat with itemAnchor in listPaneAnchor
			set strAnchor to itemAnchor as text
			set strID to ("" & strPaneID & "?" & strAnchor & "") as text
			set strSetKey to ("" & strValue & "?" & strAnchor & "") as text
			(ocidURLDict's setObject:(strID) forKey:(strSetKey))
		end repeat
	else
		#Panes that have anchors as child elements
		repeat with itemAnchor in listPaneAnchor
			set strAnchor to itemAnchor as text
			set strID to ("" & strPaneID & "?" & strAnchor & "") as text
			set strSetKey to ("" & strValue & "?" & strAnchor & "") as text
			(ocidURLDict's setObject:(strID) forKey:(strSetKey))
		end repeat
	end if
	
end repeat
#Get all the keys of the collected dictionary
set ocidAllKeys to ocidURLDict's allKeys()
#Sort it
set ocidSortedArray to ocidAllKeys's sortedArrayUsingSelector:("localizedStandardCompare:")
#NSJSONSerialization
#Convert the array to NSDATA
set ocidOption to (refMe's NSJSONWritingSortedKeys)
set listResponse to (refMe's NSJSONSerialization's dataWithJSONObject:(ocidSortedArray) options:(ocidOption) |error|:(reference))
set ocidArrayData to (first item of listResponse)
##Save the NSDATA
set ocidOption to (refMe's NSDataWritingAtomic)
set listDone to ocidArrayData's writeToURL:(ocidAllKeysFilePathURL) options:(ocidOption) |error|:(reference)
#Save as STRING
#Save the NSString as UTF8
set ocidJoinText to ocidSortedArray's componentsJoinedByString:(linefeed)
set listDone to ocidJoinText's writeToURL:(ocidAllKeysTextFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
#NSJSONSerialization
#Convert the dictionary to NSDATA
set ocidOption to (refMe's NSJSONWritingSortedKeys)
set listResponse to (refMe's NSJSONSerialization's dataWithJSONObject:(ocidURLDict) options:(ocidOption) |error|:(reference))
set ocidSaveData to (first item of listResponse)
##Save the NSDATA
set ocidOption to (refMe's NSDataWritingAtomic)
set listDone to ocidSaveData's writeToURL:(ocidJsonFilePathURL) options:(ocidOption) |error|:(reference)
#Open the save destination
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set ocidOpenURLsArray to refMe's NSMutableArray's alloc()'s init()
(ocidOpenURLsArray's addObject:(ocidJsonFilePathURL))
(ocidOpenURLsArray's addObject:(ocidAllKeysFilePathURL))
(ocidOpenURLsArray's addObject:(ocidAllKeysTextFilePathURL))
appSharedWorkspace's activateFileViewerSelectingURLs:(ocidOpenURLsArray)
log "Finished"
return true
