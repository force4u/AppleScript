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

###起動
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
###パネルの名前を取得
tell application id "com.apple.systempreferences"
	set listPaneName to name of every pane as list
end tell
if (count of listPaneName) = 0 then
	###起動待ち
	tell application id "com.apple.systempreferences"
		###起動確認　最大１０秒
		repeat 10 times
			set listPaneName to name of every pane as list
			
			if (count of listPaneName) ≠ 0 then
				exit repeat
			else
				delay 1
			end if
		end repeat
	end tell
end if
-->だいたいの戻り値（参考）
{"外観", "プリンタとスキャナ", "インターネットアカウント", "集中モード", "スクリーンセーバ", "ウォレットとApple Pay", "SiriとSpotlight", "キーボード", "デスクトップとDock", "アクセシビリティ", "壁紙", "プライバシーとセキュリティ", "機能拡張", "プロファイル", "スクリーンタイム", "Bluetooth", "AppleIDの名前", "ユーザとグループ", "ロック画面", "ディスプレイ", "Wi‑Fi", "トラックパッド", "バッテリー", "コントロールセンター", "マウス", "パスワード", "通知", "ネットワーク", "一般", "情報", "ソフトウェアアップデート", "ストレージ", "AirDropとHandoff", "ログイン項目", "言語と地域", "日付と時刻", "共有", "Time Machine", "転送またはリセット", "起動ディスク", "Touch IDとパスコード", "サウンド", "ファミリー", "Game Center", "Network Link Conditioner"}


tell current application
	activate
end tell
try
	set listResponse to (choose from list listPaneName with title "選んでください" with prompt "選んでください" default items (item 1 of listPaneName) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listResponse) is false then
	return "キャンセルしました"
end if



--> {"情報"}
set strPaneName to item 1 of listResponse as text
####ダイアログを前面に
tell current application
	set strName to name as text
end tell
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if

if strPaneName is "一般" then
	set listPaneName to {"情報", "ソフトウェアアップデート", "ストレージ", "AirDropとHandoff", "ログイン項目", "言語と地域", "日付と時刻", "共有", "Time Machine", "転送またはリセット", "起動ディスク"} as list
	try
		set listResponse to (choose from list listPaneName with title "選んでください" with prompt "パネルを選んでください" default items (item 1 of listPaneName) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
	on error
		log "エラーしました"
		return "エラーしました"
	end try
	if (item 1 of listResponse) is false then
		return "キャンセルしました"
	end if
	
	set strPaneName to item 1 of listResponse as text
end if


###選んだパネルのIDを取得
tell application id "com.apple.systempreferences"
	set strPaneId to id of pane strPaneName
end tell
###アンカーの値の取得
tell application id "com.apple.systempreferences"
	set listPaneAnchor to (name of anchors of pane strPaneName) as list
	log listPaneAnchor
	--> (*aboutSection, displaysSection, generalSection, legalSection, softwareSection, storageSection*)
end tell

try
	####ダイアログを前面に
	tell current application
		set strName to name as text
	end tell
	if strName is "osascript" then
		tell application "Finder" to activate
	else
		tell current application to activate
	end if
	set listAnchorName to (choose from list listPaneAnchor with title "選んでください" with prompt "パネルを選んでください" default items (item 1 of listPaneAnchor) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
end try
if (item 1 of listAnchorName) is false then
	return "キャンセルしました"
end if
set strAnchorName to item 1 of listAnchorName as text

###選んだアンカーで開く
tell application id "com.apple.systempreferences"
	launch
	activate
	reveal anchor strAnchorName of pane id strPaneId
end tell

###コピー用のスクリプトテキスト
set strScript to "tell application id \"com.apple.systempreferences\"\r\tlaunch\r\tactivate\r\treveal anchor  \"" & strAnchorName & "\" of pane id  \"" & strPaneId & "\"\rend tell"

####ダイアログを前面に
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
set recordResult to (display dialog "スクリプト戻り値です" with title "スクリプト" default answer strScript buttons {"クリップボードにコピー", "キャンセル", "スクリプトエディタで開く"} default button "スクリプトエディタで開く" giving up after 20 with icon aliasIconPath without hidden answer)

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
	set ocidChrSet to refMe's NSCharacterSet's URLQueryAllowedCharacterSet
	set ocidEncodedText to refMe's NSMutableString's alloc()'s initWithCapacity:0
	set ocidScript to refMe's NSString's stringWithString:(strScript)
	ocidEncodedText's setString:(ocidScript)
	########   置換　％エンコードの追加処理
	###置換レコード
	set recordPercentMap to {|+|:"%2B", |=|:"%3D", |&|:"%26", |$|:"%24"} as record
	###ディクショナリにして
	set ocidPercentMap to refMe's NSDictionary's alloc()'s initWithDictionary:recordPercentMap
	###キーの一覧を取り出します
	set ocidAllKeys to ocidPercentMap's allKeys()
	
	###取り出したキー一覧を順番に処理
	repeat with itemAllKey in ocidAllKeys
		##キーの値を取り出して
		set ocidMapValue to (ocidPercentMap's valueForKey:itemAllKey)
		##置換
		set ocidEncodedText to (ocidEncodedText's stringByReplacingOccurrencesOfString:(itemAllKey) withString:(ocidMapValue))
		##次の変換に備える
		set ocidTextToEncode to ocidEncodedText
	end repeat
	###URLになるのでロケーションとしてOPENする
	set strEncodedText to ocidTextToEncode as text
	set strURL to "applescript://com.apple.scripteditor?action=new&name=" & strPaneId & "&script=" & strEncodedText & ""
	tell application "Finder"
		open location strURL
	end tell
end if

