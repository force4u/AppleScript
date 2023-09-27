#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

###�N��
tell application id "com.apple.systempreferences" to activate
##############################
#####�_�C�A���O��O�ʂɏo��
##############################
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
##############################
#####�_�C�A���O
##############################
tell application "Finder"
	set aliasDesktopPath to path to desktop folder from user domain as alias
end tell
set aliasFilePath to (choose file with prompt "mobileconfig��I��ł�������" default location (aliasDesktopPath) of type {"com.apple.mobileconfig"} with invisibles and showing package contents without multiple selections allowed) as alias
set strFilePath to POSIX path of aliasFilePath



###�N���҂�
tell application id "com.apple.systempreferences"
	###�N���m�F�@�ő�P�O�b
	repeat 10 times
		activate
		set boolFrontMost to frontmost as boolean
		if boolFrontMost is true then
			exit repeat
		else
			delay 1
		end if
	end repeat
end tell

set strPaneId to "com.apple.Profiles-Settings.extension" as text
set strAnchorName to "Main" as text

###�A���J�[�ŊJ��
tell application id "com.apple.systempreferences"
	launch
	activate
	reveal anchor strAnchorName of pane id strPaneId
end tell
###�A���J�[�ŊJ���̑҂��@�ő�P�O�b
repeat 10 times
	tell application id "com.apple.systempreferences"
		tell pane id strPaneId
			set listAnchorName to name of anchors
		end tell
		if listAnchorName is missing value then
			delay 1
		else if listAnchorName is {"Main"} then
			exit repeat
		end if
	end tell
end repeat

tell application "Finder"
	
	set theCmdCom to ("open  �"" & strFilePath & "�" | open �"x-apple.systempreferences:com.apple.preferences.configurationprofiles�"") as text
	do shell script theCmdCom
end tell



