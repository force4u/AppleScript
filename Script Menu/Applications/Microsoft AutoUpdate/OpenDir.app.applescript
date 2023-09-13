#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
com.cocolog-nifty.quicktimer.icefloe
*)
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

###�A�v���P�[�V�����̃o���h��ID
set strBundleID to "com.microsoft.autoupdate2"
################################################
###### �C���X�g�[���ς݂̃p�[�W����
################################################
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
##�o���h������A�v���P�[�V������URL���擾
set ocidAppBundle to (refMe's NSBundle's bundleWithIdentifier:(strBundleID))
if ocidAppBundle �� (missing value) then
	set ocidAppPathURL to ocidAppBundle's bundleURL()
else if ocidAppBundle = (missing value) then
	set ocidAppPathURL to (appSharedWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID))
end if
##�\���i�A�v���P�[�V������URL�j
if ocidAppPathURL = (missing value) then
	tell application "Finder"
		try
			set aliasAppApth to (application file id strBundleID) as alias
			set strAppPath to POSIX path of aliasAppApth as text
			set strAppPathStr to refMe's NSString's stringWithString:(strAppPath)
			set strAppPath to strAppPathStr's stringByStandardizingPath()
			set ocidAppPathURL to refMe's NSURL's alloc()'s initFileURLWithPath:(strAppPath) isDirectory:true
		on error
			return "�A�v���P�[�V������������܂���ł���"
		end try
	end tell
end if

set ocidContainerDirPathURL to ocidAppPathURL's URLByDeletingLastPathComponent()

################################################
###### Finder�\��
################################################
set appShardWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appShardWorkspace's selectFile:(ocidAppPathURL's |path|()) inFileViewerRootedAtPath:(ocidContainerDirPathURL's |path|())




