#! /usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
(*
保存したWINDOW設定を削除する
システム環境設定＞＞セキュリティとプライバシー＞＞プライバシー
アクセシビリティのタブで
SystemUIServer.appに対して制御を許可してください
20180211 10.6x用を書き直し
20180214　10.11に対応
20240520 macOS14に対応
*)
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application
set appFileManager to refMe's NSFileManager's defaultManager()

#################################
###設定ファイル保存先　Application Support
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidApplicatioocidupportDirPathURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidApplicatioocidupportDirPathURL's URLByAppendingPathComponent:("com.cocolog-nifty.quicktimer/SaveFinderWindow")
###設定ファイル
set ocidPlistFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("com.apple.finder.save.window.plist") isDirectory:(false)
#################################
##設定ファイルの有無チェック
set ocidPlistFilePath to ocidPlistFilePathURL's |path|()
set boolDirExists to appFileManager's fileExistsAtPath:(ocidPlistFilePath) isDirectory:(false)
if boolDirExists = true then
	log "設定ファイルあり"
	###設定ファイル読み込み NSDATA
	set ocidOption to (refMe's NSDataReadingMappedIfSafe)
	set listResponse to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidPlistFilePathURL) options:(ocidOption) |error|:(reference)
	if (item 2 of listResponse) = (missing value) then
		log "initWithContentsOfURL 正常処理"
		set ocidReadData to (item 1 of listResponse)
	else if (item 2 of listResponse) ≠ (missing value) then
		log (item 2 of listResponse)'s code() as text
		log (item 2 of listResponse)'s localizedDescription() as text
		return "NSDATA エラーしました"
	end if
	### 解凍
	set listResponse to refMe's NSKeyedUnarchiver's unarchivedObjectOfClass:((refMe's NSObject)'s class) fromData:(ocidReadData) |error|:(reference)
	if (item 2 of listResponse) is (missing value) then
		##解凍したPlist用レコード
		set ocidPlistDict to (item 1 of listResponse)
		log "unarchivedObjectOfClass 正常終了"
	else
		log (item 2 of listResponse)'s code() as text
		log (item 2 of listResponse)'s localizedDescription() as text
		return "NSKeyedUnarchiver エラーしました"
	end if
else if boolDirExists = false then
	return "設定ファイル無し キャンセルします"
end if
#################################
##削除設定を選ぶ
#################################
#キーを取り出して
set ocidWindowSetKeyArray to ocidPlistDict's allKeys()
set listWindowSetKeyArray to ocidWindowSetKeyArray as list
if (count of listWindowSetKeyArray) = 0 then
	return "保存された設定はありません"
end if
###ダイアログ
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
set listChooseResult to (choose from list listWindowSetKeyArray with prompt "どの設定を削除しましすか？" OK button name "OK" with title "設定を削除する" without multiple selections allowed and empty selection allowed) as list
if (item 1 of listChooseResult) is false then
	return "処理をキャンセルしました"
else
	set strDelKey to (item 1 of listChooseResult) as text
end if
#################################
##削除
#################################
ocidPlistDict's removeObjectForKey:(strDelKey)

#######################################
###　アーカイブする
#######################################
# archivedDataWithRootObject:requiringSecureCoding:error:
set listResponse to refMe's NSKeyedArchiver's archivedDataWithRootObject:(ocidPlistDict) requiringSecureCoding:(false) |error|:(reference)
if (item 2 of listResponse) = (missing value) then
	log "archivedDataWithRootObject 正常処理"
	set ocidSaveData to (item 1 of listResponse)
else if (item 2 of listResponse) ≠ (missing value) then
	log (item 2 of listResponse)'s code() as text
	log (item 2 of listResponse)'s localizedDescription() as text
	return "NSKeyedArchiverでエラーしました"
end if

#######################################
###　保存する
#######################################
##保存
set ocidOption to (refMe's NSDataWritingAtomic)
set listDone to ocidSaveData's writeToURL:(ocidPlistFilePathURL) options:(ocidOption) |error|:(reference)
if (item 1 of listDone) is true then
	log "writeToURL 正常処理"
else if (item 2 of listDone) ≠ (missing value) then
	log (item 2 of listDone)'s code() as text
	log (item 2 of listDone)'s localizedDescription() as text
	return "保存で　エラーしました"
end if
