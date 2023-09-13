#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set aliasIconPath to POSIX file "/System/Applications/Calculator.app/Contents/Resources/AppIcon.icns" as alias
set strDefaultAnswer to "504" as text

set strText to "511-->777�n509-->775�n504-->770�n493-->755�n488-->750�n448-->700�n420-->644"

try
	###�_�C�A���O��O�ʂɏo��
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
	set recordResponse to (display dialog strText with title "�R���P�O�i�������" default answer strDefaultAnswer buttons {"OK", "�L�����Z��"} default button "OK" cancel button "�L�����Z��" with icon aliasIconPath giving up after 20 without hidden answer)
	
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

set strOct to doDec2Oct(strResponse) as text

try
	###�_�C�A���O��O�ʂɏo��
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
	set recordResult to (display alert ("�v�Z����:" & strOct) buttons {"�N���b�v�{�[�h�ɃR�s�[", "�L�����Z��", "OK"} default button "OK" cancel button "�L�����Z��" as informational giving up after 30)
on error
	log "�G���[���܂���"
	return
end try

###�N���b�v�{�[�h�R�s�[
if button returned of recordResult is "�N���b�v�{�[�h�ɃR�s�[" then
	set strText to strOct as text
	####�y�[�X�g�{�[�h�錾
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
end if


###################################
##	�p�[�~�b�V�����P�O�i�� ���W�i��  �@
##	Decimal to Octal
###################################
to doDec2Oct(argDecNo)
	set numDecNo to argDecNo as number
	set numDiv1 to (numDecNo div 8) as number
	set numMod1 to (numDecNo mod 8) as number
	set numDiv2 to (numDiv1 div 8) as number
	set numMod2 to (numDiv1 mod 8) as number
	set numDiv3 to (numDiv2 div 8) as number
	set numMod3 to (numDiv2 mod 8) as number
	set strOctal to (numMod3 & numMod2 & numMod1) as text
	set numOctal to strOctal as number
	return numOctal as number
	
end doDec2Oct



