#! /usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#　デスクトップポジション復帰
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
#設定ファイルの有無チェック
set ocidPlistPathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("com.apple.finder.desktopposition.plist") isDirectory:(false)
set ocidPlistPath to ocidPlistPathURL's |path|()
set boolDirExists to appFileManager's fileExistsAtPath:(ocidPlistPath) isDirectory:(true)
if boolDirExists = true then
	log "ファイルがあります"
else if boolDirExists = false then
	log "ファイルが無いので処理を終了します"
	return "ファイルが無いので処理を終了します"
end if
##処理に必要なのでデスクトップのURLを生成しておく
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSDesktopDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidDesktopDirPathURL to ocidURLsArray's firstObject()

########################################
####PLIST読み込み
########################################
#データ読み込み　DATAとして読み込む
set ocidOption to (refMe's NSDataReadingMappedIfSafe)
set listResponse to (refMe's NSData's dataWithContentsOfURL:(ocidPlistPathURL) options:(ocidOption) |error|:(reference))
if (item 2 of listResponse) ≠ (missing value) then
	log (item 2 of listResponse)'s localizedDescription() as text
	return "ファイルのデータ読み込みに失敗しました"
else if (item 2 of listResponse) = (missing value) then
	set ocidPlistData to (item 1 of listResponse)
end if
#DATAを解凍する
set ocidClassListArray to (refMe's NSMutableArray's alloc()'s initWithCapacity:(0))
(ocidClassListArray's addObject:(refMe's NSDictionary))
(ocidClassListArray's addObject:(refMe's NSMutableDictionary))
(ocidClassListArray's addObject:(refMe's NSArray))
(ocidClassListArray's addObject:(refMe's NSMutableArray))
(ocidClassListArray's addObject:(refMe's NSObject's classForCoder))
(ocidClassListArray's addObject:(refMe's NSObject's classForKeyedArchiver))
(ocidClassListArray's addObject:(refMe's NSObject's classForKeyedUnarchiver))
#クラスセット
set ocidSetClass to refMe's NSSet's alloc()'s initWithArray:(ocidClassListArray)
#解凍
set listResponse to refMe's NSKeyedUnarchiver's unarchivedObjectOfClasses:(ocidSetClass) fromData:(ocidPlistData) |error|:(reference)
if (item 2 of listResponse) ≠ (missing value) then
	log (item 2 of listResponse)'s localizedDescription() as text
	return "データをPLISTに解凍するのに失敗しました"
else if (item 2 of listResponse) = (missing value) then
	set ocidPlistDict to (item 1 of listResponse)
end if
########################################
####ポジションデータの処理
########################################
#ボジションの収集
tell application "Finder"
	#デスクトップアイテムを順に処理します
	repeat with itemDesktopItem in desktop
		tell itemDesktopItem
			#キー名を取得して
			set strKey to (name) as text
		end tell
		#読み込んだPLISTからキーで値を取り出して
		set ocidValueDict to (ocidPlistDict's objectForKey:(strKey))
		#値が無い場合＝保存した時から増えた項目
		if ocidValueDict = (missing value) then
			log "ファイル名：" & strKey & " は保存した項目から更新されています"
			set boolDone to false as boolean
		else
			#値が取れたら 実在するかチェックする
			set strURL to (ocidValueDict's valueForKey:("URL")) as text
			set ocidChkFilePathURL to (refMe's NSURL's URLWithString:(strURL))
			set ocidChkFilePathPath to ocidChkFilePathURL's |path|()
			set boolDirExists to (appFileManager's fileExistsAtPath:(ocidChkFilePathPath) isDirectory:(true))
			if boolDirExists = true then
				log "ファイルがあります"
				#ポジションを直します
				set listPosition to (ocidValueDict's valueForKey:("desktop position")) as list
				tell itemDesktopItem
					#格納するキー
					set desktop position to (listPosition)
				end tell
			else if boolDirExists = false then
				log "ファイルが無いのでこの項目は処理しません"
				set boolDone to false as boolean
			end if
		end if
	end repeat
end tell


if boolDone is false then
	log "保存したポジション情報が古くなっています更新してください"
	return "保存したポジション情報が古くなっています更新してください"
else
	return "処理終了"
end if




