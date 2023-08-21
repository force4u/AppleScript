#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# Automator ���[�N�t���[�p (�N�C�b�N�A�N�V����)
# ���[�N�t���[���󂯎��̂́w�t�H���_�x �A�v���P�[�V�����́wFinder�x
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application


set strBundleID to "jp.tmkk.XLD" as text

###�A�v���P�[�V�����̃C���X�g�[����
set ocidAppInstallPathURL to doGetBundleID2AppURL(strBundleID)
set ocidContainerDirPathURL to ocidAppInstallPathURL's URLByDeletingLastPathComponent()

set ocidSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolSelectFileResults to ocidSharedWorkspace's selectFile:(ocidAppInstallPathURL's |path|) inFileViewerRootedAtPath:(ocidContainerDirPathURL's |path|)
if boolSelectFileResults is false then
	tell application "Finder"
		set aliasAppApth to (application file id strBundleID) as alias
		set aliasContainerDirPath to (container of aliasAppApth) as alias
		open aliasContainerDirPath
	end tell
end if
###################################
### �o���h��ID����A�v���P�[�V����URL
###################################
to doGetBundleID2AppURL(argBundleID)
	set strBundleID to argBundleID as text
	set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
	##�o���h��ID����A�v���P�[�V������URL���擾
	set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(argBundleID))
	if ocidAppBundle �� (missing value) then
		set ocidAppPathURL to ocidAppBundle's bundleURL()
	else if ocidAppBundle = (missing value) then
		set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(argBundleID))
	end if
	##�\���i�A�v���P�[�V������URL�j
	if ocidAppPathURL = (missing value) then
		tell application "Finder"
			try
				set aliasAppApth to (application file id strBundleID) as alias
				set strAppPath to (POSIX path of aliasAppApth) as text
				set strAppPathStr to refMe's NSString's stringWithString:(strAppPath)
				set strAppPath to strAppPathStr's stringByStandardizingPath()
				set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(strAppPath) isDirectory:true
			on error
				return "�A�v���P�[�V������������܂���ł���"
			end try
		end tell
	end if
	return ocidAppPathURL
end doGetBundleID2AppURL