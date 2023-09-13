#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##��������os12�Ȃ̂�2.8�ɂ��Ă��邾���ł�
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


##############################
###�_�C�A���O��O�ʂ�
##############################
tell current application
	set strName to name as text
end tell
####�X�N���v�g���j���[������s������
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###�A�C�R��
set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FinderIcon.icns" as alias
###�f�t�H���g�l
set strDefaultAnswer to "755" as text
###���b�Z�[�W
set strText to "777-->511�n775-->509�n770-->504�n755-->493�n750-->488�n700-->448�n555-->365�n333-->219"
###�_�C�A���O
try
	set recordResponse to (display dialog strText with title "�R���W�i�������" default answer strDefaultAnswer buttons {"OK", "�L�����Z��"} default button "OK" cancel button "�L�����Z��" with icon aliasIconPath giving up after 20 without hidden answer)
on error
	log "�G���[���܂���"
	return "�G���[���܂���"
	error number -128
end try
if true is equal to (gave up of recordResponse) then
	return "���Ԑ؂�ł����Ȃ����Ă�������"
	error number -128
end if
if "OK" is equal to (button returned of recordResponse) then
	set strResponse to (text returned of recordResponse) as text
else
	log "�G���[���܂���"
	return "�G���[���܂���"
	error number -128
end if

###�e�L�X�g��
set ocidResponseText to (refMe's NSString's stringWithString:(strResponse))
####�߂�l�𔼊p�ɂ���
set ocidNSStringTransform to (refMe's NSStringTransformFullwidthToHalfwidth)
set ocidResponseHalfwidth to (ocidResponseText's stringByApplyingTransform:ocidNSStringTransform |reverse|:false)
###�����ȊO�̒l�����
set ocidDecSet to refMe's NSCharacterSet's decimalDigitCharacterSet
set ocidCharSet to ocidDecSet's invertedSet()
set ocidCharArray to ocidResponseHalfwidth's componentsSeparatedByCharactersInSet:ocidCharSet
set ocidInteger to ocidCharArray's componentsJoinedByString:""
set intResponse to ocidInteger as integer

###�{����
set strDem to doOct2Dem(intResponse)

##############################
###�_�C�A���O��O�ʂ�
##############################
tell current application
	set strName to name as text
end tell
####�X�N���v�g���j���[������s������
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###�_�C�A���O�ɖ߂�
set strMes to "�v�Z���ʂł��r�r(current application)'s NSNumber's numberWithInteger:(" & strDem & ") �n"
try
	set recordResult to (display dialog strMes with title strMes default answer strDem buttons {"�N���b�v�{�[�h�ɃR�s�[", "�L�����Z��", "OK"} default button "OK" cancel button "�L�����Z��" giving up after 20 with icon aliasIconPath without hidden answer) as record
on error
	log "�G���[���܂���"
	return
end try
if (gave up of recordResult) is true then
	return "���Ԑ؂�ł�"
end if
if button returned of recordResult is "�N���b�v�{�[�h�ɃR�s�[" then
	set strText to text returned of recordResult as text
	####�y�[�X�g�{�[�h�錾
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
end if
###################################
#####�p�[�~�b�V�����@�W�i���P�O�i
###################################

to doOct2Dem(argOctNo)
	set strOctalText to argOctNo as text
	set num3Line to first item of strOctalText as number
	set num2Line to 2nd item of strOctalText as number
	set num1Line to last item of strOctalText as number
	set numDecimal to (num3Line * 64) + (num2Line * 8) + (num1Line * 1)
	return numDecimal
end doOct2Dem

