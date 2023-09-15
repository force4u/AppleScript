#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##��������os12�Ȃ̂�2.8�ɂ��Ă��邾���ł�
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property objMe : a reference to current application

set listVolume to {0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100}


try
	set objResponse to (choose from list listVolume with title "�}�C�N�{�����[��" with prompt "�}�C�N�{�����[���F�I��ł�������" default items (item 1 of listVolume) OK button name "OK" cancel button name "�L�����Z��" with multiple selections allowed without empty selection allowed)
on error
	log "�G���[���܂���"
	return
end try
if objResponse is false then
	return
end if

set numVolNo to (objResponse) as integer
log numVolNo



try
	tell application "System Events" to set volume input volume numVolNo
	
	
	display notification "�}�C�NVol��" & numVolNo & "�ɂ��܂���" with title "�����I��" subtitle "�}�C�NVol��" & numVolNo & "�ɂ��܂���" sound name "Sonumi"
	log ">>>>>>>>>>>>�����I��<<<<<<<<<<<<<<<"
	return ">>>>>>>>>>>>�����I��<<<<<<<<<<<<<<<"
on error
	display notification "�G���[���܂���" with title "�G���[���܂���" subtitle "�G���[���܂���" sound name "Sonumi"
	log ">>>>>>>>>>>>�����I��<<<<<<<<<<<<<<<"
	####�G���[�����ꍇ�̓V�X�e�����ݒ���J��
	tell application "System Settings" to launch
	repeat
		try
			tell application "System Settings"
				set current pane to pane "com.apple.preference.sound"
				set thePaneID to id of current pane
			end tell
		on error
			delay 0.5
			tell application "System Settings"
				set thePaneID to id of current pane
			end tell
		end try
		if thePaneID is "com.apple.preference.sound" then
			exit repeat
		else
			delay 0.5
		end if
	end repeat
	
	--�A���J�[���w�肷��
	tell application "System Settings"
		tell current pane
			reveal anchor "input"
		end tell
	end tell
	
	return ">>>>>>>>>>>>�����I��<<<<<<<<<<<<<<<"
end try





