#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#�@�����o���c����A�v���P�[�V�����ŏ����o���΁@�h���b�v���b�g�Ƃ��Ă��g���܂�
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

on run
	#############################
	###�y�N�������zW�N���b�N�����ꍇ�@�X�N���v�g������s�����ꍇ
	set appFileManager to refMe's NSFileManager's defaultManager()
	###�_�C�A���O
	tell current application
		set strName to name as text
	end tell
	###�X�N���v�g���j���[������s������
	if strName is "osascript" then
		tell application "Finder" to activate
	else
		tell current application to activate
	end if
	### �f�t�H���g���P�[�V����
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidLibraryDirPathURL to ocidURLsArray's firstObject()
	set ocidFontsDirPathURL to (ocidLibraryDirPathURL's URLByAppendingPathComponent:("Fonts") isDirectory:true)
	set aliasDefaultLocation to (ocidFontsDirPathURL's absoluteURL()) as alias
	###�_�C�A���O
	set strMes to "�I�������t�@�C����DMG�C���[�W�t�@�C���ɕϊ����܂��B"
	set strPrompt to "�I�������t�@�C����DMG�C���[�W�t�@�C���ɕϊ����܂��B"
	set listUTI to {"public.item"}
	set listAliasFilePath to (choose file strMes with prompt strPrompt default location aliasDefaultLocation of type listUTI with invisibles, multiple selections allowed and showing package contents) as list
	open listAliasFilePath
	
end run



on open listAliasFilePath
	#############################
	###�y���O�����z�@�ŏI�I�ɃS�~���ɓ����e���|�����t�H���_�̐���
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
	repeat with itemAliasFilePath in listAliasFilePath
		#############################
		###�y�P�z�@���̓p�X
		set aliasFilePath to itemAliasFilePath as alias
		set strFilePath to (POSIX path of aliasFilePath) as text
		set ocidFilePathStr to (refMe's NSString's stringWithString:(strFilePath))
		set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
		set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:true)
		
		#############################
		###�y�Q�z�t�@�C���@�̏ꍇ�@�ƃt�H���_�̏ꍇ��
		###�t�@�C�����h���b�v���ꂽ�ꍇ�Ή�
		set listBoolIsDir to (ocidFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLIsDirectoryKey) |error|:(reference))
		###����
		if (item 2 of listBoolIsDir) = (refMe's NSNumber's numberWithBool:false) then
			log "�t�@�C���̏ꍇ"
			set ocidBaseFilePathURL to ocidFilePathURL's URLByDeletingPathExtension()
			set ocidBaseFileName to ocidBaseFilePathURL's lastPathComponent()
			set strDMGname to ((ocidBaseFileName as text) & ".dmg") as text
			set strDmgVolumeName to ocidBaseFileName as text
			set strFolderName to ocidBaseFileName as text
			set strDistName to (ocidFilePathURL's lastPathComponent()) as text
		else
			###�t�H���_�̏ꍇ
			###�t�H���_�̖��O
			set recordFileInfo to info for aliasFilePath
			set strFolderName to (name of recordFileInfo) as text
			set strDMGname to (strFolderName & ".dmg") as text
			set strDmgVolumeName to strFolderName as text
			set strDistName to strFolderName as text
		end if
		
		#############################
		###�y�R�z�e���|�����[����DMG�̖{�̂ɂȂ�t�H���_
		###DMG�ɂȂ�t�H���_�ۑ��p�X
		set ocidMakeTmpDirPathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strFolderName) isDirectory:true)
		###�R�}���h�p�̃p�X
		set strMakeDmgDirPath to ocidMakeTmpDirPathURL's |path| as text
		###�t�H���_�����
		set listDone to (appFileManager's createDirectoryAtURL:(ocidMakeTmpDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
		
		################################
		####�y�S�z�ŏI�I��DMG���ړ�����f�B���N�g��
		#### �Í���DMG�̕ۑ���
		set ocidContainerDirPathURL to ocidFilePathURL's URLByDeletingLastPathComponent()
		set strFinishedDirName to (strFolderName & "_�Í�����DMG") as text
		set ocidFinishedDirPathURL to (ocidContainerDirPathURL's URLByAppendingPathComponent:(strFinishedDirName))
		###�t�H���_�����
		set listDone to (appFileManager's createDirectoryAtURL:(ocidFinishedDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference))
		###Finder�p
		set aliasOpenDirPath to (ocidFinishedDirPathURL's absoluteURL()) as alias
		
		#############################
		###�y�T�z�ŏI�I��DMG���ړ�����p�X
		set ocidMoveDmgPathURL to (ocidFinishedDirPathURL's URLByAppendingPathComponent:(strDMGname))
		set strMoveDmgPath to (ocidMoveDmgPathURL's |path|()) as text
		
		########################################
		###�y�U�z�p�X���[�h�����@UUID�𗘗p
		###��������UUID����n�C�t������菜��
		set ocidUUIDString to (refMe's NSMutableString's alloc()'s initWithCapacity:0)
		set ocidConcreteUUID to refMe's NSUUID's UUID()
		(ocidUUIDString's setString:(ocidConcreteUUID's UUIDString()))
		set ocidUUIDRange to (ocidUUIDString's rangeOfString:ocidUUIDString)
		(ocidUUIDString's replaceOccurrencesOfString:("-") withString:("") options:(refMe's NSRegularExpressionSearch) range:ocidUUIDRange)
		set strOwnerPassword to ocidUUIDString as text
		########################################
		###�y�U�z�@�p�X���[�h�t�@�C�������ۑ�
		set strPWFileName to strDMGname & ".PW.txt"
		set ocidPWFilePathURL to (ocidFinishedDirPathURL's URLByAppendingPathComponent:(strPWFileName))
		###�e�L�X�g
		set strTextFile to "��ɂ����肵�܂������k�t�@�C���n�w" & strDMGname & "�x�̀n�𓀃p�X���[�h�����m�点���܂��n�n" & strOwnerPassword & "�n�n�𓀏o���Ȃ�������܂����炨�m�点���������B�n(�p�X���[�h���R�s�[���y�[�X�g����ۂɀn���s��X�y�[�X������Ȃ��悤�ɗ��ӂ�������)�n" as text
		set ocidPWString to (refMe's NSString's stringWithString:(strTextFile))
		set ocidUUIDData to (ocidPWString's dataUsingEncoding:(refMe's NSUTF8StringEncoding))
		#####�p�X���[�h���������e�L�X�g�t�@�C����ۑ�
		set boolResults to (ocidUUIDData's writeToURL:(ocidPWFilePathURL) atomically:true)
		
		#############################
		###�y7�z�R�Ő��������t�H���_�ɂP�̓��e���R�s�[���邽�߂�URL
		###���t�H���_���R�s�[������URL
		set ocidCopyItemDirPathURL to (ocidMakeTmpDirPathURL's URLByAppendingPathComponent:(strDistName) isDirectory:true)
		###���f�B���N�g�����R�s�[����
		set listDone to (appFileManager's copyItemAtURL:(ocidFilePathURL) toURL:(ocidCopyItemDirPathURL) |error|:(reference))
		
		#############################
		###�y8�z�R�}���h��������DMG�̃p�X
		set ocidDmgPathURL to (ocidSaveDirPathURL's URLByAppendingPathComponent:(strDMGname) isDirectory:false)
		set strDmgPath to (ocidDmgPathURL's |path|()) as text
		
		###
		delay 1
		#############################
		###�y9�z�R�}���h���s DMG����
		
		###�ǂݎ���p��DMG�쐬
		set strCommandText to ("hdiutil create -volname �"" & strDmgVolumeName & "�" -srcfolder �"" & strMakeDmgDirPath & "�" -ov -format UDRO �"" & strDmgPath & "�"") as text
		
		log strCommandText
		do shell script strCommandText
		########################################
		###�y10�z�S��URL�ɐ������ꂽDMG�t�@�C�����@�U��URL�Ɉړ�����
		###���̎��ɐ��������p�X���[�h�ňÍ�������		
		###���d�l
		set strCommandText to ("/usr/bin/hdiutil convert �"" & strDmgPath & "�" -format UDRO -o  �"" & strMoveDmgPath & "�" -encryption AES-128 -passphrase " & strOwnerPassword & "") as text
		###���s�d�l
		set strCommandText to ("/usr/bin/printf " & strOwnerPassword & " | /usr/bin/hdiutil convert �"" & strDmgPath & "�" -format UDRO -o  �"" & strMoveDmgPath & "�" -encryption AES-128 -stdinpass") as text
		log strCommandText
		
				do shell script strCommandText
		
	end repeat
	####DMG�쐬�������I�������
	###�ۑ�����J��
	(*
	tell application "Finder"
		open aliasOpenDirPath
	end tell
	*)
	########################################
	###�y11�z�ۑ�����J��
	set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
	set boolDone to appSharedWorkspace's selectFile:(ocidMoveDmgPathURL's |path|()) inFileViewerRootedAtPath:(ocidFinishedDirPathURL's |path|())
	
	########################################
	###�y12�z���ԃt�@�C�����S�~����
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSTrashDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidTrashURL to ocidURLsArray's firstObject()
	set ocidMoveTrashDirURL to (ocidTrashURL's URLByAppendingPathComponent:(strFolderName) isDirectory:true)
	set listDone to appFileManager's trashItemAtURL:(ocidSaveDirPathURL) resultingItemURL:(ocidMoveTrashDirURL) |error|:(reference)
	
	
	
end open



