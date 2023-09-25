#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
�V���v�� �W�I�R�[�f�B���O 
������w��ԏ��Ȋw������API�𗘗p���Ă��܂�
https://geocode.csis.u-tokyo.ac.jp/ 
���ȉ��̏�񂪎��W����܂�
IP�A�h���X
�A�N�Z�X����
�ϊ��������R�[�h��
�ϊ��ɐ����������R�[�h��
�ϊ��ɗv������������
*)
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##��������os12�Ȃ̂�2.8�ɂ��Ă��邾���ł�
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
property refNSNotFound : a reference to 9.22337203685477E+18 + 5807



#############################
### �N���b�v�{�[�h�̒��g���o��
###������
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidPastBoardTypeArray to ocidPasteboard's types
###�e�L�X�g�������
set boolContain to ocidPastBoardTypeArray's containsObject:"public.utf8-plain-text"
if boolContain = true then
	###�l���i�[����
	tell application "Finder"
		set strReadString to (the clipboard as text) as text
	end tell
	###Finder�ŃG���[������
else
	set boolContain to ocidPastBoardTypeArray's containsObject:"NSStringPboardType"
	if boolContain = true then
		set ocidReadString to ocidPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
		set strReadString to ocidReadString as text
	else
		log "�e�L�X�g�Ȃ�"
		set strReadString to "" as text
	end if
end if
##############################
###�_�C�A���O
set strMes to ("�Z���Ō����r������v���K�v�ł��r�w�w�͕s�v�x�͕i��w�ł͕i��ł���") as text
set strQueryText to strReadString as text
###�O�ʂ�
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set aliasIconPath to POSIX file "/System/Applications/Maps.app/Contents/Resources/AppIcon.icns" as alias
try
	set recordResult to (display dialog strMes with title "�Z���n������" default answer strQueryText buttons {"OK", "�L�����Z��"} default button "OK" with icon aliasIconPath giving up after 20 without hidden answer) as record
	if "OK" is equal to (button returned of recordResult) then
		set strReturnedText to (text returned of recordResult) as text
	else if (gave up of recordResult) is true then
		return "���Ԑ؂�ł�"
	else
		return "�L�����Z��"
	end if
on error
	log "�G���[���܂���"
	return
end try
##############################
###�߂�l���`
set ocidResponseText to (refMe's NSString's stringWithString:(strReturnedText))
###�^�u�Ɖ��s���������Ă���
set ocidTextM to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
ocidTextM's appendString:(ocidResponseText)
##���s����
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("�n") withString:("")
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("�r") withString:("")
##�^�u����
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("�t") withString:("")

##############################
##
set strBaseURL to ("https://geocode.csis.u-tokyo.ac.jp/cgi-bin/simple_geocode.cgi") as text
set ocidURL to refMe's NSURL's alloc()'s initWithString:(strBaseURL)
##�R���|�[�l���g������
set ocidComponents to refMe's NSURLComponents's componentsWithURL:(ocidURL) resolvingAgainstBaseURL:true
##�N�G���[�i�[�pArray
set ocidQueryItemArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
##�������
set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("addr") value:(ocidTextM)
ocidQueryItemArray's addObject:(ocidQueryItem)
##�R�[�h
set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("charset") value:("UTF8")
ocidQueryItemArray's addObject:(ocidQueryItem)
##�v���n
set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("geosys") value:("tokyo")
ocidQueryItemArray's addObject:(ocidQueryItem)
##�w��������STATION ADDRESS 
set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("series") value:("STATION")
ocidQueryItemArray's addObject:(ocidQueryItem)
##AND�����p?�@����͎g��Ȃ�
#	set ocidQueryItem to refMe's NSURLQueryItem's alloc()'s initWithName:("constraint") value:("�_�ސ쌧")
#	ocidQueryItemArray's addObject:(ocidQueryItem)
##
ocidComponents's setQueryItems:(ocidQueryItemArray)
##URL
set ocidAPIURL to ocidComponents's |URL|
log ocidAPIURL's absoluteString() as text

########################################
##HTML ��{�\��
###�X�^�C��
set strStylle to "<style>#bordertable {padding: 10px;width: 100%;margin: 0;border-collapse: collapse;border-spacing: 0;word-wrap: break-word;} #bordertable table { width: 80%;margin: 0px;padding: 0px;border: 0px;border-spacing:0px;border-collapse: collapse;} #bordertable caption { font-weight: 900;} #bordertable thead { font-weight: 600;border-spacing:0px;} #bordertable td {border: solid 1px #666666;padding: 5px;margin: 0px;word-wrap: break-word;border-spacing:0px;} #bordertable tr {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;} #bordertable th {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;}</style>"
###�w�b�_�[��
set strHead to "<!DOCTYPE html><html lang=�"en�"><head><meta charset=�"utf-8�"><title>[�������]" & ocidTextM & "</title>" & strStylle & "</head><body>"
###�Ō�
set strHtmlEndBody to "</body></html>"
###HTML�����o���p�̃e�L�X�g������
set ocidHTMLString to refMe's NSMutableString's alloc()'s initWithCapacity:0
####
(ocidHTMLString's appendString:strHead)


##############################
set recordiLvl to {|1|:"�s���{��", |2|:"�S�E�x���E�U����", |3|:"�s�����E���ʋ�", |4|:"���ߎs�̋�", |5|:"�厚", |6|:"���ځE����", |7|:"�X��E�n��", |8|:"���E�}��", |0|:"���x���s��", |-1|:"���W�s��"} as record
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
###�e�[�u���̊J�n��
set strHTML to ("<div id=�"bordertable�"><table><caption title=�"�^�C�g���">�������F" & ocidTextM & " ��������:" & numChild & "��</caption>") as text
set strHTML to (strHTML & "<thead title=�"���ږ��̀"><tr><th title=�"���ڂP�" scope=�"row�" >�A��</th><th title=�"���ڂQ�" scope=�"col�">�n��</th><th title=�"���ڂR�" scope=�"col�">�����N�P</th><th title=�"���ڂS�"  scope=�"col�">�����N�Q</th><th title=�"���ڂT�"  scope=�"col�"> >�����N�R</th><th title=�"���ڂU�"  scope=�"col�">�����N�S</th><th title=�"���ڂU�"  scope=�"col�">�����N�T</th><th title=�"���ڂV�"  scope=�"col�">iLvl</th></tr></thead><tbody title=�"�������ʈꗗ�" >") as text
(ocidHTMLString's appendString:(strHTML))
##############################
set numLineNo to 1 as integer
###���K�w�����̎q�v�f
repeat with itemCandidate in ocidCandidateArray
	set strAdd to (itemCandidate's elementsForName:("address"))'s stringValue as text
	set strLat to (itemCandidate's elementsForName:("latitude"))'s stringValue as text
	set strLong to (itemCandidate's elementsForName:("longitude"))'s stringValue as text
	set numiLvl to (itemCandidate's elementsForName:("iLvl"))'s stringValue as text
	set striLvl to (ocidiLvlDict's valueForKey:(numiLvl)) as text
	log striLvl
	###�����N�P
	set strMapURL to ("https://www.navitime.co.jp/maps/aroundResult?lat=" & strLat & "&lon=" & strLong & "&type=station&radius=2000")
	set strLINK1 to "<a href=�"" & strMapURL & "�" target=�"_blank�">Navitime Map</a>"
	###�����N�Q
	set strMapURL to ("https://map.yahoo.co.jp/place?lat=" & strLat & "&lon=" & strLong & "&zoom=15&maptype=twoTones")
	set strLINK2 to "<a href=�"" & strMapURL & "�" target=�"_blank�">Yahoo Map</a>"
	###�����N�R
	set strMapURL to ("https://maps.gsi.go.jp/vector/#15/" & strLat & "/" & strLong & "/&ls=vstd&disp=1&d=l")
	set strLINK3 to "<a href=�"" & strMapURL & "�" target=�"_blank�">Gsi vector Map</a>"
	###�����N�S
	set strMapURL to ("https://www.jma.go.jp/bosai/nowc/#lat:" & strLat & "/lon:" & strLong & "/zoom:15/")
	set strLINK4 to "<a href=�"" & strMapURL & "�" target=�"_blank�">Jma Map</a>"
	###�����N�T
	set strEncAdd to doTextEncode(strAdd)
	set strMapURL to ("http://maps.apple.com/?ll=" & strLat & "," & strLong & "&z=10&t=d&q=" & strEncAdd & "")
	set strLINK5 to "<a href=�"" & strMapURL & "�" target=�"_blank�">Apple Map</a>"
	###HTML�ɂ���
	set strHTML to ("<tr><th title=�"�A�Ԁ"  scope=�"row�">" & numLineNo & "</th><td title=�"�n���"><b>" & strAdd & "</b></td><td title=�"�����N�P�">" & strLINK1 & "</td><td title=�"�����N�Q�">" & strLINK2 & "</td><td title=�"�����N�R�">" & strLINK3 & "</td><td title=�"�����N�S�">" & strLINK4 & "</td><td title=�"�����N�T�">" & strLINK5 & "</td><td title=�"iLvl�">" & striLvl & "</td></tr>") as text
	(ocidHTMLString's appendString:(strHTML))
	###�J�E���g�A�b�v	
	set numLineNo to numLineNo + 1 as integer
end repeat


set strHTML to ("</tbody><tfoot><tr><th colspan=�"8�" title=�"�t�b�^�[�\�̏I���"  scope=�"row�"><a href=�"https://geocode.csis.u-tokyo.ac.jp/�" target=�"_blank�">�V���v�� �W�I�R�[�f�B���O</a></th></tr></tfoot></table></div>") as text
####�e�[�u���܂ł�ǉ�
(ocidHTMLString's appendString:(strHTML))
####�I������ǉ�
(ocidHTMLString's appendString:(strHtmlEndBody))

###�f�B���N�g��
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
###�p�X

set strFileName to ((ocidTextM as text) & ".html") as text
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false
###�t�@�C���ɏ����o��
set listDone to ocidHTMLString's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
####�e�L�X�g�G�f�B�^�ŊJ��
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
###### ���G���R�[�h
####################################
on doUrlEncode(argText)
	##�e�L�X�g
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	##�L�����N�^�Z�b�g���w��
	set ocidChrSet to refMe's NSCharacterSet's URLQueryAllowedCharacterSet
	##�L�����N�^�Z�b�g�ŕϊ�
	set ocidArgTextEncoded to ocidArgText's stringByAddingPercentEncodingWithAllowedCharacters:(ocidChrSet)
	##�e�L�X�g�`���Ɋm��
	set strTextToEncode to ocidArgTextEncoded as text
	###�l��߂�
	return strTextToEncode
end doUrlEncode
####################################
###### ���G���R�[�h
####################################
on doTextEncode(argText)
	##�e�L�X�g
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	##�L�����N�^�Z�b�g���w��
	set ocidChrSet to refMe's NSCharacterSet's URLQueryAllowedCharacterSet
	##�L�����N�^�Z�b�g�ŕϊ�
	set ocidArgTextEncoded to ocidArgText's stringByAddingPercentEncodingWithAllowedCharacters:(ocidChrSet)
	######## �u���@���G���R�[�h�̒ǉ�����
	###�u�����R�[�h
	set recordPercentMap to {|!|:"%21", |#|:"%23", |$|:"%24", |&|:"%26", |'|:"%27", |(|:"%28", |)|:"%29", |*|:"%2A", |+|:"%2B", |,|:"%2C", |:|:"%3A", |;|:"%3B", |=|:"%3D", |?|:"%3F", |@|:"%40", | |:"%20"} as record
	###�f�B�N�V���i���ɂ���
	set ocidPercentMap to refMe's NSDictionary's alloc()'s initWithDictionary:(recordPercentMap)
	###�L�[�̈ꗗ�����o���܂�
	set ocidAllKeys to ocidPercentMap's allKeys()
	###���o�����L�[�ꗗ�����Ԃɏ���
	repeat with itemAllKey in ocidAllKeys
		set strItemKey to itemAllKey as text
		##�L�[�̒l�����o����
		if strItemKey is "@" then
			##�u��
			set ocidEncodedText to (ocidArgTextEncoded's stringByReplacingOccurrencesOfString:("@") withString:("%40"))
		else
			set ocidMapValue to (ocidPercentMap's valueForKey:(strItemKey))
			##�u��
			set ocidEncodedText to (ocidArgTextEncoded's stringByReplacingOccurrencesOfString:(strItemKey) withString:(ocidMapValue))
		end if
		
		##���̕ϊ��ɔ�����
		set ocidArgTextEncoded to ocidEncodedText
	end repeat
	##�e�L�X�g�`���Ɋm��
	set strTextToEncode to ocidEncodedText as text
	###�l��߂�
	return strTextToEncode
end doTextEncode
