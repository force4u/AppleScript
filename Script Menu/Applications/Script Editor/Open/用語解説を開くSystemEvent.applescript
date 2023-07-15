#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application

set strBundleID to "com.apple.systemevents" as text


###�A�v���P�[�V�����̃C���X�g�[����
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
###�G���A�X�ɂ���
set aliasApplicationPath to (ocidAppPathURL's absoluteURL()) as alias
###�A�v���P�[�V�������X�N���v�g�G�f�B�^�ŊJ��
tell application "Script Editor"
	open aliasApplicationPath
end tell