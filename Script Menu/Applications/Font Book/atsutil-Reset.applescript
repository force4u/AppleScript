#! /usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
# ATS ATSUI はmacOS14で廃止になったので
# キャッシュは不要
# スクリプトメニューからの実行用
# com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions
property refMe : a reference to current application


set appFileManager to refMe's NSFileManager's defaultManager()
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDocumentDirPathURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidDocumentDirPathURL's URLByAppendingPathComponent:("Apple/Fonts")
#有無チェック
set ocidSaveDirPath to ocidSaveDirPathURL's |path|()
set boolDirExists to appFileManager's fileExistsAtPath:(ocidSaveDirPath) isDirectory:(true)
if boolDirExists = true then
	log "フォルダ有り処理継続"
else if boolDirExists = false then
	log "フォルダ無いので作成"
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	# 777-->511 755-->493 700-->448 766-->502 
	ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
	set listDone to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
	if (item 1 of listDone) is true then
		log "createDirectoryAtURL正常処理"
	else if (item 2 of listDone) ≠ (missing value) then
		log (item 2 of listDone)'s code() as text
		log (item 2 of listDone)'s localizedDescription() as text
		return "createDirectoryAtURL エラーしました"
	end if
	#注意書きファイルの保存
	set ocidNULLStr to refMe's NSString's stringWithString:("")
	set ocidNULLFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("_このフォルダは削除して大丈夫です") isDirectory:(false)
	set ocidOption to (refMe's NSUTF8StringEncoding)
	set listBoolDone to ocidNULLStr's writeToURL:(ocidNULLFilePathURL) atomically:(true) encoding:(ocidOption) |error|:(reference)
	if (item 1 of listBoolDone) is true then
		log "writeToURL 正常処理"
	else if (item 2 of listBoolDone) ≠ (missing value) then
		log (item 2 of listBoolDone)'s code() as text
		log (item 2 of listBoolDone)'s localizedDescription() as text
		return "ファイルの生成　エラーしました"
	end if
end if
##############################
### リセット前
##############################
##コマンド実行
set strCommandText to ("/usr/bin/atsutil fonts -list") as text
set strResponse to (do shell script strCommandText) as text
#タブだけ除去
set ocidResponse to refMe's NSMutableString's stringWithString:(strResponse)
set ocidSaveString to (ocidResponse's stringByReplacingOccurrencesOfString:("\t") withString:(""))
set ocidSaveString to (ocidSaveString's stringByReplacingOccurrencesOfString:("System Fonts:") withString:("System Fonts:---------------------"))
set ocidSaveString to (ocidSaveString's stringByReplacingOccurrencesOfString:("System Families:") withString:("System Families:---------------------"))
#
set ocidFontNameArray to ocidSaveString's componentsSeparatedByString:("\r")
set numCntFont to ocidFontNameArray's |count|() as integer
log "リセット前のフォント数：" & numCntFont
#保存先パス
set strDateNO to doGetDateNo("yyyyMMdd_リセット前")
set ocidBaseFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strDateNO) isDirectory:(false)
set ocidSaveFilePathURL to ocidBaseFilePathURL's URLByAppendingPathExtension:("txt")
#保存
set ocidOption to (refMe's NSUTF8StringEncoding)
set listBoolDone to ocidSaveString's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(ocidOption) |error|:(reference)
if (item 1 of listBoolDone) is true then
	log "writeToURL 正常処理"
else if (item 2 of listBoolDone) ≠ (missing value) then
	log (item 2 of listBoolDone)'s code() as text
	log (item 2 of listBoolDone)'s localizedDescription() as text
	return "writeToURL ファイルの生成　エラーしました"
end if
##開く
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's openURL:(ocidSaveFilePathURL)
if (boolDone) is true then
	log "openURL 正常処理"
else if (boolDone) is false then
	set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
	tell application "Finder" to open file aliasSaveFilePath
	return "openURL ファイルの生成　エラーしました"
end if
##############################
### リセット
##############################

set strCommandText to ("/usr/bin/atsutil databases -removeUser") as text
set strResponse to (do shell script strCommandText) as text

##############################
### リセット後
##############################

##コマンド実行
set strCommandText to ("/usr/bin/atsutil fonts -list") as text
set strResponse to (do shell script strCommandText) as text
#タブだけ除去
set ocidResponse to refMe's NSMutableString's stringWithString:(strResponse)
set ocidSaveString to (ocidResponse's stringByReplacingOccurrencesOfString:("\t") withString:(""))
set ocidSaveString to (ocidSaveString's stringByReplacingOccurrencesOfString:("System Fonts:") withString:("System Fonts:---------------------"))
set ocidSaveString to (ocidSaveString's stringByReplacingOccurrencesOfString:("System Families:") withString:("System Families:---------------------"))
#
set ocidFontNameArray to ocidSaveString's componentsSeparatedByString:("\r")
set numCntFont to ocidFontNameArray's |count|() as integer
log "リセット後のフォント：" & numCntFont
#保存先パス
set strDateNO to doGetDateNo("yyyyMMdd_リセット後")
set ocidBaseFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(strDateNO) isDirectory:(false)
set ocidSaveFilePathURL to ocidBaseFilePathURL's URLByAppendingPathExtension:("txt")
#保存
set ocidOption to (refMe's NSUTF8StringEncoding)
set listBoolDone to ocidSaveString's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(ocidOption) |error|:(reference)
if (item 1 of listBoolDone) is true then
	log "writeToURL 正常処理"
else if (item 2 of listBoolDone) ≠ (missing value) then
	log (item 2 of listBoolDone)'s code() as text
	log (item 2 of listBoolDone)'s localizedDescription() as text
	return "writeToURL ファイルの生成　エラーしました"
end if
##開く
set appSharedWorkspace to refMe's NSWorkspace's sharedWorkspace()
set boolDone to appSharedWorkspace's openURL:(ocidSaveFilePathURL)
if (boolDone) is true then
	log "openURL 正常処理"
else if (boolDone) is false then
	set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
	tell application "Finder" to open file aliasSaveFilePath
	return "openURL ファイルの生成　エラーしました"
end if


##############################
### 今の日付日間　テキスト
##############################
to doGetDateNo(argDateFormat)
	####日付情報の取得
	set ocidDate to refMe's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to refMe's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(refMe's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	set ocidTimeZone to refMe's NSTimeZone's alloc()'s initWithName:"Asia/Tokyo"
	ocidNSDateFormatter's setTimeZone:(ocidTimeZone)
	ocidNSDateFormatter's setDateFormat:(argDateFormat)
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo

