#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#�y���ӎ����z~���g����HOME�w��́A/User/someuser/�`����
# �ϊ������̂ŁA��������p�ƂȂ�܂�
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()


##�f�t�H���g�N���b�v�{�[�h����
set ocidPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidPasteboardArray to ocidPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
try
	set ocidPasteboardStrings to (ocidPasteboardArray's objectAtIndex:0) as text
on error
	set ocidPasteboardStrings to "" as text
end try
set strDefaultAnswer to ocidPasteboardStrings as text
if strDefaultAnswer starts with "/" then
	set strURL to strDefaultAnswer as text
else if strDefaultAnswer starts with "~" then
	set ocidFilePathStr to refMe's NSString's stringWithString:(strDefaultAnswer)
	set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath))
	set strURL to ocidFilePathURL's absoluteString() as text
else
	set strURL to ("/some/path/file/or/dir") as text
end if
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
	set strMes to ("�t�@�C���p�X����͂��Ă��������n��F�n/some/path/file/or/dir�n~/Desktop") as text
	
	set recordResponse to (display dialog strMes with title "�t�@�C���p�X����͂��Ă�������" default answer strURL buttons {"OK", "�L�����Z��"} default button "OK" cancel button "�L�����Z��" with icon aliasIconPath giving up after 20 without hidden answer)
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

if strResponse starts with "/" then
	set ocidFilePathStr to refMe's NSString's stringWithString:(strResponse)
	
else if strResponse starts with "~" then
	set ocidFilePathStr to refMe's NSString's stringWithString:(strResponse)
else
	return "�t�@�C���p�X��p�ł�"
end if
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath))
set strURL to ocidFilePathURL's absoluteString() as text
###�t�@�C�������擾���Ċg���q������Ă���
set ocidBaseNamePathURL to ocidFilePathURL's URLByDeletingPathExtension()
set strBaseFileName to (ocidBaseNamePathURL's lastPathComponent()) as text
###�ۑ��p�̃t�@�C����
set strSaveFileName to (strBaseFileName & ".fileloc") as text
###�ۑ���̓f�X�N�g�b�v
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set ocidSaveFilePathURL to ocidDesktopDirPathURL's URLByAppendingPathComponent:(strSaveFileName)
###PLIST�p��URL�̒l
set strURL to (ocidFilePathURL's absoluteString()) as text
##############################
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidPlistDict's setValue:(strURL) forKey:("URL")
###
set ocidFromat to refMe's NSPropertyListXMLFormat_v1_0
set listPlistEditDataArray to refMe's NSPropertyListSerialization's dataWithPropertyList:(ocidPlistDict) format:(ocidFromat) options:0 |error|:(reference)
set ocidPlistData to item 1 of listPlistEditDataArray
###
set listDone to ocidPlistData's writeToURL:(ocidSaveFilePathURL) options:0 |error|:(reference)


