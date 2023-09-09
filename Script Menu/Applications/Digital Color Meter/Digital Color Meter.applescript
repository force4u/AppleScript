#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "Appkit"
use framework "UniformTypeIdentifiers"
use scripting additions
property refMe : a reference to current application


set strBundleID to ("com.apple.DigitalColorMeter") as text

set boolUseDefaults to false as boolean
###########################
###起動していれば一旦終了
###########################
set ocidRunningApplication to current application's NSRunningApplication
set ocidAppArray to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
repeat with itemAppArray in ocidAppArray
	itemAppArray's terminate
end repeat
###########################
##	 ダイアログ
###########################
(*	 colorSpace
0:ネイティブの値を表示	538.title
1:P3で表示	DisplayP3String
2:sRGBで表示	539.title
3:汎用のRGBで表示	540.title
4:Adobe RGBで表示		576.title
5:L*a*b*で表示	802.title
*)
set recordTitle to {|ネイティブの値を表示|:0, |P3で表示|:1, |sRGBで表示|:2, |汎用のRGBで表示\t|:3, |Adobe RGBで表示|:4, |L*a*b*で表示|:5} as record
set ocidListDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
ocidListDict's setDictionary:(recordTitle)
set ocidAllKeys to ocidListDict's allKeys()
set listAllKeys to ocidAllKeys as list
#####ダイアログを前面に
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###ダイアログ
try
	set listResponse to (choose from list listAllKeys with title "選んでください" with prompt "選んでください" default items (item 2 of listAllKeys) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
set strResponse to (item 1 of listResponse) as text
set numSelectNo to (ocidListDict's valueForKey:(strResponse)) as integer
log numSelectNo

if boolUseDefaults is false then
	###デバイスUUID
	set strCommandText to ("/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Hardware UUID/{print $3}'") as text
	set strDeviceUUID to (do shell script strCommandText) as text
	set strFileName to ("com.apple.DigitalColorMeter2." & strDeviceUUID & ".plist") as text
	###
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidLibraryDirPathURL to ocidURLsArray's firstObject()
	set ocidByHostDirPathURL to ocidLibraryDirPathURL's URLByAppendingPathComponent:("Preferences/ByHost")
	set ocidPlistFilePathURL to ocidByHostDirPathURL's URLByAppendingPathComponent:(strFileName)
	##
	set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidPlistFilePathURL)
	##	カラースペース選択
	ocidPlistDict's setValue:(refMe's NSNumber's numberWithInteger:numSelectNo) forKey:("colorSpace")
	##	displayMode
	(*
0:10進		776.title
1:16進		777.title
2パーセント	778.title
*)
	ocidPlistDict's setValue:(refMe's NSNumber's numberWithInteger:0) forKey:("displayMode")
	##	連続的にアップデート	758.title
	ocidPlistDict's setValue:(refMe's NSNumber's numberWithInteger:1) forKey:("updateContinuously")
	##	マウスの位置を表示	756.title
	ocidPlistDict's setValue:(refMe's NSNumber's numberWithInteger:1) forKey:("showMouseLocation")
	##保存
	set boolDone to ocidPlistDict's writeToURL:(ocidPlistFilePathURL) atomically:true
else if boolUseDefaults is true then
	
	set strCommandText to ("/usr/bin/defaults -currentHost write com.apple.DigitalColorMeter2 colorSpace -integer " & numSelectNo & "") as text
	do shell script strCommandText
	set strCommandText to ("/usr/bin/defaults -currentHost write com.apple.DigitalColorMeter2 displayMode -integer 0") as text
	do shell script strCommandText
	set strCommandText to ("/usr/bin/defaults -currentHost write com.apple.DigitalColorMeter2 updateContinuously -integer 1") as text
	do shell script strCommandText
	set strCommandText to ("/usr/bin/defaults -currentHost write com.apple.DigitalColorMeter2 showMouseLocation -integer 1") as text
	do shell script strCommandText
else
	set strCommandText to ("/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Hardware UUID/{print $3}'") as text
	set strDeviceUUID to (do shell script strCommandText) as text
	set strFileName to ("com.apple.DigitalColorMeter2." & strDeviceUUID & ".plist") as text
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidLibraryDirPathURL to ocidURLsArray's firstObject()
	set ocidByHostDirPathURL to ocidLibraryDirPathURL's URLByAppendingPathComponent:("Preferences/ByHost")
	set ocidPlistFilePathURL to ocidByHostDirPathURL's URLByAppendingPathComponent:(strFileName)
	set strPlistFilePathURL to (ocidPlistFilePathURL's |path|()) as text
	
	try
		set strCommandText to ("/usr/libexec/PlistBuddy -c \"Set:colorSpace integer " & numSelectNo & "\" \"" & strPlistFilePathURL & "\"") as text
		do shell script strCommandText
		set strCommandText to ("/usr/libexec/PlistBuddy -c \"Set:displayMode integer 0\" \"" & strPlistFilePathURL & "\"") as text
		do shell script strCommandText
		set strCommandText to ("/usr/libexec/PlistBuddy -c \"Set:updateContinuously integer 1\" \"" & strPlistFilePathURL & "\"") as text
		do shell script strCommandText
		set strCommandText to ("/usr/libexec/PlistBuddy -c \"Set:showMouseLocation integer 1\" \"" & strPlistFilePathURL & "\"") as text
		do shell script strCommandText
	end try
	set strCommandText to ("/usr/libexec/PlistBuddy -c \"Save\" \"" & strPlistFilePathURL & "\"") as text
	do shell script strCommandText
end if


delay 0.2
#####CFPreferencesを再起動させて変更後の値をロードさせる
set strCommandText to "/usr/bin/killall cfprefsd" as text
do shell script strCommandText
delay 0.2

tell application id strBundleID to launch
tell application id strBundleID to activate

