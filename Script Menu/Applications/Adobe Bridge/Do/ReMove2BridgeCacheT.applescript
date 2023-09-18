#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
#	���o�[�W������Bridge�L���b�V��
#	BridgeCache��BridgeCacheT���폜���܂�
#	�I�������t�H���_�̍ŉ��w�܂ŏ������܂�
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()

tell application "Finder"
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
end tell
##############################
###�_�C�A���O��O�ʂɏo��
tell current application
	set strName to name as text
end tell
###�X�N���v�g���j���[������s������
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set strMes to "�t�H���_��I��ł�������" as text
	set strPrompt to "���o�[�W������Bridge�L���b�V���rBridgeCache��BridgeCacheT���폜���܂��r�t�H���_��I�����Ă�������" as text
	set aliasTargetDirPath to (choose folder strMes with prompt strPrompt default location aliasDefaultLocation without multiple selections allowed, invisibles and showing package contents) as alias
on error
	log "�G���[���܂���"
	return
end try
#####
set strTargetDirPath to (POSIX path of aliasTargetDirPath) as text
set ocidTargetDirPathStr to refMe's NSString's stringWithString:(strTargetDirPath)
set ocidTargetDirPath to ocidTargetDirPathStr's stringByStandardizingPath()
set ocidTargetDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidTargetDirPath) isDirectory:false)
#########################
##EMU���[�h�Ńt�@�C�����W
set ocidPropertyKeys to {(refMe's NSURLNameKey), (refMe's NSURLPathKey)}
set ocidOption to refMe's NSDirectoryEnumerationSkipsPackageDescendants
set ocidEmuDict to (appFileManager's enumeratorAtURL:(ocidTargetDirPathURL) includingPropertiesForKeys:(ocidPropertyKeys) options:(ocidOption) errorHandler:(reference))
set ocidEmuFileURLArray to ocidEmuDict's allObjects()

repeat with itemEmuPathURL in ocidEmuFileURLArray
	set listResult to (itemEmuPathURL's getResourceValue:(reference) forKey:(refMe's NSURLNameKey) |error|:(reference))
	set strFileName to (item 2 of listResult) as text
	log strFileName
	if strFileName contains ".BridgeCache" then
		###�S�~���ɓ����
		set listResult to (appFileManager's trashItemAtURL:(itemEmuPathURL) resultingItemURL:(missing value) |error|:(reference))
		###�S�~���ɓ��鎞�ɃG���[�ɂȂ������͍폜
		if (item 1 of listResult) is false then
			set listResult to (appFileManager's removeItemAtURL:(itemEmuPathURL) |error|:(reference))
		end if
	else if strFileName is ".DS_Store" then
		##DS_Store�̍폜�����Ȃ��ꍇ�̓R�����g�A�E�g
		set listResult to (appFileManager's trashItemAtURL:(itemEmuPathURL) resultingItemURL:(missing value) |error|:(reference))
	end if
end repeat

## �ʏ�L���b�V�����폜���Ȃ��ꍇ�͂�����return��
# return
#########################
##
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSCachesDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidCachesDirURL to ocidURLsArray's firstObject()
set ocidMoveToTrashPathURL to ocidCachesDirURL's URLByAppendingPathComponent:("com.adobe.bridge13")
set listResult to (appFileManager's trashItemAtURL:(ocidMoveToTrashPathURL) resultingItemURL:(ocidMoveToTrashPathURL) |error|:(reference))
set ocidMoveToTrashPathURL to ocidCachesDirURL's URLByAppendingPathComponent:("com.adobe.bridge14")
set listResult to (appFileManager's trashItemAtURL:(ocidMoveToTrashPathURL) resultingItemURL:(ocidMoveToTrashPathURL) |error|:(reference))
set ocidMoveToTrashPathURL to ocidCachesDirURL's URLByAppendingPathComponent:("Adobe/Bridge")
set listResult to (appFileManager's trashItemAtURL:(ocidMoveToTrashPathURL) resultingItemURL:(ocidMoveToTrashPathURL) |error|:(reference))
set ocidMoveToTrashPathURL to ocidCachesDirURL's URLByAppendingPathComponent:("Adobe/Bridge 2023")
set listResult to (appFileManager's trashItemAtURL:(ocidMoveToTrashPathURL) resultingItemURL:(ocidMoveToTrashPathURL) |error|:(reference))
set ocidMoveToTrashPathURL to ocidCachesDirURL's URLByAppendingPathComponent:("Adobe/Bridge 2024")
set listResult to (appFileManager's trashItemAtURL:(ocidMoveToTrashPathURL) resultingItemURL:(ocidMoveToTrashPathURL) |error|:(reference))
###
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidApplicationSupportDirURL to ocidURLsArray's firstObject()
set ocidMoveToTrashPathURL to ocidApplicationSupportDirURL's URLByAppendingPathComponent:("Adobe/Bridge 2023/logs")
set listResult to (appFileManager's trashItemAtURL:(ocidMoveToTrashPathURL) resultingItemURL:(ocidMoveToTrashPathURL) |error|:(reference))
set ocidMoveToTrashPathURL to ocidApplicationSupportDirURL's URLByAppendingPathComponent:("Adobe/Bridge 2023/CT Font Cache")
set listResult to (appFileManager's trashItemAtURL:(ocidMoveToTrashPathURL) resultingItemURL:(ocidMoveToTrashPathURL) |error|:(reference))

set ocidMoveToTrashPathURL to ocidApplicationSupportDirURL's URLByAppendingPathComponent:("Adobe/Bridge 2023/logs")
set listResult to (appFileManager's trashItemAtURL:(ocidMoveToTrashPathURL) resultingItemURL:(ocidMoveToTrashPathURL) |error|:(reference))
set ocidMoveToTrashPathURL to ocidApplicationSupportDirURL's URLByAppendingPathComponent:("Adobe/Bridge 2024/CT Font Cache")
set listResult to (appFileManager's trashItemAtURL:(ocidMoveToTrashPathURL) resultingItemURL:(ocidMoveToTrashPathURL) |error|:(reference))
