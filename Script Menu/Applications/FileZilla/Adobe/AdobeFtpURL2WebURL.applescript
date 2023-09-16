#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# Adobe FTP�T�C�g��URL��HTTP�_�E�����[�hURL�ɕϊ����܂�
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##��������os12�Ȃ̂�2.8�ɂ��Ă��邾���ł�
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions


property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()


set appPasteboard to refMe's NSPasteboard's generalPasteboard()
set ocidPasteboardArray to appPasteboard's readObjectsForClasses:({refMe's NSString}) options:(missing value)
set ocidPasteboardStrings to (ocidPasteboardArray's objectAtIndex:0)


##############################
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
set aliasIconPath to POSIX file "/Applications/Utilities/Adobe Creative Cloud/ACC/Creative Cloud.app/Contents/Resources/CreativeCloudApp.icns" as alias
set strURL to ocidPasteboardStrings as text
try
	set recordResponse to (display dialog "Adobe FTP ��URL����" with title "Adobe FTP ��URL����" default answer strURL buttons {"OK", "�L�����Z��"} default button "OK" cancel button "�L�����Z��" with icon aliasIconPath giving up after 10 without hidden answer)
	
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
	set strURL to (text returned of recordResponse) as text
else
	log "�G���[���܂���"
	return "�G���[���܂���"
	error number -128
end if


set ociddURLstr to refMe's NSString's stringWithString:strURL
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ociddURLstr)
set ocidPathComponents to ocidURL's pathComponents()
set ocidPath to ocidURL's |path|()

set ocidHTTPComponents to refMe's NSURLComponents's alloc()'s init()
ocidHTTPComponents's setScheme:("http")
ocidHTTPComponents's setHost:("ardownload.adobe.com")
ocidHTTPComponents's setPath:(ocidPath)

set strHTTPURL to (ocidHTTPComponents's |URL|'s absoluteString()) as text



set strMes to ("Adobe �_�����[�hURL�ł��r" & strHTTPURL) as text

set recordResult to (display dialog strMes with title "httpURL" default answer strHTTPURL buttons {"�N���b�v�{�[�h�ɃR�s�[", "�L�����Z��", "�_�E�����[�h"} default button "�_�E�����[�h" cancel button "�L�����Z��" giving up after 20 with icon aliasIconPath without hidden answer)

if button returned of recordResult is "�_�E�����[�h" then
	tell application "Finder"
		open location strHTTPURL
	end tell
end if

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
			set the clipboard to strTitle as text
		end tell
	end try
end if


