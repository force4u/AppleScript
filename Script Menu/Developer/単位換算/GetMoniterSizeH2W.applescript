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



set strMes to ("�c�T�C�Y�����") as text

########################
## �N���b�v�{�[�h�̒��g���o��
########################
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
		set strReadString to "1" as text
	end if
end if
##############################
#####�_�C�A���O
##############################
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
set aliasIconPath to POSIX file "/System/Applications/Calculator.app/Contents/Resources/AppIcon.icns" as alias
try
	set recordResult to (display dialog strMes with title "���͂��Ă�������" default answer strReadString buttons {"OK", "�L�����Z��"} default button "OK" with icon aliasIconPath giving up after 10 without hidden answer) as record
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
#####�߂�l���`
##############################
set ocidResponseText to (refMe's NSString's stringWithString:(strReturnedText))
###�^�u�Ɖ��s���������Ă���
set ocidTextM to refMe's NSMutableString's alloc()'s initWithCapacity:(0)
ocidTextM's appendString:(ocidResponseText)
##���s����
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("�n") withString:("")
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("�r") withString:("")
##�^�u����
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:("�t") withString:("")
####�߂�l�𔼊p�ɂ���
set ocidNSStringTransform to (refMe's NSStringTransformFullwidthToHalfwidth)
set ocidTextM to (ocidTextM's stringByApplyingTransform:ocidNSStringTransform |reverse|:false)
##�J���}�u��
set ocidTextM to ocidTextM's stringByReplacingOccurrencesOfString:(",") withString:(".")
###�����ȊO�̒l�����
#set ocidDecSet to refMe's NSCharacterSet's decimalDigitCharacterSet
#set ocidCharSet to ocidDecSet's invertedSet()
#set ocidCharArray to ocidResponseHalfwidth's componentsSeparatedByCharactersInSet:ocidCharSet
#set ocidInteger to ocidCharArray's componentsJoinedByString:""
###�e�L�X�g�ɂ��Ă���
set strTextM to ocidTextM as text
###���l��
set strResponse to strTextM as number


##############################
#####HTML��
##############################
###�X�^�C��
set strStylle to "<style>html {font-family: �"Osaka-Mono�",monospace;font-size: 24px;} #bordertable {padding: 10px;width: 100%;margin: 0;border-collapse: collapse;border-spacing: 0;word-wrap: break-word;} #bordertable table { width: 580px;margin: 0px;padding: 0px;border: 0px;border-spacing:0px;border-collapse: collapse;} #bordertable caption { font-weight: 900;} #bordertable thead { font-weight: 600;border-spacing:0px;} #bordertable td {border: solid 1px #666666;padding: 3px;margin: 0px;word-wrap: break-word;border-spacing:0px;} #bordertable tr {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;} #bordertable th {border: solid 1px #666666;padding: 0px;margin: 0px;border-spacing:0px;}</style>"
###�w�b�_�[��
set strHead to "<!DOCTYPE html><html lang=�"en�"><head><meta charset=�"utf-8�"><title>[�P�ʊ��Z] Aspect Ratio</title>" & strStylle & "</head><body>"
###�Ō�
set strHtmlEndBody to "</body></html>"

###HTML�����o���p�̃e�L�X�g������
set ocidHTMLString to refMe's NSMutableString's alloc()'s initWithCapacity:0
####body�܂ł�ǉ�
(ocidHTMLString's appendString:(strHead))
###�e�[�u���̊J�n��
set strHTML to ("<div id=�"bordertable�"><table><caption>�P�ʊ��Z Aspect Ratio</caption>") as text
set strHTML to (strHTML & "<thead title=�"���ږ��̀"><tr><th title=�"��\�I�Ȍď̀" scope=�"row�" >��\�I�Ȍď�</th><th title=�"Aspect Ratio�">�c����</th><th title=�"���" scope=�"col�">��</th><th title=�"�c�"  scope=�"col�">�c</th></tr></thead><tbody title=�"�c����̕\�" >") as text
##############################
#####�v�Z��
##############################
##���ڂ𑝂₷�ꍇ�͂��̃��R�[�h�𑝂₹��OK
set recordAspectRatio to {|01:SXGA|:{5, 4}, |02:XGA|:{4, 3}, |03:QWUXGA|:{16, 10}, |04:WQHD|:{16, 9}, |05:Cinema|:{256, 135}} as record
set ocidAspectRatioDict to refMe's NSDictionary's alloc()'s initWithDictionary:(recordAspectRatio)
set ocidAllKeys to ocidAspectRatioDict's allKeys()
set ocidDescriptor to refMe's NSSortDescriptor's sortDescriptorWithKey:("self") ascending:(true) selector:"localizedStandardCompare:"
set ocidAllKeys to ocidAllKeys's sortedArrayUsingDescriptors:({ocidDescriptor})

repeat with itemAllKeys in ocidAllKeys
	set strAllKeys to itemAllKeys as text
	log strAllKeys
	set ocidAspectRatioArray to (ocidAspectRatioDict's objectForKey:(itemAllKeys))
	###�w�����o��
	set numRatioW to (ocidAspectRatioArray's firstObject()) as integer
	set numRatioH to (ocidAspectRatioArray's lastObject()) as integer
	set numRealW to ((strResponse * numRatioW) / numRatioH) as integer
	#	log numRealW
	set strAspectRatio to (numRatioW & "x" & numRatioH) as text
	set strHTML to (strHTML & "<tr><td title=�"��\�I�Ȍď̀">" & strAllKeys & "</td><td title=�"Aspect Ratio�">" & strAspectRatio & "</td><td title=�"���">" & numRealW & "</td><td title=�"�c�">" & strResponse & "</td></tr>") as text
end repeat

set strHTML to (strHTML & "</tbody><tfoot></tfoot></table></div>") as text
####�e�[�u���܂ł�ǉ�
(ocidHTMLString's appendString:(strHTML))
####�I������ǉ�
(ocidHTMLString's appendString:(strHtmlEndBody))
##############################
#####�o�͕�
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

###�ۑ��p�X
set strFileName to "H2W.html" as text
set ocidSaveFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strFileName) isDirectory:false
####
###�t�@�C���ɏ����o��
set listDone to ocidHTMLString's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
####�e�L�X�g�G�f�B�^�ŊJ��
set aliasFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias

tell application "TextEdit"
	activate
	open file aliasFilePath
end tell


