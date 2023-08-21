#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
com.cocolog-nifty.quicktimer.icefloe
�f�t�H���g�A�v���P�[�V������ݒ肷��
*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##��������os12�Ȃ̂�2.8�ɂ��Ă��邾���ł�
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

###�ݒ荀�� URL�X�L�[��
set strScheme to "iChat://" as text
###NSURL
set ocidScheme to refMe's NSURL's URLWithString:(strScheme)

###���[�N�X�y�[�X������
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
###UTType�^�C�v�̃f�t�H���g�A�v���P�[�V����
set ocidAppPathURL to appShardWorkspace's URLsForApplicationsToOpenURL:(ocidScheme)

################################################
###�N���{�����[���ɂ���URL�݂̂ɂ���
###URL�i�[�p�̉�ARRAY
set ocidChooseArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
ocidChooseArray's setArray:ocidAppPathURL
###���W����URL�̌�
set numCntArray to count of ocidAppPathURL
###���W����URL����O���{�����[���̂��̂��폜
###�N���{�����[���̖��O
set strFilePath to "/System/Library/CoreServices/Finder.app" as text
set ocidFinderFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFinderFilePath to ocidFinderFilePathStr's stringByStandardizingPath()
set ocidFinderFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFinderFilePath) isDirectory:false)
set listVolumeNameKey to (ocidFinderFilePathURL's getResourceValue:(reference) forKey:(refMe's NSURLVolumeNameKey) |error|:(reference))
set strVolumeName to (item 2 of listVolumeNameKey) as text
####���W����URL�̐������J��Ԃ�
repeat numCntArray times
	###Array�̍폜�Ȃ̂Ō�납�珈��
	set itemAppPathURL to ocidChooseArray's objectAtIndex:(numCntArray - 1)
	###�{�����[�������擾����
	set listPathVolumeName to (itemAppPathURL's getResourceValue:(reference) forKey:(refMe's NSURLVolumeNameKey) |error|:(reference))
	set strPathVolumeName to (item 2 of listPathVolumeName) as text
	###�O���{�����[���̂��͍̂폜
	if strPathVolumeName is "Preboot" then
		log strPathVolumeName
	else if strPathVolumeName is not strVolumeName then
		ocidChooseArray's removeObjectAtIndex:(numCntArray - 1)
	end if
	set numCntArray to numCntArray - 1
end repeat


################################################
###�A�v������URL�̃��R�[�h�𐶐�����
###�_�C�A���O�p�̃A�v���P�[�V���������X�g
set listAppName to {} as list
###�A�v���P�[�V������URL���Q�Ƃ����邽�߂̃��R�[�h
set ocidBrowserDictionary to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
####################################################
####UTType�Ƃ��ė��p�\�ȃA�v���P�[�V�����ꗗ���擾����
####################################################
repeat with itemAppPathURL in ocidChooseArray
	###�A�v���P�[�V�����̖��O
	set listResponse to (itemAppPathURL's getResourceValue:(reference) forKey:(refMe's NSURLNameKey) |error|:(missing value))
	set strAppName to (item 2 of listResponse) as text
	log "�u���E�U�̖��O�́F" & strAppName & "�ł�"
	copy strAppName to end of listAppName
	####�p�X
	set aliasAppPath to itemAppPathURL's absoluteURL() as alias
	log "�u���E�U�̃p�X�́F" & aliasAppPath & "�ł�"
	####�o���h��ID�擾
	set ocidAppBunndle to (refMe's NSBundle's bundleWithURL:(itemAppPathURL))
	set ocidBunndleID to ocidAppBunndle's bundleIdentifier
	set strBundleID to ocidBunndleID as text
	log "�u���E�U��BunndleID�́F" & strBundleID & "�ł�"
	(ocidBrowserDictionary's setObject:(itemAppPathURL) forKey:(strAppName))
end repeat

################################
##�_�C�A���O
################################
###�_�C�A���O��O�ʂ�
tell current application
	set strName to name as text
end tell
####�X�N���v�g���j���[������s������
if strName is "osascript" then
	tell application "Finder"
		activate
	end tell
else
	tell current application
		activate
	end tell
end if
try
	set listResponse to (choose from list listAppName with title "�I��ł�������" with prompt "URL�X�L�[���r�y" & strScheme & "�z���J���r�A�v���P�[�V������I��ł�������" default items (item 1 of listAppName) OK button name "OK" cancel button name "�L�����Z��" without multiple selections allowed and empty selection allowed)
on error
	log "�G���[���܂���"
	return "�G���[���܂���"
end try
if listResponse is false then
	return "�L�����Z�����܂���"
end if
set strResponse to (item 1 of listResponse) as text
################################
##�A�v���P�[�V������URL���擾����
################################
###�A�v���P�[�V������URL�����o��
set ocidAppPathURL to ocidBrowserDictionary's objectForKey:(strResponse)
###�I�񂾃A�v���P�[�V�����̃o���h��ID
set ocidAppBunndle to (refMe's NSBundle's bundleWithURL:(ocidAppPathURL))
set ocidBunndleID to ocidAppBunndle's bundleIdentifier
###IF�p�Ƀe�L�X�g�ɂ��Ă���
set strBunndleID to ocidBunndleID as text


################################
##�f�t�H���g�ɐݒ肷��
################################
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
appShardWorkspace's setDefaultApplicationAtURL:(ocidAppPathURL) toOpenURLsWithScheme:("tel") completionHandler:(missing value)


#############################
###CFPreferences���ċN��
#############################
#####CFPreferences���ċN�������ĕύX��̒l�����[�h������
set strCommandText to "/usr/bin/killall cfprefsd" as text
do shell script strCommandText

