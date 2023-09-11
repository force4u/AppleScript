#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

#############################
###�_�C�A���O
tell current application
	set strName to name as text
end tell
####�X�N���v�g���j���[������s������
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
############ �f�t�H���g���P�[�V����
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias

###ANY

set strMes to ("�t�H���_��I��ł�������") as text
set strPrompt to ("�t�H���_��I��ł�������") as text
try
	###�@�t�@�C���I����
	set aliasFilePath to (choose folder strMes with prompt strPrompt default location aliasDefaultLocation without multiple selections allowed, invisibles and showing package contents) as alias
on error
	log "�G���[���܂���"
	return "�G���[���܂���"
end try
set strFilePath to (POSIX path of aliasFilePath) as text
####�h�L�������g�̃p�X��NSString
set ocidFilePath to refMe's NSString's stringWithString:(strFilePath)
####�h�L�������g�̃p�X��NSURL��
set ocidFilePathURL to refMe's NSURL's fileURLWithPath:(ocidFilePath)
###�t�@�C�������擾���Ċg���q������Ă���
set ocidBaseNamePathURL to ocidFilePathURL's URLByDeletingPathExtension()
set strBaseFileName to (ocidBaseNamePathURL's lastPathComponent()) as text
###�ۑ��p�̃t�@�C����
set strSaveFileName to (strBaseFileName & ".fileloc") as text
###�ۑ���̓f�X�N�g�b�v
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


