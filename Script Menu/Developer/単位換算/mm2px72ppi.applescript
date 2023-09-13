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


set strMes to ("mm���𔼊p�����œ���") as text



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
#####�v�Z��
##############################
set strResponse to (strResponse / 10) as number
set numVar to 2.54 as number

###���̂܂�
set numRaw to (strResponse / (numVar / 72)) as number
set strMes to ("�v�Z���ʂł�:" & strResponse & "mm ��" & numRaw & "px�@�@�r") as text
log numRaw
###�����؂�̂�
set intDown to (round of (numRaw) rounding down) as integer
log intDown
set strMes to (strMes & "�����؎�:" & intDown & "�r") as text
###�����؂�グ
set intUP to (round of (numRaw) rounding up) as integer
log intUP
set strMes to (strMes & "�����؏�:" & intUP & "�r") as text
###�؂�̂ā@�����_�Q
set num2Dec to ((round of ((numRaw) * 100) rounding down) / 100) as number
log num2Dec
set strMes to (strMes & "�����_�Q��:" & num2Dec & "�r") as text
###�؂�̂ā@�����_3
set num3Dec to ((round of ((numRaw) * 1000) rounding down) / 1000) as number
log num3Dec
set strMes to (strMes & "�����_3��:" & num3Dec & "�r") as text
###�؂�̂ā@�����_4
set num4Dec to ((round of ((numRaw) * 10000) rounding down) / 10000) as number
log num4Dec
set strMes to (strMes & "�����_4��:" & num4Dec & "�r") as text
####
set strMes to (strMes & "�����_�ȉ��v�Z�͐؂�̂Ār�y���Ӂz�s�N�Z���w�莞�ɂ́w�����x���K�v�ł�") as text
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
try
	set recordResult to (display dialog strMes with title strMes default answer numRaw buttons {"�N���b�v�{�[�h�ɃR�s�[", "�L�����Z��", "OK"} default button "OK" cancel button "�L�����Z��" giving up after 20 with icon aliasIconPath without hidden answer) as record
on error
	log "�G���[���܂���"
end try
if (gave up of recordResult) is true then
	return "���Ԑ؂�ł�"
end if
##############################
#####�l�̃R�s�[
##############################
if button returned of recordResult is "�N���b�v�{�[�h�ɃR�s�[" then
	try
		set strText to text returned of recordResult as text
		####�y�[�X�g�{�[�h�錾
		set appPasteboard to refMe's NSPasteboard's generalPasteboard()
		set ocidText to (refMe's NSString's stringWithString:(strText))
		appPasteboard's clearContents()
		appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
	on error
		tell application "Finder"
			set the clipboard to strText as text
		end tell
	end try
end if
