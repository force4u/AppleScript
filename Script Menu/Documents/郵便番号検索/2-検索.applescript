#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##©•ªŠÂ‹«‚ªos12‚È‚Ì‚Å2.8‚É‚µ‚Ä‚¢‚é‚¾‚¯‚Å‚·
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
property refNSNotFound : a reference to 9.22337203685477E+18 + 5807


#############################
###DBƒtƒ@ƒCƒ‹‚Ö‚ÌƒpƒX
tell application "Finder"
	set aliasPathToMe to (path to me) as alias
	set aliasContainerDirPath to (container of aliasPathToMe) as alias
end tell
set strContainerDirPath to (POSIX path of aliasContainerDirPath) as text
set ocidContainerDirPathStr to refMe's NSString's stringWithString:(strContainerDirPath)
set ocidContainerDirPath to ocidContainerDirPathStr's stringByStandardizingPath()
set ocidContainerDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidContainerDirPath) isDirectory:true)
set ocidDBFilePathURL to ocidContainerDirPathURL's URLByAppendingPathComponent:("data/postno.db")
set strDbFilePathURL to (ocidDBFilePathURL's |path|()) as text
#############################
### ƒNƒŠƒbƒvƒ{[ƒh‚Ì’†gæ‚èo‚µ
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
		set strReadString to "" as text
	end if
end if
##############################
###ƒ_ƒCƒAƒƒO
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
set strMes to ("ZŠ‚ÅŒŸõ@ˆê•”•ª‚Å‚à‰Â€r_“Şì‚Æ‚©‚Åw’è‚·‚é‚ÆŒŸõŒ‹‰Ê‚ª‘½‚­‚È‚è‚Ü‚·")
set aliasIconPath to POSIX file "/System/Applications/Calculator.app/Contents/Resources/AppIcon.icns" as alias
try
	set recordResult to (display dialog strMes with title "—X•Ö”Ô†ŒŸõ" default answer strReadString buttons {"OK", "ƒLƒƒƒ“ƒZƒ‹"} default button "OK" with icon aliasIconPath giving up after 20 without hidden answer) as record
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
###–ß‚è’l®Œ`
set ocidResponseText to (refMe's NSString's stringWithString:(strReturnedText))
###ƒ^ƒu‚Æ‰üs‚ğœ‹‚µ‚Ä‚¨‚­
set ocidTextM to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
ocidTextM's appendString:(ocidResponseText)
##‰üsœ‹
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("€n") withString:("")
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("€r") withString:("")
##ƒ^ƒuœ‹
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("€t") withString:("")
##############################
###‚Ğ‚ç‚ª‚È‚Ì‚İ‚Ìê‡‚ÍƒJƒ^ƒJƒi‚É
set listRegex to refMe's NSRegularExpression's regularExpressionWithPattern:("^[‚Ÿ-‚ñ[]+$") options:(0) |error|:(reference)
set ocidRegex to (item 1 of listRegex)
set ocidTextRange to refMe's NSMakeRange(0, (ocidTextM's |length|()))
log ocidTextRange
set numPach to ocidRegex's numberOfMatchesInString:(ocidTextM) options:0 range:(ocidTextRange)
if (numPach as integer) = 1 then
	set ocidTransform to (refMe's NSStringTransformHiraganaToKatakana)
	set ocidTextM to (ocidTextM's stringByApplyingTransform:(ocidTransform) |reverse|:false)
end if
###”š‚ª‚È‚¯‚ê‚Î‘SŠp‚É
set ocidTransform to (refMe's NSStringTransformFullwidthToHalfwidth)
set ocidTextM to (ocidTextM's stringByApplyingTransform:(ocidTransform) |reverse|:true)
########################################
##ƒJƒ^ƒJƒi‚ÆŠ¿š¬İ‚ÅŒŸõ•û–@‚ªˆÙ‚È‚é
set listRegex to refMe's NSRegularExpression's regularExpressionWithPattern:("^[ƒ@-ƒ–[]+$") options:(0) |error|:(reference)
set ocidRegex to (item 1 of listRegex)
set ocidTextRange to refMe's NSMakeRange(0, (ocidTextM's |length|()))
set numPach to ocidRegex's numberOfMatchesInString:(ocidTextM) options:0 range:(ocidTextRange)
set strSearchText to ocidTextM as text
if (numPach as integer) = 1 then
	set strCommandText to ("/usr/bin/sqlite3 €"" & strDbFilePathURL & "€" -tabs €"SELECT * FROM postalcode WHERE prefecture_kana LIKE '%" & strSearchText & "%' OR city_kana LIKE  '%" & strSearchText & "%' OR town_kana LIKE  '%" & strSearchText & "%';€"") as text
	log strCommandText
else
	set strCommandText to ("/usr/bin/sqlite3 €"" & strDbFilePathURL & "€" -tabs €"SELECT * FROM postalcode WHERE prefecture LIKE '%" & strSearchText & "%' OR city LIKE  '%" & strSearchText & "%' OR town LIKE  '%" & strSearchText & "%';€"") as text
	log strCommandText
end if
set strResponse to (do shell script strCommandText) as text


########################################
##
set AppleScript's text item delimiters to "€r"
set listResponse to every text item of strResponse
set AppleScript's text item delimiters to ""

########################################
##HTML Šî–{\‘¢
###ƒXƒ^ƒCƒ‹
set strStylle to "<style>#bordertable {padding: 10px;width: 100%;margin: 0;border-collapse: collapse;border-spacing: 0;word-wrap: break-word;} #bordertable table { width: 80%;margin: 0px;padding: 0px;border: 0px;border-spacing:0px;border-collapse: collapse;} #bordertable caption { font-weight: 900;} #bordertable thead { font-weight: 600;border-spacing:0px;} #bordertable td {border: solid 1px #666666;padding: 5px;margin: 0px;word-wrap: break-word;border-spacing:0px;} #bordertable tr {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;} #bordertable th {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;}</style>"
###ƒwƒbƒ_[•”
set strHead to "<!DOCTYPE html><html lang=€"en€"><head><meta charset=€"utf-8€"><title>[ŒŸõŒê‹å]" & strSearchText & "</title>" & strStylle & "</head><body>"
###ƒ{ƒfƒB
set strBody to ""
###ÅŒã
set strHtmlEndBody to "</body></html>"
###HTML‘‚«o‚µ—p‚ÌƒeƒLƒXƒg‰Šú‰»
set ocidHTMLString to refMe's NSMutableString's alloc()'s initWithCapacity:0
####
(ocidHTMLString's appendString:strHead)
#########
###ƒe[ƒuƒ‹‚ÌŠJn•”
set strHTML to ("<div id=€"bordertable€"><table><caption title=€"ƒ^ƒCƒgƒ‹€">ŒŸõŒ‹‰Ê:" & strReturnedText & "</caption>") as text
set strHTML to (strHTML & "<thead title=€"€–Ú–¼Ì€"><tr><th title=€"€–Ú‚P€" scope=€"row€" > ˜A”Ô </th><th title=€"€–Ú‚Q€" scope=€"col€"> —X•Ö”Ô† </th><th title=€"€–Ú‚R€" scope=€"col€"> ZŠ </th><th title=€"€–Ú‚S€"  scope=€"col€"> “Ç‚İ </th><th title=€"€–Ú‚T€"  scope=€"col€">’c‘ÌƒR[ƒh</th><th title=€"€–Ú‚U€"  scope=€"col€">ƒŠƒ“ƒN</th></tr></thead><tbody title=€"ŒŸõŒ‹‰Êˆê——€" >") as text
set numLineNo to 1 as integer
repeat with itemLine in listResponse
	set AppleScript's text item delimiters to "€t"
	set listLineText to every text item of itemLine
	set AppleScript's text item delimiters to ""
	
	set strCityCode to (item 1 of listLineText) as text
	set strPostNo to (item 3 of listLineText) as text
	set strAddText to ((item 7 of listLineText) & (item 8 of listLineText) & (item 9 of listLineText)) as text
	set strKana to ((item 4 of listLineText) & (item 5 of listLineText) & (item 6 of listLineText)) as text
	
	set strLinkURL to ("https://www.post.japanpost.jp/cgi-zip/zipcode.php?zip=" & strPostNo & "")
	set strMapURL to ("https://www.google.com/maps/search/—X•Ö”Ô†+" & strPostNo & "")
	set strMapAppURL to ("http://maps.apple.com/?q=—X•Ö”Ô†+" & strPostNo & "")
	set strLINK to "<a href=€"" & strLinkURL & "€" target=€"_blank€">—X­</a>&nbsp;|&nbsp;<a href=€"" & strMapURL & "€" target=€"_blank€">Google</a>&nbsp;|&nbsp;<a href=€"" & strMapAppURL & "€" target=€"_blank€">Map</a>"
	
	set strHTML to (strHTML & "<tr><th title=€"€”Ô‚P€"  scope=€"row€">" & numLineNo & "</th><td title=€"€–Ú‚Q€"><b>" & strPostNo & "</b></td><td title=€"€–Ú‚R€">" & strAddText & "</td><td title=€"€–Ú‚S€"><small>" & strKana & "</small></td><td title=€"€–Ú‚T€">" & strCityCode & "</td><td title=€"€–Ú‚U€">" & strLINK & "</td></tr>") as text
	
	set numLineNo to numLineNo + 1 as integer
end repeat


set strHTML to (strHTML & "</tbody><tfoot><tr><th colspan=€"6€" title=€"ƒtƒbƒ^[•\‚ÌI‚í‚è€"  scope=€"row€">post.japanpost.jp</th></tr></tfoot></table></div>") as text
####ƒe[ƒuƒ‹‚Ü‚Å‚ğ’Ç‰Á
(ocidHTMLString's appendString:(strHTML))
####I—¹•”‚ğ’Ç‰Á
(ocidHTMLString's appendString:(strHtmlEndBody))

###ƒfƒBƒŒƒNƒgƒŠ
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###ƒpƒX

set strFileName to (strSearchText & ".html") as text
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false
###ƒtƒ@ƒCƒ‹‚É‘‚«o‚µ
set listDone to ocidHTMLString's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
####ƒeƒLƒXƒgƒGƒfƒBƒ^‚ÅŠJ‚­
set aliasFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
(*
tell application "TextEdit"
	activate
	open file aliasFilePath
end tell
*)
tell application "Safari"
	activate
	open file aliasFilePath
end tell