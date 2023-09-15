#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#�@�����o���c����A�v���P�[�V�����ŏ����o���΁@�h���b�v���b�g�Ƃ��Ă��g���܂�
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

on run
	set strMes to "�I�������t�H���_��DMG�C���[�W�t�@�C���ɕϊ����܂��B"
	set aliasDefaultLocation to (path to fonts folder from user domain) as alias
	set listAliasDirPath to (choose folder strMes default location aliasDefaultLocation with prompt strMes with invisibles and multiple selections allowed without showing package contents) as list
	open listAliasDirPath
end run



on open listAliasDirPath
	###�G���A�X�̐������J��Ԃ�
	repeat with itemAliasDirPath in listAliasDirPath
		###���̓p�X
		set aliasDirPath to itemAliasDirPath as alias
		set strDirPath to (POSIX path of aliasDirPath) as text
		###�t�H���_�̖��O
		set recordFileInfo to info for aliasDirPath
		set strFolderName to (name of recordFileInfo) as text
		log recordFileInfo
		if (kind of recordFileInfo) is "�t�H���_" then
			##���̂܂܏���
		else if (kind of recordFileInfo) is folder then
			##���̂܂܏���
		else
			log "�f�B���N�g���ȊO�͏������܂���"
			display alert "�f�B���N�g���ȊO�͏������܂���"
			return "�f�B���N�g���ȊO�͏������܂���"
			exit repeat
		end if
		return
		###�I�񂾃t�H���_�̃R���e�i
		tell application "Finder"
			set aliasContainerDirPath to (container of aliasDirPath) as alias
		end tell
		###DMG�̖��O
		set strDirName to (strFolderName & ".dmg")
		###�o�̓p�X
		set strContainerDirPath to (POSIX path of aliasContainerDirPath) as text
		set strSaveFilePath to (strContainerDirPath & strDirName) as text
		###�R�}���h���s
		set strCommandText to ("hdiutil create -volname �"" & strFolderName & "�" -srcfolder �"" & strDirPath & "�" -ov -format UDRO �"" & strSaveFilePath & "�"") as text
		log strCommandText
		do shell script strCommandText
	end repeat
	
	###�ۑ�����J��
	tell application "Finder"
		open aliasContainerDirPath
	end tell
	
end open



