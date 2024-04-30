#! /usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#　デスクトップポジション保存
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

########################################
####前処理　ファイルとパス
########################################
set appFileManager to refMe's NSFileManager's defaultManager()
##設定ファイル保存先
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidApplicatioocidupportDirPathURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidApplicatioocidupportDirPathURL's URLByAppendingPathComponent:("com.cocolog-nifty.quicktimer/Desktop Position") isDirectory:(true)
#フォルダの有無チェック
set ocidSaveDirPath to ocidSaveDirPathURL's |path|()
set boolDirExists to appFileManager's fileExistsAtPath:(ocidSaveDirPath) isDirectory:(true)
if boolDirExists = true then
	log "すでにフォルダはあります"
else if boolDirExists = false then
	log "フォルダが無いのでつくります"
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
	set listDone to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
	if (item 2 of listDone) ≠ (missing value) then
		log (item 2 of listDone)'s localizedDescription() as text
		return "フォルダ作成でエラーしました"
	end if
end if
#設定ファイルの有無チェック
set ocidPlistPathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("com.apple.finder.desktopposition.plist") isDirectory:(false)
set ocidPlistPath to ocidPlistPathURL's |path|()
set boolDirExists to appFileManager's fileExistsAtPath:(ocidPlistPath) isDirectory:(true)
if boolDirExists = true then
	log "ファイルがあります"
else if boolDirExists = false then
	log "ファイルが無いので空のPLISTを作っておきます"
	#空のDICT
	set ocidBlankDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:(0)
	#キーアーカイブ形式で保存する
	set listResponse to refMe's NSKeyedArchiver's archivedDataWithRootObject:(ocidBlankDict) requiringSecureCoding:(false) |error|:(reference)
	set ocidSfl3Data to (item 1 of listResponse)
	if (item 2 of listResponse) ≠ (missing value) then
		log (item 2 of listDone)'s localizedDescription() as text
		return "アーカイブに失敗しました"
	end if
	#保存
	set listDone to ocidSfl3Data's writeToURL:(ocidPlistPathURL) options:0 |error|:(reference)
	if (item 2 of listDone) ≠ (missing value) then
		log (item 2 of listDone)'s localizedDescription() as text
		return "ファイルの保存に失敗しました"
	end if
end if

########################################
####ポジション収集
########################################
#ポジションを格納する
set ocidPositionDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:(0)
#ボジションの収集
tell application "Finder"
	repeat with itemDesktopItem in desktop
		tell itemDesktopItem
			#格納するキー
			set strKey to (name) as text
			#格納する値
			set listPosition to (desktop position) as list
			set strURL to (URL) as text
		end tell
		#格納用のArray
		#	set ocidSetValueArray to (refMe's NSMutableArray's alloc()'s initWithCapacity:(0))
		#	(ocidSetValueArray's addObject:(listPosition))
		#	(ocidSetValueArray's addObject:(strURL))
		#格納用のDICT
		set ocidSetValueDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:(0))
		(ocidSetValueDict's setObject:(listPosition) forKey:("desktop position"))
		(ocidSetValueDict's setObject:(strURL) forKey:("URL"))
		#Dictにセット
		(ocidPositionDict's setObject:(ocidSetValueDict) forKey:(strKey))
	end repeat
end tell

########################################
####保存
########################################
#キーアーカイブ形式で保存する
set listResponse to refMe's NSKeyedArchiver's archivedDataWithRootObject:(ocidPositionDict) requiringSecureCoding:(false) |error|:(reference)
set ocidSfl3Data to (item 1 of listResponse)
if (item 2 of listResponse) ≠ (missing value) then
	log (item 2 of listDone)'s localizedDescription() as text
	return "アーカイブに失敗しました"
end if
#保存
set listDone to ocidSfl3Data's writeToURL:(ocidPlistPathURL) options:0 |error|:(reference)
if (item 2 of listDone) ≠ (missing value) then
	log (item 2 of listDone)'s localizedDescription() as text
	return "ファイルの保存に失敗しました"
end if

return "ポジションを保存しました"
