#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions



###デバイスUUIDを取得する
set strCommandText to ("/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Hardware UUID/{print $3}'") as text
set strDeviceUUID to (do shell script strCommandText) as text
###ディレクトリ
set strPrefDirPath to ("/private/var/db/locationd/Library/Preferences/ByHost/") as text
####################################
##ファイル名
set strFileName to ("com.apple.locationd.notbackedup." & strDeviceUUID & ".plist") as text
##パス
set strPlistFilePath to (strPrefDirPath & strFileName) as text
##コマンド
set strCommandText to ("/usr/bin/sudo -u _locationd  /usr/bin/defaults read \"" & strPlistFilePath & "\" LocationServicesEnabled -boolean") as text
##実行
set strResponse to (do shell script strCommandText with administrator privileges) as text
log "notbackedup:" & strResponse

####################################
##ファイル名
set strFileName to ("com.apple.locationd." & strDeviceUUID & ".plist") as text
##パス
set strPlistFilePath to (strPrefDirPath & strFileName) as text
##コマンド
set strCommandText to ("/usr/bin/sudo -u _locationd  /usr/bin/defaults read \"" & strPlistFilePath & "\" LocationServicesEnabled -boolean") as text
##実行
set strResponse to (do shell script strCommandText with administrator privileges) as text
log "LocationServicesEnabled:" & strResponse

log "0=FALSE=無効 1=TRUE=有効"
