#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# �@mobileconfig�p
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "UniformTypeIdentifiers"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application

###�A�v���P�[�V�����̃o���h��ID
set strBundleID to "com.google.Chrome"
###�G���[����
tell application id strBundleID
	set numWindow to (count of every window) as integer
end tell
if numWindow = 0 then
	return "Window�������̂ŏ����ł��܂���"
end if

###URL�ƃ^�C�g�����擾
tell application "Google Chrome"
	tell front window
		tell active tab
			activate
			set strURL to URL as text
			set strTITLE to title as text
		end tell
	end tell
end tell
### �n�����W���o��
set ocidURLString to refMe's NSString's stringWithString:(strURL)
set ocidURL to refMe's NSURL's alloc()'s initWithString:(ocidURLString)
set ocidComponents to refMe's NSURLComponents's alloc()'s initWithURL:(ocidURL) resolvingAgainstBaseURL:(false)
set ocidQueryItems to ocidComponents's queryItems()
repeat with itemQueryItems in ocidQueryItems
	if (itemQueryItems's |name|() as text) is "cp" then
		set ocidCoordinates to (itemQueryItems's value())
		set ocidCoordinatesArray to (ocidCoordinates's componentsSeparatedByString:("~"))
		set ocidLatitude to (ocidCoordinatesArray's objectAtIndex:(0))
		set ocidLongitude to (ocidCoordinatesArray's objectAtIndex:(1))
	end if
	if (itemQueryItems's |name|() as text) is "lvl" then
		set ocidAltitude to (itemQueryItems's value())
		
	end if
end repeat
###
### �ܓx�o�x��GEO�o�[�R�[�h�@�Ή��@��ɐ���������ꍇ����
set strChl to ("http://maps.apple.com/?q=" & (ocidLatitude as text) & "," & (ocidLongitude as text) & "," & (ocidAltitude as text) & "z") as text

#####################
###�o���オ����MATMSG�e�L�X�g
log strChl
##BASE URL
set theApiUrl to "https://chart.googleapis.com/chart?" as text
##API��
set theCht to "qr" as text
##�d�オ��T�C�Ypx(72�̔{������)�@72 144 288 360 576 720 1080
set theChs to "540x540" as text
## �e�L�X�g�̃G���R�[�h �K���g�Ή�����Ȃ�SJIS��I��
set theChoe to "UTF-8" as text
##�덷�␳�@L M Q R
set theChld to "M" as text
##URL�𐮌`
set strURL to ("" & theApiUrl & "&cht=" & theCht & "&chs=" & theChs & "&choe=" & theChoe & "&chld=" & theChld & "&chl=" & strChl & "") as text
log strURL

tell application id strBundleID
	activate
	open location strURL
end tell