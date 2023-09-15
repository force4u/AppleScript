#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#�@�����o���c����A�v���P�[�V�����ŏ����o���΁@�h���b�v���b�g�Ƃ��Ă��g���܂�
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions
property refMe : a reference to current application

on run
	### �_�u���N���b�N������@�X�N���v�g������s������
	set strMes to "�I�������t�H���_��DMG�C���[�W�t�@�C���ɕϊ����܂��B"
	set aliasDefaultLocation to (path to fonts folder from user domain) as alias
	set listAliasDirPath to (choose folder strMes default location aliasDefaultLocation with prompt strMes with invisibles and multiple selections allowed without showing package contents) as list
	open listAliasDirPath
	
end run



on open listAliasDirPath
	#####�y���O�����z�ŏI�I�ɃS�~���ɓ����t�H���_�����
	###�e���|����
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidTempDirURL to appFileManager's temporaryDirectory()
	set ocidUUID to refMe's NSUUID's alloc()'s init()
	set ocidUUIDString to ocidUUID's UUIDString
	set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
	###�t�H���_�����
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	# 777-->511 755-->493 700-->448 766-->502 
	ocidAttrDict's setValue:(511) forKey:(refMe's NSFilePosixPermissions)
	set listDone to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
	
	###�G���A�X�̐������J��Ԃ�
	repeat with itemAliasDirPath in listAliasDirPath
		###�y�P�z���̓t�H���_�p�X
		set aliasDirPath to itemAliasDirPath as alias
		set strDirPath to (POSIX path of aliasDirPath) as text
		set ocidDirPathStr to (refMe's NSString's stringWithString:(strDirPath))
		set ocidDirPath to ocidDirPathStr's stringByStandardizingPath()
		set ocidDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidDirPath) isDirectory:true)
		###�t�@�C�����h���b�v���ꂽ�ꍇ�Ή�
		set listBoolIsDir to (ocidDirPathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsDirectoryKey) |error|:(reference))
		if (item 2 of listBoolIsDir) = (refMe's NSNumber's numberWithBool:false) then
			log "�f�B���N�g���ȊO�͏������܂���"
			display alert "�f�B���N�g���ȊO�͏������܂���"
			return "�f�B���N�g���ȊO�͏������܂���"
			exit repeat
		end if
		
		###�t�H���_�̖��O
		set recordFileInfo to info for aliasDirPath
		set strFolderName to (name of recordFileInfo) as text
		set strDMGname to (strFolderName & ".dmg") as text
		
		###�y�Q�z���̓t�H���_�̃R���e�i�f�B���N�g��
		set ocidContainerDirPathURL to ocidDirPathURL's URLByDeletingLastPathComponent()
		set aliasContainerDirPath to (ocidContainerDirPathURL's absoluteURL()) as alias
		
		###�y�R�z�ŏI�I�ɏo���オ����DMG�t�@�C�����ړ�������p�X
		###DMG�ɂȂ�t�H���_�ۑ��p�X
		set ocidMoveDmgPathURL to (ocidContainerDirPathURL's URLByAppendingPathComponent:(strDMGname) isDirectory:false)
		
		###�y�S�z�e���|��������DMG�t�@�C���𐶐�����p�X
		###DMG���쐬����URL
		set ocidDmgPathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strDMGname) isDirectory:false)
		###�R�}���h�p�̃p�X
		set strDmgPath to ocidDmgPathURL's |path| as text
		
		###�y�T�z�e���|�������@DMG�̖{�̂ƂȂ�f�B���N�g���@
		###DMG�ɂȂ�t�H���_
		set ocidMakeTmpDirPathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strFolderName) isDirectory:false)
		###�R�}���h�p�̃p�X
		set strMakeDmgDirPath to ocidMakeTmpDirPathURL's |path| as text
		###�t�H���_�����
		set listDone to (appFileManager's createDirectoryAtURL:(ocidMakeTmpDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
		###�y6�z���T�ō�����t�H���_���ɂP�̃t�H���_���R�s�[���邽�߂̃p�X
		###���t�H���_���R�s�[������URL
		set ocidCopyItemDirPathURL to (ocidMakeTmpDirPathURL's URLByAppendingPathComponent:(strFolderName) isDirectory:true)
		###�y�V�z�P��URL���U��URL�ɃR�s�[����
		set listDone to (appFileManager's copyItemAtURL:(ocidDirPathURL) toURL:(ocidCopyItemDirPathURL) |error|:(reference))
		###
		delay 1
		###�y�W�z�R�}���h���`���Ď��s
		set strCommandText to ("/usr/bin/hdiutil create -volname �"" & strFolderName & "�" -srcfolder �"" & strMakeDmgDirPath & "�" -ov -format UDRO �"" & strDmgPath & "�"") as text
		log strCommandText
		do shell script strCommandText
		delay 1
		###�y�X�z�S��URL�ɐ������ꂽDMG�t�@�C�����@�R��URL�Ɉړ�����
		set listDone to (appFileManager's moveItemAtURL:(ocidDmgPathURL) toURL:(ocidMoveDmgPathURL) |error|:(reference))
		
	end repeat
	####DMG�쐬�������I�������
	###�ۑ�����J��
	tell application "Finder"
		open aliasContainerDirPath
	end tell
	
	####�y�P�O�z���O�����ō�����t�H���_���S�~���ɓ����
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSTrashDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidTrashURL to ocidURLsArray's firstObject()
	set ocidMoveTrashDirURL to (ocidTrashURL's URLByAppendingPathComponent:(strFolderName) isDirectory:true)
	set listDone to appFileManager's trashItemAtURL:(ocidSaveDirPathURL) resultingItemURL:(ocidMoveTrashDirURL) |error|:(reference)
	return "�����I��"
end open



