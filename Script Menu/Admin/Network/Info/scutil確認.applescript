#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#   com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

#####最初のリスト取得
set strSubKey to doListSelect()
#####最初のコマンド実行
doCommand(strSubKey)

#########################
##リスト　選択
#########################
to doListSelect()
	set strCommandText to ("/bin/echo list | /usr/sbin/scutil") as text
	log strCommandText
	set strResponse to (do shell script strCommandText) as text
	set listChooseList to {} as list
	
	set AppleScript's text item delimiters to "\r"
	set listResponse to every text item of strResponse
	set AppleScript's text item delimiters to ""
	
	repeat with itemResponse in listResponse
		set AppleScript's text item delimiters to "="
		set listTmpSubKey to every text item of itemResponse
		set AppleScript's text item delimiters to ""
		set strSubKey to (item 2 of listTmpSubKey) as text
		set end of listChooseList to strSubKey
	end repeat
	
	try
		###ダイアログを前面に出す
		tell current application
			set strName to name as text
		end tell
		####スクリプトメニューから実行したら
		if strName is "osascript" then
			tell application "Finder"
				activate
			end tell
		else
			tell current application
				activate
			end tell
		end if
		set listResponse to (choose from list listChooseList with title "選んでください" with prompt "設定値を表示します\r選んでください" default items (item 1 of listChooseList) OK button name "OK" cancel button name "キャンセル" without multiple selections allowed and empty selection allowed) as list
	on error
		log "エラーしました"
		return "エラーしました"
	end try
	if (item 1 of listResponse) is false then
		return "キャンセルしました"
	end if
	
	set theResponse to (item 1 of listResponse) as text
end doListSelect

#########################
##コマンド実行
#########################
to doCommand(argSubKey)
	set strCommandText to ("/bin/echo \"show" & argSubKey & "\" | /usr/sbin/scutil") as text
	log strCommandText
	set strResponse to (do shell script strCommandText) as text
	###
	doDialog(strResponse)
end doCommand

#########################
##戻り値表示
#########################
to doDialog(argResponse)
	tell current application
		set strName to name as text
	end tell
	####スクリプトメニューから実行したら
	if strName is "osascript" then
		tell application "Finder"
			activate
		end tell
	else
		tell current application
			activate
		end tell
	end if
	set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/BookmarkIcon.icns" as alias
	try
		set recordResponse to (display dialog "設定内容" with title "設定内容確認" default answer argResponse buttons {"クリップボードにコピー", "終了", "もう一度"} default button "終了" cancel button "終了" with icon aliasIconPath giving up after 20 without hidden answer)
		
	on error
		log "エラーしました"
		return "エラーしました"
	end try
	if true is equal to (gave up of recordResponse) then
		return "時間切れですやりなおしてください"
	end if
	if "終了" is equal to (button returned of recordResponse) then
		set strResponse to (text returned of recordResponse) as text
		return strResponse
	else if button returned of recordResponse is "クリップボードにコピー" then
		set strText to text returned of recordResponse as text
		####ペーストボード宣言
		set appPasteboard to refMe's NSPasteboard's generalPasteboard()
		##結果をペーストボードにテキストで入れる
		set ocidText to (refMe's NSString's stringWithString:(strText))
		appPasteboard's clearContents()
		appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
		return strText
	else if button returned of recordResponse is "もう一度" then
		set strSubKey to doListSelect()
		doCommand(strSubKey)
	else
		log "キャンセルしました"
		return "キャンセルしました"
	end if
	return
end doDialog

