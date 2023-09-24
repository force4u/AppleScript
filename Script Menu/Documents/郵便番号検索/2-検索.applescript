#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
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
###DB�t�@�C���ւ̃p�X
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
tell current application
	set strName to name as text
end tell
####�X�N���v�g���j���[������s������
if strName is "osascript" then
	tell application "Finder"
		activate
	end tell
else
	tell current application
		activate
	end tell
end if
set strMes to ("�Z���Ō����@�ꕔ���ł��r�_�ސ�Ƃ��Ŏw�肷��ƌ������ʂ������Ȃ�܂�")
set aliasIconPath to POSIX file "/System/Applications/Calculator.app/Contents/Resources/AppIcon.icns" as alias
try
	set recordResult to (display dialog strMes with title "�X�֔ԍ�����" default answer strReadString buttons {"OK", "�L�����Z��"} default button "OK" with icon aliasIconPath giving up after 20 without hidden answer) as record
on error
	log "�G���[���܂���"
	return
end try

if "OK" is equal to (button returned of recordResult) then
	set strReturnedText to (text returned of recordResult) as text
else if (gave up of recordResult) is true then
	return "���Ԑ؂�ł�"
else
	return "�L�����Z��"
end if
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
###�Ђ炪�Ȃ݂̂̏ꍇ�̓J�^�J�i��
set listRegex to refMe's NSRegularExpression's regularExpressionWithPattern:("^[��-��[]+$") options:(0) |error|:(reference)
set ocidRegex to (item 1 of listRegex)
set ocidTextRange to refMe's NSMakeRange(0, (ocidTextM's |length|()))
log ocidTextRange
set numPach to ocidRegex's numberOfMatchesInString:(ocidTextM) options:0 range:(ocidTextRange)
if (numPach as integer) = 1 then
	set ocidTransform to (refMe's NSStringTransformHiraganaToKatakana)
	set ocidTextM to (ocidTextM's stringByApplyingTransform:(ocidTransform) |reverse|:false)
end if
###�������Ȃ���ΑS�p��
set ocidTransform to (refMe's NSStringTransformFullwidthToHalfwidth)
set ocidTextM to (ocidTextM's stringByApplyingTransform:(ocidTransform) |reverse|:true)
########################################
##�J�^�J�i�Ɗ������݂Ō������@���قȂ�
set listRegex to refMe's NSRegularExpression's regularExpressionWithPattern:("^[�@-���[]+$") options:(0) |error|:(reference)
set ocidRegex to (item 1 of listRegex)
set ocidTextRange to refMe's NSMakeRange(0, (ocidTextM's |length|()))
set numPach to ocidRegex's numberOfMatchesInString:(ocidTextM) options:0 range:(ocidTextRange)
set strSearchText to ocidTextM as text
if (numPach as integer) = 1 then
	set strCommandText to ("/usr/bin/sqlite3 �"" & strDbFilePathURL & "�" -tabs �"SELECT * FROM postalcode WHERE prefecture_kana LIKE '%" & strSearchText & "%' OR city_kana LIKE  '%" & strSearchText & "%' OR town_kana LIKE  '%" & strSearchText & "%';�"") as text
	log strCommandText
else
	set strCommandText to ("/usr/bin/sqlite3 �"" & strDbFilePathURL & "�" -tabs �"SELECT * FROM postalcode WHERE prefecture LIKE '%" & strSearchText & "%' OR city LIKE  '%" & strSearchText & "%' OR town LIKE  '%" & strSearchText & "%';�"") as text
	log strCommandText
end if
set strResponse to (do shell script strCommandText) as text


########################################
##
set AppleScript's text item delimiters to "�r"
set listResponse to every text item of strResponse
set AppleScript's text item delimiters to ""

########################################
##HTML ��{�\��
###�X�^�C��
set strStylle to "<style>#bordertable {padding: 10px;width: 100%;margin: 0;border-collapse: collapse;border-spacing: 0;word-wrap: break-word;} #bordertable table { width: 80%;margin: 0px;padding: 0px;border: 0px;border-spacing:0px;border-collapse: collapse;} #bordertable caption { font-weight: 900;} #bordertable thead { font-weight: 600;border-spacing:0px;} #bordertable td {border: solid 1px #666666;padding: 5px;margin: 0px;word-wrap: break-word;border-spacing:0px;} #bordertable tr {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;} #bordertable th {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;}</style>"
###�w�b�_�[��
set strHead to "<!DOCTYPE html><html lang=�"en�"><head><meta charset=�"utf-8�"><title>[�������]" & strSearchText & "</title>" & strStylle & "</head><body>"
###�{�f�B
set strBody to ""
###�Ō�
set strHtmlEndBody to "</body></html>"
###HTML�����o���p�̃e�L�X�g������
set ocidHTMLString to refMe's NSMutableString's alloc()'s initWithCapacity:0
####
(ocidHTMLString's appendString:strHead)
#########
###�e�[�u���̊J�n��
set strHTML to ("<div id=�"bordertable�"><table><caption title=�"�^�C�g���">��������:" & strReturnedText & "</caption>") as text
set strHTML to (strHTML & "<thead title=�"���ږ��̀"><tr><th title=�"���ڂP�" scope=�"row�" > �A�� </th><th title=�"���ڂQ�" scope=�"col�"> �X�֔ԍ� </th><th title=�"���ڂR�" scope=�"col�"> �Z�� </th><th title=�"���ڂS�"  scope=�"col�"> �ǂ� </th><th title=�"���ڂT�"  scope=�"col�">�c�̃R�[�h</th><th title=�"���ڂU�"  scope=�"col�">�����N</th></tr></thead><tbody title=�"�������ʈꗗ�" >") as text
set numLineNo to 1 as integer
repeat with itemLine in listResponse
	set AppleScript's text item delimiters to "�t"
	set listLineText to every text item of itemLine
	set AppleScript's text item delimiters to ""
	
	set strCityCode to (item 1 of listLineText) as text
	set strPostNo to (item 3 of listLineText) as text
	set strAddText to ((item 7 of listLineText) & (item 8 of listLineText) & (item 9 of listLineText)) as text
	set strKana to ((item 4 of listLineText) & (item 5 of listLineText) & (item 6 of listLineText)) as text
	
	set strLinkURL to ("https://www.post.japanpost.jp/cgi-zip/zipcode.php?zip=" & strPostNo & "")
	set strMapURL to ("https://www.google.com/maps/search/�X�֔ԍ�+" & strPostNo & "")
	set strMapAppURL to ("http://maps.apple.com/?q=�X�֔ԍ�+" & strPostNo & "")
	set strLINK to "<a href=�"" & strLinkURL & "�" target=�"_blank�">�X��</a>&nbsp;|&nbsp;<a href=�"" & strMapURL & "�" target=�"_blank�">Google</a>&nbsp;|&nbsp;<a href=�"" & strMapAppURL & "�" target=�"_blank�">Map</a>"
	
	set strHTML to (strHTML & "<tr><th title=�"���ԂP�"  scope=�"row�">" & numLineNo & "</th><td title=�"���ڂQ�"><b>" & strPostNo & "</b></td><td title=�"���ڂR�">" & strAddText & "</td><td title=�"���ڂS�"><small>" & strKana & "</small></td><td title=�"���ڂT�">" & strCityCode & "</td><td title=�"���ڂU�">" & strLINK & "</td></tr>") as text
	
	set numLineNo to numLineNo + 1 as integer
end repeat


set strHTML to (strHTML & "</tbody><tfoot><tr><th colspan=�"6�" title=�"�t�b�^�[�\�̏I���"  scope=�"row�">post.japanpost.jp</th></tr></tfoot></table></div>") as text
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

set strFileName to (strSearchText & ".html") as text
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