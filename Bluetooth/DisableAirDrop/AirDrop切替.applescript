#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#error number -128
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application


###今の設定
set strFilePath to "~/Library/Preferences/com.apple.NetworkBrowser.plist"
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's fileURLWithPath:(ocidFilePath)
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL)
set boolValue to (ocidPlistDict's valueForKey:("DisableAirDrop"))


if boolValue = (refMe's NSNumber's numberWithBool:false) then
	set strMes to "AirDropが有効です 無効にします"
	set listButtons to {"AirDrop無効にします", "AirDrop有効にします", "キャンセル"}
else
	set strMes to "AirDropが無効です 有効にします"
	set listButtons to {"AirDrop有効にします", "AirDrop無効にします", "キャンセル"}
end if
#####ダイアログ
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if

set aliasIconPath to POSIX file "/System/Library/CoreServices/Finder.app/Contents/Applications/AirDrop.app/Contents/Resources/OpenAirDropAppIcon.icns" as alias
set strDefaultAnswer to strMes as text
try
	set recordResponse to (display dialog strMes with title "選んでください" buttons listButtons default button (item 1 of listButtons) cancel button (item 3 of listButtons) with icon aliasIconPath giving up after 20 without hidden answer)
on error
	log "エラーしました"
	return "エラーしました"
end try
if true is equal to (gave up of recordResponse) then
	return "時間切れですやりなおしてください"
end if
if "AirDrop無効にします" is equal to (button returned of recordResponse) then
	set boolAirDrop to true as boolean
else if "AirDrop有効にします" is equal to (button returned of recordResponse) then
	set boolAirDrop to false as boolean
else
	log "キャンセルしました"
	return "キャンセルしました"
end if

###コマンド実行
if boolAirDrop = true then
	log "AirDropが有効です"
	ocidPlistDict's setObject:(refMe's NSNumber's numberWithBool:true) forKey:"DisableAirDrop"
	log "AirDropを無効に切り替えました"
else
	log "AirDropが無効です"
	ocidPlistDict's setObject:(refMe's NSNumber's numberWithBool:false) forKey:"DisableAirDrop"
	log "AirDropを有効に切り替えました"
end if

set boolDone to ocidPlistDict's writeToURL:(ocidFilePathURL) atomically:true


###CFPreferencesを再起動
set strCommandText to "/usr/bin/killall cfprefsd" as text
do shell script strCommandText

###Finder再起動
set strBundleID to "com.apple.finder" as text
set ocidRunningApplication to refMe's NSRunningApplication
set ocidAppList to ocidRunningApplication's runningApplicationsWithBundleIdentifier:(strBundleID)
###アプリケーションのURLを取得しておく
set ocidAppBundle to refMe's NSBundle's bundleWithIdentifier:(strBundleID)
if ocidAppBundle is not (missing value) then
	set ocidAppPathURL to ocidAppBundle's bundleURL()
else
	set appWorkspace to refMe's NSWorkspace's sharedWorkspace()
	set ocidAppPathURL to appWorkspace's URLForApplicationWithBundleIdentifier:(strBundleID)
end if
if (count of ocidAppList) ≠ 0 then
	###Finderを取得して
	set ocidAppFinder to ocidAppList's objectAtIndex:0
	####終了させて
	ocidAppFinder's terminate()
end if
(*
NSRunningApplicationの戻り値にタイムラグがあるため
少し待つ処理を加えた
*)
repeat 5 times
	delay 1
	set ocidRunApp to refMe's NSRunningApplication
	set ocidAppList to ocidRunApp's runningApplicationsWithBundleIdentifier:(strBundleID)
	if (count of ocidAppList) = 0 then
		###Finderが無いなら起動
		set appWorkspace to refMe's NSWorkspace's sharedWorkspace()
		set ocidOpenConfig to refMe's NSWorkspaceOpenConfiguration's configuration
		ocidOpenConfig's setHides:(refMe's NSNumber's numberWithBool:false)
		ocidOpenConfig's setActivates:(refMe's NSNumber's numberWithBool:true)
		ocidOpenConfig's setRequiresUniversalLinks:(refMe's NSNumber's numberWithBool:false)
		appWorkspace's openApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value)
	else
		###あるなら起動確認終了
		delay 1
		set ocidAppList to ocidRunApp's runningApplicationsWithBundleIdentifier:(strBundleID)
		if (count of ocidAppList) = 0 then
			###Finderが無いなら起動
			set appWorkspace to refMe's NSWorkspace's sharedWorkspace()
			set ocidOpenConfig to refMe's NSWorkspaceOpenConfiguration's configuration
			ocidOpenConfig's setHides:(refMe's NSNumber's numberWithBool:false)
			ocidOpenConfig's setActivates:(refMe's NSNumber's numberWithBool:true)
			ocidOpenConfig's setRequiresUniversalLinks:(refMe's NSNumber's numberWithBool:false)
			appWorkspace's openApplicationAtURL:(ocidAppPathURL) configuration:(ocidOpenConfig) completionHandler:(missing value)
		end if
		exit repeat
	end if
	
end repeat
