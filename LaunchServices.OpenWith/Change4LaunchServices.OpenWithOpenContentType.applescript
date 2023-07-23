#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# ƒtƒ@ƒCƒ‹‚ğŠJ‚­‚ÌƒfƒtƒHƒ‹ƒg‚ÌƒAƒvƒŠƒP[ƒVƒ‡ƒ“‚ğ‘—Ş–ˆ‚Éİ’è‚µ‚Ü‚·
# ƒtƒ@ƒCƒ‹‚Ìí—Ş‚©‚ç@ŠJ‚­‚±‚Æ‚ªo—ˆ‚éƒAƒvƒŠ‚ğŠÖ˜A•t‚¯‚Ü‚·
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "Appkit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()


###################################
#####“ü—Íƒ_ƒCƒAƒƒO
###################################
#####ƒ_ƒCƒAƒƒO‚ğ‘O–Ê‚É
tell current application
	set strName to name as text
end tell
####ƒXƒNƒŠƒvƒgƒƒjƒ…[‚©‚çÀs‚µ‚½‚ç
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set listUTI to {"public.data"} as list
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias
set strPromptText to "ƒtƒ@ƒCƒ‹‚ğ‘I‚ñ‚Å‚­‚¾‚³‚¢" as text
set strMesText to "ƒtƒ@ƒCƒ‹‚ğ‘I‚ñ‚Å‚­‚¾‚³‚¢" as text
set listAliasFilePath to (choose file strMesText with prompt strPromptText default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as list
set aliasFilePath to (item 1 of listAliasFilePath) as alias
set strAppendAttrFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to (refMe's NSString's stringWithString:(strAppendAttrFilePath))
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:true)
####UTI‚Ìæ“¾
set listResourceValue to (ocidFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLContentTypeKey) |error|:(reference))
set ocidContentType to (item 2 of listResourceValue)
set strUTI to (ocidContentType's identifier) as text
###missing value‘Îô
if strUTI is "" then
	tell application "Finder"
		set objInfo to info for aliasFilePath
		set strUTI to type identifier of objInfo as text
	end tell
end if
################################
######ƒpƒX‚ğ“n‚·‚±‚Æ‚ª‰Â”\‚ÈƒAƒvƒŠ‚ÌURL
################################
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
set ocidURLArray to appShardWorkspace's URLsForApplicationsToOpenContentType:(ocidContentType)
###ƒ_ƒCƒAƒƒO—p‚ÌƒAƒvƒŠƒP[ƒVƒ‡ƒ“–¼ƒŠƒXƒg
set listAppName to {} as list
###ƒAƒvƒŠƒP[ƒVƒ‡ƒ“‚ÌURL‚ğQÆ‚³‚¹‚é‚½‚ß‚ÌƒŒƒR[ƒh
set ocidAppDictionary to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
repeat with itemURLArray in ocidURLArray
	###ƒAƒvƒŠƒP[ƒVƒ‡ƒ“‚Ì–¼‘O
	set listResponse to (itemURLArray's getResourceValue:(reference) forKey:(refMe's NSURLNameKey) |error|:(missing value))
	set strAppName to (item 2 of listResponse) as text
	log "–¼‘O‚ÍF" & strAppName & "‚Å‚·"
	copy strAppName to end of listAppName
	set listSerArray to {} as list
	####ƒpƒX
	set aliasAppPath to itemURLArray's absoluteURL() as alias
	log "ƒpƒX‚ÍF" & aliasAppPath & "‚Å‚·"
	####ƒoƒ“ƒhƒ‹IDæ“¾
	set ocidAppBunndle to (refMe's NSBundle's bundleWithURL:(itemURLArray))
	set ocidBunndleID to ocidAppBunndle's bundleIdentifier
	set strBundleID to ocidBunndleID as text
	set listSerArray to {itemURLArray, strBundleID} as list
	log "BunndleID‚ÍF" & strBundleID & "‚Å‚·"
	(ocidAppDictionary's setObject:(listSerArray) forKey:(strAppName))
end repeat

###################################
#####ƒ_ƒCƒAƒƒO
###################################a
###ƒ_ƒCƒAƒƒO‚ğ‘O–Ê‚É
tell current application
	set strName to name as text
end tell
####ƒXƒNƒŠƒvƒgƒƒjƒ…[‚©‚çÀs‚µ‚½‚ç
if strName is "osascript" then
	tell application "Finder"
		activate
	end tell
else
	tell current application
		activate
	end tell
end if
try
	set listResponse to (choose from list listAppName with title "‘I‚ñ‚Å‚­‚¾‚³‚¢" with prompt "ƒtƒ@ƒCƒ‹‚ğŠJ‚­ƒAƒvƒŠƒP[ƒVƒ‡ƒ“‚ğ‘I‚ñ‚Å‚­‚¾‚³‚¢" default items (item 1 of listAppName) OK button name "OK" cancel button name "ƒLƒƒƒ“ƒZƒ‹" without multiple selections allowed and empty selection allowed)
on error
	log "ƒGƒ‰[‚µ‚Ü‚µ‚½"
	return "ƒGƒ‰[‚µ‚Ü‚µ‚½"
end try
if listResponse is false then
	return "ƒLƒƒƒ“ƒZƒ‹‚µ‚Ü‚µ‚½"
end if
set strResponse to (item 1 of listResponse) as text


################################
##URL‚ğŠJ‚­
################################
###ƒAƒvƒŠƒP[ƒVƒ‡ƒ“‚ÌURL‚ğæ‚èo‚·
set listChooseApp to ocidAppDictionary's objectForKey:(strResponse)
set strOpenAppUTI to (item 2 of listChooseApp) as text
set ocidAppPathURL to (item 1 of listChooseApp)
set ocidAppPath to ocidAppPathURL's |path|()
###ƒoƒ“ƒhƒ‹IDæ“¾
set ocidAppBundle to refMe's NSBundle's bundleWithURL:(ocidAppPathURL)
set ocidBundleID to ocidAppBundle's bundleIdentifier()

###################################
#####PLISTì¬
###################################
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidPlistDict's setValue:(ocidBundleID) forKey:("bundleidentifier")
ocidPlistDict's setValue:(ocidAppPath) forKey:("path")
set ocidVersionNo to (refMe's NSNumber's numberWithInteger:0)
ocidPlistDict's setValue:(ocidVersionNo) forKey:("version")
###‘‚«‚İ—p‚ÉƒoƒCƒiƒŠ[ƒf[ƒ^‚É•ÏŠ·
set ocidNSbplist to refMe's NSPropertyListBinaryFormat_v1_0
set listPlistEditData to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidNSbplist) options:0 |error|:(reference)
set ocidPlistEditData to item 1 of listPlistEditData
###PLIST•Û‘¶æ
tell application "Finder"
	set aliasPathToMe to (path to me) as alias
end tell
set strPathToMe to (POSIX path of aliasPathToMe) as text
set ocidPathToMeStr to refMe's NSString's stringWithString:(strPathToMe)
set ocidPathToMe to ocidPathToMeStr's stringByStandardizingPath()
set ocidPathToMeURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidPathToMe) isDirectory:(false)
set ocidContainerDirPathURL to ocidPathToMeURL's URLByDeletingLastPathComponent()
##PLIST‚ğ•ÛŠÇ‚·‚é‚½‚ß‚ÌƒfƒBƒŒƒNƒgƒŠ
set ocidPlistSaveDirPathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:("Plist")
set ocidPlistSaveDirPath to ocidPlistSaveDirPathURL's |path|()
set boolDirExists to appFileManager's fileExistsAtPath:(ocidPlistSaveDirPath) isDirectory:(true)
##‚È‚¯‚ê‚Îì‚é
if boolDirExists = false then
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions)
	set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidPlistSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
end if
###•Û‘¶‚·‚éƒtƒ@ƒCƒ‹–¼
set strFileName to ((ocidBundleID as text) & ".plist") as text
###PLIST‚ÌƒpƒX
set ocidPlistFilePathURL to ocidPlistSaveDirPathURL's URLByAppendingPathComponent:(strFileName)
set strPlistFilePath to (ocidPlistFilePathURL's |path|()) as text
###PLIST •Û‘¶
set ocidOption to (refMe's NSDataWritingAtomic)
set boolWritetoUrlArray to ocidPlistEditData's writeToURL:(ocidPlistFilePathURL) options:(ocidOption) |error|:(reference)
log item 1 of boolWritetoUrlArray

###################################
#####PLIST‚ÌHEXƒoƒCƒiƒŠ[‚ğæ“¾‚·‚é
###################################
set strCommandText to ("/usr/bin/xxd  -pc €"" & strPlistFilePath & "€"") as text
set strHexPlistData to (do shell script strCommandText)

###################################
#####ƒtƒ@ƒCƒ‹‚Ì”‚¾‚¯ŒJ‚è•Ô‚·
###################################



set strCommandText to ("/usr/bin/xattr -d com.apple.LaunchServices.OpenWith €"" & strAppendAttrFilePath & "€"") as text
try
	(do shell script strCommandText)
	delay 0.25
on error
	try
		set strCommandText to ("/usr/bin/xattr -c com.apple.LaunchServices.OpenWith €"" & strAppendAttrFilePath & "€"") as text
		(do shell script strCommandText)
	end try
end try
set strCommandText to ("/usr/bin/xattr  -w -x  com.apple.LaunchServices.OpenWith €"" & strHexPlistData & "€" €"" & strAppendAttrFilePath & "€"") as text
(do shell script strCommandText)
delay 0.25
set strCommandText to ("/usr/bin/xattr  -w -x com.apple.quarantine nil €"" & strAppendAttrFilePath & "€"") as text
(do shell script strCommandText)
delay 0.25





