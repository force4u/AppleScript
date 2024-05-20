#! /usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
�ۑ�����WINDOW�ݒ���폜����
�V�X�e�����ݒ聄���Z�L�����e�B�ƃv���C�o�V�[�����v���C�o�V�[
�A�N�Z�V�r���e�B�̃^�u��
SystemUIServer.app�ɑ΂��Đ���������Ă�������
20180211 10.6x�p����������
20180214�@10.11�ɑΉ�
20240520 macOS14�ɑΉ�
*)
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()

#################################
###�ݒ�t�@�C���ۑ���@Application Support
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidApplicatioocidupportDirPathURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidApplicatioocidupportDirPathURL's URLByAppendingPathComponent:("com.cocolog-nifty.quicktimer/SaveFinderWindow")
###�ݒ�t�@�C��
set ocidPlistFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("com.apple.finder.save.window.plist") isDirectory:(false)
#################################
##�ݒ�t�@�C���̗L���`�F�b�N
set ocidPlistFilePath to ocidPlistFilePathURL's |path|()
set boolDirExists to appFileManager's fileExistsAtPath:(ocidPlistFilePath) isDirectory:(false)
if boolDirExists = true then
	log "�ݒ�t�@�C������"
	###�ݒ�t�@�C���ǂݍ��� NSDATA
	set ocidOption to (refMe's NSDataReadingMappedIfSafe)
	set listResponse to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidPlistFilePathURL) options:(ocidOption) |error|:(reference)
	if (item 2 of listResponse) = (missing value) then
		log "initWithContentsOfURL ���폈��"
		set ocidReadData to (item 1 of listResponse)
	else if (item 2 of listResponse) �� (missing value) then
		log (item 2 of listResponse)'s code() as text
		log (item 2 of listResponse)'s localizedDescription() as text
		return "NSDATA �G���[���܂���"
	end if
	### ��
	set listResponse to refMe's NSKeyedUnarchiver's unarchivedObjectOfClass:((refMe's NSObject)'s class) fromData:(ocidReadData) |error|:(reference)
	if (item 2 of listResponse) is (missing value) then
		##�𓀂���Plist�p���R�[�h
		set ocidPlistDict to (item 1 of listResponse)
		log "unarchivedObjectOfClass ����I��"
	else
		log (item 2 of listResponse)'s code() as text
		log (item 2 of listResponse)'s localizedDescription() as text
		return "NSKeyedUnarchiver �G���[���܂���"
	end if
else if boolDirExists = false then
	return "�ݒ�t�@�C������ �L�����Z�����܂�"
end if
#################################
##�폜�ݒ��I��
#################################
#�L�[�����o����
set ocidWindowSetKeyArray to ocidPlistDict's allKeys()
set listWindowSetKeyArray to ocidWindowSetKeyArray as list
if (count of listWindowSetKeyArray) = 0 then
	return "�ۑ����ꂽ�ݒ�͂���܂���"
end if
###�_�C�A���O
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set listChooseResult to (choose from list listWindowSetKeyArray with prompt "�ǂ̐ݒ���폜���܂������H" OK button name "OK" with title "�ݒ���폜����" without multiple selections allowed and empty selection allowed) as list
if (item 1 of listChooseResult) is false then
	return "�������L�����Z�����܂���"
else
	set strDelKey to (item 1 of listChooseResult) as text
end if
#################################
##�폜
#################################
ocidPlistDict's removeObjectForKey:(strDelKey)

#######################################
###�@�A�[�J�C�u����
#######################################
# archivedDataWithRootObject:requiringSecureCoding:error:
set listResponse to refMe's NSKeyedArchiver's archivedDataWithRootObject:(ocidPlistDict) requiringSecureCoding:(false) |error|:(reference)
if (item 2 of listResponse) = (missing value) then
	log "archivedDataWithRootObject ���폈��"
	set ocidSaveData to (item 1 of listResponse)
else if (item 2 of listResponse) �� (missing value) then
	log (item 2 of listResponse)'s code() as text
	log (item 2 of listResponse)'s localizedDescription() as text
	return "NSKeyedArchiver�ŃG���[���܂���"
end if

#######################################
###�@�ۑ�����
#######################################
##�ۑ�
set ocidOption to (refMe's NSDataWritingAtomic)
set listDone to ocidSaveData's writeToURL:(ocidPlistFilePathURL) options:(ocidOption) |error|:(reference)
if (item 1 of listDone) is true then
	log "writeToURL ���폈��"
else if (item 2 of listDone) �� (missing value) then
	log (item 2 of listDone)'s code() as text
	log (item 2 of listDone)'s localizedDescription() as text
	return "�ۑ��Ł@�G���[���܂���"
end if
