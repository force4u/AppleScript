#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application



set strMes to ("cƒTƒCƒY‚ğ“ü—Í") as text

########################
## ƒNƒŠƒbƒvƒ{[ƒh‚Ì’†gæ‚èo‚µ
########################
###‰Šú‰»
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidPastBoardTypeArray to ocidPasteboard's types
###ƒeƒLƒXƒg‚ª‚ ‚ê‚Î
set boolContain to ocidPastBoardTypeArray's containsObject:"public.utf8-plain-text"
if boolContain = true then
	###’l‚ğŠi”[‚·‚é
	tell application "Finder"
		set strReadString to (the clipboard as text) as text
	end tell
	###Finder‚ÅƒGƒ‰[‚µ‚½‚ç
else
	set boolContain to ocidPastBoardTypeArray's containsObject:"NSStringPboardType"
	if boolContain = true then
		set ocidReadString to ocidPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
		set strReadString to ocidReadString as text
	else
		log "ƒeƒLƒXƒg‚È‚µ"
		set strReadString to "1" as text
	end if
end if
##############################
#####ƒ_ƒCƒAƒƒO
##############################
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
set aliasIconPath to POSIX file "/System/Applications/Calculator.app/Contents/Resources/AppIcon.icns" as alias
try
	set recordResult to (display dialog strMes with title "“ü—Í‚µ‚Ä‚­‚¾‚³‚¢" default answer strReadString buttons {"OK", "ƒLƒƒƒ“ƒZƒ‹"} default button "OK" with icon aliasIconPath giving up after 10 without hidden answer) as record
on error
	log "ƒGƒ‰[‚µ‚Ü‚µ‚½"
	return
end try

if "OK" is equal to (button returned of recordResult) then
	set strReturnedText to (text returned of recordResult) as text
else if (gave up of recordResult) is true then
	return "ŠÔØ‚ê‚Å‚·"
else
	return "ƒLƒƒƒ“ƒZƒ‹"
end if
##############################
#####–ß‚è’l®Œ`
##############################
set ocidResponseText to (refMe's NSString's stringWithString:(strReturnedText))
###ƒ^ƒu‚Æ‰üs‚ğœ‹‚µ‚Ä‚¨‚­
set ocidTextM to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
ocidTextM's appendString:(ocidResponseText)
##‰üsœ‹
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("€n") withString:("")
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("€r") withString:("")
##ƒ^ƒuœ‹
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("€t") withString:("")
####–ß‚è’l‚ğ”¼Šp‚É‚·‚é
set ocidNSStringTransform to (refMe's NSStringTransformFullwidthToHalfwidth)
set ocidTextM to (ocidTextM's stringByApplyingTransform:ocidNSStringTransform |reverse|:false)
##ƒJƒ“ƒ}’uŠ·
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:(",") withString:(".")
###”šˆÈŠO‚Ì’l‚ğæ‚é
#set ocidDecSet to refMe's NSCharacterSet's decimalDigitCharacterSet
#set ocidCharSet to ocidDecSet's invertedSet()
#set ocidCharArray to ocidResponseHalfwidth's componentsSeparatedByCharactersInSet:ocidCharSet
#set ocidInteger to ocidCharArray's componentsJoinedByString:""
###ƒeƒLƒXƒg‚É‚µ‚Ä‚©‚ç
set strTextM to ocidTextM as text
###”’l‚É
set strResponse to strTextM as number


##############################
#####HTML•”
##############################
###ƒXƒ^ƒCƒ‹
set strStylle to "<style>html {font-family: €"Osaka-Mono€",monospace;font-size: 24px;} #bordertable {padding: 10px;width: 100%;margin: 0;border-collapse: collapse;border-spacing: 0;word-wrap: break-word;} #bordertable table { width: 580px;margin: 0px;padding: 0px;border: 0px;border-spacing:0px;border-collapse: collapse;} #bordertable caption { font-weight: 900;} #bordertable thead { font-weight: 600;border-spacing:0px;} #bordertable td {border: solid 1px #666666;padding: 3px;margin: 0px;word-wrap: break-word;border-spacing:0px;} #bordertable tr {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;} #bordertable th {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;}</style>"
###ƒwƒbƒ_[•”
set strHead to "<!DOCTYPE html><html lang=€"en€"><head><meta charset=€"utf-8€"><title>[’PˆÊŠ·Z] Aspect Ratio</title>" & strStylle & "</head><body>"
###ÅŒã
set strHtmlEndBody to "</body></html>"

###HTML‘‚«o‚µ—p‚ÌƒeƒLƒXƒg‰Šú‰»
set ocidHTMLString to refMe's NSMutableString's alloc()'s initWithCapacity:0
####body‚Ü‚Å‚ğ’Ç‰Á
(ocidHTMLString's appendString:(strHead))
###ƒe[ƒuƒ‹‚ÌŠJn•”
set strHTML to ("<div id=€"bordertable€"><table><caption>’PˆÊŠ·Z Aspect Ratio</caption>") as text
set strHTML to (strHTML & "<thead title=€"€–Ú–¼Ì€"><tr><th title=€"‘ã•\“I‚ÈŒÄÌ€" scope=€"row€" >‘ã•\“I‚ÈŒÄÌ</th><th title=€"Aspect Ratio€">c‰¡”ä</th><th title=€"‰¡€" scope=€"col€">‰¡</th><th title=€"c€"  scope=€"col€">c</th></tr></thead><tbody title=€"c‰¡”ä‚Ì•\€" >") as text
##############################
#####ŒvZ•”
##############################
##€–Ú‚ğ‘‚â‚·ê‡‚Í‚±‚ÌƒŒƒR[ƒh‚ğ‘‚â‚¹‚ÎOK
set recordAspectRatio to {|01:SXGA|:{5, 4}, |02:XGA|:{4, 3}, |03:QWUXGA|:{16, 10}, |04:WQHD|:{16, 9}, |05:Cinema|:{256, 135}} as record
set ocidAspectRatioDict to refMe's NSDictionary's alloc()'s initWithDictionary:(recordAspectRatio)
set ocidAllKeys to ocidAspectRatioDict's allKeys()
set ocidDescriptor to refMe's NSSortDescriptor's sortDescriptorWithKey:("self") ascending:(true) selector:"localizedStandardCompare:"
set ocidAllKeys to ocidAllKeys's sortedArrayUsingDescriptors:({ocidDescriptor})

repeat with itemAllKeys in ocidAllKeys
	set strAllKeys to itemAllKeys as text
	log strAllKeys
	set ocidAspectRatioArray to (ocidAspectRatioDict's objectForKey:(itemAllKeys))
	###w”æ‚èo‚µ
	set numRatioW to (ocidAspectRatioArray's firstObject()) as integer
	set numRatioH to (ocidAspectRatioArray's lastObject()) as integer
	set numRealW to ((strResponse * numRatioW) / numRatioH) as integer
	#	log numRealW
	set strAspectRatio to (numRatioW & "x" & numRatioH) as text
	set strHTML to (strHTML & "<tr><td title=€"‘ã•\“I‚ÈŒÄÌ€">" & strAllKeys & "</td><td title=€"Aspect Ratio€">" & strAspectRatio & "</td><td title=€"‰¡€">" & numRealW & "</td><td title=€"c€">" & strResponse & "</td></tr>") as text
end repeat

set strHTML to (strHTML & "</tbody><tfoot></tfoot></table></div>") as text
####ƒe[ƒuƒ‹‚Ü‚Å‚ğ’Ç‰Á
(ocidHTMLString's appendString:(strHTML))
####I—¹•”‚ğ’Ç‰Á
(ocidHTMLString's appendString:(strHtmlEndBody))
##############################
#####o—Í•”
##############################
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
###
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)

###•Û‘¶ƒpƒX
set strFileName to "H2W.html" as text
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false
####
###ƒtƒ@ƒCƒ‹‚É‘‚«o‚µ
set listDone to ocidHTMLString's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
####ƒeƒLƒXƒgƒGƒfƒBƒ^‚ÅŠJ‚­
set aliasFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias

tell application "TextEdit"
	activate
	open file aliasFilePath
end tell


