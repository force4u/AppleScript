#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# �t�@�C�����J�����̃f�t�H���g�̃A�v���P�[�V���������ޖ��ɐݒ肵�܂�
# �A�v���P�[�V������I��
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "Appkit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

set appFileManager to refMe's NSFileManager's defaultManager()

###################################
#####�ݒ荀��
###################################

###�t���p�X�w�肩
set strPlistPath to ("/Users/XXXXXXX/XXXXXX/XXXXXX/Plist/com.apple.TextEdit.plist") as text
###path to me ����t�Z��
set strPlistName to ("com.apple.TextEdit.plist") as text
tell application "Finder"
	set aliasPathToMe to (path to me) as alias
	set aliasContainerDirPath to (container of aliasPathToMe) as text
	set aliasPlistFilePath to (file strPlistName of folder "Plist" of folder aliasContainerDirPath) as alias
end tell
set strPlistPath to (POSIX path of aliasPlistFilePath) as text

###################################
#####���̓_�C�A���O
###################################
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
set listUTI to {"public.data"} as list
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()
set aliasDefaultLocation to (ocidDesktopDirPathURL's absoluteURL()) as alias
set strPromptText to "�t�@�C����I��ł�������" as text
set strMesText to "�t�@�C����I��ł�������" as text
set listAliasFilePath to (choose file strMesText with prompt strPromptText default location (aliasDefaultLocation) of type listUTI with invisibles and multiple selections allowed without showing package contents) as list


###################################
#####PLIST��HEX�o�C�i���[���擾����
###################################
set strCommandText to ("/usr/bin/xxd  -pc �"" & strPlistPath & "�"") as text
set strHexPlistData to (do shell script strCommandText)

###################################
#####�t�@�C���̐������J��Ԃ�
###################################
repeat with itemFilePath in listAliasFilePath
	set aliasFilePath to itemFilePath as alias
	set strAppendAttrFilePath to (POSIX path of aliasFilePath) as text
	###�R�}���h���`
	set strCommandText to ("/usr/bin/xattr -d com.apple.LaunchServices.OpenWith �"" & strAppendAttrFilePath & "�"") as text
	try
		(do shell script strCommandText)
		delay 0.25
	on error
		try
			###�R�}���h���`
			set strCommandText to ("/usr/bin/xattr -c com.apple.LaunchServices.OpenWith �"" & strAppendAttrFilePath & "�"") as text
			(do shell script strCommandText)
		end try
	end try
	###�R�}���h���`
	set strCommandText to ("/usr/bin/xattr  -w -x  com.apple.LaunchServices.OpenWith �"" & strHexPlistData & "�" �"" & strAppendAttrFilePath & "�"") as text
	(do shell script strCommandText)
	delay 0.25
	###�R�}���h���`
	set strCommandText to ("/usr/bin/xattr  -w -x com.apple.quarantine nil �"" & strAppendAttrFilePath & "�"") as text
	(do shell script strCommandText)
	delay 0.25
end repeat

return "�����I��"


