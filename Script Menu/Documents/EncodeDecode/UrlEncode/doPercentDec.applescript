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
	set strMes to ("�ǂ߂镶�������G���R�[�h���܂��n�e�L�X�g��URL������͂��Ă�������") as text
	
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

##�ʏ�e�L�X�g�̏ꍇ
set strText to strResponse as text
set strDecodedText to doUrlDecode(strText) as text

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
set strMes to ("�߂�l�ł��r" & strDecodedText) as text

set recordResult to (display dialog strMes with title "%�f�R�[�h" default answer strDecodedText buttons {"�N���b�v�{�[�h�ɃR�s�[", "�L�����Z��", "OK"} default button "OK" cancel button "�L�����Z��" giving up after 20 with icon aliasIconPath without hidden answer)

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






####################################
###### ���f�R�[�h
####################################
on doUrlDecode(argText)
	##�e�L�X�g
	set ocidArgText to refMe's NSString's stringWithString:(argText)
	##�f�R�[�h
	set ocidArgTextEncoded to ocidArgText's stringByRemovingPercentEncoding
	set strArgTextEncoded to ocidArgTextEncoded as text
	return strArgTextEncoded
end doUrlDecode
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

