#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application


################################
##�f�t�H���g�N���b�v�{�[�h����e�L�X�g�擾
################################
set appPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidTypeArray to appPasteboard's types()
set boolContain to ocidTypeArray's containsObject:("public.utf8-plain-text")
if boolContain = true then
	try
		set ocidPasteboardArray to appPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
		set ocidPasteboardStrings to ocidPasteboardArray's firstObject()
	on error
		set ocidStringData to appPasteboard's stringForType:("public.utf8-plain-text")
		set ocidPasteboardStrings to (refMe's NSString's stringWithString:(ocidStringData))
	end try
else
	set ocidPasteboardStrings to (refMe's NSString's stringWithString:(""))
end if
set strDefaultAnswer to ocidPasteboardStrings as text

################################
######�_�C�A���O
################################
#####�_�C�A���O��O�ʂ�
tell current application
	set strName to name as text
end tell
####�X�N���v�g���j���[������s������
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set aliasIconPath to (POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/BookmarkIcon.icns") as alias
try
	set strMes to ("Base64�`�����f�R�[�h���܂�") as text
	
	set recordResponse to (display dialog strMes with title "���͂��Ă�������" default answer strDefaultAnswer buttons {"OK", "�L�����Z��"} default button "OK" cancel button "�L�����Z��" with icon aliasIconPath giving up after 20 without hidden answer)
on error
	log "�G���[���܂���"
	return "�G���[���܂���"
end try
if true is equal to (gave up of recordResponse) then
	return "���Ԑ؂�ł����Ȃ����Ă�������"
end if
if "OK" is equal to (button returned of recordResponse) then
	set strResponse to (text returned of recordResponse) as text
else
	log "�L�����Z�����܂���"
	return "�L�����Z�����܂���"
end if

################################
######�{����
################################

set strDecodeText to doDecodeBase64(strResponse)
set strText to strDecodeText as text



################################
######�_�C�A���O
################################
#####�_�C�A���O��O�ʂ�
tell current application
	set strName to name as text
end tell
####�X�N���v�g���j���[������s������
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
set strMes to ("�߂�l�ł��r" & strText) as text

set recordResult to (display dialog strMes with title "�f�R�[�h����" default answer strText buttons {"�N���b�v�{�[�h�ɃR�s�[", "�L�����Z��", "OK"} default button "OK" cancel button "�L�����Z��" giving up after 20 with icon aliasIconPath without hidden answer)

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


################################
######�@�f�R�[�h
################################
on doDecodeBase64(argText)
	###�e�L�X�g�ɂ���
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	###�f�R�[�h����
	set ocidArgData to refMe's NSData's alloc()'s initWithBase64EncodedString:(ocidArgText) options:(refMe's NSDataBase64DecodingIgnoreUnknownCharacters)
	###UTF�W�ɂ���
	set ocidDecodedString to refMe's NSString's alloc()'s initWithData:ocidArgData encoding:(refMe's NSUTF8StringEncoding)
	if ocidDecodedString = (missing value) then
		set strDecodedString to ("�f�R�[�h�Ɏ��s���܂����BBASE64�e�L�X�g�ł͖���������������܂���B") as text
	else if (ocidDecodedString as text) is "" then
		set strDecodedString to ("�f�R�[�h�Ɏ��s���܂����BBASE64�e�L�X�g�ł͖���������������܂���B") as text
	else
		###�e�L�X�g�Ŗ߂�
		set strDecodedString to ocidDecodedString as text
	end if
	
	return strDecodedString
end doDecodeBase64