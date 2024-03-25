#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
(*
日付データNSTaggedDateをstringに置換してから
PLISTデータをJSON形式にします
com.cocolog-nifty.quicktimer.icefloe
*)
#
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
##自分環境がos12なので2.8にしているだけです
use AppleScript version "2.8"
use framework "Foundation"
use scripting additions

property refMe : a reference to current application


####ダイアログで使うデフォルトロケーション
tell application "Finder"
	set aliasDefaultLocation to (path to desktop folder from user domain) as alias
end tell
####UTIリスト 
set listUTI to {"com.apple.property-list", "public.xml"}
####ダイアログを出す
set aliasFilePath to (choose file with prompt "ファイルを選んでください" default location (aliasDefaultLocation) of type listUTI with invisibles and showing package contents without multiple selections allowed) as alias

set strFilePath to (POSIX path of aliasFilePath) as text
set ocidFilePathStr to refMe's NSString's stringWithString:(strFilePath)
set ocidFilePath to ocidFilePathStr's stringByStandardizingPath()
set ocidFilePathURL to refMe's NSURL's fileURLWithPath:(ocidFilePath)
set ocidFileName to ocidFilePathURL's lastPathComponent()
##########################################
###【１】テンポラリディレクトリとパス
set appFileManager to refMe's NSFileManager's defaultManager()
set ocidTempDirURL to appFileManager's temporaryDirectory()
set ocidUUID to refMe's NSUUID's alloc()'s init()
set ocidUUIDString to ocidUUID's UUIDString
set ocidSaveDirPathURL to ocidTempDirURL's URLByAppendingPathComponent:(ocidUUIDString) isDirectory:true
set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
# 777-->511 755-->493 700-->448 766-->502 
ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
set listDone to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
if (item 1 of listDone) is true then
	#テンポラリファイル
	set ocidTmpFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:(ocidFileName) isDirectory:false
	log "【1】正常終了"
else if (item 1 of listDone) is false then
	log (item 2 of listDone)'s localizedDescription() as text
	return "【1】失敗しました"
end if


##########################################
### 【2】PLISTファイルをNSDATAとして読み込み
(*   NSDataReadingOptions
(*1*)log refMe's NSDataReadingMappedIfSafe as integer
(*2*)log refMe's NSDataReadingUncached as integer
(*8*)log refMe's NSDataReadingMappedAlways as integer
*)
set listReadData to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidFilePathURL) options:(refMe's NSDataReadingMappedIfSafe) |error|:(reference)
if (item 2 of listReadData) is (missing value) then
	set coidReadData to (item 1 of listReadData)
	log " 【2】正常終了"
else
	log (item 2 of listReadData)'s localizedDescription() as text
	return " 【2】失敗しました"
end if


##########################################
####【3】PLISTに変換 (optionは　0-2 Immutable /MutableContainers /MutableContainersAndLeaves)
set ocidXmlPlist to refMe's NSPropertyListXMLFormat_v1_0
set ocidPlistSerial to refMe's NSPropertyListSerialization
set ocidOption to refMe's NSPropertyListMutableContainersAndLeaves
set listPlistDict to ocidPlistSerial's propertyListWithData:(coidReadData) options:(ocidOption) format:(ocidXmlPlist) |error|:(reference)
if (item 2 of listPlistDict) is (missing value) then
	set ocidPlistDict to (item 1 of listPlistDict)
	log "【3】正常終了"
else
	log (item 2 of listPlistDict)'s localizedDescription() as text
	return "【3】失敗しました"
end if


##########################################
####【4】テンポラリファイルを保存
set ocidOption to (refMe's NSDataWritingWithoutOverwriting)
set listDone to ocidPlistDict's writeToURL:(ocidTmpFilePathURL) |error|:(reference)
if (item 1 of listDone) is true then
	log "【4】正常終了"
else if (item 1 of listDone) is false then
	log (item 2 of listDone)'s localizedDescription() as text
	return "【4】失敗しました"
end if
##########################################
####【5】テンポラリのPLISTの『フォーマット』を変更
set listReadString to refMe's NSMutableString's alloc()'s initWithContentsOfURL:(ocidTmpFilePathURL) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
if (item 2 of listReadString) is (missing value) then
	set ocidReadString to (item 1 of listReadString)
	log "【5-1】正常終了"
else
	log (item 2 of listReadString)'s localizedDescription() as text
	return "【5-1】失敗しました"
end if
##置換
set ocidSaveString to ocidReadString's stringByReplacingOccurrencesOfString:("<date>") withString:("<string>")
set ocidSaveString to ocidSaveString's stringByReplacingOccurrencesOfString:("</date>") withString:("</string>")
set ocidSaveString to ocidSaveString's stringByReplacingOccurrencesOfString:("<data>") withString:("<string>")
set ocidSaveString to ocidSaveString's stringByReplacingOccurrencesOfString:("</data>") withString:("</string>")
##上書き保存
set listDone to ocidSaveString's writeToURL:(ocidTmpFilePathURL) atomically:(true) encoding:(refMe's NSUTF8StringEncoding) |error|:(reference)
if (item 1 of listDone) is true then
	log "【5-2】正常終了"
else if (item 1 of listDone) is false then
	log (item 2 of listDone)'s localizedDescription() as text
	return "【5-2】失敗しました"
end if
##########################################
### 【6】PLISTファイルをNSDATAとして読み込み
set listReadTmpData to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidTmpFilePathURL) options:(refMe's NSDataReadingMappedIfSafe) |error|:(reference)
if (item 2 of listReadTmpData) is (missing value) then
	set ocidReadTmpData to (item 1 of listReadTmpData)
	log "【6】正常終了"
else
	log (item 2 of listReadTmpData)'s localizedDescription() as text
	return "【6】失敗しました"
end if
##########################################
####【7】PLISTに変換 (optionは　0-2 Immutable /MutableContainers /MutableContainersAndLeaves)
set ocidXmlPlist to refMe's NSPropertyListXMLFormat_v1_0
set ocidPlistSerial to refMe's NSPropertyListSerialization
set ocidOption to refMe's NSPropertyListMutableContainersAndLeaves
set listPlistDict to ocidPlistSerial's propertyListWithData:(ocidReadTmpData) options:(ocidOption) format:(ocidXmlPlist) |error|:(reference)
if (item 2 of listPlistDict) is (missing value) then
	set ocidPlistDict to (item 1 of listPlistDict)
	log "【7】正常終了"
else
	log (item 2 of listPlistDict)'s localizedDescription() as text
	return "【7】失敗しました"
end if

##########################################
### 【8】JSON初期化
(*  NSJSONReadingOptions
(*1*)log refMe's NSJSONReadingMutableContainers as integer
(*2*)log refMe's NSJSONReadingMutableLeaves as integer
(*4*)log refMe's NSJSONReadingFragmentsAllowed as integer
(*8*)log refMe's NSJSONReadingJSON5Allowed as integer
(*16*)log refMe's NSJSONReadingTopLevelDictionaryAssumed as integer
*)
set listJSONSerialization to (refMe's NSJSONSerialization's dataWithJSONObject:(ocidPlistDict) options:(refMe's NSJSONReadingJSON5Allowed) |error|:(reference))
if (item 2 of listJSONSerialization) is (missing value) then
	set ocidJsonData to (item 1 of listJSONSerialization)
	log "【8】正常終了"
else
	log (item 2 of listJSONSerialization)'s localizedDescription() as text
	return "【8】失敗しました"
end if


##########################################
####【9】保存
###保存先パスをURLを生成して
set ocidBaseFileURL to ocidFilePathURL's URLByDeletingPathExtension()
set ocidSaveFilePathURL to ocidBaseFileURL's URLByAppendingPathExtension:"json"
###保存
set ocidOption to (refMe's NSDataWritingAtomic)
set listDone to ocidJsonData's writeToURL:(ocidSaveFilePathURL) options:(ocidOption) |error|:(reference)
if (item 1 of listDone) is true then
	log "【9】正常終了"
else if (item 1 of listDone) is false then
	log (item 2 of listDone)'s localizedDescription() as text
	return "【9】失敗しました"
end if

return "処理終了"
