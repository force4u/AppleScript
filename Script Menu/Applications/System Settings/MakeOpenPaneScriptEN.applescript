#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

#################################
###Start system settings
#################################
tell application id "com.apple.systempreferences"
	launch
end tell
###Waiting for startup
tell application id "com.apple.systempreferences"
	###Start confirmation up to 10 seconds
	repeat 10 times
		activate
		set boolFrontMost to frontmost as boolean
		if boolFrontMost is true then
			exit repeat
		else
			delay 1
		end if
	end repeat
end tell
#################################
###Get the name of the panel
#################################
tell application id "com.apple.systempreferences"
	set listPaneName to name of every pane as list
end tell
###Wait for the panel name list to be reliably obtained
if (count of listPaneName) = 0 then
	###Waiting for startup
	tell application id "com.apple.systempreferences"
		###Start confirmation up to 15 seconds
		repeat 15 times
			set listPaneName to name of every pane as list
			###Wait for the panel name list to be reliably obtained
			if (count of listPaneName) ≠ 0 then
				exit repeat
			else
				delay 1
			end if
		end repeat
	end tell
end if
#################################
###[1−1] Dialog on the front
#################################
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set listResponse to (choose from list listPaneName with title "[1−1] Please select" with prompt "Please select" default items (item 1 of listPaneName) OK button name "OK" cancel button name "Cancel" without multiple selections allowed and empty selection allowed) as list
on error
	log "I made an error."
	return "I made an error."
end try
if (item 1 of listResponse) is false then
	return "I canceled."
end if
###Return value
set strPaneName to item 1 of listResponse as text
#################################
###[1−2] Dialog on the front (general only)
#################################
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###I prepared a separate list for the general.
if strPaneName is "General" then
	set listPaneName to {"About", "Software Update", "Storage", "AirDrop & Handoff", "Login Items", "Language & Region", "Date & Time", "Sharing", "Time Machine", "Transfer or Reset", "Startup Disk"} as list
	try
		set listResponse to (choose from list listPaneName with title "[1 - 2] Please choose" with prompt "Please select a panel." default items (item 1 of listPaneName) OK button name "OK" cancel button name "Cancel" without multiple selections allowed and empty selection allowed) as list
	on error
		log "I made an error."
		return "I made an error."
	end try
	if (item 1 of listResponse) is false then
		return "I canceled."
	end if
	###Return value Panel name
	set strPaneName to (item 1 of listResponse) as text
end if
#################################
###Get the target anchor of the panel ID
#################################
###Get the ID of the selected panel
tell application id "com.apple.systempreferences"
	set strPaneId to id of pane strPaneName
end tell
###Obtaining the value of the anchor
tell application id "com.apple.systempreferences"
	set listPaneAnchor to (name of anchors of pane strPaneName) as list
	log listPaneAnchor
end tell
#################################
###[2] Select anchor with the dialog on the front
#################################
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set listAnchorName to (choose from list listPaneAnchor with title "[2] Please choose" with prompt "Please select a panel." default items (item 1 of listPaneAnchor) OK button name "OK" cancel button name "Cancel" without multiple selections allowed and empty selection allowed) as list
on error
	log "I made an error."
	return "I made an error."
end try
if (item 1 of listResponse) is false then
	return "I canceled."
end if
###Return value anchor name
set strAnchorName to item 1 of listAnchorName as text

#################################
###Open with the chosen anchor
#################################
tell application id "com.apple.systempreferences"
	launch
	activate
	reveal anchor strAnchorName of pane id strPaneId
end tell
#################################
###Prepare a value for the dialog
#################################
###Script text for copying
set strScript to "#!/usr/bin/env osascript\r----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\r#com.cocolog-nifty.quicktimer.icefloe\r#" & strAnchorName & ":" & strPaneId & "\r----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\ruse AppleScript version \"2.8\"\ruse scripting additions\rtell application id \"com.apple.systempreferences\"\r\tlaunch\r\tactivate\r\treveal anchor \"" & strAnchorName & "\" of pane id \"" & strPaneId & "\"\rend tell\rtell application id \"com.apple.finder\"\r\topen location \"x-apple.systempreferences:" & strPaneId & "?" & strAnchorName & "\"\rend tell\r"
#################################
###[3] Dialog on the front
#################################
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###Dialogue
set strIconPath to "/System/Library/CoreServices/Finder.app/Contents/Resources/Finder.icns"
set aliasIconPath to POSIX file strIconPath as alias
set recordResult to (display dialog "It's a script return value." with title "A script" default answer strScript buttons {"Copy to clipboard", "Cancel", "Open in the script editor"} default button "Open in the script editor" cancel button "Cancel" giving up after 20 with icon aliasIconPath without hidden answer) as record
###Copy to clipboard
if button returned of recordResult is "Copy to clipboard" then
	set strText to text returned of recordResult as text
	####Pasteboard Declaration
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
end if
###If you press OK, generate a script.
if button returned of recordResult is "Open in the script editor" then
	##A file name
	set strFileName to (strAnchorName & "." & strPaneId & ".applescript") as text
	##The save destination is the script menu
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidLibraryDIrURL to ocidURLsArray's firstObject()
	set ocidScriptDirPathURL to ocidLibraryDIrURL's URLByAppendingPathComponent:("Scripts/Applications/System Settings/Open")
	###Make a folder
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions)
	set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidScriptDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
	set ocidSaveFilePathURL to ocidScriptDirPathURL's URLByAppendingPathComponent:(strFileName)
	###Save the script as text
	set ocidScript to refMe's NSString's stringWithString:(strScript)
	set listDone to ocidScript's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF16LittleEndianStringEncoding) |error|:(reference)
	delay 0.5
	set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
	###Open the saved script
	tell application "Script Editor"
		open aliasSaveFilePath
	end tell
end if

