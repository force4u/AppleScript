#!/usr/bin/env osascript
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
#
#com.cocolog-nifty.quicktimer.icefloe
----+----1----+----2----+-----3----+----4----+----5----+----6----+----7
use AppleScript version "2.8"
use framework "Foundation"
use framework "AppKit"
use scripting additions

property refMe : a reference to current application

set listURL to {"https://cdn07.boxcdn.net/Autoupdate.json", "https://cdn07.boxcdn.net/Autoupdate2.json", "https://cdn07.boxcdn.net/Autoupdate3.json", "https://cdn07.boxcdn.net/Autoupdate4.json"} as list

###戻り値格納用のDICT
set ocidPkgDict to refMe's NSMutableDictionary's alloc()'s initWithCapacity:0
repeat with itemURL in listURL
	###URL
	set strURL to itemURL as text
	set ocidURLString to (refMe's NSString's stringWithString:(strURL))
	set ocidJsonURL to (refMe's NSURL's alloc()'s initWithString:(ocidURLString))
	###JSON読み込み
	set ocidOption to refMe's NSDataReadingMappedIfSafe
	set listReadData to (refMe's NSData's dataWithContentsOfURL:(ocidJsonURL) options:(ocidOption) |error|:(reference))
	set ocidJsonData to (item 1 of listReadData)
	###JSON初期化 してレコードに格納
	set listJSONSerialization to (refMe's NSJSONSerialization's JSONObjectWithData:(ocidJsonData) options:0 |error|:(reference))
	set ocidJsonData to item 1 of listJSONSerialization
	##rootのレコード
	set ocidReadDict to (refMe's NSDictionary's alloc()'s initWithDictionary:(ocidJsonData))
	set ocidMacDict to (ocidReadDict's objectForKey:("mac"))
	set ocidEapDict to (ocidMacDict's objectForKey:("eap"))
	set ocidPkgURL to (ocidEapDict's valueForKey:("download-url")) as text
	set ocidVersion to (ocidReadDict's valueForKeyPath:("mac.eap.version"))
	(ocidPkgDict's setValue:(ocidPkgURL) forKey:(ocidVersion))
end repeat
set ocidAllKeys to ocidPkgDict's allKeys()
set ocidAllKeys to (ocidAllKeys's sortedArrayUsingSelector:"localizedStandardCompare:")
set listAllKeys to ocidAllKeys as list
##############################
###ダイアログを前面に出す
tell current application
	set strName to name as text
end tell
###スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if
###
set strTitle to "選んでください" as text
set strPrompt to "ダウンロードするバージョンを選んでください" as text
try
	set listResponse to (choose from list listAllKeys with title strTitle with prompt strPrompt default items (last item of listAllKeys) OK button name "OK" cancel button name "キャンセル" with multiple selections allowed and empty selection allowed) as list
on error
	log "エラーしました"
	return "エラーしました"
	error "エラーしました" number -200
end try
if listResponse = {} then
	log "何も選択していない"
	error "何も選択していない"
else if (item 1 of listResponse) is false then
	return "キャンセルしました"
	error "キャンセルしました" number -200
else
	set strValue to (ocidPkgDict's valueForKey:(item 1 of listResponse)) as text
end if

##############################
###ダイアログを前面に出す
tell current application
	set strName to name as text
end tell
###スクリプトメニューから実行したら
if strName is "osascript" then
	tell application "Finder" to activate
else
	tell current application to activate
end if

set aliasIconPath to POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"
set strMes to ("パッケージURL eap 戻り値です\rURL\r" & strValue) as text
set recordResult to (display dialog strMes with title "URL" default answer strValue buttons {"クリップボードにコピー", "キャンセル", "OK"} default button "OK" giving up after 20 with icon aliasIconPath without hidden answer)
if button returned of recordResult is "クリップボードにコピー" then
	try
		set strText to text returned of recordResult as text
		####ペーストボード宣言
		set appPasteboard to refMe's NSPasteboard's generalPasteboard()
		set ocidText to (refMe's NSString's stringWithString:(strText))
		appPasteboard's clearContents()
		appPasteboard's setString:(ocidText) forType:(refMe's NSPasteboardTypeString)
	on error
		tell application "Finder"
			set the clipboard to strTitle as text
		end tell
	end try
end if
###OKだったらサファリでダウンロード
if button returned of recordResult is "OK" then
	tell application "Safari"
		open location strValue
	end tell
end if
