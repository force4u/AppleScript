#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#�@
(*
�t�@�C���̕\����؂�ւ��܂�
*)
#
#
#                       com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application
property refNSString : a reference to refMe's NSString
property refNSURL : a reference to refMe's NSURL

property refNSMutableDictionary : a reference to refMe's NSMutableDictionary
property refNSPropertyListSerialization : a reference to refMe's NSPropertyListSerialization

set objFileManager to refMe's NSFileManager's defaultManager()

#####�ݒ荀��
set strPlistFileName to "com.apple.finder.plist" as text


##############################################
## Boolean�����̎��O��`
##############################################
-->false = 0
set ocidFalse to (refMe's NSNumber's numberWithBool:false)'s boolValue
-->true = 1
set ocidTrue to (refMe's NSNumber's numberWithBool:true)'s boolValue

##############################################
## �t�@�C���p�X�֘A
##############################################
####�����ݒ�t�H���_
set ocidUserLibraryPath to (objFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidUserLibraryPathURL to ocidUserLibraryPath's objectAtIndex:0
set ocidPreferencesURL to ocidUserLibraryPathURL's URLByAppendingPathComponent:"Preferences"
####�t�@�C����
set ocidPlistFileName to refNSString's stringWithString:strPlistFileName
#####�t�@�C������t�^
set ocidPlistFilePathURL to ocidPreferencesURL's URLByAppendingPathComponent:strPlistFileName

##############################################
## �{����
##############################################
set ocidPlistDict to refNSMutableDictionary's alloc()'s initWithCapacity:0
####�t�@�C���ǂݍ���
set ocidReadPlistData to refNSMutableDictionary's dictionaryWithContentsOfURL:ocidPlistFilePathURL |error|:(reference)
set ocidPlistDict to item 1 of ocidReadPlistData
--> ocidPlistDict ��PLIST�̓��e���S������
##############################################
## ���݂̒l�́H
##############################################
set ocidAppleShowAllFilesValue to ocidPlistDict's valueForKey:"AppleShowAllFiles"
log ocidAppleShowAllFilesValue's integerValue()
log ocidAppleShowAllFilesValue's boolValue()

if ocidAppleShowAllFilesValue is ocidTrue then
	log "���݂̐ݒ��TRUE"
else if ocidAppleShowAllFilesValue is ocidFalse then
	log "���݂̐ݒ��FALSE"
end if
##############################################
## ���݂̐ݒ�Ƌt�̐ݒ��SET����
##############################################
####�ύX��̒l�̓�����Dict������Ă���
set ocidValueForDict to refNSMutableDictionary's alloc()'s initWithCapacity:0
ocidValueForDict's setDictionary:ocidPlistDict
(*
ocidPlistDict�ɂ͌��̒l�������Ă���̂Ńo�b�N�A�b�v����肽���ꍇ��
ocidPlistDict�̓��e��ʖ��ۑ�����Ƃ���
*)
if ocidAppleShowAllFilesValue is ocidTrue then
	log "���݂̐ݒ��TRUE"
	set strMes to "�S�t�@�C���\�����~���܂���"
	####FALSE���Z�b�g���ā@�ύX���������l�p��DICT�ɖ߂�
	ocidValueForDict's setObject:ocidFalse forKey:"AppleShowAllFiles"
else if ocidAppleShowAllFilesValue is ocidFalse then
	log "���݂̐ݒ��FALSE"
	set strMes to "�S�t�@�C���\���ɐݒ�ύX���܂���"
	####TRUE���Z�b�g����@�ύX���������l�p��DICT�ɖ߂�
	ocidValueForDict's setObject:ocidTrue forKey:"AppleShowAllFiles"
end if

##############################################
## �ύX��̒l��ۑ�����
##############################################
###�o�C�i���[�`��
set ocidNSbplist to refMe's NSPropertyListBinaryFormat_v1_0
###�������ݗp�Ƀo�C�i���[�f�[�^�ɕϊ�
set ocidPlistEditDataArray to refNSPropertyListSerialization's dataWithPropertyList:ocidValueForDict format:ocidNSbplist options:0 |error|:(reference)
set ocidPlistEditData to item 1 of ocidPlistEditDataArray
####��������
set boolWritetoUrlArray to ocidPlistEditData's writeToURL:ocidPlistFilePathURL options:0 |error|:(reference)


##############################################
## Finder���ċN��
##############################################

set ocidAppList to refMe's NSRunningApplication's runningApplicationsWithBundleIdentifier:"com.apple.finder"
if (count of ocidAppList) �� 0 then
	###Finder���擾����
	set ocidAppFinder to ocidAppList's objectAtIndex:0
	####�I��������
	ocidAppFinder's terminate()
	delay 3
	###�N��������
	set ocidNewFinderApp to refMe's NSWorkspace's sharedWorkspace()
	ocidNewFinderApp's launchAppWithBundleIdentifier:"com.apple.finder" options:(refMe's NSWorkspaceLaunchDefault) additionalEventParamDescriptor:(missing value) launchIdentifier:(missing value)
else if (count of ocidAppList) = 0 then
	###Finder�������Ȃ�N��
	set ocidNewFinderApp to refMe's NSWorkspace's sharedWorkspace()
	ocidNewFinderApp's launchAppWithBundleIdentifier:"com.apple.finder" options:(refMe's NSWorkspaceLaunchDefault) additionalEventParamDescriptor:(missing value) launchIdentifier:(missing value)
end if


return "�����I��" & strMes