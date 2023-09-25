#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
ƒVƒ“ƒvƒ‹ ƒWƒIƒR[ƒfƒBƒ“ƒO 
“Œ‹‘åŠw‹óŠÔî•ñ‰ÈŠwŒ¤‹†‚ÌAPI‚ğ—˜—p‚µ‚Ä‚¢‚Ü‚·
https://geocode.csis.u-tokyo.ac.jp/ 
¦ˆÈ‰º‚Ìî•ñ‚ªûW‚³‚ê‚Ü‚·
IPƒAƒhƒŒƒX
ƒAƒNƒZƒX
•ÏŠ·‚µ‚½ƒŒƒR[ƒh”
•ÏŠ·‚É¬Œ÷‚µ‚½ƒŒƒR[ƒh”
•ÏŠ·‚É—v‚µ‚½ˆ—ŠÔ
*)
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
set strMes to ("ZŠ‚ÅŒŸõ€r•”•ªˆê’v‚ª•K—v‚Å‚·€rw‰w‚Í•s—vx‚Í•iì‰w‚Å‚Í•iì‚Å‚à‰Â") as text
set strQueryText to strReadString as text
###‘O–Ê‚É
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set aliasIconPath to POSIX file "/System/Applications/Maps.app/Contents/Resources/AppIcon.icns" as alias
try
	set recordResult to (display dialog strMes with title "ZŠ’n–¼ŒŸõ" default answer strQueryText buttons {"OK", "ƒLƒƒƒ“ƒZƒ‹"} default button "OK" with icon aliasIconPath giving up after 20 without hidden answer) as record
	if "OK" is equal to (button returned of recordResult) then
		set strReturnedText to (text returned of recordResult) as text
	else if (gave up of recordResult) is true then
		return "ŠÔØ‚ê‚Å‚·"
	else
		return "ƒLƒƒƒ“ƒZƒ‹"
	end if
on error
	log "ƒGƒ‰[‚µ‚Ü‚µ‚½"
	return
end try
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
##
set strBaseURL to ("https://geocode.csis.u-tokyo.ac.jp/cgi-bin/simple_geocode.cgi") as text
set ocidURL to refMe's NSURL's alloc()'s initWithString:(strBaseURL)
##ƒRƒ“ƒ|[ƒlƒ“ƒg‰Šú‰»
set ocidComponents to refMe's NSURLComponents's componentsWithURL:(ocidURL) resolvingAgainstBaseURL:true
##ƒNƒGƒŠ[Ši”[—pArray
set ocidQueryItemArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
##ŒŸõŒê‹å
set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("addr") value:(ocidTextM)
ocidQueryItemArray's addObject:(ocidQueryItem)
##ƒR[ƒh
set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("charset") value:("UTF8")
ocidQueryItemArray's addObject:(ocidQueryItem)
##Œv‘ªŒn
set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("geosys") value:("tokyo")
ocidQueryItemArray's addObject:(ocidQueryItem)
##‰w–¼ŒŸõ‚ÍSTATION ADDRESS 
set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("series") value:("STATION")
ocidQueryItemArray's addObject:(ocidQueryItem)
##ANDŒŸõ—p?@¡‰ñ‚Íg‚í‚È‚¢
#	set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("constraint") value:("_“ŞìŒ§")
#	ocidQueryItemArray's addObject:(ocidQueryItem)
##
ocidComponents's setQueryItems:(ocidQueryItemArray)
##URL
set ocidAPIURL to ocidComponents's |URL|
log ocidAPIURL's absoluteString() as text

########################################
##HTML Šî–{\‘¢
###ƒXƒ^ƒCƒ‹
set strStylle to "<style>#bordertable {padding: 10px;width: 100%;margin: 0;border-collapse: collapse;border-spacing: 0;word-wrap: break-word;} #bordertable table { width: 80%;margin: 0px;padding: 0px;border: 0px;border-spacing:0px;border-collapse: collapse;} #bordertable caption { font-weight: 900;} #bordertable thead { font-weight: 600;border-spacing:0px;} #bordertable td {border: solid 1px #666666;padding: 5px;margin: 0px;word-wrap: break-word;border-spacing:0px;} #bordertable tr {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;} #bordertable th {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;}</style>"
###ƒwƒbƒ_[•”
set strHead to "<!DOCTYPE html><html lang=€"en€"><head><meta charset=€"utf-8€"><title>[ŒŸõŒê‹å]" & ocidTextM & "</title>" & strStylle & "</head><body>"
###ÅŒã
set strHtmlEndBody to "</body></html>"
###HTML‘‚«o‚µ—p‚ÌƒeƒLƒXƒg‰Šú‰»
set ocidHTMLString to refMe's NSMutableString's alloc()'s initWithCapacity:0
####
(ocidHTMLString's appendString:strHead)


##############################
set recordiLvl to {|1|:"“s“¹•{Œ§", |2|:"ŒSEx’¡EU‹»‹Ç", |3|:"s’¬‘ºE“Á•Ê‹æ", |4|:"­—ßs‚Ì‹æ", |5|:"‘åš", |6|:"’š–ÚE¬š", |7|:"ŠX‹æE’n”Ô", |8|:"†E}”Ô", |0|:"ƒŒƒxƒ‹•s–¾", |-1|:"À•W•s–¾"} as record
set ocidiLvlDict to refMe's NSDictionary's alloc()'s initWithDictionary:(recordiLvl)
###
set ocidOption to (refMe's NSXMLDocumentTidyXML)
set listReadXMLDoc to refMe's NSXMLDocument's alloc()'s initWithContentsOfURL:(ocidAPIURL) options:(ocidOption) |error|:(reference)
set ocidReadXMLDoc to (item 1 of listReadXMLDoc)
###ROOT
set ocidRootElement to ocidReadXMLDoc's rootElement()
log (ocidRootElement's elementsForName:("query"))'s stringValue as text
log (ocidRootElement's elementsForName:("geodetic"))'s stringValue as text
log (ocidRootElement's elementsForName:("iConf"))'s stringValue as text
log (ocidRootElement's elementsForName:("converted"))'s stringValue as text
set listCandidateArray to ocidRootElement's nodesForXPath:("//candidate") |error|:(reference)
set ocidCandidateArray to (item 1 of listCandidateArray)
set numChild to (count of ocidCandidateArray) as integer

#########
###ƒe[ƒuƒ‹‚ÌŠJn•”
set strHTML to ("<div id=€"bordertable€"><table><caption title=€"ƒ^ƒCƒgƒ‹€">ŒŸõŒê‹åF" & ocidTextM & " ŒŸõŒ‹‰Ê:" & numChild & "Œ</caption>") as text
set strHTML to (strHTML & "<thead title=€"€–Ú–¼Ì€"><tr><th title=€"€–Ú‚P€" scope=€"row€" >˜A”Ô</th><th title=€"€–Ú‚Q€" scope=€"col€">’n–¼</th><th title=€"€–Ú‚R€" scope=€"col€">ƒŠƒ“ƒN‚P</th><th title=€"€–Ú‚S€"  scope=€"col€">ƒŠƒ“ƒN‚Q</th><th title=€"€–Ú‚T€"  scope=€"col€"> >ƒŠƒ“ƒN‚R</th><th title=€"€–Ú‚U€"  scope=€"col€">ƒŠƒ“ƒN‚S</th><th title=€"€–Ú‚U€"  scope=€"col€">ƒŠƒ“ƒN‚T</th><th title=€"€–Ú‚V€"  scope=€"col€">iLvl</th></tr></thead><tbody title=€"ŒŸõŒ‹‰Êˆê——€" >") as text
(ocidHTMLString's appendString:(strHTML))
##############################
set numLineNo to 1 as integer
###‘æˆêŠK‘w‚¾‚¯‚Ìq—v‘f
repeat with itemCandidate in ocidCandidateArray
	set strAdd to (itemCandidate's elementsForName:("address"))'s stringValue as text
	set strLat to (itemCandidate's elementsForName:("latitude"))'s stringValue as text
	set strLong to (itemCandidate's elementsForName:("longitude"))'s stringValue as text
	set numiLvl to (itemCandidate's elementsForName:("iLvl"))'s stringValue as text
	set striLvl to (ocidiLvlDict's valueForKey:(numiLvl)) as text
	log striLvl
	###ƒŠƒ“ƒN‚P
	set strMapURL to ("https://www.navitime.co.jp/maps/aroundResult?lat=" & strLat & "&lon=" & strLong & "&type=station&radius=2000")
	set strLINK1 to "<a href=€"" & strMapURL & "€" target=€"_blank€">Navitime Map</a>"
	###ƒŠƒ“ƒN‚Q
	set strMapURL to ("https://map.yahoo.co.jp/place?lat=" & strLat & "&lon=" & strLong & "&zoom=15&maptype=twoTones")
	set strLINK2 to "<a href=€"" & strMapURL & "€" target=€"_blank€">Yahoo Map</a>"
	###ƒŠƒ“ƒN‚R
	set strMapURL to ("https://maps.gsi.go.jp/vector/#15/" & strLat & "/" & strLong & "/&ls=vstd&disp=1&d=l")
	set strLINK3 to "<a href=€"" & strMapURL & "€" target=€"_blank€">Gsi vector Map</a>"
	###ƒŠƒ“ƒN‚S
	set strMapURL to ("https://www.jma.go.jp/bosai/nowc/#lat:" & strLat & "/lon:" & strLong & "/zoom:15/")
	set strLINK4 to "<a href=€"" & strMapURL & "€" target=€"_blank€">Jma Map</a>"
	###ƒŠƒ“ƒN‚T
	set strEncAdd to doTextEncode(strAdd)
	set strMapURL to ("http://maps.apple.com/?ll=" & strLat & "," & strLong & "&z=10&t=d&q=" & strEncAdd & "")
	set strLINK5 to "<a href=€"" & strMapURL & "€" target=€"_blank€">Apple Map</a>"
	###HTML‚É‚µ‚Ä
	set strHTML to ("<tr><th title=€"˜A”Ô€"  scope=€"row€">" & numLineNo & "</th><td title=€"’n–¼€"><b>" & strAdd & "</b></td><td title=€"ƒŠƒ“ƒN‚P€">" & strLINK1 & "</td><td title=€"ƒŠƒ“ƒN‚Q€">" & strLINK2 & "</td><td title=€"ƒŠƒ“ƒN‚R€">" & strLINK3 & "</td><td title=€"ƒŠƒ“ƒN‚S€">" & strLINK4 & "</td><td title=€"ƒŠƒ“ƒN‚T€">" & strLINK5 & "</td><td title=€"iLvl€">" & striLvl & "</td></tr>") as text
	(ocidHTMLString's appendString:(strHTML))
	###ƒJƒEƒ“ƒgƒAƒbƒv	
	set numLineNo to numLineNo + 1 as integer
end repeat


set strHTML to ("</tbody><tfoot><tr><th colspan=€"8€" title=€"ƒtƒbƒ^[•\‚ÌI‚í‚è€"  scope=€"row€"><a href=€"https://geocode.csis.u-tokyo.ac.jp/€" target=€"_blank€">ƒVƒ“ƒvƒ‹ ƒWƒIƒR[ƒfƒBƒ“ƒO</a></th></tr></tfoot></table></div>") as text
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

set strFileName to ((ocidTextM as text) & ".html") as text
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




####################################
###### “ƒGƒ“ƒR[ƒh
####################################
on doUrlEncode(argText)
	##ƒeƒLƒXƒg
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	##ƒLƒƒƒ‰ƒNƒ^ƒZƒbƒg‚ğw’è
	set ocidChrSet to refMe's NSCharacterSet's URLQueryAllowedCharacterSet
	##ƒLƒƒƒ‰ƒNƒ^ƒZƒbƒg‚Å•ÏŠ·
	set ocidArgTextEncoded to ocidArgText's stringByAddingPercentEncodingWithAllowedCharacters:(ocidChrSet)
	##ƒeƒLƒXƒgŒ`®‚ÉŠm’è
	set strTextToEncode to ocidArgTextEncoded as text
	###’l‚ğ–ß‚·
	return strTextToEncode
end doUrlEncode
####################################
###### “ƒGƒ“ƒR[ƒh
####################################
on doTextEncode(argText)
	##ƒeƒLƒXƒg
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	##ƒLƒƒƒ‰ƒNƒ^ƒZƒbƒg‚ğw’è
	set ocidChrSet to refMe's NSCharacterSet's URLQueryAllowedCharacterSet
	##ƒLƒƒƒ‰ƒNƒ^ƒZƒbƒg‚Å•ÏŠ·
	set ocidArgTextEncoded to ocidArgText's stringByAddingPercentEncodingWithAllowedCharacters:(ocidChrSet)
	######## ’uŠ·@“ƒGƒ“ƒR[ƒh‚Ì’Ç‰Áˆ—
	###’uŠ·ƒŒƒR[ƒh
	set recordPercentMap to {|!|:"%21", |#|:"%23", |$|:"%24", |&|:"%26", |'|:"%27", |(|:"%28", |)|:"%29", |*|:"%2A", |+|:"%2B", |,|:"%2C", |:|:"%3A", |;|:"%3B", |=|:"%3D", |?|:"%3F", |@|:"%40", | |:"%20"} as record
	###ƒfƒBƒNƒVƒ‡ƒiƒŠ‚É‚µ‚Ä
	set ocidPercentMap to refMe's NSDictionary's alloc()'s initWithDictionary:(recordPercentMap)
	###ƒL[‚Ìˆê——‚ğæ‚èo‚µ‚Ü‚·
	set ocidAllKeys to ocidPercentMap's allKeys()
	###æ‚èo‚µ‚½ƒL[ˆê——‚ğ‡”Ô‚Éˆ—
	repeat with itemAllKey in ocidAllKeys
		set strItemKey to itemAllKey as text
		##ƒL[‚Ì’l‚ğæ‚èo‚µ‚Ä
		if strItemKey is "@" then
			##’uŠ·
			set ocidEncodedText to (ocidArgTextEncoded's stringByReplacingOccurrencesOfString:("@") withString:("%40"))
		else
			set ocidMapValue to (ocidPercentMap's valueForKey:(strItemKey))
			##’uŠ·
			set ocidEncodedText to (ocidArgTextEncoded's stringByReplacingOccurrencesOfString:(strItemKey) withString:(ocidMapValue))
		end if
		
		##Ÿ‚Ì•ÏŠ·‚É”õ‚¦‚é
		set ocidArgTextEncoded to ocidEncodedText
	end repeat
	##ƒeƒLƒXƒgŒ`®‚ÉŠm’è
	set strTextToEncode to ocidEncodedText as text
	###’l‚ğ–ß‚·
	return strTextToEncode
end doTextEncode
