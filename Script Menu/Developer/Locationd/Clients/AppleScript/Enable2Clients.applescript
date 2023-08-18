#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#	要管理者権限
# 
#	
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "Appkit"
use scripting additions
property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()


####################################
###パス
####################################
set recordSystemInfo to (system info) as record
set strUNAME to (short user name of recordSystemInfo) as text
##ファイル名　
set strPlistFileName to ("clients.plist") as text
##パス
set strDbDirPath to ("/private/var/db/locationd/") as text
set strFilePath to ("" & strDbDirPath & strPlistFileName & "") as text
##パス
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
####################################
###アクセス権変更
####################################
set strCommandText to ("/usr/bin/sudo  /usr/sbin/chown " & strUNAME & " \"" & strDbDirPath & "\"") as text
doCommand2Terminal(strCommandText)
set strCommandText to ("/usr/bin/sudo /usr/sbin/chown " & strUNAME & " \"" & strFilePath & "\"") as text
doCommand2Terminal(strCommandText)

####################################
###PLIST
####################################

### 読み込み
set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithContentsOfURL:(ocidFilePathURL)
###AllKey
set ocidAllKyesArray to ocidPlistDict's allKeys()
set listAllKyesArray to ocidAllKyesArray as list

####################################
###ダイアログ
####################################
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder"
		activate
	end tell
else
	tell current application
		activate
	end tell
end if
try
	set listResponse to (choose from list listAllKyesArray with title "選んでください" with prompt "有効にする項目を選んでください" default items (item 1 of listAllKyesArray) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed without empty selection allowed) as list
on error
	####################################
	###アクセス権 を戻す
	####################################
	set strCommandText to ("/usr/bin/sudo /usr/sbin/chown _locationd  \"" & strFilePath & "\"") as text
	doCommand2Terminal(strCommandText)
	set strCommandText to ("/usr/bin/sudo /usr/sbin/chown _locationd  \"" & strDbDirPath & "\"") as text
	doCommand2Terminal(strCommandText)
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	####################################
	###アクセス権 を戻す
	####################################
	set strCommandText to ("/usr/bin/sudo /usr/sbin/chown _locationd  \"" & strFilePath & "\"") as text
	doCommand2Terminal(strCommandText)
	set strCommandText to ("/usr/bin/sudo /usr/sbin/chown _locationd  \"" & strDbDirPath & "\"") as text
	doCommand2Terminal(strCommandText)
	log "キャンセルしました"
	return "キャンセルしました"
end if

####################################
### 本処理項目削除
####################################
repeat with itemResponse in listResponse
	set strItemKey to itemResponse as text
	set ocidSubDict to (ocidPlistDict's objectForKey:(strItemKey))
	(ocidSubDict's setValue:(refMe's NSNumber's numberWithBool:true) forKey:("Authorized"))
end repeat


####################################
### 保存
####################################
set listDone to ocidPlistDict's writeToURL:(ocidFilePathURL) |error|:(reference)

####################################
###アクセス権 を戻す
####################################
set strCommandText to ("/usr/bin/sudo /usr/sbin/chown _locationd  \"" & strFilePath & "\"") as text
doCommand2Terminal(strCommandText)
set strCommandText to ("/usr/bin/sudo /usr/sbin/chown _locationd  \"" & strDbDirPath & "\"") as text
doCommand2Terminal(strCommandText)



####################################
##	locationd　再起動
####################################
##コマンド
set strCommandText to ("/usr/bin/sudo /usr/bin/killall -HUP locationd") as text
set strResponse to (do shell script strCommandText with administrator privileges) as text
log strResponse







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
