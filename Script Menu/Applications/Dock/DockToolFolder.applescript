#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
(*

*)
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "Appkit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

set listDirPath to {"~/Applications", "~/Downloads", "~/Pictures/ScreenCapture", "~/Library/CloudStorage"} as list

################################
####事前チェック
################################
set boolExists to doChkManagedPreferences()
if boolExists = false then
	log "管理された設定が無いので処理を続行します"
else if boolDone = true then
	return "設定が管理されているので処理を中止します"
end if
################################
####PLIST
################################
set DirManager to refMe's NSFileManager's defaultManager()
###URL
set ocidURLArray to (DirManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidLibraryDirPathURL to ocidURLArray's firstObject()
set ocidPlistPathURL to ocidLibraryDirPathURL's URLByAppendingPathComponent:("Preferences/com.apple.dock.plist") isDirectory:(false)
#####
set boolDone to doMakeBackUp(ocidPlistPathURL)
if boolDone = false then
	log "バックアップの作成に失敗しました"
	return "処理を中止します"
else if boolDone = true then
	log "バックアップ処理正常終了"
end if

################################
##エラー制御したいのでNSDATA経由
################################
set listReadData to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidPlistPathURL) options:(refMe's NSDataReadingMappedIfSafe) |error|:(reference)
if (item 2 of listReadData) = (missing value) then
	set coidReadData to (item 1 of listReadData)
	log "正常終了: NSDATA"
else
	log (item 2 of listReadData)'s localizedDescription() as text
	return " NSDataへの読み込みに失敗しました"
end if
################################
##NSPropertyListSerialization
################################
##可変DICTに変換
#バイナリーモード
set ocidFormat to (refMe's NSPropertyListBinaryFormat_v1_0)
#可変DICTにする
set ocidOption to (refMe's NSPropertyListMutableContainers)
#シリアライゼーション
set listReadPlistDict to refMe's NSPropertyListSerialization's propertyListWithData:(coidReadData) options:(ocidOption) format:(ocidFormat) |error|:(reference)
if (item 2 of listReadPlistDict) = (missing value) then
	log "正常終了: NSPropertyListSerialization"
	set ocidReadPlistDict to (item 1 of listReadPlistDict)
else
	log (item 2 of listReadPlistDict)'s localizedDescription() as text
	return "Plist変換に失敗しました"
end if
set numCntAllKey to ocidReadPlistDict's allKeys()
if (count of numCntAllKey) < 1 then
	return "Plistの内容が不正です"
end if

################################
##本処理　値を入れていく
################################

repeat with itemDirPath in listDirPath
	set listResponse to doChkPathExists(itemDirPath)
	if (item 1 of listResponse) = false then
		return "指定のパスは存在しません処理を中止します"
	else if (item 1 of listResponse) = true then
		set ocidDirPathURL to (item 2 of listResponse)
		log "ファイルパス：" & itemDirPath
	end if
	#########
	#Dockのアプリケーションのリスト
	set ocidPersistentArray to (ocidReadPlistDict's objectForKey:("persistent-others"))
	
	################################
	####persistent-appsデータ生成
	################################
	##セットする可変DICT３つ
	set ocidSetDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:(0))
	set ocidSetTileDataDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:(0))
	set ocidSetFileDataDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:(0))
	##アトリビュートを取得
	set ocidResourceKeyArray to (refMe's NSMutableArray's alloc()'s initWithCapacity:(0))
	(ocidResourceKeyArray's addObject:(refMe's NSURLCustomIconKey))
	(ocidResourceKeyArray's addObject:(refMe's NSURLIsApplicationKey))
	(ocidResourceKeyArray's addObject:(refMe's NSURLPathKey))
	(ocidResourceKeyArray's addObject:(refMe's NSURLLocalizedNameKey))
	(ocidResourceKeyArray's addObject:(refMe's NSURLContentModificationDateKey))
	#
	set listResponse to (ocidDirPathURL's resourceValuesForKeys:(ocidResourceKeyArray) |error|:(reference))
	if (item 2 of listResponse) = (missing value) then
		log "正常終了: resourceValuesForKeys"
		set ocidURLAttarDict to (item 1 of listResponse)
	else if (item 2 of listResponse) ≠ (missing value) then
		log (item 2 of listResponse)'s localizedDescription() as text
		return "resourceValuesForKeysに失敗しました"
	end if
	##############【１】ROOT
	###GUID実際はランダム番号だがNSFileSystemFileNumberを使う
	set listResponse to (DirManager's attributesOfItemAtPath:(ocidDirPathURL's |path|()) |error|:(reference))
	if (item 2 of listResponse) = (missing value) then
		log "正常終了: attributesOfItemAtPath"
		set ocidFileAttarDict to (item 1 of listResponse)
	else if (item 2 of listResponse) ≠ (missing value) then
		log (item 2 of listResponse)'s localizedDescription() as text
		return "attributesOfItemAtPathに失敗しました"
	end if
	set numGUID to (ocidFileAttarDict's objectForKey:(refMe's NSFileSystemFileNumber))
	set ocidIntValue to (refMe's NSNumber's numberWithInteger:(numGUID))
	(ocidSetDict's setValue:(numGUID) forKey:("GUID"))
	###tile-type
	set ocidStringValue to (refMe's NSString's stringWithString:("directory-tile"))
	(ocidSetDict's setObject:(ocidStringValue) forKey:("tile-type"))
	##############【２】tile_data
	####file-type
	#	169		Launchpad とMission Control
	#	41			それ以外はまぁ４１で間違いなさそう
	#	2				フォルダ
	set ocidSetFileTypeValue to (refMe's NSNumber's numberWithInteger:(2))
	(ocidSetTileDataDict's setObject:(ocidSetFileTypeValue) forKey:("file-type"))
	####showas
	set ocidIntValue to (refMe's NSNumber's numberWithInteger:0)
	(ocidSetTileDataDict's setObject:(ocidIntValue) forKey:("showas"))
	####displayas
	set ocidIntValue to (refMe's NSNumber's numberWithInteger:0)
	(ocidSetTileDataDict's setObject:(ocidIntValue) forKey:("displayas"))
	####arrangement
	set ocidIntValue to (refMe's NSNumber's numberWithInteger:2)
	(ocidSetTileDataDict's setObject:(ocidIntValue) forKey:("arrangement"))
	####preferreditemsize
	set ocidIntValue to (refMe's NSNumber's numberWithInteger:0)
	(ocidSetTileDataDict's setObject:(ocidIntValue) forKey:("preferreditemsize"))
	####dock-extra
	set ocidBoolValue to (refMe's NSNumber's numberWithBool:false)
	(ocidSetTileDataDict's setObject:(ocidBoolValue) forKey:("is-beta"))
	####file-label"
	set ocidLocalizedName to (ocidURLAttarDict's objectForKey:(refMe's NSURLLocalizedNameKey))
	set ocidFileLabel to (ocidLocalizedName's stringByDeletingPathExtension())
	set ocidFileLabelString to ocidFileLabel's UTF8String()
	(ocidSetTileDataDict's setObject:(ocidFileLabelString) forKey:("file-label"))
	####file-mod-date
	set ocidModificationDate to (ocidURLAttarDict's objectForKey:(refMe's NSURLContentModificationDateKey))
	set ocidModDate to ocidModificationDate's timeIntervalSince1970
	set ocidIntValue to ocidModDate's intValue()
	(ocidSetTileDataDict's setObject:(ocidIntValue) forKey:("file-mod-date"))
	####parent-mod-date は今日の今
	set ocidNow to refMe's NSDate's now
	set ocidNowNo to ocidNow's timeIntervalSince1970
	set ocidIntValue to ocidNowNo's intValue
	(ocidSetTileDataDict's setObject:(ocidIntValue) forKey:("parent-mod-date"))
	####book
	set ocidOption to (refMe's NSURLBookmarkCreationWithSecurityScope)
	set listResponse to (ocidDirPathURL's bookmarkDataWithOptions:(ocidOption) includingResourceValuesForKeys:(ocidResourceKeyArray) relativeToURL:(missing value) |error|:(reference))
	if (item 2 of listResponse) = (missing value) then
		log "正常終了: bookmarkDataWithOptions"
		set ocidBookMarkData to (item 1 of listResponse)
	else if (item 2 of listResponse) ≠ (missing value) then
		log (item 2 of listResponse)'s localizedDescription() as text
		return "BOOKMARKエイリアスデータの取得に失敗しました"
	end if
	(ocidSetTileDataDict's setObject:(ocidBookMarkData) forKey:("book"))
	
	##############【３】file_data
	####_CFURLString
	set coidAbsoluteStringPath to ocidDirPathURL's absoluteString()
	(ocidSetFileDataDict's setObject:(coidAbsoluteStringPath) forKey:("_CFURLString"))
	####_CFURLStringType
	#		0	/File/Path
	#		15 file:// のURL形式
	set ocidIntValue to (refMe's NSNumber's numberWithInteger:(15))
	(ocidSetFileDataDict's setObject:(ocidIntValue) forKey:("_CFURLStringType"))
	##############【４】セットするDICTにまとめる
	(ocidSetTileDataDict's setObject:(ocidSetFileDataDict) forKey:("file-data"))
	(ocidSetDict's setObject:(ocidSetTileDataDict) forKey:("tile-data"))
	
	################################
	####追加データを元のPLISTに戻す
	################################
	(ocidPersistentArray's addObject:(ocidSetDict))
end repeat




################################
####保存
################################
set listDone to ocidReadPlistDict's writeToURL:(ocidPlistPathURL) |error|:(reference)
if (item 2 of listDone) = (missing value) then
	log "ファイルの保存終了: writeToURL"
	
else if (item 2 of listDone) ≠ (missing value) then
	log (item 2 of listDone)'s localizedDescription() as text
	return "ファイルの保存に失敗しました"
end if


################################
###CFPreferencesを再起動
################################
#####CFPreferencesを再起動させて変更後の値をロードさせる

set strCommandText to "/usr/bin/killall cfprefsd" as text
do shell script strCommandText
set strCommandText to "/bin/ps -ale  | grep -v grep | grep 'com.apple.dock.extra'| awk '{print $2}'" as text
try
	set strPid to (do shell script strCommandText) as text
	log "com.apple.dock.extraのPID：" & strPid
	set strCommandText to "/usr/bin/kill - 9 " & strPid & "" as text
	try
		do shell script strCommandText
	end try
end try
log "終了しました　Dockを再起動します"
try
	set strCommandText to ("/usr/bin/killall Dock")
	do shell script strCommandText
end try
(*
		set strPlistPath to "/System/Library/LaunchAgents/com.apple.cfprefsd.xpc.agent.plist"
		set strCommandText to ("/bin/launchctl stop -w \"" & strAgentPath & "\"")
		try
			do shell script strCommandText
		end try
		set strCommandText to ("/bin/launchctl start -w \"" & strAgentPath & "\"")
		try
			do shell script strCommandText
		end try 
	set strPlistPath to "/System/Library/LaunchDaemons/com.apple.cfprefsd.xpc.daemon.plist"
	set strCommandText to ("/bin/launchctl stop -w \"" & strAgentPath & "\"")
	try
		do shell script strCommandText
	end try
	set strCommandText to ("/bin/launchctl start -w \"" & strAgentPath & "\"")
	try
		do shell script strCommandText
	end try
	*)



##############################
### 今の日付日間　テキスト
##############################
to doGetDateNo(argDateFormat)
	####日付情報の取得
	set ocidDate to current application's NSDate's |date|()
	###日付のフォーマットを定義
	set ocidNSDateFormatter to current application's NSDateFormatter's alloc()'s init()
	ocidNSDateFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"ja_JP_POSIX")
	set ocidTimeZone to refMe's NSTimeZone's alloc()'s initWithName:"Asia/Tokyo"
	ocidNSDateFormatter's setTimeZone:(ocidTimeZone)
	ocidNSDateFormatter's setDateFormat:(argDateFormat)
	set ocidDateAndTime to ocidNSDateFormatter's stringFromDate:ocidDate
	set strDateAndTime to ocidDateAndTime as text
	return strDateAndTime
end doGetDateNo


to doChkManagedPreferences()
	################################
	####Managed Preferencesチェック
	################################
	set DirManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (DirManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSLocalDomainMask))
	set ocidLibraryDirPathURL to ocidURLsArray's firstObject()
	#
	set ocidProcessInfo to refMe's NSProcessInfo's processInfo()
	set ocidEnvDict to ocidProcessInfo's environment()
	set strShortUserName to (ocidEnvDict's valueForKey:"USER") as text
	set strSetValue to ("/Managed Preferences/" & strShortUserName & "/com.apple.dock.plist") as text
	set ocidManagedPlistPathURL to ocidLibraryDirPathURL's URLByAppendingPathComponent:(strSetValue) isDirectory:(false)
	set boolExists to DirManager's fileExistsAtPath:(ocidManagedPlistPathURL's |path|())
	if boolExists is false then
		log "管理された設定が無いので処理を続行します"
		return false
	else if boolExists is true then
		log "設定が管理されているので処理を中止します"
		return true
	end if
end doChkManagedPreferences


to doChkPathExists(argDirPath)
	################################
	####パスと位置情報を受け取る
	################################
	set DirManager to refMe's NSFileManager's defaultManager()
	##受け取ったパスの実存チェック
	set ocidAppPathStr to refMe's NSString's stringWithString:(argDirPath)
	set ocidAppPath to ocidAppPathStr's stringByStandardizingPath()
	set ocidDirPathURL to (refMe's NSURL's alloc()'s initFileURLWithPath:(ocidAppPath))
	set boolExists to DirManager's fileExistsAtPath:(ocidAppPath)
	if boolExists = false then
		log "指定のパスは存在しません処理を中止します"
		return {false, ocidDirPathURL}
	else if boolExists = true then
		log "処理を開始します"
		return {true, ocidDirPathURL}
	end if
end doChkPathExists



to doMakeBackUp(argFilePathURl)
	################################
	####書類フォルダにバックアップ
	################################
	set DirManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (DirManager's URLsForDirectory:(refMe's NSDocumentDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidDocumentDirPathURL to ocidURLsArray's firstObject()
	#フォルダ名は日付
	set strDate to doGetDateNo("yyyyMMdd") as text
	set strSetValue to ("Apple/Preferences/" & strDate) as text
	set ocidBackUpDirPathURL to ocidDocumentDirPathURL's URLByAppendingPathComponent:(strSetValue) isDirectory:(true)
	set boolExists to DirManager's fileExistsAtPath:(ocidBackUpDirPathURL's |path|()) isDirectory:(true)
	if boolExists = false then
		log "バックアップ用のディレクトリを作ります"
		log "場所は$HOME/Documents/Apple/Preferences/日付です"
		set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
		# 777-->511 755-->493 700-->448 766-->502 
		ocidAttrDict's setValue:(448) forKey:(refMe's NSFilePosixPermissions)
		set listDone to DirManager's createDirectoryAtURL:(ocidBackUpDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
		if (item 1 of listDone) = true then
			log "正常終了: createDirectoryAtURL"
		else if (item 1 of listDone) = false then
			log (item 2 of listDone)'s localizedDescription() as text
			log " バックアップ用のディレクトリの作成に失敗しました"
			return
		end if
	else if boolExists = true then
		log "バックアップ用のディレクトリはすでにありました"
	end if
	set ocidBackupFilePathURL to ocidBackUpDirPathURL's URLByAppendingPathComponent:("com.apple.dock.plist")
	set boolExists to DirManager's fileExistsAtPath:(ocidBackupFilePathURL's |path|()) isDirectory:(false)
	if boolExists = true then
		log "すでにバックアップがあるので今回はバックアップしません"
		return true
	else if boolExists = false then
		set listDone to DirManager's copyItemAtURL:(argFilePathURl) toURL:(ocidBackupFilePathURL) |error|:(reference)
		if (item 1 of listDone) = true then
			log "設定ファイルのバックアップを作成しました"
			return true
		else if (item 1 of listDone) = false then
			log (item 2 of listDone)'s localizedDescription() as text
			log " ファイルのコピーに失敗しました"
			return false
		end if
	end if
end doMakeBackUp
