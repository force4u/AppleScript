#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use framework "UniformTypeIdentifiers"
use scripting additions

property refMe : a reference to current application

#################################
###システム設定起動
#################################
tell application id "com.apple.systempreferences"
	launch
end tell
###起動待ち
tell application id "com.apple.systempreferences"
	###起動確認　最大１０秒
	repeat 10 times
		activate
		set boolFrontMost to frontmost as boolean
		if boolFrontMost is true then
			exit repeat
		else
			delay 1
		end if
	end repeat
end tell
#################################
###パネルの名前を取得
#################################
tell application id "com.apple.systempreferences"
	set listPaneName to name of every pane as list
end tell
###パネル名リストが確実に取得されるのを待つ
if (count of listPaneName) = 0 then
	###起動待ち
	tell application id "com.apple.systempreferences"
		###起動確認　最大１５秒
		repeat 15 times
			set listPaneName to name of every pane as list
			###パネル名リストが確実に取得されるのを待つ
			if (count of listPaneName) ≠ 0 then
				exit repeat
			else
				delay 1
			end if
		end repeat
	end tell
end if
#################################
###【１−１】ダイアログを前面に
#################################
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set listResponse to (choose from list listPaneName with title "【１−１】選んでください" with prompt "選んでください" default items (item 1 of listPaneName) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if
###戻り値
set strPaneName to item 1 of listResponse as text
#################################
###【１−２】ダイアログを前面に（一般限定）
#################################
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###一般だけは別にリストを用意した
if strPaneName is "一般" then
	set listPaneName to {"情報", "ソフトウェアアップデート", "ストレージ", "AirDropとHandoff", "ログイン項目", "言語と地域", "日付と時刻", "共有", "Time Machine", "転送またはリセット", "起動ディスク"} as list
	try
		set listResponse to (choose from list listPaneName with title "【１ー２】選んでください" with prompt "パネルを選んでください" default items (item 1 of listPaneName) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
	on error
		log "エラーしました"
		return "エラーしました"
	end try
	if (item 1 of listResponse) is false then
		return "キャンセルしました"
	end if
	###戻り値　パネル名
	set strPaneName to (item 1 of listResponse) as text
end if

#################################
###パネルのIDの対象アンカーを取得
#################################
###選んだパネルのIDを取得
tell application id "com.apple.systempreferences"
	set strPaneId to id of pane strPaneName
end tell
###アンカーの値の取得
tell application id "com.apple.systempreferences"
	set listPaneAnchor to (name of anchors of pane strPaneName) as list
	log listPaneAnchor
end tell
#################################
###【２】ダイアログを前面に　アンカー選択
#################################
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
try
	set listAnchorName to (choose from list listPaneAnchor with title "【２】選んでください" with prompt "パネルを選んでください" default items (item 1 of listPaneAnchor) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listAnchorName) is false then
	return "キャンセルしました"
end if
###戻り値　アンカー名
set strAnchorName to item 1 of listAnchorName as text

#################################
###選んだアンカーで開く
#################################
tell application id "com.apple.systempreferences"
	launch
	activate
	reveal anchor strAnchorName of pane id strPaneId
end tell
#################################
###ダイアログ用に値を用意
#################################
###コピー用のスクリプトテキスト
set strScript to "#!/usr/bin/env osascript\r----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\r#com.cocolog-nifty.quicktimer.icefloe\r#" & strAnchorName & ":" & strPaneId & "\r----+----1----+----2----+-----3----+----4----+----5----+----6----+----7\ruse AppleScript version \"2.8\"\ruse scripting additions\rtell application id \"com.apple.systempreferences\"\r\tlaunch\r\tactivate\r\treveal anchor \"" & strAnchorName & "\" of pane id \"" & strPaneId & "\"\rend tell\rtell application id \"com.apple.finder\"\r\topen location \"x-apple.systempreferences:" & strPaneId & "?" & strAnchorName & "\"\rend tell\r"
#################################
###【３】ダイアログを前面に
#################################
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###ダイアログ
set strIconPath to "/System/Library/CoreServices/Finder.app/Contents/Resources/Finder.icns"
set aliasIconPath to POSIX file strIconPath as alias
set recordResult to (display dialog "スクリプト戻り値です" with title "スクリプト" default answer strScript buttons {"クリップボードにコピー", "キャンセル", "スクリプトエディタで開く"} default button "スクリプトエディタで開く" cancel button "キャンセル" giving up after 20 with icon aliasIconPath without hidden answer)
###クリップボードにコピー
if button returned of recordResult is "クリップボードにコピー" then
	set strText to text returned of recordResult as text
	####ペーストボード宣言
	set appPasteboard to refMe's NSPasteboard's generalPasteboard()
	set ocidText to (refMe's NSString's stringWithString:(strText))
	appPasteboard's clearContents()
	appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
end if
###OK押したらスクリプト生成
if button returned of recordResult is "スクリプトエディタで開く" then
	##ファイル名
	set strFileName to (strAnchorName & "." & strPaneId & ".applescript") as text
	##保存先はスクリプトメニュー
	set appFileManager to refMe's NSFileManager's defaultManager()
	set ocidURLsArray to (appFileManager's URLsForDirectory:(refMe's NSLibraryDirectory) inDomains:(refMe's NSUserDomainMask))
	set ocidLibraryDIrURL to ocidURLsArray's firstObject()
	set ocidScriptDirPathURL to ocidLibraryDIrURL's URLByAppendingPathComponent:("Scripts/Applications/System Settings/Open")
	###フォルダを作って
	set ocidAttrDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
	ocidAttrDict's setValue:(493) forKey:(refMe's NSFilePosixPermissions)
	set listBoolMakeDir to appFileManager's createDirectoryAtURL:(ocidScriptDirPathURL) withIntermediateDirectories:true attributes:(ocidAttrDict) |error|:(reference)
	set ocidSaveFilePathURL to ocidScriptDirPathURL's URLByAppendingPathComponent:(strFileName)
	###スクリプトをテキストで保存
	set ocidScript to refMe's NSString's stringWithString:(strScript)
	set listDone to ocidScript's writeToURL:(ocidSaveFilePathURL) atomically:(true) encoding:(refMe's NSUTF16LittleEndianStringEncoding) |error|:(reference)
	delay 0.5
	set aliasSaveFilePath to (ocidSaveFilePathURL's absoluteURL()) as alias
	###保存したスクリプトを開く
	tell application "Script Editor"
		open aliasSaveFilePath
	end tell
end if

