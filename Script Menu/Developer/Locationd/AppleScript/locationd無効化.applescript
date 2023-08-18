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
####################################設定前
##ファイル名
set strFileName to ("com.apple.locationd.notbackedup." & strDeviceUUID & ".plist") as text
##パス
set strPlistFilePath to (strPrefDirPath & strFileName) as text
##コマンド
set strCommandText to ("/usr/bin/sudo  -u  _locationd /usr/bin/defaults read \"" & strPlistFilePath & "\" LocationServicesEnabled -boolean") as text
##実行
set strResponse to (do shell script strCommandText with administrator privileges) as text
log "設定前notbackedup:" & strResponse

####################################設定前
##ファイル名
set strFileName to ("com.apple.locationd." & strDeviceUUID & ".plist") as text
##パス
set strPlistFilePath to (strPrefDirPath & strFileName) as text
##コマンド
set strCommandText to ("/usr/bin/sudo  -u  _locationd /usr/bin/defaults read \"" & strPlistFilePath & "\" LocationServicesEnabled -boolean") as text
##実行
set strResponse to (do shell script strCommandText with administrator privileges) as text
log "設定前LocationServicesEnabled:" & strResponse

####################################設定
##ファイル名
set strFileName to ("com.apple.locationd.notbackedup." & strDeviceUUID & ".plist") as text
##パス
set strPlistFilePath to (strPrefDirPath & strFileName) as text
##コマンド
set strCommandText to ("/usr/bin/sudo -u _locationd  /usr/bin/defaults write \"" & strPlistFilePath & "\" LocationServicesEnabled -boolean false") as text
##実行
doCommand2Terminal(strCommandText)
##set strResponse to (do shell script strCommandText with administrator privileges) as text
##log "設定notbackedup:" & strResponse

####################################設定
##ファイル名
set strFileName to ("com.apple.locationd." & strDeviceUUID & ".plist") as text
##パス
set strPlistFilePath to (strPrefDirPath & strFileName) as text
##コマンド
set strCommandText to ("/usr/bin/sudo  -u _locationd /usr/bin/defaults write \"" & strPlistFilePath & "\" LocationServicesEnabled -boolean false") as text
##実行
doCommand2Terminal(strCommandText)
##set strResponse to (do shell script strCommandText with administrator privileges) as text
##log "設定LocationServicesEnabled:" & strResponse

####################################
##	locationd　再起動
####################################
delay 1
##コマンド
set strCommandText to ("/usr/bin/sudo /usr/bin/killall locationd") as text
set strResponse to (do shell script strCommandText with administrator privileges) as text
log strResponse

####################################設定後
##ファイル名
set strFileName to ("com.apple.locationd.notbackedup." & strDeviceUUID & ".plist") as text
##パス
set strPlistFilePath to (strPrefDirPath & strFileName) as text
##コマンド
set strCommandText to ("/usr/bin/sudo  -u  _locationd /usr/bin/defaults read \"" & strPlistFilePath & "\" LocationServicesEnabled -boolean") as text
##実行
set strResponse to (do shell script strCommandText with administrator privileges) as text
log "設定後 notbackedup:" & strResponse

####################################設定後
##ファイル名
set strFileName to ("com.apple.locationd." & strDeviceUUID & ".plist") as text
##パス
set strPlistFilePath to (strPrefDirPath & strFileName) as text
##コマンド
set strCommandText to ("/usr/bin/sudo  -u  _locationd /usr/bin/defaults read \"" & strPlistFilePath & "\" LocationServicesEnabled -boolean") as text
##実行
set strResponse to (do shell script strCommandText with administrator privileges) as text
log "設定後LocationServicesEnabled:" & strResponse






to doCommand2Terminal(argCommandText)
	##############################
	## 実行するコマンド
	set strCommandText to argCommandText as text
	##############################
	tell application "Terminal" to activate
	delay 0.2
	## 実行中チェック
	tell application "Terminal"
		set numCntWindow to (count of every window) as integer
	end tell
	delay 0.5
	if numCntWindow = 0 then
		log "Windowないので新規で作る"
		tell application "Terminal"
			set objNewWindow to (do script "\n")
		end tell
	else
		log "Windowがある場合は、何か実行中か？をチェック"
		tell application "Terminal"
			tell front window
				tell front tab
					set boolTabStatus to busy as boolean
					set listProcess to processes as list
				end tell
			end tell
			set objNewWindow to selected tab of front window
		end tell
		###前面のタブがbusy＝実行中なら新規Window作る
		if boolTabStatus = true then
			tell application "Terminal"
				set objNewWindow to (do script "\n")
			end tell
			###前面のタブにプロセスが無い場合=exit済みの場合は新規Window作る
		else if listProcess = {} then
			tell application "Terminal"
				set objNewWindow to (do script "\n")
			end tell
		end if
	end if
	delay 0.5
	##############################
	##　コマンド実行
	tell application "Terminal"
		do script strCommandText in objNewWindow
	end tell
	delay 1
	log "コマンド実行中"
	
	##############################
	## コマンド終了チェック
	(*
objNewWindowにWindowIDとTabIDが入っているので
objNewWindowに対してbusyを確認する事で
処理が終わっているか？がわかる
*)
	## 無限ループ防止で１００回
	repeat 100 times
		tell application "Terminal"
			set boolTabStatus to busy of objNewWindow
		end tell
		if boolTabStatus is false then
			log "コマンド処理終了しました"
			tell application "Terminal"
				tell front window
					tell front tab
						set listProcess to processes as list
					end tell
				end tell
			end tell
			set numCntProcess to (count of listProcess) as integer
			if numCntProcess ≤ 2 then
				exit repeat
			else
				delay 1
			end if
			--->このリピートを抜けて次の処理へ
		else if boolTabStatus is true then
			log "コマンド処理中"
			delay 1
			--->busyなのであと1秒まつ
		end if
	end repeat
	
	##############################
	## exit打って終了
	tell application "Terminal"
		do script "exit" in objNewWindow
	end tell
	##############################
	## exitの処理待ちしてClose
	repeat 20 times
		tell application "Terminal"
			tell front window
				tell front tab
					set listProcess to processes as list
				end tell
			end tell
		end tell
		if listProcess = {} then
			tell application "Terminal"
				tell front window
					#	tell front tab
					close saving no
					#	end tell
				end tell
			end tell
			exit repeat
		else
			delay 1
		end if
	end repeat
	
	
	
end doCommand2Terminal
