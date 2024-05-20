#! /usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#	FinderWindowのを保存して
# 配置を後で呼び出すようにします
#まずはWindowを保存してから実行してください
#
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
if numCntWindow > 0 then
	#ダイアログ
	set strName to (name of current application) as text
	if strName is "osascript" then
		tell application "Finder" to activate
	else
		tell current application to activate
	end if
	set recordResponse to display alert "今すでにあるFinderWindowsをどうしますか？" message "1:今あるウィンドウはそのまま\n2:今あるウィンドウを閉じてから設定を開く" buttons {"1:そのまま", "2：閉じる"} default button "2：閉じる" giving up after 10 as informational
	if (gave up of recordResponse) is true then
		return "時間切れです　キャンセルしました"
	else if (button returned of recordResponse) is "1:そのまま" then
		log "ウィンドウはそのままにします"
	else if (button returned of recordResponse) is "2：閉じる" then
		tell application "Finder"
			close every Finder window
		end tell
	else if (button returned of recordResponse) is "" then
		return "時間切れです　最初からやりなおしてください"
	end if
end if

#################################
###設定ファイル保存先　Application Support
set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSApplicationSupportDirectory) inDomains:(refMe's NSUserDomainMask))
set ocidApplicatioocidupportDirPathURL to ocidURLsArray's firstObject()
set ocidSaveDirPathURL to ocidApplicatioocidupportDirPathURL's URLByAppendingPathComponent:("com.cocolog-nifty.quicktimer/SaveFinderWindow")
###設定ファイル
set ocidPlistFilePathURL to ocidSaveDirPathURL's URLByAppendingPathComponent:("com.apple.finder.save.window.plist")
#################################
##設定ファイルの有無チェック
set ocidPlistFilePath to ocidPlistFilePathURL's |path|()
set boolDirExists to appFileManager's fileExistsAtPath:(ocidPlistFilePath) isDirectory:(true)
if boolDirExists = true then
	log "設定ファイルあり"
	###設定ファイル読み込み NSDATA
	set ocidOption to (refMe's NSDataReadingMappedIfSafe)
	set listResponse to refMe's NSData's alloc()'s initWithContentsOfURL:(ocidPlistFilePathURL) options:(ocidOption) |error|:(reference)
	if (item 2 of listResponse) = (missing value) then
		log "正常処理"
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
		log "正常終了"
	else
		log (item 2 of listResponse)'s code() as text
		log (item 2 of listResponse)'s localizedDescription() as text
		return "NSKeyedUnarchiver エラーしました"
	end if
else if boolDirExists = false then
	log "設定ファイル無し"
	return "WINDOWセットが保存されていません先に保存してください"
end if
#キーを取り出して
set ocidWindowSetKeyArray to ocidPlistDict's allKeys()
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
set listChooseResult to (choose from list listWindowSetKeyArray with prompt "どの設定を呼び出しますか？" OK button name "OK" with title "設定を呼び出す" without multiple selections allowed and empty selection allowed) as list
if (item 1 of listChooseResult) is false then
	return "処理をキャンセルしました"
else
	set strCallKey to (item 1 of listChooseResult) as text
end if
#################################
##設定読み込み
#################################
#指定した設定のリスト
set ocidWindowArray to ocidPlistDict's objectForKey:(strCallKey)
set numCntArray to ocidWindowArray's |count|() as integer
#読み込んだ設定リストの数だけ繰り返し
repeat with itemNo from 0 to (numCntArray - 1) by 1
	#順番にWINDOWの設定を読み込んで
	set ocidSetWindowDict to (ocidWindowArray's objectAtIndex:(itemNo))
	#パスを取得
	set strOpenFilePath to (ocidSetWindowDict's valueForKey:("target")) as text
	set aliasTargetPath to (POSIX file strOpenFilePath) as alias
	##まずはFinderで指定のパスのウィンドウを開いて
	tell application "Finder"
		set objNewWindow to (make new Finder window to folder aliasTargetPath)
	end tell
	##共通設定をまず設定して
	tell application "Finder"
		tell objNewWindow
			set boolGetValue to (ocidSetWindowDict's valueForKey:("toolbar visible"))'s boolValue() as boolean
			set toolbar visible to boolGetValue
			set boolGetValue to (ocidSetWindowDict's valueForKey:("statusbar visible"))'s boolValue() as boolean
			set statusbar visible to boolGetValue
			set boolGetValue to (ocidSetWindowDict's valueForKey:("pathbar visible"))'s boolValue() as boolean
			set pathbar visible to boolGetValue
			set boolGetValue to (ocidSetWindowDict's valueForKey:("zoomed"))'s boolValue() as boolean
			set zoomed to boolGetValue
			set boolGetValue to (ocidSetWindowDict's valueForKey:("collapsed"))'s boolValue() as boolean
			set collapsed to boolGetValue
			(* ReadOnly=デフォルトの設定に依存
			set boolGetValue to (ocidSetWindowDict's valueForKey:("closeable"))'s boolValue() as boolean
			set closeable to boolGetValue
			set boolGetValue to (ocidSetWindowDict's valueForKey:("titled"))'s boolValue() as boolean
			set titled to boolGetValue
			set boolGetValue to (ocidSetWindowDict's valueForKey:("floating"))'s boolValue() as boolean
			set floating to boolGetValue
			set boolGetValue to (ocidSetWindowDict's valueForKey:("modal"))'s boolValue() as boolean
			set modal to boolGetValue
			set boolGetValue to (ocidSetWindowDict's valueForKey:("resizable"))'s boolValue() as boolean
			set resizable to boolGetValue
			set boolGetValue to (ocidSetWindowDict's valueForKey:("zoomable"))'s boolValue() as boolean
			set zoomable to boolGetValue
			set boolGetValue to (ocidSetWindowDict's valueForKey:("visible"))'s boolValue() as boolean
			set visible to boolGetValue
			*)
			#
			set numGetValue to (ocidSetWindowDict's valueForKey:("sidebar width"))'s integerValue() as integer
			set sidebar width to numGetValue
			#			
		end tell
	end tell
	##ビューオプションを設定していく
	set strCurrentView to (ocidSetWindowDict's valueForKey:("current view")) as text
	#(icon view/‌list view/‌column view/‌group view/‌flow view) 
	##
	if strCurrentView is "column view" then
		tell application "Finder"
			set current view of objNewWindow to column view
			set numGetValue to (ocidSetWindowDict's valueForKey:("text size"))'s integerValue() as integer
			set (text size of column view options of objNewWindow) to numGetValue
			set boolGetValue to (ocidSetWindowDict's valueForKey:("shows icon"))'s boolValue() as boolean
			set (shows icon of column view options of objNewWindow) to boolGetValue
			set boolGetValue to (ocidSetWindowDict's valueForKey:("shows icon preview"))'s boolValue() as boolean
			set (shows icon preview of column view options of objNewWindow) to boolGetValue
			set boolGetValue to (ocidSetWindowDict's valueForKey:("shows preview column"))'s boolValue() as boolean
			set (shows preview column of column view options of objNewWindow) to boolGetValue
			set boolGetValue to (ocidSetWindowDict's valueForKey:("discloses preview pane"))'s boolValue() as boolean
			set (discloses preview pane of column view options of objNewWindow) to boolGetValue
		end tell
	else if strCurrentView is "list view" then
		tell application "Finder"
			set current view of objNewWindow to list view
			set boolGetValue to (ocidSetWindowDict's valueForKey:("calculates folder sizes"))'s boolValue() as boolean
			set (calculates folder sizes of list view options of objNewWindow) to boolGetValue
			set boolGetValue to (ocidSetWindowDict's valueForKey:("shows icon preview"))'s boolValue() as boolean
			set (shows icon preview of list view options of objNewWindow) to boolGetValue
			set boolGetValue to (ocidSetWindowDict's valueForKey:("uses relative dates"))'s boolValue() as boolean
			set (uses relative dates of list view options of objNewWindow) to boolGetValue
			set numGetValue to (ocidSetWindowDict's valueForKey:("text size"))'s integerValue() as integer
			set (text size of list view options of objNewWindow) to numGetValue
		end tell
		set strGetValue to (ocidSetWindowDict's valueForKey:("icon size")) as text
		if strGetValue contains "small" then
			tell application "Finder"
				set (icon size of list view options of objNewWindow) to small icon
			end tell
		else if strGetValue contains "large" then
			tell application "Finder"
				set (icon size of list view options of objNewWindow) to large icon
			end tell
		end if
	else if strCurrentView is "icon view" then
		tell application "Finder"
			set current view of objNewWindow to icon view
			set numGetValue to (ocidSetWindowDict's valueForKey:("icon size"))'s integerValue() as integer
			set (icon size of icon view options of objNewWindow) to numGetValue
			set numGetValue to (ocidSetWindowDict's valueForKey:("text size"))'s integerValue() as integer
			set (text size of icon view options of objNewWindow) to numGetValue
			set boolGetValue to (ocidSetWindowDict's valueForKey:("shows item info"))'s boolValue() as boolean
			set (shows item info of icon view options of objNewWindow) to boolGetValue
			set boolGetValue to (ocidSetWindowDict's valueForKey:("shows icon preview"))'s boolValue() as boolean
			set (shows icon preview of icon view options of objNewWindow) to boolGetValue
		end tell
		set strLabelPosition to (ocidSetWindowDict's valueForKey:("label position")) as text
		if strLabelPosition contains "right" then
			tell application "Finder"
				set (label position of icon view options of objNewWindow) to right
			end tell
		else if strLabelPosition contains "bottom" then
			tell application "Finder"
				set (label position of icon view options of objNewWindow) to bottom
			end tell
		end if
		set strArrangement to (ocidSetWindowDict's valueForKey:("arrangement")) as text
		if strArrangement contains "not" then
			tell application "Finder"
				set (arrangement of icon view options of objNewWindow) to not arranged
			end tell
		else if strArrangement contains "grid" then
			tell application "Finder"
				set (arrangement of icon view options of objNewWindow) to snap to grid
			end tell
		else if strArrangement contains "name" then
			tell application "Finder"
				set (arrangement of icon view options of objNewWindow) to arranged by name
			end tell
		else if strArrangement contains "modification" then
			tell application "Finder"
				set (arrangement of icon view options of objNewWindow) to arranged by modification date
			end tell
		else if strArrangement contains "creation" then
			tell application "Finder"
				set (arrangement of icon view options of objNewWindow) to arranged by creation date
			end tell
		else if strArrangement contains "size" then
			tell application "Finder"
				set (arrangement of icon view options of objNewWindow) to arranged by size
			end tell
		else if strArrangement contains "kind" then
			tell application "Finder"
				set (arrangement of icon view options of objNewWindow) to arranged by kind
			end tell
		else if strArrangement contains "label" then
			tell application "Finder"
				set (arrangement of icon view options of objNewWindow) to arranged by label
			end tell
		end if
	else if strCurrentView is "group view" then
		tell application "Finder"
			set current view of objNewWindow to flow view
		end tell
	else if strCurrentView is "flow view" then
		tell application "Finder"
			set current view of objNewWindow to flow view
		end tell
	end if
	###ポジション
	set listPosition to (ocidSetWindowDict's valueForKey:("position")) as list
	tell application "Finder"
		set position of objNewWindow to listPosition
	end tell
	###WINDOWサイズ
	set listBounds to (ocidSetWindowDict's valueForKey:("bounds")) as list
	tell application "Finder"
		set bounds of objNewWindow to listBounds
	end tell
end repeat





