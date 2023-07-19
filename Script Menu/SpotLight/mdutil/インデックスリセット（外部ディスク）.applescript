#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set appFileManager to refMe's NSFileManager's defaultManager()
set boolTrue to refMe's NSNumber's numberWithBool:true
set boolFalse to refMe's NSNumber's numberWithBool:false

####bool値を定義
set boolTrue to refMe's NSNumber's numberWithBool:true
set boolFalse to refMe's NSNumber's numberWithBool:false
####ボリュームリスト
set ocidResourceArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
ocidResourceArray's addObject:(refMe's NSURLVolumeIsEjectableKey)
ocidResourceArray's addObject:(refMe's NSURLVolumeIsInternalKey)

set ocidDriveListArray to appFileManager's mountedVolumeURLsIncludingResourceValuesForKeys:ocidResourceArray options:(refMe's NSVolumeEnumerationSkipHiddenVolumes)
set listDriveListArray to ocidDriveListArray as list

try
	tell current application
		activate
		set listResponse to (choose from list listDriveListArray with title "選んでください" with prompt "牽引インデックスのリセットを実行します\r外部ディスクを選んでください" default items (item 2 of listDriveListArray) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed and empty selection allowed) as list
	end tell
on error
	log "エラーしました"
	return "エラーしました"
	error "エラーしました" number -200
end try
if (count of listResponse) = 0 then
	log "選択無しの場合の処理"
	return "選択無しでした"
else if (item 1 of listResponse) is false then
	return "キャンセルしました"
	error "キャンセルしました" number -200
end if


###ボリュームの数だけ繰り返し
repeat with itemResponse in listResponse
	###リスト内は«class furl»なのでエリアスで確定させてから
	set aliasVolumePath to itemResponse as alias
	set strVolumePath to POSIX path of aliasVolumePath as text
	###パスとURL
	set ocidVolumePathStr to (refMe's NSString's stringWithString:(strVolumePath))
	set ocidVolumePath to ocidVolumePathStr's stringByStandardizingPath
	set ocidVolumePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidVolumePath) isDirectory:true)
	
	####getResourceValue
	set listResponseArray to (ocidVolumePathURL's getResourceValue:(reference) forKey:(refMe's NSURLVolumeIsInternalKey) |error|:(missing value))
	set ocidResourceValue to item 2 of listResponseArray
	if ocidResourceValue is (missing value) then
		log "ネットワークマウンドドライブ"
	else if ocidResourceValue is boolTrue then
		log "起動ディスク 又は内臓パーティション"
	else if ocidResourceValue is boolFalse then
		log "外付けドライブ"
		set strVolumePath to (ocidVolumePathURL's |path|()) as text
		###コマンド１　インデックス削除して
		set strCommandText01 to "/usr/bin/mdutil -d \"" & strVolumePath & "/\"" as text
		###コマンド２　再作成
		set strCommandText02 to "/usr/bin/mdutil -i on  \"" & strVolumePath & "/\"" as text
		##############################
		###起動 Terminal
		tell application "Terminal" to launch
		###起動待ち　最大１０秒
		repeat 20 times
			tell application "Terminal"
				activate
				set boolFrontMost to frontmost as boolean
			end tell
			if boolFrontMost = true then
				exit repeat
			else
				delay 0.5
			end if
		end repeat
		
		####ターミナルで開く
		tell application "Terminal"
			activate
			set objNewWindow to (do script "\n\n")
			delay 1
			do script strCommandText01 in objNewWindow
			delay 2
			do script strCommandText02 in objNewWindow
		end tell
	end if
	
end repeat
################################
######処理の終了のチェック
################################
## 無限ループ防止で１００回
repeat 100 times
	tell application "Terminal"
		set boolTabStatus to busy of objNewWindow
	end tell
	if boolTabStatus is false then
		log "コマンド処理終了しました"
		exit repeat
		--->このリピートを抜けて次の処理へ
	else if boolTabStatus is true then
		log "コマンド処理中"
		delay 1
		--->busyなのであと1秒まつ
	end if
end repeat
tell application "Terminal" to activate
################################
######exit打って終了
################################
tell application "Terminal"
	do script "exit" in objNewWindow
end tell
################################
######ウィンドウを閉じる
################################
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
################################
######ターミナルを終了させる
################################
tell application "Terminal"
	quit saving no
end tell
