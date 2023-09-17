#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application

set strBundleID to "cx.c3.theunarchiver" as text
###�o���h��ID����A�v���P�[�V����URL
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(strBundleID))
if ocidAppBundle �� (missing value) then
	set ocidAppPathURL to ocidAppBundle's bundleURL()
else if ocidAppBundle = (missing value) then
	set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID))
end if
if ocidAppPathURL = (missing value) then
	tell application "Finder"
		try
			set aliasAppApth to (application file id strBundleID) as alias
		on error
			return "�A�v���P�[�V������������܂���ł���"
		end try
	end tell
	set strAppPath to POSIX path of aliasAppApth as text
	set strAppPathStr to refMe's NSString's stringWithString:(strAppPath)
	set strAppPath to strAppPathStr's stringByStandardizingPath()
	set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:true
end if
##############################
#####CFBundleDocumentTypes�̎擾
set ocidPlistPathURL to ocidAppPathURL's URLByAppendingPathComponent:("Contents/Info.plist")
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistPathURL)
set ocidDocTypeArray to ocidPlistDict's objectForKey:"CFBundleDocumentTypes"
if ocidDocTypeArray = (missing value) then
	return "�G���[�@AppStore�ł͔�Ή��ł�"
end if

####�𓀉\�ȃR���e���c�^�C�v�����X�g�ɂ���
set listUTl to {} as list
repeat with itemDocTypeArray in ocidDocTypeArray
	set ocidContentTypesArray to (itemDocTypeArray's objectForKey:"LSItemContentTypes")
	if ocidContentTypesArray = (missing value) then
		log "�R���e���c�^�C�v�̐ݒ肪����܂���"
	else
		repeat with itemContentTypes in ocidContentTypesArray
			set end of listUTl to (itemContentTypes as text)
		end repeat
	end if
end repeat
log listUTl


set listExtension to {} as list
repeat with itemDocTypeArray in ocidDocTypeArray
	set ocidContentTypesArray to (itemDocTypeArray's objectForKey:"CFBundleTypeExtensions")
	if ocidContentTypesArray = (missing value) then
		log "�R���e���c�^�C�v�̐ݒ肪����܂���"
	else
		repeat with itemContentTypes in ocidContentTypesArray
			set end of listExtension to (itemContentTypes as text)
		end repeat
	end if
end repeat



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

tell application "Finder"
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
end tell
try
	set listDirPath to (choose folder "�t�H���_��I��ł�������" with prompt "�t�H���_��I�����Ă�������" default location aliasDefaultLocation with multiple selections allowed without invisibles and showing package contents) as list
on error
	log "�G���[���܂���"
	return
end try

###�t�@�C���̐������J�Ԃ�
repeat with itemDirPath in listDirPath
	set aliasDirPath to itemDirPath as alias
	tell application "Finder"
		tell folder aliasDirPath
			set listAliasFilePath to every item
		end tell
	end tell
	repeat with itemAliasFilePath in listAliasFilePath
		tell application "Finder"
			set aliasFilePath to itemAliasFilePath as alias
			set objInfo to info for aliasFilePath
			if (kind of objInfo) is not "�t�H���_" then
				set strUTI to (type identifier of objInfo)
				set strExt to name extension of objInfo
			else
				set strUTI to ""
				set strExt to ""
			end if
		end tell
		if listUTl contains strUTI then
			tell application id strBundleID to open file aliasFilePath
		else if listExtension contains strExt then
			tell application id strBundleID to open file aliasFilePath
		else
			log "�𓀂ł��Ȃ���ނł�"
		end if
	end repeat
	return
end repeat


return