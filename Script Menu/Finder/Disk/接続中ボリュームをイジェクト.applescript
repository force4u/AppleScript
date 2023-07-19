#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions


property refMe : a reference to current application


###初期化
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set appFileManager to refMe's NSFileManager's defaultManager()
####bool値を定義
set boolTrue to refMe's NSNumber's numberWithBool:true
set boolFalse to refMe's NSNumber's numberWithBool:false
#############################################
###ボリュームリストを取得
set ocidResourceArray to refMe's NSMutableArray's alloc()'s initWithCapacity:0
ocidResourceArray's addObject:(refMe's NSURLVolumeIsRemovableKey)
ocidResourceArray's addObject:(refMe's NSURLVolumeIsInternalKey)
ocidResourceArray's addObject:(refMe's NSURLVolumeIsEjectableKey)
ocidResourceArray's addObject:(refMe's NSURLVolumeIsLocalKey)
set ocidDriveListArray to appFileManager's mountedVolumeURLsIncludingResourceValuesForKeys:(ocidResourceArray) options:(refMe's NSVolumeEnumerationSkipHiddenVolumes)

#############################################
###ボリュームのURLの数だけ繰り返し
##外付けでイジェクト可能なドライブリストを格納する
set ocidDriveLisArrayM to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
####
repeat with itemDriveURL in ocidDriveListArray
	###キーを取り出して
	set listResDict to (itemDriveURL's resourceValuesForKeys:(ocidResourceArray) |error|:(reference))
	set ocidResourceValuesDict to item 1 of listResDict
	###内臓ドライブか？
	set boolIsInternal to (ocidResourceValuesDict's objectForKey:(refMe's NSURLVolumeIsInternalKey))
	###ローカルデバイスか？ true でローカル　falseでネットワークドライブ
	set boolLocal to (ocidResourceValuesDict's objectForKey:(refMe's NSURLVolumeIsLocalKey))
	###外付けで
	if boolIsInternal = boolFalse then
		##対象に加える
		(ocidDriveLisArrayM's addObject:(itemDriveURL's |path|() as text))
		###リムーバブル＝USBメモリー等か
		set boolRemovable to (ocidResourceValuesDict's objectForKey:(refMe's NSURLVolumeIsRemovableKey))
		if boolRemovable = boolTrue then
			#		log "リムーバブル＝USBメモリー"
		end if
		###イジェクト＝排出可能か？　※アンマウント出来るとは違う
		set boolEjectable to (ocidResourceValuesDict's objectForKey:(refMe's NSURLVolumeIsEjectableKey))
		if boolEjectable = boolTrue then
			#		log "イジェクト可能＝CD/DVDやUSBメモリ"
		end if
		###ネットワークドライブ
	else if boolLocal = boolFalse then
		##対象に加える
		(ocidDriveLisArrayM's addObject:(itemDriveURL's |path|() as text))
	end if
end repeat

#############################################
###ダイアログを前面に
tell current application
	set strName to name as text
end tell
####スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###ダイアログ用にリストに
set listDriveList to ocidDriveLisArrayM as list

try
	tell current application
		activate
		set listResponse to (choose from list listDriveList with title "選んでください" with prompt "アンマウントします" default items (item 1 of listDriveList) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed and empty selection allowed) as list
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
	###NSURLにする
	set ocidFilePath to (refMe's NSString's stringWithString:(itemResponse))
	set ocidFilePath to ocidFilePath's stringByStandardizingPath
	set ocidFilePathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidFilePath) isDirectory:false)
	set ocidResulut to (appSharedWorkspace's unmountAndEjectDeviceAtURL:(ocidFilePathURL) |error|:(reference))
	if (item 1 of ocidResulut) = false then
		doGetErrorData(item 2 of ocidResulut) as list
	end if
end repeat

to doGetErrorData(ocidNSErrorData)
	#####個別のエラー情報
	log "エラーコード：" & ocidNSErrorData's code() as text
	log "エラードメイン：" & ocidNSErrorData's domain() as text
	set strMes to ("Description:" & ocidNSErrorData's localizedDescription()) as text
	if strMes contains "-47" then
		set strMes to "使用中のファイルがあります\r" & strMes
		display alert strMes
	else
		display alert strMes
	end if
	log "FailureReason:" & ocidNSErrorData's localizedFailureReason() as text
	log ocidNSErrorData's localizedRecoverySuggestion() as text
	log ocidNSErrorData's localizedRecoveryOptions() as text
	log ocidNSErrorData's recoveryAttempter() as text
	log ocidNSErrorData's helpAnchor() as text
	set ocidNSErrorUserInfo to ocidNSErrorData's userInfo()
	set ocidAllValues to ocidNSErrorUserInfo's allValues() as list
	set ocidAllKeys to ocidNSErrorUserInfo's allKeys() as list
	repeat with ocidKeys in ocidAllKeys
		if (ocidKeys as text) is "NSUnderlyingError" then
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s localizedDescription() as text
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s localizedFailureReason() as text
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s localizedRecoverySuggestion() as text
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s localizedRecoveryOptions() as text
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s recoveryAttempter() as text
			log (ocidNSErrorUserInfo's valueForKey:ocidKeys)'s helpAnchor() as text
		else
			####それ以外の値はそのままテキストで読める
			log (ocidKeys as text) & ": " & (ocidNSErrorUserInfo's valueForKey:ocidKeys) as text
		end if
	end repeat
	
end doGetErrorData
