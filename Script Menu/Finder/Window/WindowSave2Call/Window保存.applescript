#! /usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#	FinderWindowのを保存して
# 配置を後で呼び出すようにします
#Finder WindowのViewは　一部読み取り専用の値があるため
#完全に同じ表示にはできません
(*
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
###ウィンドウの有無チェック
tell application "Finder"
	set numCntWindow to (count of every Finder window) as integer
end tell
if numCntWindow = 0 then
	return "保存するウィンドウがありません"
end if
#################################
###設定ファイル保存先　Application Support
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidApplicatioocidupportDirPathURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidApplicatioocidupportDirPathURL's URLByAppendingPathComponent:("com.cocolog-nifty.quicktimer/SaveFinderWindow")
###フォルダの有無チェック
set ocidSaveDirPath to ocidSaveDirPathURL's |path|()
set boolDirExists to appFileManager's fileExistsAtPath:(ocidSaveDirPath) isDirectory:(true)
if boolDirExists is true then
	log "設定の保存用フォルダがありますー＞処理継続"
else if boolDirExists is false then
	log "設定の保存用フォルダがありません"
	#フォルダを作る
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions)
	set listDone to appFileManager's createDirectoryAtURL:(ocidSaveDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
	if (item 1 of listDone) is true then
		log "createDirectoryAtURL 正常処理"
	else if (item 2 of listDone) ≠ (missing value) then
		log (item 2 of listDone)'s code() as text
		log (item 2 of listDone)'s localizedDescription() as text
		return "フォルダ作成　エラーしました"
	end if
	#注意書きファイルの保存
	set ocidNULLStr to refMe's NSString's stringWithString:("")
	set ocidNULLFilePathURL to ocidApplicatioocidupportDirPathURL's URLByAppendingPathComponent:("com.cocolog-nifty.quicktimer/_このフォルダは削除して大丈夫です") isDirectory:(false)
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

###設定ファイル
set ocidPlistFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("com.apple.finder.save.window.plist")
#################################
###ダイアログ
set strName to (name of current application) as text
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
#前面ウィンドウの名前->設定名にする
tell application "Finder"
	tell front Finder window
		set strWindowName to name as text
	end tell
end tell
#日付
set strDateNO to doGetDateNo("yyyyMMdd") as text
#設定名 ウィンドウ名＋日付
set strDefaultsAnswer to (strWindowName & "_" & strDateNO) as text
#ダイアログアイコン
set aliasIconPath to (POSIX file "/System/Library/CoreServices/Certificate Assistant.app/Contents/Resources/AppIcon.icns") as alias
try
	set recordResponse to (display dialog "保存ウィンドウの設定名を決めてください\nこの名称で次回呼び出します" with title "設定名を決めてください" default answer strDefaultsAnswer buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" with icon aliasIconPath giving up after 30 without hidden answer) as record
	if true is equal to (gave up of recordResponse) then
		log "時間切れですやりなおしてください"
		error number -128
	end if
	if "OK" is (button returned of recordResponse) then
		set strResponse to (text returned of recordResponse) as text
	end if
on error
	return "キャンセルしました"
end try
#################################
##設定ファイルの有無チェック
set ocidPlistFilePath to ocidPlistFilePathURL's |path|()
set boolFileExists to appFileManager's fileExistsAtPath:(ocidPlistFilePath) isDirectory:(false)
if boolFileExists = true then
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
else if boolFileExists = false then
	log "設定ファイル無し"
	##空のPlist用レコード
	set ocidPlistDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
end if
#キーを取り出して
set ocidWindowSetKeyArray to ocidPlistDict's allKeys()
#設定名に重複がないかチェックして
set boolContain to ocidWindowSetKeyArray's containsObject:(strResponse)
##重複している場合は最初からやり直し
if boolContain is true then
	try
		set recordResponse to (display alert ("設定が重複しています。\n設定名を変更してください") buttons {"OK", "キャンセル"} default button "OK" cancel button "キャンセル" as informational giving up after 10) as record
	on error
		log "エラーしました"
		return "キャンセルしました。"
	end try
	if (button returned of recordResponse) is "OK" then
		set boolContain to false
		##このファイルを再実行する
		tell application "Finder"
			set aliasPathToMe to (path to me) as alias
		end tell
		run script aliasPathToMe
	else if (gave up of recordResponse) is true then
		return "時間切れです　キャンセルしました。"
	end if
end if

#######################################
###現在のウィンドウの情報を収集する
#######################################
tell application "Finder"
	set numCntWindow to (count of every Finder window) as integer
end tell
if numCntWindow = 0 then
	return "保存するウィンドウがありません"
end if
# Finder Windowをリストで収集
tell application "Finder"
	set listEveryWindow to every Finder window as list
end tell

#######################################
###　本処理
#######################################
##対象のWINDOWセットとして保存するWINDOWの値のリスト
set ocidSetWindowArray to refMe's NSMutableArray's alloc()'s initWithCapacity:(0)
# Windowの数だけ繰り返し
repeat with itemWindow in listEveryWindow
	set ocidSetWindowDict to (refMe's NSMutableDictionary's alloc()'s initWithCapacity:0)
	tell application "Finder"
		##WINDOWの値を取得して順番に格納していく
		tell itemWindow
			set boolToolBarVisible to toolbar visible as boolean
			(ocidSetWindowDict's setValue:(boolToolBarVisible) forKey:("toolbar visible"))
			set boolStatusBarVisible to statusbar visible as boolean
			(ocidSetWindowDict's setValue:(boolStatusBarVisible) forKey:("statusbar visible"))
			set boolPathBarVisible to pathbar visible as boolean
			(ocidSetWindowDict's setValue:(boolPathBarVisible) forKey:("pathbar visible"))
			set boolZoomed to zoomed as boolean
			(ocidSetWindowDict's setValue:(boolZoomed) forKey:("zoomed"))
			set boolCloseable to closeable as boolean
			(ocidSetWindowDict's setValue:(boolCloseable) forKey:("closeable"))
			set boolTitled to titled as boolean
			(ocidSetWindowDict's setValue:(boolTitled) forKey:("titled"))
			set boolFloating to floating as boolean
			(ocidSetWindowDict's setValue:(boolFloating) forKey:("floating"))
			set boolModal to modal as boolean
			(ocidSetWindowDict's setValue:(boolModal) forKey:("modal"))
			set boolResizable to resizable as boolean
			(ocidSetWindowDict's setValue:(boolResizable) forKey:("resizable"))
			set boolZoomable to zoomable as boolean
			(ocidSetWindowDict's setValue:(boolZoomable) forKey:("zoomable"))
			set boolVisible to visible as boolean
			(ocidSetWindowDict's setValue:(boolVisible) forKey:("visible"))
			set boolCollapsed to collapsed as boolean
			(ocidSetWindowDict's setValue:(boolCollapsed) forKey:("collapsed"))
			#
			set numSideBarWidth to sidebar width as integer
			(ocidSetWindowDict's setValue:(numSideBarWidth) forKey:("sidebar width"))
			set numIndex to index as integer
			(ocidSetWindowDict's setValue:(numIndex) forKey:("index"))
			#
			set aliasTargetPath to target as alias
			set strTargetPath to (POSIX path of aliasTargetPath) as text
			(ocidSetWindowDict's setValue:(strTargetPath) forKey:("target"))
			set strName to name as text
			(ocidSetWindowDict's setValue:(strName) forKey:("name"))
			#
			set listPosition to position as list
			(ocidSetWindowDict's setValue:(listPosition) forKey:("position"))
			set listBounds to bounds as list
			(ocidSetWindowDict's setValue:(listBounds) forKey:("bounds"))
			set strCurrentView to current view as text
			(ocidSetWindowDict's setValue:(strCurrentView) forKey:("current view"))
		end tell
		########
		#オプション
		if strCurrentView is "column view" then
			set numSetValue to (text size of column view options of itemWindow)
			(ocidSetWindowDict's setValue:(numSetValue) forKey:("text size"))
			set boolSetValue to (shows icon of column view options of itemWindow)
			(ocidSetWindowDict's setValue:(boolSetValue) forKey:("shows icon"))
			set boolSetValue to (shows icon preview of column view options of itemWindow)
			(ocidSetWindowDict's setValue:(boolSetValue) forKey:("shows icon preview"))
			set boolSetValue to (shows preview column of column view options of itemWindow)
			(ocidSetWindowDict's setValue:(boolSetValue) forKey:("shows preview column"))
			set boolSetValue to (discloses preview pane of column view options of itemWindow)
			(ocidSetWindowDict's setValue:(boolSetValue) forKey:("discloses preview pane"))
		else if strCurrentView is "icon view" then
			set numSetValue to (icon size of icon view options of itemWindow)
			(ocidSetWindowDict's setValue:(numSetValue) forKey:("icon size"))
			set numSetValue to (text size of icon view options of itemWindow)
			(ocidSetWindowDict's setValue:(numSetValue) forKey:("text size"))
			set boolSetValue to (shows item info of icon view options of itemWindow)
			(ocidSetWindowDict's setValue:(boolSetValue) forKey:("shows item info"))
			set boolSetValue to (shows icon preview of icon view options of itemWindow)
			(ocidSetWindowDict's setValue:(boolSetValue) forKey:("shows icon preview"))
			set strSetValue to (arrangement of icon view options of itemWindow) as text
			(ocidSetWindowDict's setValue:(strSetValue) forKey:("arrangement"))
			set strSetValue to (label position of icon view options of itemWindow) as text
			(ocidSetWindowDict's setValue:(strSetValue) forKey:("label position"))
			#	set strSetValue to (background picture of icon view options of itemWindow)
			#	set listSetValue to (background color of icon view options of itemWindow) as list
		else if strCurrentView is "list view" then
			set boolSetValue to (calculates folder sizes of list view options of itemWindow)
			(ocidSetWindowDict's setValue:(boolSetValue) forKey:("calculates folder sizes"))
			set boolSetValue to (shows icon preview of list view options of itemWindow)
			(ocidSetWindowDict's setValue:(boolSetValue) forKey:("shows icon preview"))
			set boolSetValue to (uses relative dates of list view options of itemWindow)
			(ocidSetWindowDict's setValue:(boolSetValue) forKey:("uses relative dates"))
			set numSetValue to (text size of list view options of itemWindow)
			(ocidSetWindowDict's setValue:(numSetValue) forKey:("text size"))
			set strSetValue to (icon size of list view options of itemWindow) as text
			(ocidSetWindowDict's setValue:(strSetValue) forKey:("icon size"))
			#	set strSetValue to (sort column of list view options of itemWindow)
		end if
	end tell
	#Windowmの値をセットするArrayに追加
	(ocidSetWindowArray's addObject:(ocidSetWindowDict))
	#全てのWINDOWの値の収集が終わったら
end repeat
#保存するPLISTにダイアログの戻り値をキーにしてセット
ocidPlistDict's setObject:(ocidSetWindowArray) forKey:(strResponse)


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





